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
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text(l10n.markLabel),
                ),
              ),
              ListTile(
                title: Text(l10n.absentLabel),
                trailing: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(l10n.markLabel),
                ),
              ),
              ListTile(
                title: Text(l10n.excusedLabel),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text(l10n.markLabel),
                ),
              ),
              ListTile(
                title: Text(l10n.sickLabel),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text(l10n.markLabel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
