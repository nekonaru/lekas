import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'class_schedule_screen.dart';

class SpaceDetailScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const SpaceDetailScreen({super.key, required this.spaceId});

  @override
  ConsumerState<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends ConsumerState<SpaceDetailScreen> {
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
                        Text('Kode: ${space.code}'),
                      if (space.level != null)
                        Text('Jenjang: ${space.level}'),
                      if (space.period != null)
                        Text('Semester: ${space.period}'),
                      if (space.sks != null)
                        Text('SKS: ${space.sks}'),
                      if (space.targetGrade != null)
                        Text('Target Nilai: ${space.targetGrade}'),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: const Text('Jadwal Kelas'),
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
                title: const Text('Tugas'),
                leading: const Icon(Icons.task),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Kehadiran'),
                leading: const Icon(Icons.check_circle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Bobot Komponen'),
                leading: const Icon(Icons.percent),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Catatan Pertemuan'),
                leading: const Icon(Icons.note),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Kontak dan Tautan Kelas'),
                leading: const Icon(Icons.contact_phone),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Daftar Bawaan'),
                leading: const Icon(Icons.inventory),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
