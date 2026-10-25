import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class KontakKelasScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const KontakKelasScreen({super.key, required this.spaceId});

  @override
  ConsumerState<KontakKelasScreen> createState() => _KontakKelasScreenState();
}

class _KontakKelasScreenState extends ConsumerState<KontakKelasScreen> {
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
        final lecturer = space.meta?.lecturer ?? '-';
        final room = space.meta?.room ?? '-';
        final link = space.meta?.link ?? '-';

        return Scaffold(
          appBar: AppBar(title: const Text('Kontak dan Tautan Kelas')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(space.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Dosen / Pengajar'),
                subtitle: Text(lecturer),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Ruangan'),
                subtitle: Text(room),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Tautan Kelas'),
                subtitle: Text(link),
                trailing: const Icon(Icons.launch),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                title: const Text('Buka WhatsApp Dosen'),
                trailing: const Icon(Icons.chat),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Salin Nomor Ruangan'),
                trailing: const Icon(Icons.copy),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
