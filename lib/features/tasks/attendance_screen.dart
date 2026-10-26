import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
          appBar: AppBar(title: const Text('Kehadiran')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(space.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Hadir'),
                  trailing: Text('9 / 11', style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: const Text('Sisa Jatah Absen'),
                  trailing: Text('2', style: const TextStyle(fontSize: 20, color: Colors.orange)),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Hadir'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Tandai'),
                ),
              ),
              ListTile(
                title: const Text('Absen'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Tandai'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
              ListTile(
                title: const Text('Izin'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Tandai'),
                ),
              ),
              ListTile(
                title: const Text('Sakit'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Tandai'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
