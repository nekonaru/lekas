String normalize(String input, Map<String, String> abbrev) {
  var s = input.toLowerCase().trim();
  s = s.replaceAll(RegExp(r'\s+'), ' ');
  for (final e in abbrev.entries) {
    s = s.replaceAll(RegExp('\\b${RegExp.escape(e.key)}\\b'), e.value);
  }
  return s;
}