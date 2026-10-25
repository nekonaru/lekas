/// Pencocokan wadah (space) lewat nama, kode, dan alias.
class Matcher {
  final List<Map<String, String>> spaces;

  Matcher(this.spaces);

  /// Cari wadah yang cocok dengan teks. Mengembalikan spaceId atau null.
  String? match(String text) {
    if (spaces.isEmpty) return null;

    final lowerText = text.toLowerCase();

    // Exact match on name or code
    for (final space in spaces) {
      final name = space['name']?.toLowerCase() ?? '';
      final code = space['code']?.toLowerCase() ?? '';
      if (name.isNotEmpty && lowerText.contains(name)) {
        return space['id'];
      }
      if (code.isNotEmpty && lowerText.contains(code)) {
        return space['id'];
      }
    }

    // Match on aliases
    for (final space in spaces) {
      final aliases = space['aliases'] ?? '';
      for (final alias in aliases.split(',')) {
        final cleanAlias = alias.trim().toLowerCase();
        if (cleanAlias.isNotEmpty && lowerText.contains(cleanAlias)) {
          return space['id'];
        }
      }
    }

    return null;
  }

  /// Cari semua wadah yang cocok dengan teks (untuk saran multiple).
  List<Map<String, String>> matchAll(String text) {
    final lowerText = text.toLowerCase();
    final matched = <Map<String, String>>[];

    for (final space in spaces) {
      final name = space['name']?.toLowerCase() ?? '';
      final code = space['code']?.toLowerCase() ?? '';
      var score = 0;

      if (name.isNotEmpty && lowerText.contains(name)) score += 10;
      if (code.isNotEmpty && lowerText.contains(code)) score += 8;

      final aliases = space['aliases'] ?? '';
      for (final alias in aliases.split(',')) {
        final cleanAlias = alias.trim().toLowerCase();
        if (cleanAlias.isNotEmpty && lowerText.contains(cleanAlias)) score += 5;
      }

      if (score > 0) {
        matched.add({...space, 'score': score.toString()});
      }
    }

    matched.sort((a, b) => int.parse(b['score'] ?? '0').compareTo(int.parse(a['score'] ?? '0')));
    return matched;
  }
}
