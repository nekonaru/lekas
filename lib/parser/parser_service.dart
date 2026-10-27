/// Main parser for Quick Add (design section 6.1).
///
/// Combines the normalizer, the time extractor, the space matcher and the
/// type keywords into one pure Dart call with no Flutter dependency, so it
/// can be tested against a large corpus.
library;

import 'normalizer.dart';
import 'time_extractor.dart';
import 'matcher.dart';
import 'advanced_extractor.dart';
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

  // Design section 7.15: the extra chips of the advanced parser.
  final List<String> subtasks;
  final List<String> links;
  final String? submitMethod;
  final String? submitTarget;
  final String? filenamePattern;
  final int? estimateMinutes;
  final String? tag;
  final bool priorityConflict;
  final String? inlineNote;

  ParsedTask({
    required this.title,
    this.spaceId,
    this.type,
    this.deadline,
    this.priority = 1,
    this.isGroup = false,
    this.notes,
    this.needsConfirmation = false,
    this.subtasks = const [],
    this.links = const [],
    this.submitMethod,
    this.submitTarget,
    this.filenamePattern,
    this.estimateMinutes,
    this.tag,
    this.priorityConflict = false,
    this.inlineNote,
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
    final isIndonesian = locale != 'en';

    // Step 1: the list of a shared message becomes subtasks while its line
    // breaks are still there, and the file name pattern is taken raw (both
    // of design section 7.15); normalizing afterwards folds the lines.
    final subtasks = extractSubtasks(input);
    final filename = extractFilenamePattern(subtasks.remainingText);

    // Step 2: normalize case, spacing and abbreviations.
    var normalized = normalize(filename.remainingText, idAbbrev);

    // Step 3: the extra tokens of design section 7.15, in the order they
    // matter: links, email, submission method, "@wadah" and "#tag",
    // estimate, priority markers and words, and a note in round brackets.
    final links = extractLinks(normalized);
    normalized = links.remainingText;
    final email = extractEmail(normalized);
    normalized = email.remainingText;
    final submission = extractSubmitMethod(normalized, email: email.email);
    normalized = submission.remainingText;
    final container = extractContainerTag(normalized);
    normalized = container.remainingText;
    // The estimate runs before the time step: "estimasi 3 jam" is an
    // estimate while "3 jam lagi" has to stay a relative moment (7.15).
    final estimate = extractEstimate(normalized);
    normalized = estimate.remainingText;
    final markers = extractPriorityMarkers(normalized);
    normalized = markers.remainingText;
    final words = extractPriorityWords(normalized, isIndonesian: isIndonesian);
    normalized = words.remainingText;
    final note = extractInlineNote(normalized);
    normalized = note.remainingText;

    // Step 3: extract the task type.
    String? type;
    for (final entry in idTypeKeywords.entries) {
      if (_hasWord(normalized, entry.key)) {
        type = entry.value;
        normalized = _remove(normalized, entry.key);
        break;
      }
    }

    // Step 4: extract time and date.
    final timeResult = timeExtractor.extract(normalized, moment);
    normalized = timeResult.remainingText;

    // Step 5: extract the work mode.
    var isGroup = false;
    for (final word in const ['kelompok', 'individu', 'sendiri', 'mandiri', 'group']) {
      if (_hasWord(normalized, word)) {
        isGroup = word == 'kelompok' || word == 'group';
        normalized = _remove(normalized, word);
        break;
      }
    }

    // Step 6: match the space by name, code or alias. An explicit "@name"
    // token speaks first and falls back to the rest of the text when no
    // space goes by that name (design section 7.15).
    String? spaceId;
    String? spaceName;
    String? fromToken;
    if (container.spaceToken != null) {
      fromToken = matcher.match(container.spaceToken!);
    }
    if (fromToken != null) {
      spaceId = fromToken;
    } else {
      if (container.spaceToken != null) {
        // Nothing answered the token, so it belongs to the title after all.
        normalized = '$normalized @${container.spaceToken}';
      }
      if (normalized.trim().isNotEmpty) {
        spaceId = matcher.match(normalized);
      }
    }
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

    // Step 7: whatever is left becomes the title.
    var title = _clean(normalized);
    if (title.isEmpty) title = spaceName ?? kUntitledTask;

    // Step 8: priority. A `!` marker wins, then the words of design 7.15,
    // then the plain word check of the base parser.
    var priority = 1;
    if (markers.seen) {
      priority = markers.priority;
    } else if (words.priority != 1 || words.conflict) {
      priority = words.priority;
    } else {
      final lowerInput = input.toLowerCase();
      if (_hasAnyWord(lowerInput, const ['penting', 'urgent', 'tinggi', 'high'])) {
        priority = 2;
      } else if (_hasAnyWord(lowerInput, const ['rendah', 'low', 'santai'])) {
        priority = 0;
      }
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
      subtasks: subtasks.subtasks,
      links: links.links,
      submitMethod: submission.submitMethod,
      submitTarget: submission.submitMethod == 'email' ? email.email : null,
      filenamePattern: filename.filenamePattern,
      estimateMinutes: estimate.minutes,
      tag: container.tag,
      priorityConflict: words.conflict,
      inlineNote: note.note,
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
