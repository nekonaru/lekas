import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/components/empty_state.dart';
import '../../core/open_link.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Quick links: a short list of sites the user opens every single day,
/// for example the campus portal, the e-learning page, the library.
/// Links are stored locally, can be reordered by drag, and open through
/// the platform channel so they land in a browser or an app.
class TautanCepatScreen extends ConsumerStatefulWidget {
  const TautanCepatScreen({super.key});

  @override
  ConsumerState<TautanCepatScreen> createState() => _TautanCepatScreenState();
}

class _TautanCepatScreenState extends ConsumerState<TautanCepatScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context)!;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addQuickLink),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.linkTitleLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'https://',
                border: const OutlineInputBorder(),
                prefixText: 'https://',
              ),
            ),
          ],
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
    final title = _titleController.text.trim();
    var url = _urlController.text.trim();
    _titleController.clear();
    _urlController.clear();
    if (saved != true || title.isEmpty || url.isEmpty) return;
    if (url.startsWith('http://')) url = url.replaceFirst('http://', 'https://');
    if (!url.startsWith('https://')) url = 'https://$url';
    final now = DateTime.now().millisecondsSinceEpoch;
    await ref.read(quickLinkRepositoryProvider).insertQuickLink(
          QuickLink(
            id: const Uuid().v4(),
            title: title,
            url: url,
            sortOrder: DateTime.now().millisecondsSinceEpoch,
            updatedAt: now,
          ),
        );
    if (mounted) setState(() {});
  }

  Future<void> _delete(QuickLink link) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteQuickLink),
        content: Text(link.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(quickLinkRepositoryProvider).deleteQuickLink(link.id);
    if (mounted) setState(() {});
  }

  static String _hostOf(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(quickLinkRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.globalQuickLinksTitle)),
      body: StreamBuilder<List<QuickLink>>(
        stream: repo.watchQuickLinks(),
        builder: (context, snapshot) {
          // Card order follows sortOrder once the user drags; before any
          // drag, fall back to insertion order of the id.
          final links = [...(snapshot.data ?? <QuickLink>[])]
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          if (links.isEmpty) {
            return EmptyState(
              message: l10n.emptyQuickLinks,
              icon: Icons.bookmark_border,
            );
          }
          return ListView.builder(
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              return ListTile(
                leading: const Icon(Icons.link),
                title: Text(link.title),
                subtitle: Text(_hostOf(link.url)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.deleteLabel,
                  onPressed: () => _delete(link),
                ),
                onTap: () => openExternalLink(link.url),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        tooltip: l10n.addQuickLink,
        child: const Icon(Icons.add),
      ),
    );
  }
}
