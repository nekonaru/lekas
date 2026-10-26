import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show MethodChannel, MissingPluginException, PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_service.dart';

const String _platformChannel = 'lekas/platform';

/// The reminder check screen (design section 4.6): permission state, a one
/// minute test notification, and the battery optimization guide.
class DiagnosticScreen extends ConsumerStatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  ConsumerState<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends ConsumerState<DiagnosticScreen> {
  bool? _notificationsEnabled;
  bool? _exactAlarmAllowed;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final service = ref.read(reminderServiceProvider);
    final enabled = await service.notificationsEnabled();
    final exact = await service.canScheduleExact();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _exactAlarmAllowed = exact;
    });
  }

  Future<void> _openPlatform(String method) async {
    try {
      await const MethodChannel(_platformChannel).invokeMethod<void>(method);
    } on PlatformException {
      // Vendor removed the screen; the guide text stays available.
    } on MissingPluginException {
      // Not running on Android.
    }
  }

  Future<void> _runTest() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(reminderServiceProvider);
    final now = DateTime.now();
    try {
      await service.scheduleTestNotification();
      await ref.read(diagnosticRepositoryProvider).insertDiagnostic(Diagnostic(
            id: 'test-${now.millisecondsSinceEpoch}',
            kind: 'test',
            createdAt: now.millisecondsSinceEpoch,
            result: 'scheduled',
            note: 'fires at ${now.add(const Duration(minutes: 1)).toIso8601String()}',
          ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reminderCheckHint)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
      await _refresh();
    }
  }

  String _statusLabel(AppLocalizations l10n, bool? value) {
    if (value == null) return l10n.statusUnknown;
    return value ? l10n.statusGranted : l10n.statusDenied;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(diagnosticRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkReminder)),
      body: FutureBuilder<List<Diagnostic>>(
        future: repo.getDiagnostics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data ?? <Diagnostic>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.reminderCheckHint, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _busy ? null : _runTest,
                icon: const Icon(Icons.timer_outlined),
                label: Text(l10n.testNotification),
              ),
              const SizedBox(height: 24),
              _StatusTile(
                title: l10n.notifPermission,
                status: _statusLabel(l10n, _notificationsEnabled),
                ok: _notificationsEnabled == true,
                onTap: () => _openPlatform('openNotificationSettings'),
                actionLabel: l10n.openSystemSettings,
              ),
              _StatusTile(
                title: l10n.exactAlarmPermission,
                status: _statusLabel(l10n, _exactAlarmAllowed),
                ok: _exactAlarmAllowed == true,
                onTap: null,
                actionLabel: l10n.openSystemSettings,
              ),
              ListTile(
                leading: const Icon(Icons.battery_saver),
                title: Text(l10n.batteryOptimization),
                subtitle: Text(l10n.batteryGuide),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openPlatform('openBatterySettings'),
              ),
              const Divider(height: 32),
              Text(l10n.testHistory,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              if (history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('-'),
                ),
              ...history.map(
                (d) => ListTile(
                  dense: true,
                  title: Text(d.kind),
                  subtitle: Text(d.note ?? d.result ?? '-'),
                  trailing: Text(
                    DateTime.fromMillisecondsSinceEpoch(d.createdAt)
                        .toLocal()
                        .toString()
                        .split('.').first,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.title,
    required this.status,
    required this.ok,
    required this.actionLabel,
    this.onTap,
  });

  final String title;
  final String status;
  final bool ok;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle : Icons.error_outline,
        color: ok ? Colors.green : Colors.orange,
      ),
      title: Text(title),
      subtitle: Text(status),
      trailing: onTap == null ? null : TextButton(onPressed: onTap, child: Text(actionLabel)),
      onTap: onTap,
    );
  }
}
