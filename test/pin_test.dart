import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/core/components/task_section.dart';
import 'package:lekas/l10n/app_localizations_en.dart';

void main() {
  group('pin (design section 5.9)', () {
    test('the pinned group comes before every other section', () {
      expect(TodaySection.values.first, TodaySection.pinned);
    });

    test('the pinned group has its own title and icon', () {
      final section = TaskSection(
        section: TodaySection.pinned,
        tasks: const [],
        now: DateTime(2026, 10, 26),
        locale: 'en',
      );
      expect(section.title(AppLocalizationsEn()), 'Pinned');
      expect(section.icon, Icons.push_pin);
    });
  });
}
