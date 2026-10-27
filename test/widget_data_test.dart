import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/domain/widget_data.dart';

void main() {
  group('task list widget rows (design section 7.8)', () {
    test('finished rows drop out and the rest keep their order', () {
      final rows = widgetTaskRows(const [
        (id: 'a', title: 'laprak', done: false),
        (id: 'b', title: 'seminar', done: true),
        (id: 'c', title: 'uis', done: false),
      ]);
      expect(rows.map((row) => row.id), ['a', 'c']);
    });

    test('never more than six lines', () {
      final rows = widgetTaskRows([
        for (var i = 0; i < 9; i++) (id: '$i', title: 't$i', done: false),
      ]);
      expect(rows, hasLength(6));
    });
  });

  group('focus widget rows (design sections 5.24 and 7.8)', () {
    test('done focus rows stay visible with their flag', () {
      final rows = widgetFocusRows(const [
        (id: 'a', title: 'laprak', done: true),
        (id: 'b', title: 'uis', done: false),
      ]);
      expect(rows, hasLength(2));
      expect(rows.first.done, isTrue);
    });

    test('the three focus slots are the hard limit', () {
      final rows = widgetFocusRows([
        for (var i = 0; i < 5; i++) (id: '$i', title: 't$i', done: false),
      ]);
      expect(rows, hasLength(3));
    });
  });

  group('class time of the widget (design section 9)', () {
    test('the separator follows the language', () {
      expect(widgetClassTime(DateTime(2026, 10, 27, 9, 5)), '09.05');
      expect(
          widgetClassTime(DateTime(2026, 10, 27, 9, 5), separator: ':'),
          '09:05');
      expect(widgetClassTime(DateTime(2026, 10, 27, 21, 0)), '21.00');
    });
  });

  group('exam countdown (design section 7.8)', () {
    final now = DateTime(2026, 10, 27, 8, 0);

    test('the nearest deadline ahead wins', () {
      final countdown = widgetExamCountdown(
        now: now,
        exams: [
          (course: 'Basdat', title: 'UTS', deadline: DateTime(2026, 11, 3)),
          (course: 'Algoritma', title: 'UTS', deadline: DateTime(2026, 10, 30)),
          (course: 'Kalkulus', title: 'Kuis', deadline: DateTime(2026, 10, 29)),
        ],
      );
      expect(countdown, (course: 'Kalkulus', title: 'Kuis', days: 2));
    });

    test('today counts as zero days', () {
      final countdown = widgetExamCountdown(
        now: now,
        exams: [
          (course: 'Basdat', title: 'Submit', deadline: DateTime(2026, 10, 27, 23, 59)),
        ],
      );
      expect(countdown!.days, 0);
    });

    test('a deadline that passed never shows a negative count', () {
      expect(
        widgetExamCountdown(
          now: now,
          exams: [
            (course: 'Basdat', title: 'Lama', deadline: DateTime(2026, 10, 20)),
          ],
        ),
        isNull,
      );
      expect(
        widgetExamCountdown(now: now, exams: const []),
        isNull,
      );
    });
  });
}
