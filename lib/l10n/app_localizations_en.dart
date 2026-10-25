// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get todayTitle => 'Today';

  @override
  String tasksCount(int count) {
    return '$count tasks';
  }

  @override
  String get inboxTitle => 'Inbox';

  @override
  String get spacesTitle => 'Spaces';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get quickAddHint => 'Add task quickly...';

  @override
  String get emptyToday =>
      'No tasks today. Enjoy your time, or plan for tomorrow?';

  @override
  String get undo => 'Undo';

  @override
  String get done => 'Done';

  @override
  String get snooze1h => 'Snooze 1 hour';

  @override
  String morningSummary(int classes, int tasks) {
    return 'Today: $classes classes, $tasks tasks.';
  }

  @override
  String get addSpace => 'Add Space';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get spaceName => 'Space name';

  @override
  String get spaceCode => 'Code (optional)';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get taskNotes => 'Notes';

  @override
  String get taskContainer => 'Space';

  @override
  String get taskDeadline => 'Deadline';

  @override
  String get taskPriority => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get pickDate => 'Pick date';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get taskDetail => 'Task Detail';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get exportBackup => 'Export Backup JSON';

  @override
  String get importBackup => 'Import Backup JSON';

  @override
  String get checkReminder => 'Check Reminder';

  @override
  String get welcome => 'Welcome';

  @override
  String get addFirstSpace => 'Add First Space';

  @override
  String get start => 'Start';

  @override
  String get back => 'Back';

  @override
  String get saveContinue => 'Save & Continue';

  @override
  String get finish => 'Finish';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get english => 'English';

  @override
  String get chooseLevel => 'Choose Level';

  @override
  String get college => 'College';

  @override
  String get school => 'School';

  @override
  String get spaceNameLabel => 'Space Name';

  @override
  String inboxCount(int count) {
    return '$count notes not yet organized.';
  }
}
