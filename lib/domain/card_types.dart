/// Card type helpers for the flashcard variants. Pure and offline.
library;

const List<String> kCardKinds = ['qa', 'cloze', 'choice'];

/// Choice cards keep their options as a semicolon-separated string.
List<String> parseChoices(String? raw) => (raw ?? '')
    .split(';')
    .map((option) => option.trim())
    .where((option) => option.isNotEmpty)
    .toList();

/// Choices are compared case-insensitively; the correct answer is `back`.
bool choiceMatches(String? options, String back, String chosen) =>
    chosen.trim().toLowerCase() == back.trim().toLowerCase() &&
    parseChoices(options).any(
      (option) => option.toLowerCase() == chosen.trim().toLowerCase(),
    );

/// A cloze card marks its blank with `____` in the front text.
bool hasClozeBlank(String front) => front.contains('____');
