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
import 'dictionaries/en.dart';
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

/// How much of the input the parser ever looks at.
///
/// Quick Add parses on every settled keystroke and on whatever a share or a
/// voice note hands it, so a pasted web page has to become a short title
/// instead of a freeze (design section 7.15).
const int kMaxParsedChars = 4000;

/// The input cut at a word boundary, so the cap never chops a token in half.
String _capForParsing(String input) {
  if (input.length <= kMaxParsedChars) return input;
  final cut = input.lastIndexOf(' ', kMaxParsedChars);
  return input.substring(0, cut <= 0 ? kMaxParsedChars : cut);
}

class ParserService {
  final Matcher matcher;
  final List<Map<String, String>> spaces;

  ParserService({
    required this.matcher,
    required this.spaces,
  });

  /// Builds a parser for the currently active spaces, aliases included.
  factory ParserService.forSpaces(List<Map<String, String>> spaces) {
    return ParserService(
      matcher: Matcher(spaces),
      spaces: spaces,
    );
  }

  /// Parses raw text into a [ParsedTask]. [now] is injectable so tests stay
  /// deterministic.
  ///
  /// [locale] picks the active language. Both dictionaries are always read
  /// together (design section 8.5): the active one comes first, so it wins a
  /// conflict and gets first pick of the words, and the other one fills in
  /// what it lacks, which keeps mixed sentences such as "submit laprak
  /// friday 23.59" readable in either language.
  ParsedTask parse(String input, {String locale = 'id', DateTime? now}) {
    final moment = now ?? DateTime.now();
    final isIndonesian = !locale.toLowerCase().startsWith('en');

    final abbrev = _merge(idAbbrev, enAbbrev, isIndonesian);
    final days = _merge(idDays, enDays, isIndonesian);
    final months = _merge(idMonths, enMonths, isIndonesian);
    final typeKeywords = _merge(idTypeKeywords, enTypeKeywords, isIndonesian);
    final extractor = TimeExtractor(
      days: days,
      months: months,
      abbreviations: abbrev,
      englishActive: !isIndonesian,
    );

    // Only the part of the text that can still change the result is read;
    // the notes below keep the original message untouched.
    final text = _capForParsing(input);

    // Step 1: the list of a shared message becomes subtasks while its line
    // breaks are still there, and the file name pattern is taken raw (both
    // of design section 7.15); normalizing afterwards folds the lines.
    final subtasks = extractSubtasks(text);
    final filename = extractFilenamePattern(subtasks.remainingText);

    // Step 2: normalize case, spacing and abbreviations of both languages.
    var normalized = normalize(filename.remainingText, abbrev);

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

    // Step 3: extract the task type, mapped to the neutral keys of design
    // 8.3, so "kuis" and "quiz" land on the same value.
    String? type;
    for (final entry in typeKeywords.entries) {
      if (_hasWord(normalized, entry.key)) {
        type = entry.value;
        normalized = _remove(normalized, entry.key);
        break;
      }
    }

    // Step 4: extract time and date.
    final timeResult = extractor.extract(normalized, moment);
    normalized = timeResult.remainingText;

    // Step 5: extract the work mode, in both languages.
    var isGroup = false;
    final modeWords = <String>[
      if (isIndonesian) ...const ['kelompok', 'individu', 'sendiri', 'mandiri'],
      ...const ['group', 'individual', 'solo', 'alone'],
      if (!isIndonesian) ...const ['kelompok', 'individu', 'sendiri', 'mandiri'],
    ];
    for (final word in modeWords) {
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
      final lowerInput = text.toLowerCase();
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

  /// Merges the two dictionaries of one kind: the active language comes
  /// first, so it decides conflicts and gets the first look at the words,
  /// and the other language fills in what it does not know (design 8.5).
  static Map<String, V> _merge<V>(
    Map<String, V> indonesian,
    Map<String, V> english,
    bool useIndonesian,
  ) {
    final active = useIndonesian ? indonesian : english;
    final fallback = useIndonesian ? english : indonesian;
    return {
      ...active,
      for (final entry in fallback.entries)
        if (!active.containsKey(entry.key)) entry.key: entry.value,
    };
  }

  static String _remove(String text, String token) =>
      text.replaceAll(RegExp(RegExp.escape(token), caseSensitive: false), ' ');

  static String _clean(String text) {
    var out = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    out = out.replaceAll(RegExp(r'^[\s,;:\-]+'), '');
    out = out.replaceAll(RegExp(r'[\s,;:\-]+$'), '');
    return out;
  }
}
