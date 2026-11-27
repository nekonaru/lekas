/// Card type helpers for the flashcard variants. Pure and offline.
library;

const List<String> kCardKinds = ['qa', 'cloze', 'choice', 'order', 'pair'];

/// Order cards keep their items separated by newlines in the front field.
List<String> parseOrderSteps(String? raw) => (raw ?? '')
    .split(RegExp(r'[\n;]'))
    .map((step) => step.trim())
    .where((step) => step.isNotEmpty)
    .toList();

/// Pair cards keep `A|B` lines: left is the prompt, right the answer.
List<({String prompt, String answer})> parsePairs(String? raw) => (raw ?? '')
    .split(RegExp(r'[\n;]'))
    .map((line) => line.split('|'))
    .where((parts) => parts.length >= 2)
    .map((parts) => (
          prompt: parts[0].trim(),
          answer: parts.sublist(1).join('|').trim(),
        ))
    .where((pair) => pair.prompt.isNotEmpty && pair.answer.isNotEmpty)
    .toList();

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
