/// Routes that can open a task without going through the shell.
const kDeepLinkHost = 'task';

/// Extracts a task id from `lekas://task/<id>`. Returns null for anything
/// else, so an unknown or malformed link never navigates.
String? taskIdFromLink(String input) {
  final uri = Uri.tryParse(input);
  if (uri == null) return null;
  if (uri.scheme != 'lekas' || uri.host != kDeepLinkHost) return null;
  final id = uri.pathSegments.isEmpty ? '' : uri.pathSegments.first;
  if (id.isEmpty) return null;
  // Keep ids to the characters the app itself generates (uuid v4).
  return RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(id) ? id : null;
}
