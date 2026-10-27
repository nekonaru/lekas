import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'database.dart';
import 'space_repository.dart';
import 'task_repository.dart';
import 'subtask_repository.dart';
import 'tag_repository.dart';
import 'attendance_repository.dart';
import 'class_slot_repository.dart';
import 'reminder_repository.dart';
import 'settings_repository.dart';
import 'attachment_repository.dart';
import 'task_event_repository.dart';
import 'focus_session_repository.dart';
import 'task_template_repository.dart';
import 'class_exception_repository.dart';
import 'space_item_repository.dart';
import 'quick_link_repository.dart';
import 'class_note_repository.dart';
import 'diagnostic_repository.dart';
import 'grade_component_repository.dart';
import 'saved_filter_repository.dart';
import 'task_dep_repository.dart';
import 'backup_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(LazyDatabase(_openNativeDatabase));
  ref.onDispose(db.close);
  return db;
});

/// Opens the same database outside the provider tree. Used by background
/// isolates such as the boot receiver and notification action buttons.
Future<AppDatabase> openAppDatabase() async {
  return AppDatabase(LazyDatabase(_openNativeDatabase));
}

Future<QueryExecutor> _openNativeDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'lekas.sqlite'));
  return NativeDatabase.createInBackground(file);
}

final spaceRepositoryProvider = Provider<SpaceRepository>((ref) {
  return SpaceRepository(ref.read(appDatabaseProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(appDatabaseProvider));
});

final subtaskRepositoryProvider = Provider<SubtaskRepository>((ref) {
  return SubtaskRepository(ref.read(appDatabaseProvider));
});

/// Free tags (design section 5.9).
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository(ref.read(appDatabaseProvider));
});

/// Attendance records and the absence quota (design section 5.19).
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.read(appDatabaseProvider));
});

/// The screen a notification action should open once the app is up, for
/// example the focus picker behind the morning summary button (design
/// section 5.24). Cleared as soon as the route has been pushed.
final pendingNotificationRouteProvider = StateProvider<String?>((ref) => null);

final classSlotRepositoryProvider = Provider<ClassSlotRepository>((ref) {
  return ClassSlotRepository(ref.read(appDatabaseProvider));
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository(ref.read(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.read(appDatabaseProvider));
});

final attachmentRepositoryProvider = Provider<AttachmentRepository>((ref) {
  return AttachmentRepository(ref.read(appDatabaseProvider));
});

final taskEventRepositoryProvider = Provider<TaskEventRepository>((ref) {
  return TaskEventRepository(ref.read(appDatabaseProvider));
});

final focusSessionRepositoryProvider = Provider<FocusSessionRepository>((ref) {
  return FocusSessionRepository(ref.read(appDatabaseProvider));
});

final taskTemplateRepositoryProvider = Provider<TaskTemplateRepository>((ref) {
  return TaskTemplateRepository(ref.read(appDatabaseProvider));
});

final classExceptionRepositoryProvider = Provider<ClassExceptionRepository>((ref) {
  return ClassExceptionRepository(ref.read(appDatabaseProvider));
});

final spaceItemRepositoryProvider = Provider<SpaceItemRepository>((ref) {
  return SpaceItemRepository(ref.read(appDatabaseProvider));
});

final quickLinkRepositoryProvider = Provider<QuickLinkRepository>((ref) {
  return QuickLinkRepository(ref.read(appDatabaseProvider));
});

final classNoteRepositoryProvider = Provider<ClassNoteRepository>((ref) {
  return ClassNoteRepository(ref.read(appDatabaseProvider));
});

final diagnosticRepositoryProvider = Provider<DiagnosticRepository>((ref) {
  return DiagnosticRepository(ref.read(appDatabaseProvider));
});

final gradeComponentRepositoryProvider = Provider<GradeComponentRepository>((ref) {
  return GradeComponentRepository(ref.read(appDatabaseProvider));
});

final savedFilterRepositoryProvider = Provider<SavedFilterRepository>((ref) {
  return SavedFilterRepository(ref.read(appDatabaseProvider));
});

final taskDepRepositoryProvider = Provider<TaskDepRepository>((ref) {
  return TaskDepRepository(ref.read(appDatabaseProvider));
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.read(appDatabaseProvider));
});

final onboardedProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  final value = await repo.get('onboarded');
  return value == 'true';
});

/// Display language, default Indonesian (design section 8.8).
final localeProvider = FutureProvider<Locale>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return Locale(await repo.getLanguage());
});

/// Theme preference: system, light or dark. Default follows the system.
final themeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  switch (await repo.get('theme_mode')) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});
