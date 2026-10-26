import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class WadahNonMatkulScreen extends ConsumerStatefulWidget {
  const WadahNonMatkulScreen({super.key});

  @override
  ConsumerState<WadahNonMatkulScreen> createState() => _WadahNonMatkulScreenState();
}

class _WadahNonMatkulScreenState extends ConsumerState<WadahNonMatkulScreen> {
  Future<void> _createSpace(String kind, String defaultName) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: defaultName);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addSpace),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.spaceName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    final name = controller.text.trim();
    controller.dispose();
    if (confirmed != true || name.isEmpty || !mounted) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await ref.read(spaceRepositoryProvider).insertSpace(Space(
          id: const Uuid().v4(),
          name: name,
          color: AppTheme.containerColors[0].toARGB32(),
          kind: kind,
          archived: false,
          createdAt: now,
          updatedAt: now,
        ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.spaceCreated(name))),
    );
  }

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
            onTap: () => _createSpace('org', l10n.orgSpace),
          ),
          ListTile(
            title: Text(l10n.projectSpace),
            subtitle: Text(l10n.projectSpaceSubtitle),
            trailing: const Icon(Icons.work),
            onTap: () => _createSpace('project', l10n.projectSpace),
          ),
          ListTile(
            title: Text(l10n.personalSpace),
            subtitle: Text(l10n.personalSpaceSubtitle),
            trailing: const Icon(Icons.person),
            onTap: () => _createSpace('personal', l10n.personalSpace),
          ),
          ListTile(
            title: Text(l10n.otherSpace),
            subtitle: Text(l10n.otherSpaceSubtitle),
            trailing: const Icon(Icons.folder),
            onTap: () => _createSpace('other', l10n.otherSpace),
          ),
        ],
      ),
    );
  }
}
