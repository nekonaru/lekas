import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
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
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(attachmentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lampiran')),
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
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            maxSize: 10 * 1024 * 1024,
          );
          if (result != null && result.files.single.path != null) {
            final file = File(result.files.single.path!);
            await repo.insertAttachment(Attachment(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              taskId: widget.taskId,
              kind: 'file',
              pathOrUrl: file.path,
              mime: result.files.single.extension,
              sizeBytes: await file.length(),
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
