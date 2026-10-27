/// Extracts a date and time from normalized text in either language.
///
/// Returns the parsed moment plus the text that is left over, and a flag that
/// tells the caller the guess needs a human check (design section 6.1).
///
/// The dictionaries carry both languages at once (design section 8.5); the
/// [englishActive] flag only settles the words that mean two things, such as
/// "minggu" (Sunday or a week).
library;

class TimeExtractionResult {
  const TimeExtractionResult({
    this.dateTime,
    required this.remainingText,
    this.needsConfirmation = false,
  });

  final DateTime? dateTime;
  final String remainingText;
  final bool needsConfirmation;
}

/// Default clock time when a date is known but no time was written: 23:59.
const int kDefaultHour = 23;
const int kDefaultMinute = 59;

/// A parsed date plus whether the caller should ask the user to confirm it.
class _DateGuess {
  const _DateGuess(this.date, [this.needsConfirmation = false]);

  final DateTime date;
  final bool needsConfirmation;
}

class TimeExtractor {
  const TimeExtractor({
    required this.days,
    required this.months,
    required this.abbreviations,
    this.englishActive = false,
  });

  final Map<String, int> days;
  final Map<String, int> months;
  final Map<String, String> abbreviations;

  /// True when the language the user typed in is English, which decides the
  /// words that are ambiguous between the two languages (design 8.5).
  final bool englishActive;

  static final RegExp _space = RegExp(r'\s+');

  TimeExtractionResult extract(String text, DateTime now) {
    var working = ' ${text.toLowerCase().trim()} ';
    var needsConfirmation = false;
    DateTime? result;
    int? hour;
    int minute = 0;
    var ambiguousHour = false;

    for (final entry in abbreviations.entries) {
      working = working.replaceAll(
        RegExp('\\b${RegExp.escape(entry.key)}\\b'),
        entry.value,
      );
    }

    // "sebelum jam 12" and "before 12" mean 12:00 on the mentioned day.
    final before = RegExp(
            r'\b(?:sebelum|before)\s+(?:jam|pukul|at)?\s*(\d{1,2})(?:[:.](\d{2}))?\b',
            caseSensitive: false)
        .firstMatch(working);
    if (before != null) {
      hour = _clampHour(int.parse(before.group(1)!));
      minute = before.group(2) != null ? int.parse(before.group(2)!) : 0;
      working = _remove(working, before.group(0)!);
    }

    // Clock time: "23.59", "08:00", "pukul 7.30", "7:00 PM", "11:59pm".
    if (hour == null) {
      final clock = RegExp(
              r'\b(?:pukul|jam|at)?\s*(\d{1,2})[:.](\d{2})\s*(a\.m\.|p\.m\.|am|pm)?',
              caseSensitive: false)
          .firstMatch(working);
      if (clock != null) {
        hour = _clampHour(int.parse(clock.group(1)!));
        minute = int.parse(clock.group(2)!) % 60;
        final suffix = clock.group(3)?.toLowerCase();
        if (suffix == 'pm' || suffix == 'p.m.') {
          if (hour < 12) hour += 12;
        } else if (suffix == 'am' || suffix == 'a.m.') {
          if (hour == 12) hour = 0;
        } else if (RegExp(r'\b(?:am|a\.m\.|pagi|morning)\b').hasMatch(working) &&
            hour == 12) {
          hour = 0;
        } else if (RegExp(r'\b(?:pm|p\.m\.|malam)\b').hasMatch(working) &&
            hour < 12) {
          hour += 12;
        }
        working = _remove(working, clock.group(0)!);
      }
    }

    // "7pm", "11 pm", "8:00 a.m." written without a colon for the hour.
    if (hour == null) {
      final meridiem = RegExp(
              r'\b(?:jam|pukul|at)?\s*(\d{1,2})\s*(a\.m\.|p\.m\.|am|pm)\b',
              caseSensitive: false)
          .firstMatch(working);
      final value = meridiem != null ? int.parse(meridiem.group(1)!) : 0;
      if (meridiem != null && value < 24) {
        hour = _clampHour(value);
        minute = 0;
        final suffix = meridiem.group(2)!.toLowerCase();
        if (suffix == 'pm' || suffix == 'p.m.') {
          if (hour < 12) hour += 12;
        } else if (hour == 12) {
          hour = 0;
        }
        working = _remove(working, meridiem.group(0)!);
      }
    }

    // "jam 7 malam", "jam 8 pagi", "at 7", plain "jam 7".
    if (hour == null) {
      final jam = RegExp(
        r'\b(?:jam|pukul|at)\s+(\d{1,2})(?:[:.](\d{2}))?\s*'
        r'(pagi|siang|sore|malam|morning|afternoon|evening|night|am|pm)?\b',
        caseSensitive: false,
      ).firstMatch(working);
      if (jam != null) {
        hour = _clampHour(int.parse(jam.group(1)!));
        minute = jam.group(2) != null ? int.parse(jam.group(2)!) : 0;
        final period = (jam.group(3) ?? '').toLowerCase();
        if (period == 'sore' ||
            period == 'malam' ||
            period == 'pm' ||
            period == 'evening' ||
            period == 'night') {
          if (hour < 12) hour += 12;
        } else if ((period == 'pagi' || period == 'morning') && hour == 12) {
          hour = 0;
        } else if (period.isEmpty) {
          // Design 6.1: "jam 7" without a period picks the next future
          // occurrence and is flagged for correction.
          ambiguousHour = true;
        }
        working = _remove(working, jam.group(0)!);
      }
    }

    // "7 pagi", "9 malam", "7 in the morning" without the word "jam".
    if (hour == null) {
      final bare = RegExp(
        r'\b(\d{1,2})(?:[:.](\d{2}))?\s+(pagi|siang|sore|malam|'
        r'morning|afternoon|evening|night)\b',
        caseSensitive: false,
      ).firstMatch(working);
      if (bare != null) {
        hour = _clampHour(int.parse(bare.group(1)!));
        minute = bare.group(2) != null ? int.parse(bare.group(2)!) : 0;
        final period = bare.group(3)!.toLowerCase();
        if (period == 'sore' ||
            period == 'malam' ||
            period == 'evening' ||
            period == 'night') {
          if (hour < 12) hour += 12;
        } else if ((period == 'pagi' || period == 'morning') && hour == 12) {
          hour = 0;
        }
        working = _remove(working, bare.group(0)!);
      }
    }

    // Relative moments: "3 jam lagi", "2 hari lagi", "in 3 hours".
    var keepComputedTime = false;
    var relative = RegExp(r'\b(\d+)\s*(jam|hari|menit)\s+lagi\b').firstMatch(working);
    var englishRelative = false;
    if (relative == null) {
      relative = RegExp(r'\bin\s+(\d+)\s*(hours?|hrs?|minutes?|mins?|days?)\b',
              caseSensitive: false)
          .firstMatch(working);
      englishRelative = relative != null;
    }
    if (relative != null) {
      final value = int.parse(relative.group(1)!);
      final unit = relative.group(2)!.toLowerCase();
      final bool isHours;
      var isDays = false;
      if (englishRelative) {
        isDays = unit.startsWith('day');
        isHours = !isDays && !unit.startsWith('m');
      } else {
        isDays = unit == 'hari';
        isHours = unit == 'jam';
      }
      if (isDays) {
        final day = DateTime(now.year, now.month, now.day + value);
        result = DateTime(day.year, day.month, day.day,
            hour ?? kDefaultHour, hour != null ? minute : kDefaultMinute);
      } else {
        result = now.add(isHours
            ? Duration(hours: value)
            : Duration(minutes: value));
        keepComputedTime = true;
      }
      working = _remove(working, relative.group(0)!);
    }

    // "hari ini"/"today", "besok"/"tomorrow", "lusa"/"day after tomorrow".
    if (result == null) {
      final lower = working;
      if (lower.contains('hari ini') || _hasWord(lower, 'today')) {
        result = DateTime(now.year, now.month, now.day);
        working = _remove(working, 'hari ini');
        working = _removeWord(working, 'today');
      } else if (_hasWord(lower, 'day after tomorrow') ||
          lower.contains('lusa')) {
        result = DateTime(now.year, now.month, now.day + 2);
        working = _removeWord(working, 'day after tomorrow');
        working = _remove(working, 'lusa');
      } else if (lower.contains('besok') || _hasWord(lower, 'tomorrow')) {
        result = DateTime(now.year, now.month, now.day + 1);
        working = _remove(working, 'besok');
        working = _removeWord(working, 'tomorrow');
      }
    }

    // "minggu depan" and "next week" without a day name mean one week from now.
    if (result == null &&
        (RegExp(r'\bminggu\s+depan\b').hasMatch(working) ||
            RegExp(r'\bnext\s+week\b').hasMatch(working))) {
      result = DateTime(now.year, now.month, now.day + 7);
      working = _remove(working, 'minggu depan');
      working = _removeWord(working, 'next week');
    }

    // Weekday names from both languages. "jumat"/"friday" on a Friday means
    // next Friday (design 6.1).
    if (result == null) {
      for (final entry in days.entries) {
        if (!_hasWord(working, entry.key)) continue;
        // "minggu" alone means week, not Sunday; only "hari minggu" is a
        // date. With English active the word is taken as Sunday but still
        // flagged, because it can also mean a week (design 8.5).
        if (entry.key == 'minggu' &&
            !englishActive &&
            !_hasPhrase(working, 'hari minggu')) {
          needsConfirmation = true;
          continue;
        }
        final hasNext = _hasWord(working, 'depan') || _hasWord(working, 'next');
        final int daysToAdd;
        if (hasNext) {
          // "jumat depan"/"next friday": that weekday in the next calendar
          // week, where a week starts on Monday.
          daysToAdd = 7 - now.weekday + entry.value;
        } else {
          daysToAdd = entry.value - now.weekday > 0
              ? entry.value - now.weekday
              : entry.value - now.weekday + 7;
        }
        final date = DateTime(now.year, now.month, now.day + daysToAdd);
        result = date;
        needsConfirmation = true;
        if (entry.key == 'minggu' && englishActive) needsConfirmation = true;
        if (entry.key == 'minggu') {
          working = _remove(working, 'hari minggu');
          working = _removeWord(working, 'minggu');
        } else {
          working = _remove(working, entry.key);
        }
        working = _removeWord(working, 'depan');
        working = _removeWord(working, 'next');
        break;
      }
    }

    if (result == null) {
      final monthGuess = _extractMonth(working, now);
      if (monthGuess != null) {
        result = monthGuess.date;
        if (monthGuess.needsConfirmation) needsConfirmation = true;
        working = _removeMonthText(working);
      }
    }

    // Day of month without a month name: "tanggal 25", "tgl 25", "the 25th".
    if (result == null) {
      final dayOfMonth = RegExp(
              r'\b(?:tanggal|tgl)\s+(\d{1,2})\b|\b(?:the\s+)?(\d{1,2})'
              r'(?:st|nd|rd|th)\b',
              caseSensitive: false)
          .firstMatch(working);
      if (dayOfMonth != null) {
        final wanted =
            int.parse(dayOfMonth.group(1) ?? dayOfMonth.group(2)!);
        var candidate = DateTime(now.year, now.month, wanted);
        if (candidate.isBefore(DateTime(now.year, now.month, now.day))) {
          candidate = DateTime(now.year, now.month + 1, wanted);
        }
        result = candidate;
        working = _remove(working, dayOfMonth.group(0)!);
      }
    }

    if (result != null) {
      final int hourPart;
      final int minutePart;
      if (hour != null) {
        hourPart = hour;
        minutePart = minute;
      } else if (keepComputedTime) {
        hourPart = result.hour;
        minutePart = result.minute;
      } else {
        hourPart = kDefaultHour;
        minutePart = kDefaultMinute;
      }
      result = DateTime(result.year, result.month, result.day, hourPart, minutePart);
      if (hour != null && ambiguousHour) needsConfirmation = true;
    } else if (hour != null) {
      // A clock time on its own: pick the next future occurrence.
      var candidate = DateTime(now.year, now.month, now.day, hour, minute);
      if (!candidate.isAfter(now)) {
        candidate = DateTime(now.year, now.month, now.day + 1, hour, minute);
      }
      result = candidate;
      needsConfirmation = true;
    }

    working = _removeAll(working, const ['jam', 'pukul', 'tanggal', 'tgl', 'sebelum', 'lagi', 'depan']);
    // "before" only belongs to a date phrase, so it is dropped only when one
    // was found and never from an ordinary title.
    if (result != null) working = _removeWord(working, 'before');

    return TimeExtractionResult(
      dateTime: result,
      remainingText: working.replaceAll(_space, ' ').trim(),
      needsConfirmation: needsConfirmation,
    );
  }

  _DateGuess? _extractMonth(String working, DateTime now) {
    for (final entry in months.entries) {
      if (!_hasWord(working, entry.key)) continue;
      var day = now.day;
      var guessed = false;
      // Both orders count: "25 oktober" and "october 25" (design 8.5).
      final withDay = RegExp(
              r'\b(?:tanggal\s+)?(\d{1,2})\s+'
              '${RegExp.escape(entry.key)}')
          .firstMatch(working) ??
          RegExp(
                  '\\b${RegExp.escape(entry.key)}\\s+(?:the\\s+)?(\\d{1,2})\\b')
              .firstMatch(working);
      if (withDay != null) {
        day = int.parse(withDay.group(1)!);
      } else {
        // A month on its own means the end of that month, and the chip asks
        // the user to confirm the day.
        day = DateTime(now.year, entry.value + 1, 0).day;
        guessed = true;
      }
      var year = now.year;
      if (entry.value < now.month || (entry.value == now.month && day < now.day)) {
        year += 1;
      }
      return _DateGuess(DateTime(year, entry.value, day), guessed);
    }
    return null;
  }

  String _removeMonthText(String working) {
    var text = working;
    for (final name in months.keys) {
      text = _remove(text, name);
    }
    return text.replaceAll(RegExp(r'\b(?:tanggal\s+)?\d{1,2}\b\s*$'), '').trim();
  }

  static int _clampHour(int hour) => hour >= 24 ? 0 : hour;

  static bool _hasWord(String text, String word) =>
      RegExp('\\b${RegExp.escape(word)}\\b').hasMatch(text);

  static bool _hasPhrase(String text, String phrase) =>
      text.contains(phrase);

  static String _remove(String text, String token) =>
      text.replaceAll(token, ' ');

  /// Removes a whole word only, so "today" never damages "yesterday".
  static String _removeWord(String text, String word) =>
      text.replaceAll(RegExp('\\b${RegExp.escape(word)}\\b'), ' ');

  static String _removeAll(String text, List<String> tokens) {
    var out = text;
    for (final token in tokens) {
      out = _remove(out, token);
    }
    return out;
  }
}
