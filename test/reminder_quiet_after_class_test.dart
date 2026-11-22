import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/reminders/reminder_service.dart';

void main() {
  test('a class ending inside quiet hours waits until 06:05', () {
    final held = DateTime(2026, 11, 20, 22, 30);
    final moved = moveOutOfQuietAfterClass(
      held,
      DateTime(2026, 11, 21, 10),
    );
    expect(moved, DateTime(2026, 11, 21, 6, 5));
    expect(moved.isAfter(held), isTrue);
    expect(isInQuietHours(moved), isFalse);
  });

  test('an early-morning class end moves forward the same day', () {
    final moved = moveOutOfQuietAfterClass(
      DateTime(2026, 11, 20, 5, 30),
      DateTime(2026, 11, 20, 12),
    );
    expect(moved, DateTime(2026, 11, 20, 6, 5));
  });

  test('a class end outside quiet hours is untouched', () {
    final held = DateTime(2026, 11, 20, 9, 30);
    expect(
      moveOutOfQuietAfterClass(held, DateTime(2026, 11, 21, 10)),
      held,
    );
  });

  test('never pushes a reminder past its deadline', () {
    final held = DateTime(2026, 11, 20, 23, 30);
    final moved = moveOutOfQuietAfterClass(
      held,
      DateTime(2026, 11, 21, 5),
    );
    // The class end is still before the early deadline, so it is kept.
    expect(moved.isBefore(DateTime(2026, 11, 21, 5)), isTrue);
  });
}
