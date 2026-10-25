// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint, unused_element

abstract class $AppDatabase extends GeneratedDatabase {
  $AppDatabase(QueryExecutor e) : super(e);

  $SpacesTable get spaces;
  $SpaceAliasesTable get spaceAliases;
  $SpaceMetaTable get spaceMeta;
  $TasksTable get tasks;
  $SubtasksTable get subtasks;
  $ClassSlotsTable get classSlots;
  $TagsTable get tags;
  $TaskTagsTable get taskTags;
  $AttachmentsTable get attachments;
  $RemindersTable get reminders;
  $TaskEventsTable get taskEvents;
  $FocusSessionsTable get focusSessions;
  $TaskTemplatesTable get taskTemplates;
  $ParserPrefsTable get parserPrefs;
  $SettingsTable get settings;
  $TaskDepsTable get taskDeps;
  $ClassExceptionsTable get classExceptions;
  $SpaceItemsTable get spaceItems;
  $QuickLinksTable get quickLinks;
  $ClassNotesTable get classNotes;
  $DiagnosticsTable get diagnostics;
  $GradeComponentsTable get gradeComponents;
  $SavedFiltersTable get savedFilters;
}

// ---------- Spaces ----------

class $SpacesTable extends Spaces with TableInfo<$SpacesTable, Space> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpacesTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    code,
    color,
    level,
    period,
    sks,
    targetGrade,
    finalGrade,
    kind,
    archived,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Space> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- SpaceAliases ----------

class $SpaceAliasesTable extends SpaceAliases
    with TableInfo<$SpaceAliasesTable, SpaceAlias> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpaceAliasesTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [spaceId, alias];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'space_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpaceAlias> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- SpaceMeta ----------

class $SpaceMetaTable extends SpaceMeta
    with TableInfo<$SpaceMetaTable, SpaceMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpaceMetaTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [spaceId, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'space_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpaceMetaData> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- Tasks ----------

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    title,
    notes,
    type,
    deadline,
    startAt,
    priority,
    status,
    weightPercent,
    scoreObtained,
    estimateMinutes,
    isGroup,
    pinned,
    inbox,
    targetAt,
    submitMethod,
    submitTarget,
    filenamePattern,
    submittedAt,
    focusDate,
    parentId,
    repeatKind,
    repeatEvery,
    sourceText,
    createdAt,
    completedAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- Subtasks ----------

class $SubtasksTable extends Subtasks with TableInfo<$SubtasksTable, Subtask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtasksTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    title,
    done,
    sortOrder,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subtask> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- ClassSlots ----------

class $ClassSlotsTable extends ClassSlots
    with TableInfo<$ClassSlotsTable, ClassSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassSlotsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    weekday,
    startMin,
    endMin,
    room,
    kind,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassSlot> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- Tags ----------

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- TaskTags ----------

class $TaskTagsTable extends TaskTags with TableInfo<$TaskTagsTable, TaskTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTagsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [taskId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskTag> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- Attachments ----------

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    kind,
    pathOrUrl,
    mime,
    sizeBytes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- Reminders ----------

class $RemindersTable extends Reminders with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    classSlotId,
    fireAt,
    kind,
    notifId,
    fired,
    ackedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- TaskEvents ----------

class $TaskEventsTable extends TaskEvents with TableInfo<$TaskEventsTable, TaskEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskEventsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    kind,
    oldValue,
    newValue,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskEvent> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- FocusSessions ----------

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [id, taskId, startedAt, durationSec];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSession> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- TaskTemplates ----------

class $TaskTemplatesTable extends TaskTemplates
    with TableInfo<$TaskTemplatesTable, TaskTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTemplatesTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    estimateMinutes,
    subtasksJson,
    milestonesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskTemplate> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- ParserPrefs ----------

class $ParserPrefsTable extends ParserPrefs
    with TableInfo<$ParserPrefsTable, ParserPref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParserPrefsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parser_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParserPref> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- Settings ----------

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- TaskDeps ----------

class $TaskDepsTable extends TaskDeps with TableInfo<$TaskDepsTable, TaskDep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskDepsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [taskId, dependsOn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_deps';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskDep> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- ClassExceptions ----------

class $ClassExceptionsTable extends ClassExceptions
    with TableInfo<$ClassExceptionsTable, ClassException> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassExceptionsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    classSlotId,
    date,
    kind,
    newStartMin,
    newEndMin,
    newRoom,
    note,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_exceptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassException> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- SpaceItems ----------

class $SpaceItemsTable extends SpaceItems
    with TableInfo<$SpaceItemsTable, SpaceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpaceItemsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    title,
    sortOrder,
    checkedOn,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'space_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpaceItem> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- QuickLinks ----------

class $QuickLinksTable extends QuickLinks
    with TableInfo<$QuickLinksTable, QuickLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuickLinksTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    url,
    sortOrder,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quick_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuickLink> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- ClassNotes ----------

class $ClassNotesTable extends ClassNotes
    with TableInfo<$ClassNotesTable, ClassNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassNotesTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    meetingNo,
    date,
    title,
    body,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassNote> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- Diagnostics ----------

class $DiagnosticsTable extends Diagnostics
    with TableInfo<$DiagnosticsTable, Diagnostic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosticsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [id, kind, createdAt, result, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnostics';
  @override
  VerificationContext validateIntegrity(
    Insertable<Diagnostic> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- GradeComponents ----------

class $GradeComponentsTable extends GradeComponents
    with TableInfo<$GradeComponentsTable, GradeComponent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GradeComponentsTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [spaceId, key, weightPercent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grade_components';
  @override
  VerificationContext validateIntegrity(
    Insertable<GradeComponent> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- SavedFilters ----------

class $SavedFiltersTable extends SavedFilters
    with TableInfo<$SavedFiltersTable, SavedFilter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedFiltersTable(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    queryJson,
    sortOrder,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_filters';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedFilter> instance, {
    bool isInserting = false,
  }) => VerificationContext();
}

// ---------- Internal database ----------

class _$AppDatabase extends $AppDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);

  @override
  $SpacesTable get spaces => $SpacesTable(this);
  @override
  $SpaceAliasesTable get spaceAliases => $SpaceAliasesTable(this);
  @override
  $SpaceMetaTable get spaceMeta => $SpaceMetaTable(this);
  @override
  $TasksTable get tasks => $TasksTable(this);
  @override
  $SubtasksTable get subtasks => $SubtasksTable(this);
  @override
  $ClassSlotsTable get classSlots => $ClassSlotsTable(this);
  @override
  $TagsTable get tags => $TagsTable(this);
  @override
  $TaskTagsTable get taskTags => $TaskTagsTable(this);
  @override
  $AttachmentsTable get attachments => $AttachmentsTable(this);
  @override
  $RemindersTable get reminders => $RemindersTable(this);
  @override
  $TaskEventsTable get taskEvents => $TaskEventsTable(this);
  @override
  $FocusSessionsTable get focusSessions => $FocusSessionsTable(this);
  @override
  $TaskTemplatesTable get taskTemplates => $TaskTemplatesTable(this);
  @override
  $ParserPrefsTable get parserPrefs => $ParserPrefsTable(this);
  @override
  $SettingsTable get settings => $SettingsTable(this);
  @override
  $TaskDepsTable get taskDeps => $TaskDepsTable(this);
  @override
  $ClassExceptionsTable get classExceptions => $ClassExceptionsTable(this);
  @override
  $SpaceItemsTable get spaceItems => $SpaceItemsTable(this);
  @override
  $QuickLinksTable get quickLinks => $QuickLinksTable(this);
  @override
  $ClassNotesTable get classNotes => $ClassNotesTable(this);
  @override
  $DiagnosticsTable get diagnostics => $DiagnosticsTable(this);
  @override
  $GradeComponentsTable get gradeComponents => $GradeComponentsTable(this);
  @override
  $SavedFiltersTable get savedFilters => $SavedFiltersTable(this);

  @override
  int get schemaVersion => 1;
}
