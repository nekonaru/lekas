/// Plans a batch update over a set of selected task ids. Pure, so the
/// rules can be tested without a database or widget tree.
library;

class BatchEdit {
  const BatchEdit({
    required this.spaceId,
    required this.priority,
    required this.done,
    required this.tagNames,
  });

  /// Null means keep each task's current value.
  final String? spaceId;
  final int? priority;
  final bool? done;
  final List<String> tagNames;

  bool get hasChange =>
      spaceId != null || priority != null || done != null || tagNames.isNotEmpty;
}

/// Normalizes tag names the way TagRepository.ensureTag does, so a batch
/// cannot create near-duplicate tags from different capitalization.
List<String> normalizeTagNames(Iterable<String> raw) {
  final result = <String>{};
  for (final name in raw) {
    final cleaned = name.trim().replaceFirst(RegExp(r'^#+'), '');
    final normalized = cleaned.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    if (normalized.isNotEmpty) result.add(normalized);
  }
  final list = result.toList()..sort();
  return list;
}
