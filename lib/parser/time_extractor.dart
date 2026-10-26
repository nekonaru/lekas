/// Extracts a date and time from normalized Indonesian text.
///
/// Returns the parsed moment plus the text that is left over, and a flag that
/// tells the caller the guess needs a human check (design section 6.1).
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
  });

  final Map<String, int> days;
  final Map<String, int> months;
  final Map<String, String> abbreviations;

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

    // "sebelum jam 12" means 12:00 on the mentioned day.
    final before = RegExp(r'\bsebelum\s+(?:jam|pukul)?\s*(\d{1,2})(?:[:.](\d{2}))?\b')
        .firstMatch(working);
    if (before != null) {
      hour = _clampHour(int.parse(before.group(1)!));
      minute = before.group(2) != null ? int.parse(before.group(2)!) : 0;
      working = _remove(working, before.group(0)!);
    }

    // Clock time: "23.59", "08:00", "pukul 7.30".
    if (hour == null) {
      final clock = RegExp(r'\b(?:pukul|jam)?\s*(\d{1,2})[:.](\d{2})\b').firstMatch(working);
      if (clock != null) {
        hour = _clampHour(int.parse(clock.group(1)!));
        minute = int.parse(clock.group(2)!) % 60;
        if (RegExp(r'\b(?:am|a\.m\.|pagi)\b').hasMatch(working) && hour == 12) {
          hour = 0;
        } else if (RegExp(r'\b(?:pm|p\.m\.)\b').hasMatch(working) && hour < 12) {
          hour += 12;
        }
        working = _remove(working, clock.group(0)!);
      }
    }

    // "jam 7 malam", "jam 8 pagi", plain "jam 7".
    if (hour == null) {
      final jam = RegExp(
        r'\b(?:jam|pukul)\s+(\d{1,2})(?:[:.](\d{2}))?\s*(pagi|siang|sore|malam|am|pm)?\b',
        caseSensitive: false,
      ).firstMatch(working);
      if (jam != null) {
        hour = _clampHour(int.parse(jam.group(1)!));
        minute = jam.group(2) != null ? int.parse(jam.group(2)!) : 0;
        final period = (jam.group(3) ?? '').toLowerCase();
        if (period == 'sore' || period == 'malam' || period == 'pm') {
          if (hour < 12) hour += 12;
        } else if (period == 'pagi' && hour == 12) {
          hour = 0;
        } else if (period.isEmpty) {
          // Design 6.1: "jam 7" without a period picks the next future
          // occurrence and is flagged for correction.
          ambiguousHour = true;
        }
        working = _remove(working, jam.group(0)!);
      }
    }

    // "7 pagi", "9 malam" without the word "jam".
    if (hour == null) {
      final bare = RegExp(
        r'\b(\d{1,2})(?:[:.](\d{2}))?\s+(pagi|siang|sore|malam)\b',
        caseSensitive: false,
      ).firstMatch(working);
      if (bare != null) {
        hour = _clampHour(int.parse(bare.group(1)!));
        minute = bare.group(2) != null ? int.parse(bare.group(2)!) : 0;
        final period = bare.group(3)!.toLowerCase();
        if (period == 'sore' || period == 'malam') {
          if (hour < 12) hour += 12;
        } else if (period == 'pagi' && hour == 12) {
          hour = 0;
        }
        working = _remove(working, bare.group(0)!);
      }
    }

    // Relative moments: "3 jam lagi", "2 hari lagi".
    var keepComputedTime = false;
    final relative = RegExp(r'\b(\d+)\s*(jam|hari|menit)\s+lagi\b').firstMatch(working);
    if (relative != null) {
      final value = int.parse(relative.group(1)!);
      switch (relative.group(2)!) {
        case 'jam':
          result = now.add(Duration(hours: value));
          keepComputedTime = true;
        case 'menit':
          result = now.add(Duration(minutes: value));
          keepComputedTime = true;
        case 'hari':
          final day = DateTime(now.year, now.month, now.day + value);
          result = DateTime(day.year, day.month, day.day,
              hour ?? kDefaultHour, hour != null ? minute : kDefaultMinute);
      }
      working = _remove(working, relative.group(0)!);
    }

    // "hari ini" (today), "besok" (tomorrow), "lusa" (day after tomorrow).
    if (result == null) {
      final lower = working;
      if (lower.contains('hari ini')) {
        result = DateTime(now.year, now.month, now.day);
        working = _remove(working, 'hari ini');
      } else if (lower.contains('besok')) {
        result = DateTime(now.year, now.month, now.day + 1);
        working = _remove(working, 'besok');
      } else if (lower.contains('lusa')) {
        result = DateTime(now.year, now.month, now.day + 2);
        working = _remove(working, 'lusa');
      }
    }

    // "minggu depan" without a day name means one week from now.
    if (result == null && RegExp(r'\bminggu\s+depan\b').hasMatch(working)) {
      result = DateTime(now.year, now.month, now.day + 7);
      working = _remove(working, 'minggu depan');
    }

    // Weekday names. "jumat" on a Friday means next Friday (design 6.1).
    if (result == null) {
      for (final entry in days.entries) {
        if (!_hasWord(working, entry.key)) continue;
        // "minggu" alone means week, not Sunday; only "hari minggu" is a
        // date. Flag it so the user corrects the date on the chip.
        if (entry.key == 'minggu' && !_hasPhrase(working, 'hari minggu')) {
          needsConfirmation = true;
          continue;
        }
        final int daysToAdd;
        if (working.contains('depan')) {
          // "jumat depan": that weekday in the next calendar week, where a
          // week starts on Monday.
          daysToAdd = 7 - now.weekday + entry.value;
        } else {
          daysToAdd = entry.value - now.weekday > 0
              ? entry.value - now.weekday
              : entry.value - now.weekday + 7;
        }
        final date = DateTime(now.year, now.month, now.day + daysToAdd);
        result = date;
        needsConfirmation = true;
        if (entry.key == 'minggu') {
          working = _remove(working, 'hari minggu');
        } else {
          working = _remove(working, entry.key);
        }
        working = _remove(working, 'depan');
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

    // Day of month without a month name: "tanggal 25" or "tgl 25".
    if (result == null) {
      final dayOfMonth =
          RegExp(r'\b(?:tanggal|tgl)\s+(\d{1,2})\b').firstMatch(working);
      if (dayOfMonth != null) {
        final wanted = int.parse(dayOfMonth.group(1)!);
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
      final withDay =
          RegExp(r'\b(?:tanggal\s+)?(\d{1,2})\s+' + entry.key).firstMatch(working);
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

  static String _removeAll(String text, List<String> tokens) {
    var out = text;
    for (final token in tokens) {
      out = _remove(out, token);
    }
    return out;
  }
}
