import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/components/empty_state.dart';
import '../../core/date_util.dart';
import '../../core/file_rules.dart';
import '../../core/files_channel.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// The per course file manager: a real folder tree on the phone, created
/// in the app the user picks once. Modules, notes, problem sets and even
/// an archive of past tasks can live here, one folder per purpose.
class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key, required this.spaceId, required this.spaceName});

  final String spaceId;
  final String spaceName;

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  /// The tree the user picked once (Documents/Lekas). Null until the first
  /// pick; if the permission gets lost the screen falls back to setup.
  String? _treeUri;

  /// Segments below the course root (['Materi', 'Modul 1']).
  List<String> _path = const [];

  /// Bumped to force the list future to rebuild after a write.
  int _refreshTick = 0;

  bool _busy = false;

  Future<List<FolderEntry>>? _entriesFuture;

  @override
  void initState() {
    super.initState();
    _loadRoot();
  }

  Future<void> _loadRoot() async {
    final repo = ref.read(filesRepositoryProvider);
    final tree = await repo.rootUri();
    if (!mounted) return;
    setState(() => _treeUri = tree);
    if (tree != null) {
      final ok = await repo.ensureCourseRoot(tree, widget.spaceName);
      if (!mounted) return;
      if (!ok) {
        setState(() => _treeUri = null);
        _showSnack(permissionLostText());
        return;
      }
      _refresh();
    }
  }

  String permissionLostText() {
    final l10n = AppLocalizations.of(context)!;
    return l10n.permissionLostFolder;
  }

  void _refresh() {
    setState(() {
      _refreshTick++;
      _entriesFuture = null;
    });
  }

  Future<void> _onPickTapped() async {
    final repo = ref.read(filesRepositoryProvider);
    final channel = FilesChannel();
    final tree = await channel.pickTree();
    if (!mounted) return;
    if (tree == null) {
      final error = await channel.lastError();
      if (!mounted) return;
      if (error != null) {
        _showSnack(error);
      }
      return;
    }
    await repo.setRootUri(tree);
    final ok = await repo.ensureCourseRoot(tree, widget.spaceName);
    if (!mounted) return;
    if (!ok) {
      _showSnack(permissionLostText());
      return;
    }
    setState(() {
      _treeUri = tree;
      _path = const [];
    });
    _refresh();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String get _currentDir =>
      _path.isEmpty ? widget.spaceName : _path.join(' / ');

  Future<List<FolderEntry>> _loadEntries() {
    final repo = ref.read(filesRepositoryProvider);
    final tree = _treeUri;
    if (tree == null) return Future.value(const []);
    return repo.listCourseFiles(tree, widget.spaceName, _path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final appBar = AppBar(
      title: Text(widget.spaceName),
      actions: _treeUri == null
          ? null
          : [
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined),
                tooltip: l10n.newFolderLabel,
                onPressed: _busy ? null : _createFolderDialog,
              ),
              IconButton(
                icon: const Icon(Icons.upload_file_outlined),
                tooltip: l10n.importFileLabel,
                onPressed: _busy ? null : _importFile,
              ),
            ],
    );

    if (_treeUri == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.filesLabel)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_open_outlined,
                  size: 88,
                  color: colors.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.filesSetupTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.filesSetupBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _onPickTapped,
                  icon: const Icon(Icons.folder),
                  label: Text(l10n.pickFilesFolder),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.filesOpenInFileManager,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _entriesFuture ??= _loadEntries();

    return Scaffold(
      appBar: appBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          _breadcrumb(context),
          Expanded(
            child: FutureBuilder<List<FolderEntry>>(
              key: ValueKey(_refreshTick),
              future: _entriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final entries = snapshot.data ?? const <FolderEntry>[];
                if (entries.isEmpty) {
                  return EmptyState(
                    message: _path.isEmpty
                        ? l10n.folderEmpty
                        : l10n.folderEmpty,
                    icon: Icons.folder_open_outlined,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: entries.length + 1,
                  itemBuilder: (context, index) {
                    if (index == entries.length) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Text(
                          l10n.filesSurviveDeletion,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                        ),
                      );
                    }
                    final entry = entries[index];
                    return _entryTile(context, entry);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _breadcrumb(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            if (_path.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                tooltip: 'Up',
                onPressed: () => setState(() {
                      _path = List.of(_path)..removeLast();
                      _entriesFuture = null;
                    }),
              ),
            Icon(
              _path.isEmpty
                  ? Icons.folder_open_outlined
                  : Icons.folder_outlined,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _currentDir,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _iconColor(BuildContext context, FileIconKind kind) {
    switch (kind) {
      case FileIconKind.pdf:
        return const Color(0xFFDC2626);
      case FileIconKind.archive:
        return const Color(0xFFF59E0B);
      case FileIconKind.image:
        return const Color(0xFF10B981);
      case FileIconKind.document:
      case FileIconKind.text:
        return const Color(0xFF3B82F6);
      case FileIconKind.spreadsheet:
        return const Color(0xFF059669);
      case FileIconKind.presentation:
        return const Color(0xFFEC4899);
      case FileIconKind.audio:
        return const Color(0xFF8B5CF6);
      case FileIconKind.video:
        return const Color(0xFFF97316);
      case FileIconKind.generic:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _iconFor(FileIconKind kind) {
    switch (kind) {
      case FileIconKind.pdf:
        return Icons.picture_as_pdf_outlined;
      case FileIconKind.archive:
        return Icons.archive_outlined;
      case FileIconKind.image:
        return Icons.image_outlined;
      case FileIconKind.document:
        return Icons.description_outlined;
      case FileIconKind.text:
        return Icons.notes_outlined;
      case FileIconKind.spreadsheet:
        return Icons.table_chart_outlined;
      case FileIconKind.presentation:
        return Icons.slideshow_outlined;
      case FileIconKind.audio:
        return Icons.audio_file_outlined;
      case FileIconKind.video:
        return Icons.video_file_outlined;
      case FileIconKind.generic:
        return Icons.insert_drive_file_outlined;
    }
  }

  Widget _entryTile(BuildContext context, FolderEntry entry) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final colors = Theme.of(context).colorScheme;
    final kind = fileIconKind(entry.name);
    return ListTile(
      leading: entry.isDirectory
          ? const Icon(Icons.folder_rounded, color: Color(0xFFF59E0B))
          : Icon(_iconFor(kind), color: _iconColor(context, kind)),
      title: Text(entry.name),
      subtitle: entry.isDirectory
          ? Text(l10n.folderLabel)
          : Text(
              '${formatFileSize(entry.sizeBytes)} · '
              '${DateUtil.formatDateTime(DateTime.fromMillisecondsSinceEpoch(entry.modifiedMs), locale)}',
            ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        tooltip: l10n.editLabel,
        onSelected: (value) {
          if (value == 'rename') {
            _renameDialog(entry);
          } else {
            _deleteDialog(entry);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'rename',
            child: Text(entry.isDirectory ? l10n.renameFolder : l10n.renameFile),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text(
              entry.isDirectory ? l10n.deleteFolder : l10n.deleteFile,
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
      onTap: () {
        if (entry.isDirectory) {
          setState(() {
            _path = [..._path, entry.name];
            _entriesFuture = null;
          });
        } else {
          _openFile(entry.name);
        }
      },
    );
  }

  Future<void> _openFile(String name) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(filesRepositoryProvider);
    final tree = _treeUri;
    if (tree == null) return;
    final ok = await repo.openEntry(tree, widget.spaceName, _path, name);
    if (!ok) {
      _showSnack(l10n.filesOpenFailed);
    }
  }

  Future<void> _importFile() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(filesRepositoryProvider);
    final tree = _treeUri;
    if (tree == null) return;
    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: false,
      );
      if (result == null) {
        setState(() => _busy = false);
        return;
      }
      var imported = 0;
      for (final file in result.files) {
        final path = file.path;
        if (path == null) continue;
        final ok = await repo.importFile(
          tree,
          widget.spaceName,
          _path,
          sanitizeFileName(file.name),
          path,
        );
        if (ok) imported++;
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _entriesFuture = null;
      });
      if (imported > 0) {
        _showSnack('${l10n.fileImported} ($imported)');
      } else {
        _showSnack(l10n.filesImportFailed);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        _showSnack(l10n.filesImportFailed);
      }
    }
  }

  Future<void> _createFolderDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.newFolderLabel),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.folderNameLabel,
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
    final name = sanitizeFileSegment(controller.text);
    Future<void>.delayed(
      const Duration(milliseconds: 400),
      controller.dispose,
    );
    if (created != true || name.isEmpty) return;
    // Guard the pick against collisions before hitting the channel.
    final repo = ref.read(filesRepositoryProvider);
    final tree = _treeUri;
    if (tree == null) return;
    final available =
        await repo.validNameAvailable(tree, widget.spaceName, _path, name);
    if (!mounted) return;
    if (!available) {
      _showSnack(l10n.folderAlreadyExists);
      return;
    }
    final ok = await repo.createFolder(tree, widget.spaceName, _path, name);
    if (!mounted) return;
    if (!ok) {
      _showSnack(l10n.unableToCreateFolder);
      return;
    }
    _refresh();
  }

  Future<void> _renameDialog(FolderEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: entry.name);
    final renamed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(entry.isDirectory ? l10n.renameFolder : l10n.renameFile),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: entry.isDirectory
              ? TextCapitalization.words
              : TextCapitalization.none,
          decoration: InputDecoration(
            labelText: entry.isDirectory
                ? l10n.folderNameLabel
                : l10n.renameFile,
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
    final name = entry.isDirectory
        ? sanitizeFileSegment(controller.text)
        : sanitizeFileName(controller.text);
    Future<void>.delayed(
      const Duration(milliseconds: 400),
      controller.dispose,
    );
    if (renamed != true || name.isEmpty || name == entry.name) return;
    final repo = ref.read(filesRepositoryProvider);
    final tree = _treeUri;
    if (tree == null) return;
    final ok =
        await repo.renameEntry(tree, widget.spaceName, _path, entry.name, name);
    if (!mounted) return;
    if (!ok) {
      _showSnack(l10n.filesOpFailed);
      return;
    }
    _refresh();
  }

  Future<void> _deleteDialog(FolderEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          entry.isDirectory ? l10n.deleteFolder : l10n.deleteFile,
        ),
        content: Text(
          entry.isDirectory
              ? '${entry.name}\n${l10n.deleteFolderBody}'
              : entry.name,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repo = ref.read(filesRepositoryProvider);
    final tree = _treeUri;
    if (tree == null) return;
    final ok =
        await repo.deleteEntry(tree, widget.spaceName, _path, entry.name);
    if (!mounted) return;
    if (!ok) {
      _showSnack(l10n.filesOpFailed);
      return;
    }
    _refresh();
  }
}
