import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const AttendanceScreen({super.key, required this.spaceId});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  /// Today's record is stored in space meta under `attendance:<yyyy-MM-dd>`.
  String? _todayStatus;

  String get _todayKey =>
      'attendance:${DateTime.now().toIso8601String().split('T').first}';

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    final value =
        await ref.read(spaceRepositoryProvider).getMeta(widget.spaceId, _todayKey);
    if (!mounted) return;
    setState(() => _todayStatus = value);
  }

  Future<void> _mark(String status, String label) async {
    final l10n = AppLocalizations.of(context)!;
    await ref.read(spaceRepositoryProvider).setMeta(widget.spaceId, _todayKey, status);
    if (!mounted) return;
    setState(() => _todayStatus = status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.attendanceSavedToday(label))),
    );
  }

  Widget _markButton({
    required String status,
    required String statusLabel,
    Color? background,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final selected = _todayStatus == status;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selected)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.check_circle, color: Colors.green),
          ),
        ElevatedButton(
          onPressed: () => _mark(status, statusLabel),
          style:
              background == null ? null : ElevatedButton.styleFrom(backgroundColor: background),
          child: Text(l10n.markLabel),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(spaceRepositoryProvider);

    return FutureBuilder<Space>(
      future: repo.getSpace(widget.spaceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final space = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.attendanceTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(space.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Text(l10n.presentLabel),
                  trailing: const Text('9 / 11', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: Text(l10n.remainingAbsenceQuota),
                  trailing:
                      const Text('2', style: TextStyle(fontSize: 20, color: Colors.orange)),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.presentLabel),
                trailing: _markButton(
                  status: 'present',
                  statusLabel: l10n.presentLabel,
                ),
              ),
              ListTile(
                title: Text(l10n.absentLabel),
                trailing: _markButton(
                  status: 'absent',
                  statusLabel: l10n.absentLabel,
                  background: Colors.red,
                ),
              ),
              ListTile(
                title: Text(l10n.excusedLabel),
                trailing: _markButton(
                  status: 'excused',
                  statusLabel: l10n.excusedLabel,
                ),
              ),
              ListTile(
                title: Text(l10n.sickLabel),
                trailing: _markButton(
                  status: 'sick',
                  statusLabel: l10n.sickLabel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
