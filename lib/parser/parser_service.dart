/// Parser utama untuk Quick Add.
/// Menggabungkan normalizer, time_extractor, matcher, dan type keywords.
import 'package:intl/intl.dart';
import '../data/models.dart';
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

class ParserService {
  final TimeExtractor timeExtractor;
  final Matcher matcher;
  final List<Map<String, String>> spaces;

  ParserService({
    required this.timeExtractor,
    required this.matcher,
    required this.spaces,
  });

  /// Parse teks mentah menjadi ParsedTask.
  ParsedTask parse(String input, {String locale = 'id'}) {
    final now = DateTime.now();

    // Step 1: Normalize
    var normalized = normalize(input, idAbbrev);

    // Step 2: Extract type keywords
    String? type;
    idTypeKeywords.forEach((keyword, neutralType) {
      if (normalized.contains(keyword)) {
        type = neutralType;
        normalized = normalized.replaceAll(keyword, '').trim();
      }
    });

    // Step 3: Extract time
    final timeResult = timeExtractor.extract(normalized, now);
    normalized = timeResult.remainingText.trim();

    // Step 4: Match space (wadah)
    String? spaceId;
    if (normalized.isNotEmpty) {
      spaceId = matcher.match(normalized);
      if (spaceId != null) {
        final space = spaces.firstWhere((s) => s['id'] == spaceId);
        normalized = normalized.replaceAll(space['name']!, '').trim();
        final code = space['code'];
        if (code != null && code.isNotEmpty) {
          normalized = normalized.replaceAll(code, '').trim();
        }
      }
    }

    // Step 5: Remaining text is title
    final title = normalized.isEmpty ? 'Tugas Tanpa Judul' : normalized;

    // Step 6: Detect group mode
    final isGroup = input.toLowerCase().contains('kelompok') ||
        input.toLowerCase().contains('group');

    // Step 7: Priority detection
    int priority = 1;
    final lowerInput = input.toLowerCase();
    if (lowerInput.contains('penting') || lowerInput.contains('urgent') ||
        lowerInput.contains('tinggi') || lowerInput.contains('!tinggi') ||
        lowerInput.contains('!high')) {
      priority = 2;
    } else if (lowerInput.contains('rendah') || lowerInput.contains('low') ||
        lowerInput.contains('santai') || lowerInput.contains('!rendah') ||
        lowerInput.contains('!low')) {
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
      notes: input, // Store original text as notes
    );
  }
}
