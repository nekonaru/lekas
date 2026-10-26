import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class CatatanPertemuanScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const CatatanPertemuanScreen({super.key, required this.spaceId});

  @override
  ConsumerState<CatatanPertemuanScreen> createState() => _CatatanPertemuanScreenState();
}

class _CatatanPertemuanScreenState extends ConsumerState<CatatanPertemuanScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _openNote(ClassNote note) async {
    final l10n = AppLocalizations.of(context)!;
    final deleted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(note.title ?? l10n.untitledNote),
        content: Text(note.body ?? l10n.noNotesLabel),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
    if (deleted != true || !mounted) return;
    await ref.read(classNoteRepositoryProvider).deleteClassNote(note.id);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.deleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(classNoteRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.meetingNotesTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: l10n.noteTitleLabel),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bodyController,
                  decoration: InputDecoration(labelText: l10n.noteBodyLabel),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isEmpty) return;
                    await repo.insertClassNote(ClassNote(
                      id: const Uuid().v4(),
                      spaceId: widget.spaceId,
                      title: _titleController.text,
                      body: _bodyController.text.isEmpty ? null : _bodyController.text,
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    ));
                    _titleController.clear();
                    _bodyController.clear();
                    if (mounted) setState(() {});
                  },
                  child: Text(l10n.save),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ClassNote>>(
              future: repo.getClassNotes(widget.spaceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notes = snapshot.data ?? [];
                if (notes.isEmpty) {
                  return Center(child: Text(l10n.noMeetingNotesYet));
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      title: Text(note.title ?? l10n.untitledNote),
                      subtitle: Text(note.body ?? ''),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openNote(note),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
