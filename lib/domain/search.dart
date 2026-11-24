/// Token based text matching shared by the global search. Every token of
/// the query must appear somewhere in the haystack, in any order, so
/// "basis data besok" finds a task titled "Kumpul basis data besok".
library;

/// Returns true when every whitespace-separated token of [query] occurs
/// in [text], case-insensitively. An empty query never matches.
bool matchesQuery(String text, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return false;
  final haystack = text.toLowerCase();
  return needle.split(RegExp(r'\s+')).every(haystack.contains);
}
