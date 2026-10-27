import 'package:uuid/uuid.dart';

import 'attachment_repository.dart';
import 'database.dart';
import 'subtask_repository.dart';
import 'tag_repository.dart';

/// Writes the parts of a parsed message that live beside the task row
/// (design section 7.15): the `#tag`, the proposed subtasks and the links
/// that became attachments. Everything here is optional, so a plain
/// sentence saves nothing extra.
Future<void> saveParsedExtras({
  required String taskId,
  required TagRepository tags,
  required SubtaskRepository subtasks,
  required AttachmentRepository attachments,
  String? tag,
  List<String> subtaskTitles = const [],
  List<String> links = const [],
  int? nowMs,
}) async {
  final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;

  final trimmedTag = tag?.trim();
  if (trimmedTag != null && trimmedTag.isNotEmpty) {
    await tags.setTaskTags(taskId, [trimmedTag]);
  }

  var order = 0;
  for (final title in subtaskTitles) {
    final clean = title.trim();
    if (clean.isEmpty) continue;
    await subtasks.insertSubtask(Subtask(
      id: const Uuid().v4(),
      taskId: taskId,
      title: clean,
      done: false,
      sortOrder: order,
      updatedAt: now,
    ));
    order++;
  }

  for (final url in links) {
    final clean = url.trim();
    if (clean.isEmpty) continue;
    await attachments.insertAttachment(Attachment(
      id: const Uuid().v4(),
      taskId: taskId,
      kind: 'link',
      pathOrUrl: clean,
      createdAt: now,
    ));
  }
}
