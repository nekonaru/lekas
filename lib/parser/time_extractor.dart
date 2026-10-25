/// Ekstraksi waktu dari teks yang telah dinormalisasi.
/// Mengembalikan DateTime atau null bila tidak ada waktu yang ditemukan.
import 'package:intl/intl.dart';

class TimeExtractionResult {
  final DateTime? dateTime;
  final String remainingText;
  final bool needsConfirmation;

  TimeExtractionResult({
    this.dateTime,
    required this.remainingText,
    this.needsConfirmation = false,
  });
}

class TimeExtractor {
  final Map<String, int> days;
  final Map<String, int> months;
  final Map<String, String> abbreviations;

  TimeExtractor({
    required this.days,
    required this.months,
    required this.abbreviations,
  });

  TimeExtractionResult extract(String text, DateTime now) {
    var workingText = text;
    DateTime? result;
    bool needsConfirmation = false;

    // Expand abbreviations
    for (final entry in abbreviations.entries) {
      workingText = workingText.replaceAll(
        RegExp(r'\b${RegExp.escape(entry.key)}\b'),
        entry.value,
      );
    }

    // Try to extract time patterns: "jam 8", "08.00", "23.59", "7pm", "7:00 PM"
    final timeRegex = RegExp(
      r'(?:jam\s+)?(\d{1,2})[:\.](\d{2})\s*(?:(p?)\.?\s*m\.?)?',
      caseSensitive: false,
    );
    final timeMatch = timeRegex.firstMatch(workingText);
    int hour = -1;
    int minute = 0;
    bool isPM = false;

    if (timeMatch != null) {
      hour = int.parse(timeMatch.group(1)!);
      minute = int.parse(timeMatch.group(2)!);
      final ampm = timeMatch.group(3);
      if (ampm != null && ampm.toLowerCase() == 'p') {
        isPM = true;
      }
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
    }

    // Try "jam 7 malam", "jam 7 pagi"
    final timeWordRegex = RegExp(
      r'jam\s+(\d{1,2})\s*(pagi|siang|sore|malam)?',
      caseSensitive: false,
    );
    final timeWordMatch = timeWordRegex.firstMatch(workingText);
    if (timeWordMatch != null && hour == -1) {
      hour = int.parse(timeWordMatch.group(1)!);
      final period = timeWordMatch.group(2)?.toLowerCase();
      if (period == 'malam' || period == 'sore') {
        if (hour < 12) hour += 12;
      } else if (period == 'pagi' && hour == 12) {
        hour = 0;
      }
    }

    // Try relative time: "3 jam lagi", "2 hari lagi"
    final relativeRegex = RegExp(r'(\d+)\s*(jam|hari|menit)\s+lagi', caseSensitive: false);
    final relativeMatch = relativeRegex.firstMatch(workingText);
    if (relativeMatch != null) {
      final value = int.parse(relativeMatch.group(1)!);
      final unit = relativeMatch.group(2)!;
      if (unit == 'jam') {
        result = now.add(Duration(hours: value));
      } else if (unit == 'hari') {
        result = now.add(Duration(days: value));
      } else if (unit == 'menit') {
        result = now.add(Duration(minutes: value));
      }
      workingText = workingText.replaceAll(relativeMatch.group(0)!, '').trim();
    }

    // Try day names: "senin", "jumat", etc.
    if (result == null) {
      for (final entry in days.entries) {
        if (workingText.contains(entry.key)) {
          final targetWeekday = entry.value;
          final currentWeekday = now.weekday; // 1=Mon, 7=Sun
          var daysToAdd = targetWeekday - currentWeekday;
          if (daysToAdd <= 0) daysToAdd += 7;
          // "minggu depan" or "next week" adds another 7
          if (workingText.contains('depan') || workingText.contains('next')) {
            daysToAdd += 7;
          }
          var candidateDate = DateTime(
            now.year, now.month, now.day,
          ).add(Duration(days: daysToAdd));

          if (hour != -1) {
            candidateDate = DateTime(
              candidateDate.year, candidateDate.month, candidateDate.day, hour, minute,
            );
          } else {
            candidateDate = DateTime(candidateDate.year, candidateDate.month, candidateDate.day, 23, 59);
          }

          result = candidateDate;
          needsConfirmation = true; // Day name alone needs confirmation
          workingText = workingText.replaceAll(entry.key, '').trim();
          break;
        }
      }
    }

    // Try month names: "oktober", "januari", etc.
    if (result == null) {
      for (final entry in months.entries) {
        if (workingText.contains(entry.key)) {
          final targetMonth = entry.value;
          var targetYear = now.year;
          var targetDay = now.day;

          // Check for "tgl 25" pattern
          final dayRegex = RegExp(r'tgl\s+(\d{1,2})', caseSensitive: false);
          final dayMatch = dayRegex.firstMatch(workingText);
          if (dayMatch != null) {
            targetDay = int.parse(dayMatch.group(1)!);
          }

          // If month already passed this year, use next year
          if (targetMonth < now.month || (targetMonth == now.month && targetDay < now.day)) {
            targetYear++;
          }

          var candidateDate = DateTime(targetYear, targetMonth, targetDay);
          if (hour != -1) {
            candidateDate = DateTime(
              candidateDate.year, candidateDate.month, candidateDate.day, hour, minute,
            );
          } else {
            candidateDate = DateTime(candidateDate.year, candidateDate.month, candidateDate.day, 23, 59);
          }

          result = candidateDate;
          workingText = workingText.replaceAll(entry.key, '').trim();
          if (dayMatch != null) {
            workingText = workingText.replaceAll(dayMatch.group(0)!, '').trim();
          }
          break;
        }
      }
    }

    // Try "besok", "hari ini", "lusa"
    if (result == null) {
      final lowerText = workingText.toLowerCase();
      if (lowerText.contains('besok')) {
        result = DateTime(now.year, now.month, now.day + 1,
            hour != -1 ? hour : 23, hour != -1 ? minute : 59);
        workingText = workingText.replaceAll('besok', '').trim();
      } else if (lowerText.contains('hari ini')) {
        result = DateTime(now.year, now.month, now.day,
            hour != -1 ? hour : 23, hour != -1 ? minute : 59);
        workingText = workingText.replaceAll('hari ini', '').trim();
      } else if (lowerText.contains('lusa')) {
        result = DateTime(now.year, now.month, now.day + 2,
            hour != -1 ? hour : 23, hour != -1 ? minute : 59);
        workingText = workingText.replaceAll('lusa', '').trim();
      }
    }

    // Default: no time found, return null with remaining text
    if (result == null) {
      return TimeExtractionResult(
        dateTime: null,
        remainingText: workingText.trim(),
        needsConfirmation: false,
      );
    }

    return TimeExtractionResult(
      dateTime: result,
      remainingText: workingText.trim(),
      needsConfirmation: needsConfirmation,
    );
  }
}
