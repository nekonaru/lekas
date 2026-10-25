import 'package:drift/drift.dart';

import 'models.dart';

part 'database.g.dart';

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

class TaskTags extends Table {
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
