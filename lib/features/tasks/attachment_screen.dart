import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../core/constants.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class AttachmentScreen extends ConsumerStatefulWidget {
  final String taskId;
  const AttachmentScreen({super.key, required this.taskId});

  @override
  ConsumerState<AttachmentScreen> createState() => _AttachmentScreenState();
}

class _AttachmentScreenState extends ConsumerState<AttachmentScreen> {
  /// Sends the attachment to another app (design section 7.6).
  Future<void> _share(Attachment attachment) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      if (attachment.kind == 'link') {
        await Share.share(attachment.pathOrUrl);
        return;
      }
      final file = File(attachment.pathOrUrl);
      if (!await file.exists()) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.attachmentFileMissing)),
        );
        return;
      }
      await Share.shareXFiles([XFile(file.path)]);
    } catch (_) {
      // A share sheet can fail when no app accepts the payload.
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.attachmentFileMissing)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(attachmentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.attachmentsTitle)),
      body: FutureBuilder<List<Attachment>>(
        future: repo.getAttachments(widget.taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final attachments = snapshot.data ?? [];

          return ListView.builder(
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              final attachment = attachments[index];
              return ListTile(
                title: Text(attachment.pathOrUrl.split('/').last),
                subtitle: Text(attachment.kind),
                trailing: const Icon(Icons.share),
                onTap: () => _share(attachment),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final result = await FilePicker.platform.pickFiles(
            type: FileType.any,
          );
          if (result != null && result.files.single.path != null) {
            final file = File(result.files.single.path!);
            final size = await file.length();
            // Keeps a huge file from being copied into the app directory
            // without the user ever seeing why the app grew.
            if (size > maxAttachmentBytes) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.attachmentTooBig(maxAttachmentBytes ~/ (1024 * 1024)),
                  ),
                ),
              );
              return;
            }
            await repo.insertAttachment(Attachment(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              taskId: widget.taskId,
              kind: 'file',
              pathOrUrl: file.path,
              mime: result.files.single.extension,
              sizeBytes: size,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ));
            if (mounted) setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
