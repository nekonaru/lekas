import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/ics.dart';

void main() {
  test('weeklyByDay maps DateTime.weekday to RFC 5545 codes', () {
    expect(weeklyByDay(1), 'MO');
    expect(weeklyByDay(3), 'WE');
    expect(weeklyByDay(7), 'SU');
  });

  test('export uses CRLF line endings', () {
    final ics = buildIcsCalendar([
      IcsEvent(
        uid: 'u1@lekas',
        start: DateTime(2026, 11, 20),
        summary: 'Tugas',
        isAllDay: true,
      ),
    ]);
    expect(ics, contains('\r\n'));
    expect(ics, startsWith('BEGIN:VCALENDAR\r\n'));
    expect(ics, endsWith('END:VCALENDAR\r\n'));
  });

  test('round-trip: export then parse recovers the events', () {
    final events = [
      IcsEvent(
        uid: 'task-1@lekas',
        start: DateTime(2026, 11, 20),
        summary: 'Kerjakan laporan',
        isAllDay: true,
      ),
      IcsEvent(
        uid: 'slot-1@lekas',
        start: DateTime(2026, 11, 17, 9, 0),
        end: DateTime(2026, 11, 17, 10, 40),
        summary: 'Biologi',
        location: 'Lab 2',
        rrule: 'FREQ=WEEKLY;BYDAY=TU',
      ),
    ];
    final parsed = parseIcs(buildIcsCalendar(events));
    expect(parsed, hasLength(2));
    expect(parsed[0].summary, 'Biologi'); // sorted by start
    expect(parsed[1].summary, 'Kerjakan laporan');
    expect(parsed[0].rrule, 'FREQ=WEEKLY;BYDAY=TU');
    expect(parsed[0].location, 'Lab 2');
    expect(parsed[0].isAllDay, isFalse);
    expect(parsed[1].isAllDay, isTrue);
  });

  test('escaping survives commas, semicolons and newlines', () {
    final events = [
      IcsEvent(
        uid: 'u2@lekas',
        start: DateTime(2026, 11, 20),
        summary: 'Bab 3, soal 1; sertakan\njawaban',
        description: 'Baris satu\nbaris dua',
        isAllDay: true,
      ),
    ];
    final parsed = parseIcs(buildIcsCalendar(events));
    expect(parsed.single.summary, 'Bab 3, soal 1; sertakan\njawaban');
    expect(parsed.single.description, 'Baris satu\nbaris dua');
  });

  test('a very long summary is folded and parsed back intact', () {
    final long = 'Laporan ' * 40; // well past the 75 octet fold
    final events = [
      IcsEvent(
        uid: 'u3@lekas',
        start: DateTime(2026, 11, 20),
        summary: long,
        isAllDay: true,
      ),
    ];
    final parsed = parseIcs(buildIcsCalendar(events));
    expect(parsed.single.summary, long);
  });

  test('LF line endings parse just like CRLF', () {
    const doc = 'BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nUID:x\n'
        'DTSTART:20261120T090000\nSUMMARY:Ujian\nEND:VEVENT\nEND:VCALENDAR\n';
    final parsed = parseIcs(doc);
    expect(parsed, hasLength(1));
    expect(parsed.single.summary, 'Ujian');
    expect(parsed.single.start, DateTime(2026, 11, 20, 9));
  });

  test('Z timestamps are read as UTC and converted to local', () {
    const doc = 'BEGIN:VEVENT\nUID:x\n'
        'DTSTART:2026-01-15T10:00:00Z\n' // dashes are tolerated too
        'SUMMARY:Webinar\nEND:VEVENT\n';
    final parsed = parseIcs(doc);
    expect(parsed.single.start,
        DateTime.utc(2026, 1, 15, 10).toLocal());
  });

  test('events without DTSTART are skipped, others survive', () {
    const doc = 'BEGIN:VEVENT\nSUMMARY:NoStart\nEND:VEVENT\n'
        'BEGIN:VEVENT\nDTSTART:20261120T000000\nSUMMARY:Kept\nEND:VEVENT\n';
    final parsed = parseIcs(doc);
    expect(parsed, hasLength(1));
    expect(parsed.single.summary, 'Kept');
  });

  test('VCALENDAR junk and empty files parse to nothing', () {
    expect(parseIcs('hello world'), isEmpty);
    expect(parseIcs(''), isEmpty);
    expect(parseIcs('BEGIN:VCALENDAR\nEND:VCALENDAR\n'), isEmpty);
  });
}
