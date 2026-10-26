/// Matches a space (course container) against free text using its name, code
/// and aliases. The longest token wins so a short code never beats a name.
class Matcher {
  final List<Map<String, String>> spaces;

  Matcher(this.spaces);

  /// Finds the best space for [text]. Returns the space id or null.
  String? match(String text) {
    if (spaces.isEmpty) return null;

    final lowerText = text.toLowerCase();
    String? bestId;
    var bestLength = 1;

    for (final space in spaces) {
      for (final token in _tokensOf(space)) {
        if (token.length <= bestLength) continue;
        if (_containsWord(lowerText, token)) {
          bestId = space['id'];
          bestLength = token.length;
        }
      }
    }
    return bestId;
  }

  /// All searchable spellings of a space: name, code and aliases.
  List<String> _tokensOf(Map<String, String> space) {
    final tokens = <String>[
      (space['name'] ?? '').trim().toLowerCase(),
      (space['code'] ?? '').trim().toLowerCase(),
      for (final alias in (space['aliases'] ?? '').split(','))
        alias.trim().toLowerCase(),
    ];
    return tokens.where((t) => t.length >= 2).toList();
  }

  /// Finds every space that matches [text], best score first.
  List<Map<String, String>> matchAll(String text) {
    final lowerText = text.toLowerCase();
    final matched = <Map<String, String>>[];

    for (final space in spaces) {
      var score = 0;
      for (final token in _tokensOf(space)) {
        if (_containsWord(lowerText, token)) score += token.length;
      }
      if (score > 0) {
        matched.add({...space, 'score': score.toString()});
      }
    }

    matched.sort((a, b) =>
        int.parse(b['score'] ?? '0').compareTo(int.parse(a['score'] ?? '0')));
    return matched;
  }

  /// A token counts when it appears as a whole word or as a word inside the
  /// text, which keeps "dbms" from matching inside "pdbmsx".
  static bool _containsWord(String text, String token) {
    if (token.isEmpty) return false;
    return RegExp('\\b${RegExp.escape(token)}\\b').hasMatch(text);
  }
}
