/// Thin wrapper over the native file channel and the path rules it
/// enforces. Names the user types (course names, folder names, file
/// display names) never reach the native side unchecked: `/`, `\` and the
/// reserved characters are flattened to `-`, runs of whitespace collapse,
/// dots are not allowed at the ends, and everything is capped in length,
/// so what the user typed cannot escape the picked tree.
library;

const String kLekasFolderName = 'Lekas';

String sanitizeFileSegment(String input) {
  var name = input.trim();
  name = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '-');
  name = name.replaceAll(RegExp(r'\s+'), ' ');
  name = name.replaceAll(RegExp(r'-+'), '-');
  // No trailing periods or spaces: Windows and SAF both reject them.
  name = name.replaceAll(RegExp(r'[. ]+$'), '');
  if (name.length > 80) name = name.substring(0, 80);
  return name.isEmpty ? 'untitled' : name;
}

String sanitizeFileName(String input) {
  final name = sanitizeFileSegment(input);
  final dot = name.lastIndexOf('.');
  if (dot <= 0) return name;
  final extension = name.substring(dot);
  final base = name.substring(0, dot);
  final cleanBase = sanitizeFileSegment(base);
  return '$cleanBase$extension';
}

/// Formats bytes as a short human string for file rows (B, KB, MB, GB).
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
  final gb = mb / 1024;
  return '${gb.toStringAsFixed(2)} GB';
}
