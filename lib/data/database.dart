import 'package:drift/drift.dart';

part 'database.g.dart';

/// One tracked course or container. Lookups by id use the primary key;
/// the secondary indexes below cover the filters of the lists (schema 3).
@TableIndex(name: 'idx_spaces_deleted', columns: {#deletedAt})
class Spaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  IntColumn get color => integer()();
  TextColumn get level => text().nullable()();
  TextColumn get period => text().nullable()();
  IntColumn get sks => integer().nullable()();
  TextColumn get targetGrade => text().nullable()();
  TextColumn get finalGrade => text().nullable()();
  TextColumn get kind => text().withDefault(const Constant('course'))();

  /// Attendance (design section 5.19): planned meetings and the absence
  /// limit in percent, both with the campus defaults applied in code.
  IntColumn get totalMeetings => integer().nullable()();
  IntColumn get maxAbsentPercent => integer().nullable()();
  BoolColumn get excusedCountsAbsent => boolean().nullable()();

  /// The optional "mark your attendance" prompt of design section 5.19.
  BoolColumn get attendPrompt => boolean().nullable()();

  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SpaceAliases extends Table {
  TextColumn get spaceId => text().references(Spaces, #id)();
  TextColumn get alias => text()();

  @override
  Set<Column> get primaryKey => {spaceId, alias};
}

class SpaceMeta extends Table {
  TextColumn get spaceId => text().references(Spaces, #id)();
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {spaceId, key};
}

/// Every list screen filters on `deleted_at IS NULL` and then on the
/// deadline, the status or the course, so those four columns are indexed.
@TableIndex(name: 'idx_tasks_deadline', columns: {#deadline})
@TableIndex(name: 'idx_tasks_status', columns: {#status})
@TableIndex(name: 'idx_tasks_space', columns: {#spaceId})
@TableIndex(name: 'idx_tasks_deleted', columns: {#deletedAt})
@TableIndex(name: 'idx_tasks_focus', columns: {#focusDate})
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().nullable().references(Spaces, #id)();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get type => text().nullable()();
  IntColumn get deadline => integer().nullable()();
  IntColumn get startAt => integer().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(1))();
  TextColumn get status => text().withDefault(const Constant('todo'))();
  RealColumn get weightPercent => real().nullable()();
  RealColumn get scoreObtained => real().nullable()();
  IntColumn get estimateMinutes => integer().nullable()();
  BoolColumn get isGroup => boolean().withDefault(const Constant(false))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get inbox => boolean().withDefault(const Constant(false))();
  IntColumn get targetAt => integer().nullable()();
  TextColumn get submitMethod => text().nullable()();
  TextColumn get submitTarget => text().nullable()();
  TextColumn get filenamePattern => text().nullable()();
  IntColumn get submittedAt => integer().nullable()();
  IntColumn get focusDate => integer().nullable()();
  TextColumn get parentId => text().nullable().references(Tasks, #id)();
  TextColumn get repeatKind => text().nullable()();
  IntColumn get repeatEvery => integer().nullable()();
  TextColumn get sourceText => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_subtasks_task', columns: {#taskId})
class Subtasks extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_class_slots_space', columns: {#spaceId})
class ClassSlots extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().references(Spaces, #id)();
  IntColumn get weekday => integer()();
  IntColumn get startMin => integer()();
  IntColumn get endMin => integer()();
  TextColumn get room => text().nullable()();
  TextColumn get kind => text().withDefault(const Constant('lecture'))();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Reverse lookup by tag: the primary key only covers `tag_id` as its
/// second column, so filtering by tag alone needs its own index.
@TableIndex(name: 'idx_task_tags_tag', columns: {#tagId})
class TaskTags extends Table {
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

@TableIndex(name: 'idx_attachments_task', columns: {#taskId})
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get kind => text()();
  TextColumn get pathOrUrl => text()();
  TextColumn get mime => text().nullable()();
  IntColumn get sizeBytes => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Reminders are read per task and scheduled in `fire_at` order on every
/// sync (design section 5.4).
@TableIndex(name: 'idx_reminders_task', columns: {#taskId})
@TableIndex(name: 'idx_reminders_fire', columns: {#fireAt})
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().nullable().references(Tasks, #id)();
  TextColumn get classSlotId => text().nullable().references(ClassSlots, #id)();
  IntColumn get fireAt => integer()();
  TextColumn get kind => text().nullable()();
  IntColumn get notifId => integer()();
  BoolColumn get fired => boolean().withDefault(const Constant(false))();
  IntColumn get ackedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_task_events_task', columns: {#taskId})
class TaskEvents extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get kind => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_focus_sessions_task', columns: {#taskId})
class FocusSessions extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  IntColumn get startedAt => integer()();
  IntColumn get durationSec => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class TaskTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text().nullable()();
  IntColumn get estimateMinutes => integer().nullable()();
  TextColumn get subtasksJson => text().nullable()();
  TextColumn get milestonesJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ParserPrefs extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

class TaskDeps extends Table {
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get dependsOn => text().references(Tasks, #id)();
  @override
  Set<Column> get primaryKey => {taskId, dependsOn};
}

/// Exceptions are read two ways: per slot during the schedule and per
/// calendar day when a holiday clears a class (design section 5.12).
@TableIndex(name: 'idx_class_exceptions_slot', columns: {#classSlotId})
@TableIndex(name: 'idx_class_exceptions_date', columns: {#date})
class ClassExceptions extends Table {
  TextColumn get id => text()();
  TextColumn get classSlotId => text().nullable().references(ClassSlots, #id)();
  TextColumn get date => text()();
  TextColumn get kind => text()();
  IntColumn get newStartMin => integer().nullable()();
  IntColumn get newEndMin => integer().nullable()();
  TextColumn get newRoom => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_space_items_space', columns: {#spaceId})
class SpaceItems extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().references(Spaces, #id)();
  TextColumn get title => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get checkedOn => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class QuickLinks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get url => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_class_notes_space', columns: {#spaceId})
class ClassNotes extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().references(Spaces, #id)();
  IntColumn get meetingNo => integer().nullable()();
  TextColumn get date => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get body => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Diagnostics extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  IntColumn get createdAt => integer()();
  TextColumn get result => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class GradeComponents extends Table {
  TextColumn get spaceId => text().references(Spaces, #id)();
  TextColumn get key => text()();
  RealColumn get weightPercent => real()();

  @override
  Set<Column> get primaryKey => {spaceId, key};
}

class SavedFilters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get queryJson => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One recorded meeting of a class (design section 5.19): `present`,
/// `absent`, `excused` or `sick`, stored per local calendar day.
@TableIndex(name: 'idx_attendance_space_date', columns: {#spaceId, #date})
class Attendance extends Table {
  TextColumn get id => text()();
  TextColumn get spaceId => text().references(Spaces, #id)();
  TextColumn get slotId => text().nullable().references(ClassSlots, #id)();

  /// Local calendar day as `YYYY-MM-DD` (design section 10).
  TextColumn get date => text()();
  TextColumn get status => text()();
  TextColumn get note => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Spaces,
  SpaceAliases,
  SpaceMeta,
  Tasks,
  Subtasks,
  ClassSlots,
  Tags,
  TaskTags,
  Attachments,
  Reminders,
  TaskEvents,
  FocusSessions,
  TaskTemplates,
  ParserPrefs,
  Settings,
  TaskDeps,
  ClassExceptions,
  SpaceItems,
  QuickLinks,
  ClassNotes,
  Diagnostics,
  GradeComponents,
  SavedFilters,
  Attendance,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Attendance and the per course settings of design 5.19.
            await m.createTable(attendance);
            await m.addColumn(spaces, spaces.totalMeetings);
            await m.addColumn(spaces, spaces.maxAbsentPercent);
            await m.addColumn(spaces, spaces.excusedCountsAbsent);
            await m.addColumn(spaces, spaces.attendPrompt);
          }
          if (from < 3) {
            // Secondary indexes for the list, reminder and attendance
            // queries (schema 3). The generated objects carry the exact
            // CREATE INDEX statements.
            await m.createIndex(idxSpacesDeleted);
            await m.createIndex(idxTasksDeadline);
            await m.createIndex(idxTasksStatus);
            await m.createIndex(idxTasksSpace);
            await m.createIndex(idxTasksDeleted);
            await m.createIndex(idxTasksFocus);
            await m.createIndex(idxSubtasksTask);
            await m.createIndex(idxClassSlotsSpace);
            await m.createIndex(idxTaskTagsTag);
            await m.createIndex(idxAttachmentsTask);
            await m.createIndex(idxRemindersTask);
            await m.createIndex(idxRemindersFire);
            await m.createIndex(idxTaskEventsTask);
            await m.createIndex(idxFocusSessionsTask);
            await m.createIndex(idxClassExceptionsSlot);
            await m.createIndex(idxClassExceptionsDate);
            await m.createIndex(idxSpaceItemsSpace);
            await m.createIndex(idxClassNotesSpace);
            await m.createIndex(idxAttendanceSpaceDate);
          }
        },
      );
}
