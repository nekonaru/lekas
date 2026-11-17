/// iCalendar (.ics) export and import for the Lekas calendar tools.
/// Pure functions, no Flutter, so the logic is testable in isolation.
///
/// The exported calendar carries one all-day event per open task and one
/// weekly recurring event per class slot. The importer returns the events
/// it found; turning them into tasks is the caller's job.
library;

/// One calendar event. Floating local times (no Z suffix) are used on
/// export, UTC instants are converted on import.
class IcsEvent {
  const IcsEvent({
    required this.uid,
    required this.start,
    this.end,
    required this.summary,
    this.description,
    this.location,
    this.rrule,
    this.isAllDay = false,
  });

  final String uid;
  final DateTime start;
  final DateTime? end;
  final String summary;
  final String? description;
  final String? location;
  final String? rrule;
  final bool isAllDay;
}

const List<String> _weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

/// Builds a complete VCALENDAR document. CRLF line endings per RFC 5545.
String buildIcsCalendar(List<IcsEvent> events, {String name = 'Lekas'}) {
  final buffer = StringBuffer();
  _line(buffer, 'BEGIN:VCALENDAR');
  _line(buffer, 'VERSION:2.0');
  _line(buffer, 'PRODID:-//Lekas//ID');
  _line(buffer, 'CALSCALE:GREGORIAN');
  _line(buffer, 'METHOD:PUBLISH');
  _line(buffer, 'X-WR-CALNAME:${_escapeText(name)}');
  final now = _stamp(DateTime.now().toUtc());
  for (final event in events) {
    _line(buffer, 'BEGIN:VEVENT');
    _line(buffer, 'UID:${event.uid}');
    _line(buffer, 'DTSTAMP:$now');
    if (event.isAllDay) {
      _line(buffer, 'DTSTART;VALUE=DATE:${_dateOnly(event.start)}');
      if (event.end != null) {
        _line(buffer, 'DTEND;VALUE=DATE:${_dateOnly(event.end!)}');
      }
    } else {
      _line(buffer, 'DTSTART:${_dateTime(event.start)}');
      if (event.end != null) {
        _line(buffer, 'DTEND:${_dateTime(event.end!)}');
      }
    }
    _line(buffer, 'SUMMARY:${_escapeText(event.summary)}');
    if (event.description != null && event.description!.isNotEmpty) {
      _line(buffer, 'DESCRIPTION:${_escapeText(event.description!)}');
    }
    if (event.location != null && event.location!.isNotEmpty) {
      _line(buffer, 'LOCATION:${_escapeText(event.location!)}');
    }
    if (event.rrule != null && event.rrule!.isNotEmpty) {
      _line(buffer, 'RRULE:${event.rrule}');
    }
    _line(buffer, 'END:VEVENT');
  }
  _line(buffer, 'END:VCALENDAR');
  return buffer.toString();
}

/// The BYDAY parameter for a weekly RRULE, e.g. BYDAY=MO,WE.
String weeklyByDay(int weekday) {
  // DateTime.weekday: Monday is 1 .. Sunday is 7.
  return _weekdays[(weekday - 1) % 7];
}

/// Parses a .ics document into events. Tolerates LF or CRLF, unfolds
/// continuation lines, ignores VTIMEZONEs and anything outside VEVENT,
/// and converts Z times to local. Events without a DTSTART are skipped.
List<IcsEvent> parseIcs(String content) {
  final physical = content
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n');
  // RFC 5545: a line starting with a space or tab continues the previous one.
  final lines = <String>[];
  for (final line in physical) {
    if ((line.startsWith(' ') || line.startsWith('\t')) && lines.isNotEmpty) {
      lines[lines.length - 1] = lines.last + line.substring(1);
    } else {
      lines.add(line);
    }
  }

  final events = <IcsEvent>[];
  Map<String, _Keyed>? current;
  for (final line in lines) {
    // Trailing spaces can be significant payload, so no trimming here.
    final tag = line.trim().toUpperCase();
    if (tag == 'BEGIN:VEVENT') {
      current = {};
      continue;
    }
    if (tag == 'END:VEVENT') {
      if (current != null) {
        final event = _eventFrom(current);
        if (event != null) events.add(event);
      }
      current = null;
      continue;
    }
    if (current == null) continue;
    final idx = line.indexOf(':');
    if (idx <= 0) continue;
    final keyPart = line.substring(0, idx);
    final value = line.substring(idx + 1);
    final segments = keyPart.split(';');
    final key = segments.first.toUpperCase();
    final params = <String, String>{};
    for (final segment in segments.skip(1)) {
      final eq = segment.indexOf('=');
      if (eq > 0) {
        params[segment.substring(0, eq).toUpperCase()] =
            segment.substring(eq + 1).toUpperCase();
      }
    }
    // Later duplicates win: files are usually consistent within a VEVENT.
    current[key] = _Keyed(value, params);
  }
  events.sort((a, b) => a.start.compareTo(b.start));
  return events;
}

class _Keyed {
  const _Keyed(this.value, this.params);
  final String value;
  final Map<String, String> params;
}

IcsEvent? _eventFrom(Map<String, _Keyed> fields) {
  final startField = fields['DTSTART'];
  if (startField == null) return null;
  final start = _parseDate(startField);
  if (start == null) return null;
  final end = _parseDate(fields['DTEND']);
  final isAllDay = startField.params['VALUE'] == 'DATE';
  return IcsEvent(
    uid: fields['UID']?.value ?? '${start.millisecondsSinceEpoch}@lekas-import',
    start: start,
    end: end,
    summary: _unescapeText(fields['SUMMARY']?.value ?? ''),
    description: _nullIfEmpty(_unescapeText(fields['DESCRIPTION']?.value)),
    location: _nullIfEmpty(_unescapeText(fields['LOCATION']?.value)),
    rrule: fields['RRULE']?.value,
    isAllDay: isAllDay,
  );
}

DateTime? _parseDate(_Keyed? field) {
  if (field == null) return null;
  final value = field.value.trim().replaceAll(RegExp(r'[-:]'), '');
  final isDate = field.params['VALUE'] == 'DATE';
  if (isDate || value.replaceAll('T', '').length == 8) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 8) return null;
    final year = int.tryParse(digits.substring(0, 4));
    final month = int.tryParse(digits.substring(4, 6));
    final day = int.tryParse(digits.substring(6, 8));
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }
  final match = RegExp(r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})(Z?)$')
      .firstMatch(value);
  if (match == null) return null;
  final parts = [for (final i in [1, 2, 3, 4, 5, 6]) int.parse(match.group(i)!)];
  if (match.group(7) == 'Z') {
    return DateTime.utc(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5])
        .toLocal();
  }
  return DateTime(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5]);
}

String? _nullIfEmpty(String value) => value.isEmpty ? null : value;

/// Escapes TEXT values per RFC 5545 section 3.3.11.
String _escapeText(String value) {
  final out = value
      .replaceAll('\\', '\\\\')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,')
      .replaceAll('\n', '\\n')
      .replaceAll('\r\n', '\\n');
  return out;
}

/// Reverses [_escapeText].
String _unescapeText(String? value) {
  if (value == null) return '';
  final out = StringBuffer();
  var i = 0;
  while (i < value.length) {
    final ch = value[i];
    if (ch == '\\' && i + 1 < value.length) {
      final next = value[i + 1];
      switch (next) {
        case 'n':
        case 'N':
          out.write('\n');
          i += 2;
          continue;
        case ',':
          out.write(',');
          i += 2;
          continue;
        case ';':
          out.write(';');
          i += 2;
          continue;
        case '\\':
          out.write('\\');
          i += 2;
          continue;
      }
    }
    out.write(ch);
    i += 1;
  }
  return out.toString();
}

String _dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

String _dateTime(DateTime date) =>
    '${_dateOnly(date)}T${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}${date.second.toString().padLeft(2, '0')}';

String _stamp(DateTime utc) => '${_dateOnly(utc)}T${utc.hour.toString().padLeft(2, '0')}${utc.minute.toString().padLeft(2, '0')}${utc.second.toString().padLeft(2, '0')}Z';

/// Folds at 70 characters per RFC 5545 3.1.
void _line(StringBuffer buffer, String line) {
  const limit = 70;
  if (line.length <= limit) {
    buffer.write(line);
    buffer.write('\r\n');
    return;
  }
  var remaining = line;
  var first = true;
  while (remaining.length > limit) {
    buffer.write(first ? '' : ' ');
    buffer.write(remaining.substring(0, limit));
    buffer.write('\r\n');
    remaining = remaining.substring(limit);
    first = false;
  }
  if (remaining.isNotEmpty) {
    buffer.write(first ? '' : ' ');
    buffer.write(remaining);
    buffer.write('\r\n');
  }
}


