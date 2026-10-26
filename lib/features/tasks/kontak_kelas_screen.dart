import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
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
  /// Contact fields live in space meta so they survive app restarts.
  final Map<String, String> _contact = {};

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<void> _loadContact() async {
    final repo = ref.read(spaceRepositoryProvider);
    for (final key in ['lecturer', 'room', 'link']) {
      final value = await repo.getMeta(widget.spaceId, key);
      if (value != null) _contact[key] = value;
    }
    if (mounted) setState(() {});
  }

  String _valueOf(String key) => _contact[key] ?? '';

  Future<void> _editField(String key, String title) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _valueOf(key));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
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
    final value = controller.text.trim();
    controller.dispose();
    if (confirmed != true || !mounted) return;
    await ref.read(spaceRepositoryProvider).setMeta(widget.spaceId, key, value);
    if (!mounted) return;
    setState(() => _contact[key] = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.saved)),
    );
  }

  Future<void> _openClassLink() async {
    final l10n = AppLocalizations.of(context)!;
    final link = _valueOf('link').trim();
    if (link.isEmpty) {
      await _editField('link', l10n.classLinkLabel);
      return;
    }
    // No url_launcher dependency, so the link goes to the system share sheet.
    final url = link.startsWith('http') ? link : 'https://$link';
    await Share.share(url, subject: l10n.classLinkLabel);
  }

  Future<void> _openLecturerWhatsApp() async {
    final l10n = AppLocalizations.of(context)!;
    final lecturer = _valueOf('lecturer').trim();
    if (lecturer.isEmpty) {
      await _editField('lecturer', l10n.lecturerLabel);
      return;
    }
    // No url_launcher dependency: a wa.me link is shared so it can be opened.
    final digits = lecturer.replaceAll(RegExp('[^0-9]'), '');
    await Share.share(digits.isEmpty ? lecturer : 'https://wa.me/$digits');
  }

  Future<void> _copyRoom() async {
    final l10n = AppLocalizations.of(context)!;
    final room = _valueOf('room').trim();
    if (room.isEmpty) {
      await _editField('room', l10n.roomLabel);
      return;
    }
    await Clipboard.setData(ClipboardData(text: room));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.copiedToClipboard)),
    );
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
        final space = snapshot.data!;
        final lecturer = _valueOf('lecturer');
        final room = _valueOf('room');
        final link = _valueOf('link');

        return Scaffold(
          appBar: AppBar(title: Text(l10n.classContactsLinksTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(space.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              ListTile(
                title: Text(l10n.lecturerLabel),
                subtitle: Text(lecturer.isEmpty ? '-' : lecturer),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editField('lecturer', l10n.lecturerLabel),
              ),
              ListTile(
                title: Text(l10n.roomLabel),
                subtitle: Text(room.isEmpty ? '-' : room),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editField('room', l10n.roomLabel),
              ),
              ListTile(
                title: Text(l10n.classLinkLabel),
                subtitle: Text(link.isEmpty ? '-' : link),
                trailing: const Icon(Icons.launch),
                onTap: _openClassLink,
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.openLecturerWhatsApp),
                trailing: const Icon(Icons.chat),
                onTap: _openLecturerWhatsApp,
              ),
              ListTile(
                title: Text(l10n.copyRoomNumber),
                trailing: const Icon(Icons.copy),
                onTap: _copyRoom,
              ),
            ],
          ),
        );
      },
    );
  }
}
