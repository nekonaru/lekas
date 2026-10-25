// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get todayTitle => 'Hari Ini';

  @override
  String tasksCount(int count) {
    return '$count tugas';
  }

  @override
  String get inboxTitle => 'Inbox';

  @override
  String get spacesTitle => 'Wadah';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get quickAddHint => 'Tambah tugas cepat...';

  @override
  String get emptyToday =>
      'Belum ada tugas hari ini. Nikmati waktumu, atau rencanakan besok?';

  @override
  String get undo => 'Urungkan';

  @override
  String get done => 'Selesai';

  @override
  String get snooze1h => 'Tunda 1 jam';

  @override
  String morningSummary(int classes, int tasks) {
    return 'Hari ini: $classes kelas, $tasks tugas.';
  }
}
