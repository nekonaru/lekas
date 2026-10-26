import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:async' show unawaited;
import 'package:flutter/widgets.dart' show Locale, WidgetsFlutterBinding;
import 'package:flutter/services.dart'
    show MethodChannel, MissingPluginException, PlatformException;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/models.dart';
import '../data/providers.dart';
import '../data/reminder_repository.dart';
import '../data/settings_repository.dart';
import '../data/task_repository.dart';
import '../l10n/app_localizations.dart';

/// One reminder offset before a deadline (design section 4.6).
class ReminderSpec {
  const ReminderSpec(this.kind, this.offset);

  /// Stable key stored in the reminders table, e.g. `d3`.
  final String kind;

  /// How long before the deadline this reminder fires.
  final Duration offset;
}

/// Standard reminder ladder: H-3, H-1, 3 hours, 30 minutes.
const List<ReminderSpec> kReminderSpecs = [
  ReminderSpec('d3', Duration(days: 3)),
  ReminderSpec('d1', Duration(days: 1)),
  ReminderSpec('h3', Duration(hours: 3)),
  ReminderSpec('m30', Duration(minutes: 30)),
];

/// Extra lead time for heavy tasks (weight at or above [kHeavyTaskWeight]).
const ReminderSpec kHeavyTaskSpec = ReminderSpec('d7', Duration(days: 7));
const double kHeavyTaskWeight = 60;

/// Only this many days ahead are ever scheduled (design section 4.6).
const int kScheduleHorizonDays = 14;

/// Quiet hours window: 22:00 up to 06:00 (design section 4.6).
const int kQuietStartHour = 22;
const int kQuietEndHour = 6;
const int kQuietShiftHour = 21;
const int kQuietShiftMinute = 55;

/// Kind used by the "snooze 1 hour" action button.
const String kKindSnooze = 'snooze';

const String kChannelDeadline = 'deadline_channel';
const String kChannelOverdue = 'overdue_channel';
const String kChannelSummary = 'summary_channel';
const String kChannelTest = 'test_channel';

const String _timezoneChannel = 'lekas/timezone';

/// Notification payload: `task|<taskId>|<action>`.
class ReminderPayload {
  const ReminderPayload(this.taskId, this.action);

  final String taskId;
  final String action;

  static const String actionOpen = 'open';
  static const String actionDone = 'done';
  static const String actionSnooze = 'snooze';

  static ReminderPayload? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('|');
    if (parts.length != 3 || parts.first != 'task') return null;
    if (parts[1].isEmpty) return null;
    return ReminderPayload(parts[1], parts[2]);
  }

  String encode() => 'task|$taskId|$action';
}

/// Result of the two reminder actions in a notification.
class ReminderAction {
  const ReminderAction(this.taskId, this.kind);

  final String taskId;
  final String kind;
}

/// Applies the quiet hours rule: a reminder that would fire between 22:00 and
/// 06:00 moves to 21:55 of the evening it would fire, so nobody is woken up.
/// The shift never moves a reminder past its own deadline, and a reminder that
/// no longer fits is left untouched for the caller to drop.
DateTime moveOutOfQuietHours(DateTime fireAt, DateTime deadline) {
  final inQuiet = fireAt.hour >= kQuietStartHour || fireAt.hour < kQuietEndHour;
  if (!inQuiet) return fireAt;
  final DateTime candidate;
  if (fireAt.hour >= kQuietStartHour) {
    candidate = DateTime(fireAt.year, fireAt.month, fireAt.day, kQuietShiftHour,
        kQuietShiftMinute);
  } else {
    final previousDay = DateTime(
        fireAt.year, fireAt.month, fireAt.day - 1, kQuietShiftHour, kQuietShiftMinute);
    candidate = previousDay;
  }
  if (candidate.isAfter(deadline)) return fireAt;
  return candidate;
}

class _Desired {
  const _Desired(this.fireAt, this.task, this.kind);

  final DateTime fireAt;
  final Task task;
  final String kind;
}

/// Schedules a single notification, choosing exact or inexact alarms based on
/// what the device currently allows. Shared by the app and the background
/// isolate that handles notification action buttons.
Future<void> scheduleNotification({
  required int id,
  required DateTime when,
  required String title,
  required String body,
  required String payload,
  String channelId = kChannelDeadline,
  AppLocalizations? l10n,
}) async {
  final plugin = FlutterLocalNotificationsPlugin();
  final android =
      plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  var exact = true;
  if (android != null) {
    try {
      exact = await android.canScheduleExactNotifications() ?? false;
    } on PlatformException {
      exact = false;
    }
  }
  final details = NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelId,
      channelDescription: 'Lekas task reminders',
      importance: Importance.high,
      priority: Priority.high,
      actions: l10n == null ? null : _notificationActions(l10n),
    ),
  );
  final scheduled = tz.TZDateTime.from(when, tz.local);
  final mode = exact
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle;
  try {
    await plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  } on PlatformException {
    // Exact alarms may be refused on some devices; fall back to inexact.
    await plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
}

List<AndroidNotificationAction> _notificationActions(AppLocalizations l10n) {
  return [
    AndroidNotificationAction(
      ReminderPayload.actionDone,
      l10n.done,
      showsUserInterface: false,
      cancelNotification: true,
    ),
    AndroidNotificationAction(
      ReminderPayload.actionSnooze,
      l10n.snooze1h,
      showsUserInterface: false,
      cancelNotification: true,
    ),
  ];
}

/// Background entry point used by `BootReceiver`. Reconciles every reminder
/// after a reboot or an app update, then tells native code it is done.
@pragma('vm:entry-point')
Future<void> reminderBoot() async {
  WidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('lekas/boot');
  try {
    final container = ProviderContainer();
    try {
      final service = container.read(reminderServiceProvider);
      await service.init();
      await service.syncAll();
    } finally {
      container.dispose();
    }
  } catch (error, stack) {
    debugPrint('reminderBoot failed: $error\n$stack');
  } finally {
    try {
      await channel.invokeMethod('done');
    } on PlatformException {
      // Native side may already be gone; nothing to do.
    }
  }
}

/// Handles notification action buttons while the app runs in the background.
/// Runs in its own isolate, so it opens its own database and never touches
/// Riverpod.
@pragma('vm:entry-point')
Future<void> onNotificationActionBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  final payload = ReminderPayload.tryParse(response.payload);
  if (payload == null) return;
  final action = response.actionId ?? payload.action;
  if (action != ReminderPayload.actionDone && action != ReminderPayload.actionSnooze) {
    return;
  }
  AppDatabase? db;
  try {
    db = await openAppDatabase();
    if (action == ReminderPayload.actionDone) {
      await _markDoneInDb(db, payload.taskId);
    } else {
      await _snoozeInDb(db, payload.taskId);
    }
  } catch (error, stack) {
    debugPrint('notification action failed: $error\n$stack');
  } finally {
    await db?.close();
  }
}

Future<void> _markDoneInDb(AppDatabase db, String taskId) async {
  final repository = TaskRepository(db);
  try {
    final task = await repository.getTask(taskId);
    if (task.status != 'done') {
      await repository.markDone(taskId);
    }
  } catch (_) {
    // Task may be gone already; cancel nothing.
  }
}

Future<void> _snoozeInDb(AppDatabase db, String taskId) async {
  tz_data.initializeTimeZones();
  final repository = TaskRepository(db);
  final reminderRepository = ReminderRepository(db);
  final settings = SettingsRepository(db);
  Task task;
  try {
    task = await repository.getTask(taskId);
  } catch (_) {
    return;
  }
  if (task.deletedAt != null) return;
  final now = DateTime.now();
  final target = now.add(const Duration(hours: 1));
  final fireAt = moveOutOfQuietHours(target, target);
  final seq = await _nextNotifId(settings);
  final payload = ReminderPayload(taskId, ReminderPayload.actionOpen).encode();
  final language = await settings.getLanguage();
  final l10n = await AppLocalizations.delegate.load(Locale(language));
  await reminderRepository.insertReminder(Reminder(
    id: '$kKindSnooze:$taskId:${now.millisecondsSinceEpoch}',
    taskId: taskId,
    fireAt: fireAt.millisecondsSinceEpoch,
    kind: kKindSnooze,
    notifId: seq,
    fired: false,
  ));
  await settings.set('notif_id_seq', '${seq + 1}');
  await scheduleNotification(
    id: seq,
    when: fireAt,
    title: task.title,
    body: l10n.reminderSnoozed,
    payload: payload,
  );
}

Future<int> _nextNotifId(SettingsRepository settings) async {
  final raw = await settings.get('notif_id_seq');
  final parsed = int.tryParse(raw ?? '');
  return (parsed == null || parsed < 1000) ? 1000 : parsed;
}

class ReminderService {
  ReminderService(this._ref);

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final Ref _ref;
  bool _initialized = false;
  AppLocalizations? _l10nCache;
  Future<void>? _syncChain;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Initializes the plugin, notification channels and the local time zone.
  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    await _setLocalTimeZone();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: _onForegroundResponse,
      onDidReceiveBackgroundNotificationResponse: onNotificationActionBackground,
    );
    await _createChannels();
    _initialized = true;
  }

  Future<void> _setLocalTimeZone() async {
    String? zoneName;
    try {
      const channel = MethodChannel(_timezoneChannel);
      zoneName = await channel.invokeMethod<String>('getID');
    } on PlatformException {
      zoneName = null;
    } on MissingPluginException {
      zoneName = null;
    }
    try {
      tz.setLocalLocation(tz.getLocation(zoneName ?? 'Asia/Jakarta'));
    } catch (_) {
      // Keep the default location rather than failing the whole app.
    }
  }

  Future<void> _createChannels() async {
    const channels = <AndroidNotificationChannel>[
      AndroidNotificationChannel(
        kChannelDeadline,
        'Deadline',
        description: 'Task deadline reminders',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        kChannelOverdue,
        'Overdue tasks',
        description: 'Reminders for late tasks',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        kChannelSummary,
        'Summary',
        description: 'Morning and evening summary',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        kChannelTest,
        'Test',
        description: 'One off test reminders',
        importance: Importance.high,
      ),
    ];
    final android = _android;
    if (android == null) return;
    for (final channel in channels) {
      await android.createNotificationChannel(channel);
    }
  }

  Future<AppLocalizations> _l10n() async {
    final cached = _l10nCache;
    if (cached != null) return cached;
    final settings = _ref.read(settingsRepositoryProvider);
    final language = await settings.getLanguage();
    final loaded = await AppLocalizations.delegate.load(Locale(language));
    _l10nCache = loaded;
    return loaded;
  }

  /// Asks for the Android 13+ notification permission.
  /// Returns true when notifications are allowed afterwards.
  Future<bool> requestNotificationPermission() async {
    final android = _android;
    if (android == null) return true;
    try {
      return await android.requestNotificationsPermission() ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Asks for permission to use exact alarms (Android 12+).
  Future<bool> requestExactAlarmPermission() async {
    final android = _android;
    if (android == null) return true;
    try {
      return await android.requestExactAlarmsPermission() ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// True when the system currently shows notifications for this app.
  Future<bool> notificationsEnabled() async {
    final android = _android;
    if (android == null) return true;
    try {
      return await android.areNotificationsEnabled() ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// True when exact alarms may be scheduled; null when unknown.
  Future<bool?> canScheduleExact() async {
    final android = _android;
    if (android == null) return null;
    try {
      return await android.canScheduleExactNotifications();
    } on PlatformException {
      return null;
    }
  }

  /// Reconciles the reminders table with the plugin schedule.
  ///
  /// Runs after every task change, on app start, and from the boot receiver.
  /// Past reminders, reminders of finished or deleted tasks and anything
  /// beyond the 14 day window are cancelled; new or moved reminders are
  /// scheduled again with the same notification id. Runs are serialized so
  /// overlapping task writes cannot interleave.
  Future<void> syncAll() {
    final run = (_syncChain ?? Future<void>.value()).then((_) => _sync());
    _syncChain = run.catchError((Object error, StackTrace stack) {
      debugPrint('reminder sync failed: $error\n$stack');
    });
    return run;
  }

  Future<void> _sync() async {
    if (!_initialized) await init();
    final tasks = await _ref.read(taskRepositoryProvider).getTasks(includeInbox: true);
    final reminderRepository = _ref.read(reminderRepositoryProvider);
    final now = DateTime.now();
    final horizon = now.add(const Duration(days: kScheduleHorizonDays));
    final nowMs = now.millisecondsSinceEpoch;

    final desired = <String, _Desired>{};
    for (final task in tasks) {
      if (task.deletedAt != null || task.status == 'done') continue;
      final deadlineMs = task.deadline;
      if (deadlineMs == null) continue;
      final deadline = DateTime.fromMillisecondsSinceEpoch(deadlineMs);
      DateTime? taken;
      for (final spec in _specsFor(task)) {
        final raw = deadline.subtract(spec.offset);
        if (!raw.isAfter(now) || raw.isAfter(horizon)) continue;
        final fireAt = moveOutOfQuietHours(raw, deadline);
        if (!fireAt.isAfter(now)) continue;
        if (taken != null &&
            taken.difference(fireAt).abs() < const Duration(minutes: 2)) {
          continue;
        }
        taken = fireAt;
        desired['${task.id}:${spec.kind}'] = _Desired(fireAt, task, spec.kind);
      }
    }

    final l10n = await _l10n();
    final existing = await reminderRepository.getReminders();
    final existingByKey = <String, Reminder>{for (final row in existing) row.id: row};
    var nextId = await _nextNotifId(_ref.read(settingsRepositoryProvider));

    for (final row in existing) {
      final isFreshSnooze =
          row.kind == kKindSnooze && row.fireAt > nowMs && !desired.containsKey(row.id);
      if (desired.containsKey(row.id) || isFreshSnooze) continue;
      await _plugin.cancel(row.notifId);
      await reminderRepository.deleteReminder(row.id);
    }

    var allocated = false;
    for (final entry in desired.entries) {
      final fireMs = entry.value.fireAt.millisecondsSinceEpoch;
      final row = existingByKey[entry.key];
      if (row != null) {
        if (row.fireAt == fireMs) continue;
        await _plugin.cancel(row.notifId);
        await reminderRepository.updateReminder(
            row.copyWith(fireAt: fireMs, fired: false));
        await _scheduleRow(entry.value, row.notifId, l10n);
      } else {
        final notifId = nextId++;
        allocated = true;
        final newRow = Reminder(
          id: entry.key,
          taskId: entry.value.task.id,
          fireAt: fireMs,
          kind: entry.value.kind,
          notifId: notifId,
          fired: false,
        );
        await reminderRepository.insertReminder(newRow);
        await _scheduleRow(entry.value, notifId, l10n);
      }
    }

    if (allocated) {
      await _ref.read(settingsRepositoryProvider).set('notif_id_seq', '$nextId');
    }
  }

  List<ReminderSpec> _specsFor(Task task) {
    final specs = <ReminderSpec>[...kReminderSpecs];
    final weight = task.weightPercent;
    if (weight != null && weight >= kHeavyTaskWeight) {
      specs.insert(0, kHeavyTaskSpec);
    }
    return specs;
  }

  Future<void> _scheduleRow(_Desired desired, int notifId, AppLocalizations l10n) {
    final payload = ReminderPayload(desired.task.id, ReminderPayload.actionOpen).encode();
    return scheduleNotification(
      id: notifId,
      when: desired.fireAt,
      title: desired.task.title,
      body: _bodyFor(desired.kind, l10n),
      payload: payload,
      l10n: l10n,
    );
  }

  String _bodyFor(String kind, AppLocalizations l10n) {
    switch (kind) {
      case 'd7':
        return l10n.reminderIn7Days;
      case 'd3':
        return l10n.reminderIn3Days;
      case 'd1':
        return l10n.reminderIn1Day;
      case 'h3':
        return l10n.reminderIn3Hours;
      case 'm30':
        return l10n.reminderIn30Minutes;
      case kKindSnooze:
        return l10n.reminderSnoozed;
      default:
        return l10n.reminderIn3Days;
    }
  }

  void _onForegroundResponse(NotificationResponse response) {
    final payload = ReminderPayload.tryParse(response.payload);
    if (payload == null) return;
    final action = response.actionId ?? payload.action;
    if (action == ReminderPayload.actionDone) {
      _ref.read(taskRepositoryProvider).markDone(payload.taskId).then(
            (_) => syncAll(),
            onError: (Object error) => debugPrint('mark done failed: $error'),
          );
    } else if (action == ReminderPayload.actionSnooze) {
      _snooze(payload.taskId);
    }
  }

  Future<void> _snooze(String taskId) async {
    await snoozeTaskAt(taskId, DateTime.now().add(const Duration(hours: 1)));
  }

  /// Snoozes a task to [fireAt] (design section 5.5): the deadline does not
  /// move, only a single reminder is added for the chosen moment.
  Future<void> snoozeTaskAt(String taskId, DateTime fireAt) async {
    if (!_initialized) await init();
    final repository = _ref.read(taskRepositoryProvider);
    final reminderRepository = _ref.read(reminderRepositoryProvider);
    final settings = _ref.read(settingsRepositoryProvider);
    Task task;
    try {
      task = await repository.getTask(taskId);
    } catch (_) {
      return;
    }
    if (task.deletedAt != null) return;
    final now = DateTime.now();
    final moment = moveOutOfQuietHours(fireAt, fireAt);
    // Drops the snoozes of this task so repeated tunda does not pile up.
    for (final row in await reminderRepository.getReminders()) {
      if (row.kind == kKindSnooze && row.taskId == taskId) {
        await _plugin.cancel(row.notifId);
        await reminderRepository.deleteReminder(row.id);
      }
    }
    final notifId = await _nextNotifId(settings);
    await reminderRepository.insertReminder(Reminder(
      id: '$kKindSnooze:$taskId:${now.millisecondsSinceEpoch}',
      taskId: taskId,
      fireAt: moment.millisecondsSinceEpoch,
      kind: kKindSnooze,
      notifId: notifId,
      fired: false,
    ));
    await settings.set('notif_id_seq', '${notifId + 1}');
    final l10n = await _l10n();
    await scheduleNotification(
      id: notifId,
      when: moment,
      title: task.title,
      body: l10n.reminderSnoozed,
      payload: ReminderPayload(taskId, ReminderPayload.actionOpen).encode(),
      l10n: l10n,
    );
  }

  /// Schedules a one minute test reminder for the reminder check screen.
  Future<void> scheduleTestNotification() async {
    if (!_initialized) await init();
    final l10n = await _l10n();
    final now = DateTime.now();
    await scheduleNotification(
      id: kTestNotificationId,
      when: now.add(const Duration(minutes: 1)),
      title: l10n.testNotificationTitle,
      body: l10n.testNotificationBody,
      payload: '',
      channelId: kChannelTest,
      l10n: l10n,
    );
  }

  Future<void> cancelTestNotification() => _plugin.cancel(kTestNotificationId);

  /// Shows a notification right away, used to verify permission state.
  Future<void> showNow(String title, String body) async {
    if (!_initialized) await init();
    await _plugin.show(
      kTestNotificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          kChannelTest,
          'Test',
          channelDescription: 'One off test reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancelTaskReminders(String taskId) async {
    final reminderRepository = _ref.read(reminderRepositoryProvider);
    final rows = await reminderRepository.getReminders();
    for (final row in rows) {
      if (row.taskId != taskId) continue;
      await _plugin.cancel(row.notifId);
      await reminderRepository.deleteReminder(row.id);
    }
  }

  /// Cancels every scheduled notification this app owns.
  Future<void> cancelAll() => _plugin.cancelAll();
}

/// Notification id reserved for the reminder check screen.
const int kTestNotificationId = 999999;

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(ref);
});

/// Every non deleted task, used to keep reminders in sync.
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasks(includeInbox: true);
});

/// Reconciles the schedule whenever a task is created, edited, completed or
/// deleted, so a changed deadline always replaces the old reminders.
final reminderSyncProvider = Provider<void>((ref) {
  ref.watch(allTasksProvider).whenData((tasks) {
    unawaited(ref.read(reminderServiceProvider).syncAll());
  });
});
