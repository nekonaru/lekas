import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../tasks/attendance_screen.dart';
import '../tasks/catatan_pertemuan_screen.dart';
import '../tasks/daftar_bawaan_screen.dart';
import '../tasks/kontak_kelas_screen.dart';
import '../tasks/tasks_screen.dart';
import '../tasks/weight_component_screen.dart';
import 'class_schedule_screen.dart';

class SpaceDetailScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const SpaceDetailScreen({super.key, required this.spaceId});

  @override
  ConsumerState<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends ConsumerState<SpaceDetailScreen> {
  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
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
        final space = snapshot.data;
        if (space == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.spacesTitle)),
            body: Center(child: Text(l10n.recordNotFound)),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(space.name)),
          body: ListView(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        space.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      if (space.code != null)
                        Text(l10n.spaceCodeValue(space.code!)),
                      if (space.level != null)
                        Text(l10n.spaceLevelValue(space.level!)),
                      if (space.period != null)
                        Text(l10n.spacePeriodValue(space.period!)),
                      if (space.sks != null)
                        Text(l10n.spaceSksValue('${space.sks}')),
                      if (space.targetGrade != null)
                        Text(l10n.spaceTargetGradeValue('${space.targetGrade}')),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.classScheduleTitle),
                leading: const Icon(Icons.schedule),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClassScheduleScreen(spaceId: space.id),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.tasksMenuLabel),
                leading: const Icon(Icons.task),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(const TasksScreen()),
              ),
              ListTile(
                title: Text(l10n.attendanceTitle),
                leading: const Icon(Icons.check_circle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(AttendanceScreen(spaceId: space.id)),
              ),
              ListTile(
                title: Text(l10n.componentWeightLabel),
                leading: const Icon(Icons.percent),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(WeightComponentScreen(
                    spaceId: space.id, spaceName: space.name)),
              ),
              ListTile(
                title: Text(l10n.meetingNotesTitle),
                leading: const Icon(Icons.note),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(CatatanPertemuanScreen(spaceId: space.id)),
              ),
              ListTile(
                title: Text(l10n.classContactsLinksTitle),
                leading: const Icon(Icons.contact_phone),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(KontakKelasScreen(spaceId: space.id)),
              ),
              ListTile(
                title: Text(l10n.defaultChecklistShort),
                leading: const Icon(Icons.inventory),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(const DaftarBawaanScreen()),
              ),
            ],
          ),
        );
      },
    );
  }
}
