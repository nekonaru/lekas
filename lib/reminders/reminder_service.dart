import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';
import '../data/models.dart';

class ReminderService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final ProviderRef _ref;

  ReminderService(this._ref);

  Future<void> init() async {
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap - navigate to task
      },
    );

    // Create notification channels
    await _createChannels();
  }

  Future<void> _createChannels() async {
    const androidChannel = AndroidNotificationChannel(
      'deadline_channel',
      'Deadline',
      description: 'Pengingat deadline tugas',
      importance: Importance.high,
    );
    const overdueChannel = AndroidNotificationChannel(
      'overdue_channel',
      'Tugas Terlambat',
      description: 'Pengingat tugas terlambat',
      importance: Importance.high,
    );
    const summaryChannel = AndroidNotificationChannel(
      'summary_channel',
      'Ringkasan',
      description: 'Ringkasan pagi dan malam',
      importance: Importance.defaultImportance,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(overdueChannel);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(summaryChannel);
  }

  /// Jadwalkan pengingat untuk tugas: H-3, H-1, 3 jam, 30 menit sebelum deadline.
  Future<void> scheduleTaskReminders({
    required String taskId,
    required DateTime deadline,
    required int notifIdBase,
  }) async {
    await cancelTaskReminders(taskId);

    final intervals = [
      const Duration(days: 3),
      const Duration(hours: 1),
      const Duration(hours: 3),
      const Duration(minutes: 30),
    ];

    final kinds = ['d3', 'd1', 'h3', 'm30'];

    for (int i = 0; i < intervals.length; i++) {
      final fireAt = deadline.subtract(intervals[i]);
      if (fireAt.isAfter(DateTime.now())) {
        final notifId = notifIdBase + i;
        await schedule(
          id: notifId,
          when: fireAt,
          title: 'Pengingat Tugas',
          body: 'Tugas mendekati deadline',
          payload: taskId,
          channelId: 'deadline_channel',
        );
      }
    }
  }

  Future<void> cancelTaskReminders(String taskId) async {
    // Cancel notifications based on taskId - need to track notifIds
    // For now, this is a stub that would need notification ID tracking
  }

  /// Jadwalkan ulang semua pengingat aktif setelah boot atau perubahan bahasa.
  Future<void> rescheduleAll() async {
    // Load from reminders table and re-schedule
  }

  Future<void> schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    String? payload,
    String channelId = 'deadline_channel',
  }) async {
    final tzDateTime = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          channelDescription: 'Pengingat tugas',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: false,
      payload: payload,
    );
  }

  Future<void> cancel(int id) async => _plugin.cancel(id);

  Future<void> cancelAll() async => _plugin.cancelAll();

  Future<void> testNotification() async {
    await _plugin.show(
      999,
      'Test Pengingat',
      'Ini adalah notifikasi tes dari Lekas',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test',
          channelDescription: 'Notifikasi tes',
        ),
      ),
    );
  }

  /// Jadwalkan pengingat overdue harian
  Future<void> scheduleOverdueReminder({
    required List<String> taskTitles,
    required DateTime fireAt,
    required int notifId,
  }) async {
    final title = taskTitles.length == 1
        ? 'Tugas terlambat: ${taskTitles.first}'
        : '${taskTitles.length} tugas terlambat';
    final body = taskTitles.join(', ');

    await schedule(
      id: notifId,
      when: fireAt,
      title: title,
      body: body,
      channelId: 'overdue_channel',
    );
  }
}

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(ref);
});
