import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'database.dart';
import 'models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lekas.sqlite'));
    return NativeDatabase.createInBackground(file);
  }));
  ref.onDispose(db.close);
  return db;
});

final spaceRepositoryProvider = Provider<SpaceRepository>((ref) {
  return SpaceRepository(ref.read(appDatabaseProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(appDatabaseProvider));
});

final subtaskRepositoryProvider = Provider<SubtaskRepository>((ref) {
  return SubtaskRepository(ref.read(appDatabaseProvider));
});

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
