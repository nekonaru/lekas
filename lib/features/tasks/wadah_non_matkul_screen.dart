import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class WadahNonMatkulScreen extends ConsumerStatefulWidget {
  const WadahNonMatkulScreen({super.key});

  @override
  ConsumerState<WadahNonMatkulScreen> createState() => _WadahNonMatkulScreenState();
}

class _WadahNonMatkulScreenState extends ConsumerState<WadahNonMatkulScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nonCourseSpaceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.orgSpace),
            subtitle: Text(l10n.orgSpaceSubtitle),
            trailing: const Icon(Icons.group),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.projectSpace),
            subtitle: Text(l10n.projectSpaceSubtitle),
            trailing: const Icon(Icons.work),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.personalSpace),
            subtitle: Text(l10n.personalSpaceSubtitle),
            trailing: const Icon(Icons.person),
            onTap: () {},
          ),
          ListTile(
            title: Text(l10n.otherSpace),
            subtitle: Text(l10n.otherSpaceSubtitle),
            trailing: const Icon(Icons.folder),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
