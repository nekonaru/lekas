/// Main parser for Quick Add (design section 6.1).
///
/// Combines the normalizer, the time extractor, the space matcher and the
/// type keywords into one pure Dart call with no Flutter dependency, so it
/// can be tested against a large corpus.
library;

import 'normalizer.dart';
import 'time_extractor.dart';
import 'matcher.dart';
import 'dictionaries/id.dart';

class ParsedTask {
  final String title;
  final String? spaceId;
  final String? type;
  final DateTime? deadline;
  final int priority;
  final bool isGroup;
  final String? notes;
  final bool needsConfirmation;

  ParsedTask({
    required this.title,
    this.spaceId,
    this.type,
    this.deadline,
    this.priority = 1,
    this.isGroup = false,
    this.notes,
    this.needsConfirmation = false,
  });
}

const String kUntitledTask = 'Untitled task';

class ParserService {
  final TimeExtractor timeExtractor;
  final Matcher matcher;
  final List<Map<String, String>> spaces;

  ParserService({
    required this.timeExtractor,
    required this.matcher,
    required this.spaces,
  });

  /// Builds a parser for the currently active spaces, aliases included.
  factory ParserService.forSpaces(List<Map<String, String>> spaces) {
    return ParserService(
      timeExtractor: TimeExtractor(
        days: idDays,
        months: idMonths,
        abbreviations: idAbbrev,
      ),
      matcher: Matcher(spaces),
      spaces: spaces,
    );
  }

  /// Parses raw text into a [ParsedTask]. [now] is injectable so tests stay
  /// deterministic.
  ParsedTask parse(String input, {String locale = 'id', DateTime? now}) {
    final moment = now ?? DateTime.now();

    // Step 1: normalize case, spacing and abbreviations.
    var normalized = normalize(input, idAbbrev);

    // Step 2: extract the task type.
    String? type;
    for (final entry in idTypeKeywords.entries) {
      if (_hasWord(normalized, entry.key)) {
        type = entry.value;
        normalized = _remove(normalized, entry.key);
        break;
      }
    }

    // Step 3: extract time and date.
    final timeResult = timeExtractor.extract(normalized, moment);
    normalized = timeResult.remainingText;

    // Step 4: extract the work mode.
    var isGroup = false;
    for (final word in const ['kelompok', 'individu', 'sendiri', 'mandiri', 'group']) {
      if (_hasWord(normalized, word)) {
        isGroup = word == 'kelompok' || word == 'group';
        normalized = _remove(normalized, word);
        break;
      }
    }

    // Step 5: match the space by name, code or alias.
    String? spaceId;
    String? spaceName;
    if (normalized.trim().isNotEmpty) {
      spaceId = matcher.match(normalized);
      if (spaceId != null) {
        final space = spaces.firstWhere(
          (s) => s['id'] == spaceId,
          orElse: () => const <String, String>{},
        );
        spaceName = space['name'];
        final tokens = <String>[
          if (space['name'] != null) space['name']!.toLowerCase(),
          if (space['code'] != null) space['code']!.toLowerCase(),
          ...?space['aliases']
              ?.split(',')
              .map((a) => a.trim().toLowerCase())
              .where((a) => a.isNotEmpty),
        ];
        for (final token in tokens) {
          normalized = _remove(normalized, token);
        }
      }
    }

    // Step 6: whatever is left becomes the title.
    var title = _clean(normalized);
    if (title.isEmpty) title = spaceName ?? kUntitledTask;

    // Step 7: priority words.
    var priority = 1;
    final lowerInput = input.toLowerCase();
    if (_hasAnyWord(lowerInput, const ['penting', 'urgent', 'tinggi', '!tinggi', '!high', 'high'])) {
      priority = 2;
    } else if (_hasAnyWord(lowerInput, const ['rendah', 'low', 'santai', '!rendah', '!low'])) {
      priority = 0;
    }

    return ParsedTask(
      title: title,
      spaceId: spaceId,
      type: type,
      deadline: timeResult.dateTime,
      priority: priority,
      isGroup: isGroup,
      needsConfirmation: timeResult.needsConfirmation,
      notes: input.trim(),
    );
  }

  static bool _hasWord(String text, String word) =>
      RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false).hasMatch(text);

  static bool _hasAnyWord(String text, List<String> words) =>
      words.any((word) => _hasWord(text, word));

  static String _remove(String text, String token) =>
      text.replaceAll(RegExp(RegExp.escape(token), caseSensitive: false), ' ');

  static String _clean(String text) {
    var out = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    out = out.replaceAll(RegExp(r'^[\s,;:\-]+'), '');
    out = out.replaceAll(RegExp(r'[\s,;:\-]+$'), '');
    return out;
  }
}
