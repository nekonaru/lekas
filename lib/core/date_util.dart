import 'package:intl/intl.dart';

class DateUtil {
  /// Formatters are built by parsing their pattern, which costs more than
  /// formatting a date; the cards call these for every list row, so each
  /// locale keeps one instance.
  static final Map<String, DateFormat> _dateFormats = {};
  static final Map<String, DateFormat> _timeFormats = {};

  static DateFormat _dateFormatFor(String locale) =>
      _dateFormats.putIfAbsent(locale, () => DateFormat.yMMMEd(locale));

  static DateFormat _timeFormatFor(String locale) =>
      _timeFormats.putIfAbsent(locale, () => DateFormat.Hm(locale));

  static String formatDate(DateTime dateTime, String locale) {
    return _dateFormatFor(locale).format(dateTime);
  }

  static String formatTime(DateTime dateTime, String locale) {
    return _timeFormatFor(locale).format(dateTime);
  }

  static String formatDateTime(DateTime dateTime, String locale) {
    return '${formatDate(dateTime, locale)}, ${formatTime(dateTime, locale)}';
  }

  static String relativeTime(DateTime dateTime, String locale) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    if (minutes < 1) return 'baru saja';
    if (minutes < 60) return '$minutes menit lagi';
    if (hours < 24) return '$hours jam lagi';
    if (days < 7) return '$days hari lagi';
    return formatDate(dateTime, locale);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static int toFocusDateKey(DateTime dateTime) {
    return dateTime.year * 10000 + dateTime.month * 100 + dateTime.day;
  }

  static DateTime fromFocusDateKey(int key) {
    final year = key ~/ 10000;
    final month = (key % 10000) ~/ 100;
    final day = key % 100;
    return DateTime(year, month, day);
  }
}
