import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        final lecturer = '-';
        final room = '-';
        final link = '-';

        return Scaffold(
          appBar: AppBar(title: Text(l10n.classContactsLinksTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(space.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              ListTile(
                title: Text(l10n.lecturerLabel),
                subtitle: Text(lecturer),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: Text(l10n.roomLabel),
                subtitle: Text(room),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: Text(l10n.classLinkLabel),
                subtitle: Text(link),
                trailing: const Icon(Icons.launch),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.openLecturerWhatsApp),
                trailing: const Icon(Icons.chat),
                onTap: () {},
              ),
              ListTile(
                title: Text(l10n.copyRoomNumber),
                trailing: const Icon(Icons.copy),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
