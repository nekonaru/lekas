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

  @override
  String get reminderIn7Days => 'Deadline in 7 days';

  @override
  String get reminderIn3Days => 'Deadline in 3 days';

  @override
  String get reminderIn1Day => 'Deadline tomorrow';

  @override
  String get reminderIn3Hours => 'Deadline in 3 hours';

  @override
  String get reminderIn30Minutes => 'Deadline in 30 minutes';

  @override
  String get reminderSnoozed => 'Reminder snoozed for 1 hour';

  @override
  String get testNotificationTitle => 'Reminder test';

  @override
  String get testNotificationBody => 'If you can read this, reminders work.';

  @override
  String get testNotification => 'Test notification in 1 minute';

  @override
  String get notifPermission => 'Notification permission';

  @override
  String get exactAlarmPermission => 'Exact alarm permission';

  @override
  String get batteryOptimization => 'Battery optimization';

  @override
  String get statusGranted => 'Granted';

  @override
  String get statusDenied => 'Denied';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get openSystemSettings => 'Open system settings';

  @override
  String get testHistory => 'Test history';

  @override
  String get batteryGuide =>
      'Some brands such as Xiaomi, Oppo, Realme and Samsung hold back background notifications. Turn battery optimization off for Lekas so reminders always arrive.';

  @override
  String get reminderCheckHint =>
      'Run the test below and check whether the notification arrives within a minute.';

  @override
  String get permissionExplain =>
      'Lekas needs notification permission so deadline reminders reach your phone.';

  @override
  String get allow => 'Allow';

  @override
  String get notNow => 'Not now';

  @override
  String get backupTitle => 'Backup Data';

  @override
  String exportedTo(String path) {
    return 'Exported to: $path';
  }

  @override
  String importedTasks(int count) {
    return 'Imported: $count tasks';
  }

  @override
  String get autoBackupFolder => 'Pick Auto Backup Folder';

  @override
  String get autoBackupFolderHint => 'For automatic weekly backups';

  @override
  String folderPicked(String path) {
    return 'Folder: $path';
  }

  @override
  String get shareAsTextTitle => 'Share as Text';

  @override
  String get shareAsTextBody => 'Share tasks or a weekly list to WhatsApp.';

  @override
  String get taskDependenciesTitle => 'Task Dependencies';

  @override
  String get taskDependenciesBody => 'Tasks waiting for other tasks to finish.';

  @override
  String get importScheduleOcrTitle => 'Import Schedule from Screenshot';

  @override
  String get importScheduleOcrBody =>
      'Import your course schedule from a screenshot or portal text.';

  @override
  String get weeklyLoadMapTitle => 'Weekly Load Map';

  @override
  String get weeklyLoadMapBody =>
      'Weekly load map and effective hours are available.';

  @override
  String get projectMilestoneTitle => 'Projects and Milestones';

  @override
  String get projectMilestoneBody =>
      'Project management with milestones and a countdown plan.';

  @override
  String get freeTimeSuggestionTitle => 'Free Time Suggestions';

  @override
  String get freeTimeSuggestionBody =>
      'Time gap suggestions for focused study.';

  @override
  String get gradeSimulatorTitle => 'Grade Simulator';

  @override
  String get gradeSimulatorBody => '\"What if\" grade simulator.';

  @override
  String get examStudyPlanTitle => 'Exam Study Plan';

  @override
  String get examStudyPlanBody => 'Automatic study plan for exams.';

  @override
  String get taskListTitle => 'Task List';

  @override
  String get taskListBody => 'Task list.';

  @override
  String get timerFocusTitle => 'Focus Timer';

  @override
  String get timerFocusBody => '25/5 minute focus timer (Pomodoro).';

  @override
  String get encryptedBackupTitle => 'Encrypted Backup';

  @override
  String get enableBackupEncryption => 'Enable Backup Encryption';

  @override
  String get backupEncryptionMethod => 'AES-GCM with a password';

  @override
  String get passwordWarning => 'Warning';

  @override
  String get passwordLostWarning =>
      'A lost password means the backup cannot be opened.';

  @override
  String get voiceQuickAddTitle => 'Voice Quick Add';

  @override
  String get voiceQuickAddHint => 'Tap the microphone to speak a task';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get defaultChecklistTitle => 'Default Checklist per Course';

  @override
  String get checklistLaptop => 'Laptop';

  @override
  String get checklistLanCable => 'LAN Cable';

  @override
  String get checklistPrintReport => 'Printed Lab Report';

  @override
  String get demoModeTitle => 'Demo Mode';

  @override
  String get trySampleData => 'Try with Sample Data';

  @override
  String get trySampleDataSubtitle => '3 courses, 8 tasks, sample schedule';

  @override
  String get deleteSampleData => 'Delete Sample Data';

  @override
  String get deleteSampleDataSubtitle => 'Delete all sample data';

  @override
  String get fullCalendarTitle => 'Full Calendar';

  @override
  String get tabMonth => 'Month';

  @override
  String get tabWeek => 'Week';

  @override
  String get tabAgenda => 'Agenda';

  @override
  String get monthView => 'Month view';

  @override
  String get weekView => 'Week view';

  @override
  String get agendaView => 'Chronological agenda';

  @override
  String get appLockTitle => 'App Lock';

  @override
  String get enableAppLock => 'Enable App Lock';

  @override
  String get appLockMethod => 'Fingerprint or PIN';

  @override
  String get schoolModeTheme => 'High School Mode Theme';

  @override
  String get schoolModeThemeSubtitle => 'Switch the wording to high school';

  @override
  String get iconShortcutsTitle => 'Icon Shortcuts and Quick Settings';

  @override
  String get appIconShortcut => 'App Icon Shortcut';

  @override
  String get appIconShortcutSubtitle =>
      'Long press the launcher icon: Add Task, Today, Inbox';

  @override
  String get quickSettingsTile => 'Quick Settings Tile';

  @override
  String get quickSettingsTileSubtitle =>
      'One tap from the notification shade opens Quick Add';

  @override
  String get optionalPersistentNotification =>
      'Optional Persistent Notification';

  @override
  String get optionalPersistentNotificationSubtitle =>
      'Quick typing column (off by default)';

  @override
  String get globalQuickLinksTitle => 'Global Quick Links';

  @override
  String get quickLinkSiakad => 'SIAKAD';

  @override
  String get quickLinkELearning => 'Campus E-Learning';

  @override
  String get quickLinkLibrary => 'Library';

  @override
  String get simpleRecurringTasksTitle => 'Simple Recurring Tasks';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatDailySubtitle => 'Every day';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatWeeklySubtitle => 'A specific day every week';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatMonthlySubtitle => 'A specific date every month';

  @override
  String get duplicateDetectionTitle => 'Duplicate Detection';

  @override
  String get duplicateDetectionItemSubtitle => 'Duplicate check for this task';

  @override
  String get semesterStatsTitle => 'Semester Statistics and Recap';

  @override
  String get onTimePercentage => 'On-Time Percentage';

  @override
  String get busiestCourse => 'Busiest Course';

  @override
  String get attendanceRecap => 'Attendance Recap';

  @override
  String get weeklyTrend => 'Weekly Trend';

  @override
  String get exportImagePdfTitle => 'Export Image and PDF';

  @override
  String get exportWeekSchedule => 'Export Week Schedule';

  @override
  String get exportWeekScheduleSubtitle => 'Image of this week\'s schedule';

  @override
  String get exportTaskList => 'Export Task List';

  @override
  String get exportTaskListSubtitle => 'Image of this week\'s task list';

  @override
  String get exportGradeRecap => 'Export Grade Recap';

  @override
  String get exportGradeRecapSubtitle => 'PDF grade recap per course';

  @override
  String get exportDeadlineHistory => 'Export Deadline History';

  @override
  String get exportDeadlineHistorySubtitle => 'PDF proof of deadline changes';

  @override
  String get nonCourseSpaceTitle => 'Non-Course Spaces';

  @override
  String get orgSpace => 'Organization';

  @override
  String get orgSpaceSubtitle => 'Campus organization';

  @override
  String get projectSpace => 'Project';

  @override
  String get projectSpaceSubtitle => 'Campus project';

  @override
  String get personalSpace => 'Personal';

  @override
  String get personalSpaceSubtitle => 'Personal activities';

  @override
  String get otherSpace => 'Others';

  @override
  String get otherSpaceSubtitle => 'Other spaces';

  @override
  String get advancedWidgetsTitle => 'Advanced Widgets';

  @override
  String get widgetTaskListSubtitle => '3-6 rows with checkboxes';

  @override
  String get widgetTodayClasses => 'Today\'s Classes';

  @override
  String get widgetTodayClassesSubtitle => 'Short schedule';

  @override
  String get widgetExamCountdown => 'Exam Countdown';

  @override
  String get widgetExamCountdownSubtitle => 'Countdown to the next exam';

  @override
  String get widgetTodayFocus => 'Today\'s Focus';

  @override
  String get widgetTodayFocusSubtitle => 'Three focus tasks with checkboxes';

  @override
  String get todayFocusTitle => 'Today\'s Focus';

  @override
  String get ocrScreenshotTitle => 'Screenshot OCR';

  @override
  String get chooseScreenshot => 'Choose Screenshot';

  @override
  String get chooseScreenshotSubtitle => 'Pick an image to extract its text';

  @override
  String extractedFile(String path) {
    return 'Extracted: $path';
  }

  @override
  String get ocrLimitations => 'OCR Limitations';

  @override
  String get ocrLimitationsSubtitle =>
      'OCR results on handwriting or tilted photos will be poor.';

  @override
  String get gradePredictionTitle => 'Grade Prediction';

  @override
  String get noGradeComponents => 'No grade components yet.';

  @override
  String weightPercentLabel(String percent) {
    return 'Weight: $percent%';
  }

  @override
  String get autoBackupTitle => 'Automatic Backup';

  @override
  String get weeklyBackup => 'Weekly Backup';

  @override
  String get weeklyBackupSubtitle => 'Automatic backup to the chosen folder';

  @override
  String backupFolderPicked(String path) {
    return 'Backup folder: $path';
  }

  @override
  String get keepLast4Backups => 'Keep the Last 4 Backups';

  @override
  String get keepLast4BackupsSubtitle =>
      'Older backups are deleted automatically';

  @override
  String get warnOlderThan14Days => 'Warn When Older Than 14 Days';

  @override
  String get warnOlderThan14DaysSubtitle =>
      'Warn when the last backup is older than 14 days';

  @override
  String get deadlineHistoryTitle => 'Deadline History';

  @override
  String get emptyDeadlineHistory => 'No deadline changes yet.';

  @override
  String deadlineChangeLabel(String oldValue, String newValue) {
    return '$oldValue → $newValue';
  }

  @override
  String get mergeImportTitle => 'Import and Merge';

  @override
  String get importAndMergeBackup => 'Import and Merge Backup';

  @override
  String get importAndMergeBackupSubtitle =>
      'Merge data from a backup with the current data';

  @override
  String mergedTasks(int count) {
    return 'Merged: $count tasks';
  }

  @override
  String actionFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get multiLineQuickAddTitle => 'Multi-Line Quick Add';

  @override
  String get pasteMultipleLinesLabel =>
      'Paste several lines (one line = one task)';

  @override
  String tasksWillBeCreated(int count) {
    return '$count tasks will be created';
  }

  @override
  String get createTasks => 'Create Tasks';

  @override
  String get emptyTrash => 'Trash is empty.';

  @override
  String deletedAtLabel(String date) {
    return 'Deleted: $date';
  }

  @override
  String get attachmentsTitle => 'Attachments';

  @override
  String get classContactsLinksTitle => 'Class Contacts and Links';

  @override
  String get lecturerLabel => 'Lecturer / Teacher';

  @override
  String get roomLabel => 'Room';

  @override
  String get classLinkLabel => 'Class Link';

  @override
  String get openLecturerWhatsApp => 'Open Lecturer WhatsApp';

  @override
  String get copyRoomNumber => 'Copy Room Number';

  @override
  String get examStudyMaterialsTitle => 'Exams and Study Materials';

  @override
  String get noExamsYet => 'No exams yet.';

  @override
  String daysRemaining(int days) {
    return '$days days left';
  }

  @override
  String get examNoDeadline => 'Someday';

  @override
  String get quizLabel => 'Quiz';

  @override
  String get midtermLabel => 'Midterm';

  @override
  String get finalExamLabel => 'Final';

  @override
  String get morningNightSummaryTitle => 'Morning and Night Summary';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get todayTasksLabel => 'Today\'s tasks';

  @override
  String get tomorrowTasksLabel => 'Tomorrow\'s tasks';

  @override
  String get overdueTasksLabel => 'Overdue tasks';

  @override
  String get summaryScheduleNote =>
      'Morning summary sent at 07:00\nNight wrap-up sent at 20:30';

  @override
  String get searchFilterTitle => 'Search and Filter';

  @override
  String get searchTitleOrNotesLabel => 'Search title or notes';

  @override
  String get filterLabel => 'Filter';

  @override
  String get filterSubtitle => 'Space, type, status';

  @override
  String get changeSemesterTitle => 'Change Semester';

  @override
  String get newSemester => 'New Semester';

  @override
  String get semesterPeriodExample => 'Example: Even 2026/2027';

  @override
  String get unfinishedTasksOptionsLabel =>
      'Choose an option for unfinished tasks:';

  @override
  String get keepInArchive => 'Leave in archive';

  @override
  String get moveToNewSpace => 'Move to a new space';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get createNewSemester => 'Create New Semester';

  @override
  String get snoozeReminderTitle => 'Snooze Reminder';

  @override
  String get pickSnoozeTimeLabel => 'Pick a snooze time:';

  @override
  String get oneHourLabel => '1 hour';

  @override
  String get tonight7pmLabel => 'Tonight 19:00';

  @override
  String get tomorrow7amLabel => 'Tomorrow 07:00';

  @override
  String get weekendLabel => 'Weekend';

  @override
  String get pickTimeLabel => 'Pick time';

  @override
  String get meetingNotesTitle => 'Meeting Notes';

  @override
  String get noteTitleLabel => 'Note title';

  @override
  String get noteBodyLabel => 'Note body';

  @override
  String get noMeetingNotesYet => 'No meeting notes yet.';

  @override
  String get untitledNote => 'Untitled';

  @override
  String get submissionMethodTitle => 'Submission Method';

  @override
  String get submissionMethodLabel => 'Submission method';

  @override
  String get submitMethodPaper => 'Paper / Hard Copy';

  @override
  String get othersLabel => 'Others';

  @override
  String get submitTargetLabel => 'Destination (email, LMS class, room)';

  @override
  String get filenamePatternLabel => 'File Name Pattern';

  @override
  String componentWeightTitle(String spaceName) {
    return 'Component Weight - $spaceName';
  }

  @override
  String get weightPercentFieldLabel => 'Weight (%)';

  @override
  String weightTotalMustBe100(String total) {
    return 'Weight total: $total%, must be 100%';
  }

  @override
  String get assignmentLabel => 'Assignment';

  @override
  String get attendanceLabel => 'Attendance';

  @override
  String get subtasksTitle => 'Subtasks';

  @override
  String get noSubtasksYet => 'No subtasks yet.';

  @override
  String get editSubtaskTitle => 'Edit Subtask';

  @override
  String get personalTargetTitle => 'Personal Target';

  @override
  String get targetCompletionDate => 'Target Completion';

  @override
  String get notSetYet => 'Not set yet';

  @override
  String get attendanceTitle => 'Attendance';

  @override
  String get presentLabel => 'Present';

  @override
  String get remainingAbsenceQuota => 'Remaining Absence Quota';

  @override
  String get markLabel => 'Mark';

  @override
  String get absentLabel => 'Absent';

  @override
  String get excusedLabel => 'Excused';

  @override
  String get sickLabel => 'Sick';

  @override
  String get shareIntakeTitle => 'Tasks from Sharing';

  @override
  String get shareIntakeHint =>
      'Check the sentences you want as tasks, then correct them with the chips.';

  @override
  String get shareNoCandidates =>
      'No matching sentence. Save as a single task.';

  @override
  String get saveSelected => 'Save Checked';

  @override
  String savedTasksCount(int count) {
    return 'Saved: $count tasks';
  }

  @override
  String get savedViewsTitle => 'Saved Views';

  @override
  String get saveViewTitle => 'Save View';

  @override
  String get viewNameLabel => 'View name';

  @override
  String get overdueTaskReminderTitle => 'Overdue Task Reminder';

  @override
  String get noOverdueTasks => 'No overdue tasks.';

  @override
  String overdueDaysLabel(int days, String deadline) {
    return '$days days late. Deadline: $deadline';
  }

  @override
  String get resetDeadlineLabel => 'Reset';

  @override
  String priorityBadgeLabel(String value) {
    return 'Priority $value';
  }

  @override
  String deadlineAtLabel(String value) {
    return 'Deadline: $value';
  }

  @override
  String estimateMinutesLabel(int minutes) {
    return 'Estimate: $minutes minutes';
  }

  @override
  String subtaskProgressLabel(int done, int total) {
    return 'Subtasks ($done/$total)';
  }

  @override
  String get addLabel => 'Add';

  @override
  String get reopenTooltip => 'Reopen';

  @override
  String get markDoneTooltip => 'Mark as done';

  @override
  String get addSubtaskTitle => 'Add Subtask';

  @override
  String get subtaskTitleHint => 'Subtask title';

  @override
  String get statusTodo => 'To do';

  @override
  String get statusDoing => 'In progress';

  @override
  String get statusRevision => 'Revision';

  @override
  String get taskModeGroup => 'Group';

  @override
  String get emptyInboxNote => 'No notes yet.';

  @override
  String get noNotesLabel => 'No notes';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get quickAddMenuLabel => 'Quick Add Task';

  @override
  String get smartSnoozeLabel => 'Smart Snooze';

  @override
  String get morningNightSummaryShort => 'Morning/Night Summary';

  @override
  String get overdueTasksMenuLabel => 'Overdue Tasks';

  @override
  String get exportBackupShort => 'Export Backup';

  @override
  String get importBackupShort => 'Import Backup';

  @override
  String get emptySpaces => 'No spaces (courses) yet.';

  @override
  String spaceCodeValue(String value) {
    return 'Code: $value';
  }

  @override
  String spaceLevelValue(String value) {
    return 'Level: $value';
  }

  @override
  String spacePeriodValue(String value) {
    return 'Semester: $value';
  }

  @override
  String spaceSksValue(String value) {
    return 'Credits: $value';
  }

  @override
  String spaceTargetGradeValue(String value) {
    return 'Target grade: $value';
  }

  @override
  String get classScheduleTitle => 'Class Schedule';

  @override
  String get tasksMenuLabel => 'Tasks';

  @override
  String get componentWeightLabel => 'Component Weight';

  @override
  String get defaultChecklistShort => 'Default Checklist';

  @override
  String get startTimeLabel => 'Start time (HH:MM)';

  @override
  String get endTimeLabel => 'End time (HH:MM)';

  @override
  String get emptyClassSchedule => 'No class schedule yet.';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get welcomeSubtitle =>
      'Lekas helps you record tasks and course deadlines.';

  @override
  String get enterFirstCourseSubtitle => 'Enter your first course name.';

  @override
  String get firstCourseFallback => 'First Course';

  @override
  String get allLabel => 'All';

  @override
  String get typeLabReport => 'Lab report';

  @override
  String get typePaper => 'Paper';

  @override
  String get typePresentation => 'Presentation';

  @override
  String get emptyTaskList => 'No tasks yet.';

  @override
  String get typeLabel => 'Type';

  @override
  String get attachmentFileMissing => 'The file is no longer on this device.';

  @override
  String get openLabel => 'Open';

  @override
  String get noDuplicateFound => 'No duplicate found for this task.';

  @override
  String get saved => 'Saved';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get noStatsDataYet => 'No data for this statistic yet.';

  @override
  String attendanceSavedToday(String status) {
    return 'Attendance recorded for today: $status';
  }

  @override
  String get featureNotAvailable => 'This feature is not available yet.';

  @override
  String get enabledLabel => 'Enabled';

  @override
  String get disabledLabel => 'Disabled';

  @override
  String spaceCreated(String name) {
    return 'Space created: $name';
  }

  @override
  String tasksProcessed(int count) {
    return '$count tasks processed';
  }

  @override
  String get deleted => 'Deleted';

  @override
  String get sampleDataRemoved => 'Sample data removed';
}
