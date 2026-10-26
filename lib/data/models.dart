import 'package:drift/drift.dart';

abstract class LekasDataClass extends LekasDataClass {
  @override
  Map<String, dynamic> toJson() => {};
}

class Space extends LekasDataClass {
  final String id;
  final String name;
  final String? code;
  final int color;
  final String? level;
  final String? period;
  final int? sks;
  final String? targetGrade;
  final String? finalGrade;
  final String kind;
  final int totalMeetings;
  final int maxAbsentPercent;
  final bool excusedCountsAbsent;
  final bool attendPrompt;
  final bool isSample;
  final bool archived;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  Space({
    required this.id,
    required this.name,
    this.code,
    required this.color,
    this.level,
    this.period,
    this.sks,
    this.targetGrade,
    this.finalGrade,
    this.kind = 'course',
    this.totalMeetings = 16,
    this.maxAbsentPercent = 25,
    this.excusedCountsAbsent = false,
    this.attendPrompt = false,
    this.isSample = false,
    this.archived = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      if (forInserting || id.isNotEmpty) 'id': id,
      'name': name,
      if (code != null || forInserting) 'code': code,
      'color': color,
      if (level != null || forInserting) 'level': level,
      if (period != null || forInserting) 'period': period,
      if (sks != null || forInserting) 'sks': sks,
      if (targetGrade != null || forInserting) 'target_grade': targetGrade,
      if (finalGrade != null || forInserting) 'final_grade': finalGrade,
      if (forInserting || kind.isNotEmpty) 'kind': kind,
      if (forInserting || totalMeetings != 0) 'total_meetings': totalMeetings,
      if (forInserting || maxAbsentPercent != 0) 'max_absent_percent': maxAbsentPercent,
      if (forInserting) 'excused_counts_absent': excusedCountsAbsent,
      if (forInserting) 'attend_prompt': attendPrompt,
      if (forInserting) 'is_sample': isSample,
      if (forInserting) 'archived': archived,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (deletedAt != null || forInserting) 'deleted_at': deletedAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  Space copyWith({
    String? id,
    String? name,
    String? code,
    int? color,
    String? level,
    String? period,
    int? sks,
    String? targetGrade,
    String? finalGrade,
    String? kind,
    int? totalMeetings,
    int? maxAbsentPercent,
    bool? excusedCountsAbsent,
    bool? attendPrompt,
    bool? isSample,
    bool? archived,
    int? createdAt,
    int? updatedAt,
    int? deletedAt,
  }) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      color: color ?? this.color,
      level: level ?? this.level,
      period: period ?? this.period,
      sks: sks ?? this.sks,
      targetGrade: targetGrade ?? this.targetGrade,
      finalGrade: finalGrade ?? this.finalGrade,
      kind: kind ?? this.kind,
      totalMeetings: totalMeetings ?? this.totalMeetings,
      maxAbsentPercent: maxAbsentPercent ?? this.maxAbsentPercent,
      excusedCountsAbsent: excusedCountsAbsent ?? this.excusedCountsAbsent,
      attendPrompt: attendPrompt ?? this.attendPrompt,
      isSample: isSample ?? this.isSample,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class SpaceAlias extends LekasDataClass {
  final String spaceId;
  final String alias;

  SpaceAlias({required this.spaceId, required this.alias});

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'space_id': spaceId,
      'alias': alias,
    };
  }

  @override
  Value? get $primaryKey => null; // composite key

  SpaceAlias copyWith({String? spaceId, String? alias}) {
    return SpaceAlias(
      spaceId: spaceId ?? this.spaceId,
      alias: alias ?? this.alias,
    );
  }
}

class SpaceMetaData extends LekasDataClass {
  final String spaceId;
  final String key;
  final String? value;

  SpaceMetaData({required this.spaceId, required this.key, this.value});

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'space_id': spaceId,
      'key': key,
      if (value != null || forInserting) 'value': value,
    };
  }

  @override
  Value? get $primaryKey => null; // composite key

  SpaceMetaData copyWith({String? spaceId, String? key, String? value}) {
    return SpaceMetaData(
      spaceId: spaceId ?? this.spaceId,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
}

class Task extends LekasDataClass {
  final String id;
  final String? spaceId;
  final String title;
  final String? notes;
  final String? type;
  final int? deadline;
  final int? startAt;
  final int priority;
  final String status;
  final double? weightPercent;
  final double? scoreObtained;
  final int? estimateMinutes;
  final bool isGroup;
  final bool pinned;
  final bool inbox;
  final int? targetAt;
  final String? submitMethod;
  final String? submitTarget;
  final String? filenamePattern;
  final int? submittedAt;
  final int? focusDate;
  final String? parentId;
  final String? repeatKind;
  final int? repeatEvery;
  final String? sourceText;
  final int createdAt;
  final int? completedAt;
  final int updatedAt;
  final int? deletedAt;

  Task({
    required this.id,
    this.spaceId,
    required this.title,
    this.notes,
    this.type,
    this.deadline,
    this.startAt,
    this.priority = 1,
    this.status = 'todo',
    this.weightPercent,
    this.scoreObtained,
    this.estimateMinutes,
    this.isGroup = false,
    this.pinned = false,
    this.inbox = false,
    this.targetAt,
    this.submitMethod,
    this.submitTarget,
    this.filenamePattern,
    this.submittedAt,
    this.focusDate,
    this.parentId,
    this.repeatKind,
    this.repeatEvery,
    this.sourceText,
    required this.createdAt,
    this.completedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      if (forInserting || id.isNotEmpty) 'id': id,
      if (spaceId != null || forInserting) 'space_id': spaceId,
      'title': title,
      if (notes != null || forInserting) 'notes': notes,
      if (type != null || forInserting) 'type': type,
      if (deadline != null || forInserting) 'deadline': deadline,
      if (startAt != null || forInserting) 'start_at': startAt,
      if (forInserting || priority != 0) 'priority': priority,
      if (forInserting || status.isNotEmpty) 'status': status,
      if (weightPercent != null || forInserting) 'weight_percent': weightPercent,
      if (scoreObtained != null || forInserting) 'score_obtained': scoreObtained,
      if (estimateMinutes != null || forInserting) 'estimate_minutes': estimateMinutes,
      if (forInserting) 'is_group': isGroup,
      if (forInserting) 'pinned': pinned,
      if (forInserting) 'inbox': inbox,
      if (targetAt != null || forInserting) 'target_at': targetAt,
      if (submitMethod != null || forInserting) 'submit_method': submitMethod,
      if (submitTarget != null || forInserting) 'submit_target': submitTarget,
      if (filenamePattern != null || forInserting) 'filename_pattern': filenamePattern,
      if (submittedAt != null || forInserting) 'submitted_at': submittedAt,
      if (focusDate != null || forInserting) 'focus_date': focusDate,
      if (parentId != null || forInserting) 'parent_id': parentId,
      if (repeatKind != null || forInserting) 'repeat_kind': repeatKind,
      if (repeatEvery != null || forInserting) 'repeat_every': repeatEvery,
      if (sourceText != null || forInserting) 'source_text': sourceText,
      'created_at': createdAt,
      if (completedAt != null || forInserting) 'completed_at': completedAt,
      'updated_at': updatedAt,
      if (deletedAt != null || forInserting) 'deleted_at': deletedAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  Task copyWith({
    String? id,
    String? spaceId,
    String? title,
    String? notes,
    String? type,
    int? deadline,
    int? startAt,
    int? priority,
    String? status,
    double? weightPercent,
    double? scoreObtained,
    int? estimateMinutes,
    bool? isGroup,
    bool? pinned,
    bool? inbox,
    int? targetAt,
    String? submitMethod,
    String? submitTarget,
    String? filenamePattern,
    int? submittedAt,
    int? focusDate,
    String? parentId,
    String? repeatKind,
    int? repeatEvery,
    String? sourceText,
    int? createdAt,
    int? completedAt,
    int? updatedAt,
    int? deletedAt,
  }) {
    return Task(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      deadline: deadline ?? this.deadline,
      startAt: startAt ?? this.startAt,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      weightPercent: weightPercent ?? this.weightPercent,
      scoreObtained: scoreObtained ?? this.scoreObtained,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      isGroup: isGroup ?? this.isGroup,
      pinned: pinned ?? this.pinned,
      inbox: inbox ?? this.inbox,
      targetAt: targetAt ?? this.targetAt,
      submitMethod: submitMethod ?? this.submitMethod,
      submitTarget: submitTarget ?? this.submitTarget,
      filenamePattern: filenamePattern ?? this.filenamePattern,
      submittedAt: submittedAt ?? this.submittedAt,
      focusDate: focusDate ?? this.focusDate,
      parentId: parentId ?? this.parentId,
      repeatKind: repeatKind ?? this.repeatKind,
      repeatEvery: repeatEvery ?? this.repeatEvery,
      sourceText: sourceText ?? this.sourceText,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class Subtask extends LekasDataClass {
  final String id;
  final String taskId;
  final String title;
  final bool done;
  final int sortOrder;
  final int updatedAt;
  final int? deletedAt;

  Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.done = false,
    this.sortOrder = 0,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      if (forInserting) 'done': done,
      if (forInserting) 'sort_order': sortOrder,
      'updated_at': updatedAt,
      if (deletedAt != null || forInserting) 'deleted_at': deletedAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  Subtask copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? done,
    int? sortOrder,
    int? updatedAt,
    int? deletedAt,
  }) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      done: done ?? this.done,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class ClassSlot extends LekasDataClass {
  final String id;
  final String spaceId;
  final int weekday;
  final int startMin;
  final int endMin;
  final String? room;
  final String kind;
  final int updatedAt;
  final int? deletedAt;

  ClassSlot({
    required this.id,
    required this.spaceId,
    required this.weekday,
    required this.startMin,
    required this.endMin,
    this.room,
    this.kind = 'lecture',
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'space_id': spaceId,
      'weekday': weekday,
      'start_min': startMin,
      'end_min': endMin,
      if (room != null || forInserting) 'room': room,
      if (forInserting || kind.isNotEmpty) 'kind': kind,
      'updated_at': updatedAt,
      if (deletedAt != null || forInserting) 'deleted_at': deletedAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  ClassSlot copyWith({
    String? id,
    String? spaceId,
    int? weekday,
    int? startMin,
    int? endMin,
    String? room,
    String? kind,
    int? updatedAt,
    int? deletedAt,
  }) {
    return ClassSlot(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      weekday: weekday ?? this.weekday,
      startMin: startMin ?? this.startMin,
      endMin: endMin ?? this.endMin,
      room: room ?? this.room,
      kind: kind ?? this.kind,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class Tag extends LekasDataClass {
  final String id;
  final String name;

  Tag({required this.id, required this.name});

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  Tag copyWith({String? id, String? name}) {
    return Tag(id: id ?? this.id, name: name ?? this.name);
  }
}

class TaskTag extends LekasDataClass {
  final String taskId;
  final String tagId;

  TaskTag({required this.taskId, required this.tagId});

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'task_id': taskId,
      'tag_id': tagId,
    };
  }

  @override
  Value? get $primaryKey => null;

  TaskTag copyWith({String? taskId, String? tagId}) {
    return TaskTag(taskId: taskId ?? this.taskId, tagId: tagId ?? this.tagId);
  }
}

class Attachment extends LekasDataClass {
  final String id;
  final String taskId;
  final String kind;
  final String pathOrUrl;
  final String? mime;
  final int? sizeBytes;
  final int createdAt;

  Attachment({
    required this.id,
    required this.taskId,
    required this.kind,
    required this.pathOrUrl,
    this.mime,
    this.sizeBytes,
    required this.createdAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'task_id': taskId,
      'kind': kind,
      'path_or_url': pathOrUrl,
      if (mime != null || forInserting) 'mime': mime,
      if (sizeBytes != null || forInserting) 'size_bytes': sizeBytes,
      'created_at': createdAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  Attachment copyWith({
    String? id,
    String? taskId,
    String? kind,
    String? pathOrUrl,
    String? mime,
    int? sizeBytes,
    int? createdAt,
  }) {
    return Attachment(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      kind: kind ?? this.kind,
      pathOrUrl: pathOrUrl ?? this.pathOrUrl,
      mime: mime ?? this.mime,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Reminder extends LekasDataClass {
  final String id;
  final String? taskId;
  final String? classSlotId;
  final int fireAt;
  final String? kind;
  final int notifId;
  final bool fired;
  final int? ackedAt;

  Reminder({
    required this.id,
    this.taskId,
    this.classSlotId,
    required this.fireAt,
    this.kind,
    required this.notifId,
    this.fired = false,
    this.ackedAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      if (taskId != null || forInserting) 'task_id': taskId,
      if (classSlotId != null || forInserting) 'class_slot_id': classSlotId,
      'fire_at': fireAt,
      if (kind != null || forInserting) 'kind': kind,
      'notif_id': notifId,
      if (forInserting) 'fired': fired,
      if (ackedAt != null || forInserting) 'acked_at': ackedAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  Reminder copyWith({
    String? id,
    String? taskId,
    String? classSlotId,
    int? fireAt,
    String? kind,
    int? notifId,
    bool? fired,
    int? ackedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      classSlotId: classSlotId ?? this.classSlotId,
      fireAt: fireAt ?? this.fireAt,
      kind: kind ?? this.kind,
      notifId: notifId ?? this.notifId,
      fired: fired ?? this.fired,
      ackedAt: ackedAt ?? this.ackedAt,
    );
  }
}

class TaskEvent extends LekasDataClass {
  final String id;
  final String taskId;
  final String kind;
  final String? oldValue;
  final String? newValue;
  final String? note;
  final int createdAt;

  TaskEvent({
    required this.id,
    required this.taskId,
    required this.kind,
    this.oldValue,
    this.newValue,
    this.note,
    required this.createdAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'task_id': taskId,
      'kind': kind,
      if (oldValue != null || forInserting) 'old_value': oldValue,
      if (newValue != null || forInserting) 'new_value': newValue,
      if (note != null || forInserting) 'note': note,
      'created_at': createdAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  TaskEvent copyWith({
    String? id,
    String? taskId,
    String? kind,
    String? oldValue,
    String? newValue,
    String? note,
    int? createdAt,
  }) {
    return TaskEvent(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      kind: kind ?? this.kind,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class FocusSession extends LekasDataClass {
  final String id;
  final String taskId;
  final int startedAt;
  final int durationSec;

  FocusSession({
    required this.id,
    required this.taskId,
    required this.startedAt,
    required this.durationSec,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'task_id': taskId,
      'started_at': startedAt,
      'duration_sec': durationSec,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  FocusSession copyWith({
    String? id,
    String? taskId,
    int? startedAt,
    int? durationSec,
  }) {
    return FocusSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startedAt: startedAt ?? this.startedAt,
      durationSec: durationSec ?? this.durationSec,
    );
  }
}

class TaskTemplate extends LekasDataClass {
  final String id;
  final String name;
  final String? type;
  final int? estimateMinutes;
  final String? subtasksJson;
  final String? milestonesJson;

  TaskTemplate({
    required this.id,
    required this.name,
    this.type,
    this.estimateMinutes,
    this.subtasksJson,
    this.milestonesJson,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'name': name,
      if (type != null || forInserting) 'type': type,
      if (estimateMinutes != null || forInserting) 'estimate_minutes': estimateMinutes,
      if (subtasksJson != null || forInserting) 'subtasks_json': subtasksJson,
      if (milestonesJson != null || forInserting) 'milestones_json': milestonesJson,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  TaskTemplate copyWith({
    String? id,
    String? name,
    String? type,
    int? estimateMinutes,
    String? subtasksJson,
    String? milestonesJson,
  }) {
    return TaskTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      subtasksJson: subtasksJson ?? this.subtasksJson,
      milestonesJson: milestonesJson ?? this.milestonesJson,
    );
  }
}

class ParserPref extends LekasDataClass {
  final String key;
  final String? value;

  ParserPref({required this.key, this.value});

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'key': key,
      if (value != null || forInserting) 'value': value,
    };
  }

  @override
  Value? get $primaryKey => Value(key);

  ParserPref copyWith({String? key, String? value}) {
    return ParserPref(key: key ?? this.key, value: value ?? this.value);
  }
}

class Setting extends LekasDataClass {
  final String key;
  final String? value;

  Setting({required this.key, this.value});

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'key': key,
      if (value != null || forInserting) 'value': value,
    };
  }

  @override
  Value? get $primaryKey => Value(key);

  Setting copyWith({String? key, String? value}) {
    return Setting(key: key ?? this.key, value: value ?? this.value);
  }
}

class TaskDep extends LekasDataClass {
  final String taskId;
  final String dependsOn;

  TaskDep({required this.taskId, required this.dependsOn});

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'task_id': taskId,
      'depends_on': dependsOn,
    };
  }

  @override
  Value? get $primaryKey => null;

  TaskDep copyWith({String? taskId, String? dependsOn}) {
    return TaskDep(taskId: taskId ?? this.taskId, dependsOn: dependsOn ?? this.dependsOn);
  }
}

class ClassException extends LekasDataClass {
  final String id;
  final String? classSlotId;
  final String date;
  final String kind;
  final int? newStartMin;
  final int? newEndMin;
  final String? newRoom;
  final String? note;
  final int updatedAt;
  final int? deletedAt;

  ClassException({
    required this.id,
    this.classSlotId,
    required this.date,
    required this.kind,
    this.newStartMin,
    this.newEndMin,
    this.newRoom,
    this.note,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      if (classSlotId != null || forInserting) 'class_slot_id': classSlotId,
      'date': date,
      'kind': kind,
      if (newStartMin != null || forInserting) 'new_start_min': newStartMin,
      if (newEndMin != null || forInserting) 'new_end_min': newEndMin,
      if (newRoom != null || forInserting) 'new_room': newRoom,
      if (note != null || forInserting) 'note': note,
      'updated_at': updatedAt,
      if (deletedAt != null || forInserting) 'deleted_at': deletedAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  ClassException copyWith({
    String? id,
    String? classSlotId,
    String? date,
    String? kind,
    int? newStartMin,
    int? newEndMin,
    String? newRoom,
    String? note,
    int? updatedAt,
    int? deletedAt,
  }) {
    return ClassException(
      id: id ?? this.id,
      classSlotId: classSlotId ?? this.classSlotId,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      newStartMin: newStartMin ?? this.newStartMin,
      newEndMin: newEndMin ?? this.newEndMin,
      newRoom: newRoom ?? this.newRoom,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class SpaceItem extends LekasDataClass {
  final String id;
  final String spaceId;
  final String title;
  final int sortOrder;
  final String? checkedOn;
  final int updatedAt;
  final int? deletedAt;

  SpaceItem({
    required this.id,
    required this.spaceId,
    required this.title,
    this.sortOrder = 0,
    this.checkedOn,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'space_id': spaceId,
      'title': title,
      if (forInserting) 'sort_order': sortOrder,
      if (checkedOn != null || forInserting) 'checked_on': checkedOn,
      'updated_at': updatedAt,
      if (deletedAt != null || forInserting) 'deleted_at': deletedAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  SpaceItem copyWith({
    String? id,
    String? spaceId,
    String? title,
    int? sortOrder,
    String? checkedOn,
    int? updatedAt,
    int? deletedAt,
  }) {
    return SpaceItem(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      checkedOn: checkedOn ?? this.checkedOn,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class QuickLink extends LekasDataClass {
  final String id;
  final String title;
  final String url;
  final int sortOrder;
  final int updatedAt;
  final int? deletedAt;

  QuickLink({
    required this.id,
    required this.title,
    required this.url,
    this.sortOrder = 0,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'title': title,
      'url': url,
      if (forInserting) 'sort_order': sortOrder,
      'updated_at': updatedAt,
      if (deletedAt != null || forInserting) 'deleted_at': deletedAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  QuickLink copyWith({
    String? id,
    String? title,
    String? url,
    int? sortOrder,
    int? updatedAt,
    int? deletedAt,
  }) {
    return QuickLink(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class ClassNote extends LekasDataClass {
  final String id;
  final String spaceId;
  final int? meetingNo;
  final String? date;
  final String? title;
  final String? body;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  ClassNote({
    required this.id,
    required this.spaceId,
    this.meetingNo,
    this.date,
    this.title,
    this.body,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'space_id': spaceId,
      if (meetingNo != null || forInserting) 'meeting_no': meetingNo,
      if (date != null || forInserting) 'date': date,
      if (title != null || forInserting) 'title': title,
      if (body != null || forInserting) 'body': body,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (deletedAt != null || forInserting) 'deleted_at': deletedAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  ClassNote copyWith({
    String? id,
    String? spaceId,
    int? meetingNo,
    String? date,
    String? title,
    String? body,
    int? createdAt,
    int? updatedAt,
    int? deletedAt,
  }) {
    return ClassNote(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      meetingNo: meetingNo ?? this.meetingNo,
      date: date ?? this.date,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class Diagnostic extends LekasDataClass {
  final String id;
  final String kind;
  final int createdAt;
  final String? result;
  final String? note;

  Diagnostic({
    required this.id,
    required this.kind,
    required this.createdAt,
    this.result,
    this.note,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'kind': kind,
      'created_at': createdAt,
      if (result != null || forInserting) 'result': result,
      if (note != null || forInserting) 'note': note,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  Diagnostic copyWith({String? id, String? kind, int? createdAt, String? result, String? note}) {
    return Diagnostic(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      result: result ?? this.result,
      note: note ?? this.note,
    );
  }
}

class GradeComponent extends LekasDataClass {
  final String spaceId;
  final String key;
  final double weightPercent;

  GradeComponent({
    required this.spaceId,
    required this.key,
    required this.weightPercent,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'space_id': spaceId,
      'key': key,
      'weight_percent': weightPercent,
    };
  }

  @override
  Value? get $primaryKey => null;

  GradeComponent copyWith({String? spaceId, String? key, double? weightPercent}) {
    return GradeComponent(
      spaceId: spaceId ?? this.spaceId,
      key: key ?? this.key,
      weightPercent: weightPercent ?? this.weightPercent,
    );
  }
}

class SavedFilter extends LekasDataClass {
  final String id;
  final String name;
  final String queryJson;
  final int sortOrder;
  final int updatedAt;
  final int? deletedAt;

  SavedFilter({
    required this.id,
    required this.name,
    required this.queryJson,
    this.sortOrder = 0,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toColumns(bool forInserting) {
    return {
      'id': id,
      'name': name,
      'query_json': queryJson,
      if (forInserting) 'sort_order': sortOrder,
      'updated_at': updatedAt,
      if (deletedAt != null || forInserting) 'deleted_at': deletedAt,
    };
  }

  @override
  Value? get $primaryKey => Value(id);

  SavedFilter copyWith({
    String? id,
    String? name,
    String? queryJson,
    int? sortOrder,
    int? updatedAt,
    int? deletedAt,
  }) {
    return SavedFilter(
      id: id ?? this.id,
      name: name ?? this.name,
      queryJson: queryJson ?? this.queryJson,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
