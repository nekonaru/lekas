import 'dart:async' show StreamController;

import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import 'database.dart';
import 'task_dep_repository.dart';
import 'task_template_repository.dart' show decodeSubtaskTitles;

class TaskRepository {
  final AppDatabase db;
  TaskRepository(this.db);

  /// Tasks that became startable because the task passed to [markDone] was
  /// their last open prerequisite (design section 5.27). The notification
  /// layer listens; nothing else subscribes.
  final StreamController<String> _unblockedController =
      StreamController<String>.broadcast();

  Stream<String> get justUnblocked => _unblockedController.stream;

  /// Closes [justUnblocked] when the provider that owns this repository is
  /// disposed, so no listener is called on a dead container.
  void dispose() {
    _unblockedController.close();
  }

  /// Query streams already handed out, keyed by their arguments.
  ///
  /// drift reuses the stream behind a query, but every `watch()` call wraps
  /// it in a new object. A `StreamBuilder` compares streams by identity, so
  /// building a screen with `stream: repo.watchTasks(...)` used to cancel and
  /// reopen the subscription on every rebuild: one extra query, one pass
  /// through the waiting state (a spinner flash) for every tap in selection
  /// mode. Returning the same instance keeps a single subscription alive for
  /// as long as anyone listens.
  final Map<String, Stream<List<Task>>> _watchCache = {};

  Stream<List<Task>> _watch(String key, Stream<List<Task>> Function() build) =>
      _watchCache.putIfAbsent(key, build);

  Stream<List<Task>> watchTasks({String? spaceId, bool includeInbox = false}) {
    return _watch('tasks:${spaceId ?? '*'}:$includeInbox', () {
      final query = db.select(db.tasks)..where((t) => t.deletedAt.isNull());
      if (spaceId != null) {
        query.where((t) => t.spaceId.equals(spaceId));
      } else if (!includeInbox) {
        query.where((t) => t.inbox.equals(false));
      }
      return query.watch();
    });
  }

  Future<List<Task>> getTasks(
      {String? spaceId, bool includeInbox = false}) async {
    final query = db.select(db.tasks)..where((t) => t.deletedAt.isNull());
    if (spaceId != null) {
      query.where((t) => t.spaceId.equals(spaceId));
    } else if (!includeInbox) {
      query.where((t) => t.inbox.equals(false));
    }
    return query.get();
  }

  Future<Task> getTask(String id) async {
    return (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
  }

  /// The most recently created task that is still in the app (design
  /// section 7.16): the source for "repeat space, type and deadline time".
  /// Inbox and completed tasks count, they are just as recent as the rest.
  Future<Task?> getLatestTask() async {
    final query = db.select(db.tasks)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(1);
    final rows = await query.get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> insertTask(Task task) async {
    await db.into(db.tasks).insert(task);
  }

  Future<void> updateTask(Task task) async {
    await db.update(db.tasks).replace(task);
  }

  Future<void> softDeleteTask(String id) async {
    // Write only the two columns: replace() would rebuild the row from
    // scratch and drop notes, deadline, space and every other field.
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> restoreTask(String id) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        deletedAt: const Value(null),
      ),
    );
  }

  /// Marks a task done. If the task carries a repeat kind, the next
  /// occurrence is created automatically; nothing else happens to it.
  Future<void> markDone(String id, {int? completedAt}) async {
    // Read, update and the recurring insert must be one atomic write. Two
    // rapid taps on the same task would otherwise both create the next
    // occurrence of a recurring series.
    await db.transaction(() async {
      final existing = await getTask(id);
      await db.update(db.tasks).replace(existing.copyWith(
        status: 'done',
        completedAt: Value(completedAt ?? DateTime.now().millisecondsSinceEpoch),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      // Recurring task: schedule the next occurrence.
      if (existing.repeatKind != null && existing.status != 'done') {
        final next = _nextOccurrence(existing);
        if (next != null) await insertTask(next);
      }
      // Only a first completion opens doors: marking a finished task again
      // would repeat the notice for everyone waiting on it (design 5.27).
      if (existing.status == 'done') return;
      for (final freed in await TaskDepRepository(db).unblockedBy(id)) {
        if (!_unblockedController.isClosed) _unblockedController.add(freed);
      }
    });
  }

  /// The next occurrence of a recurring [task] (design: simple recurring
  /// tasks). Returns null when the kind is unknown.
  Task? _nextOccurrence(Task task) {
    final baseMs = task.deadline ?? task.createdAt;
    final from = DateTime.fromMillisecondsSinceEpoch(baseMs);
    final every = task.repeatEvery ?? 1;
    final DateTime next;
    switch (task.repeatKind) {
      case 'daily':
        next = from.add(Duration(days: every));
      case 'weekly':
        next = from.add(Duration(days: 7 * every));
      case 'monthly':
        // Dart rolls over when a day does not exist in the target month
        // (Jan 31 + 1 month would be Mar 3), so clamp to the month's last day.
        final target =
            DateTime(from.year, from.month + every, 1, from.hour, from.minute);
        final lastDay = DateTime(target.year, target.month + 1, 0).day;
        next = DateTime(
          target.year,
          target.month,
          from.day < lastDay ? from.day : lastDay,
          from.hour,
          from.minute,
        );
      default:
        return null;
    }
    return task.copyWith(
      id: const Uuid().v4(),
      status: 'todo',
      pinned: false,
      focusDate: const Value(null),
      completedAt: const Value(null),
      repeatKind: Value(task.repeatKind),
      repeatEvery: Value(task.repeatEvery),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deadline: task.deadline != null ? Value(next.millisecondsSinceEpoch) : const Value.absent(),
    );
  }
  /// Puts a finished task back on the list: the undo snackbars and the
  /// focus picker both need it (design section 5.24).
  Future<void> reopenTask(String id) async {
    final existing = await getTask(id);
    await db.update(db.tasks).replace(existing.copyWith(
      status: 'todo',
      completedAt: const Value(null),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  /// Pins or unpins a task (design section 5.9): pinned tasks always come
  /// first on the Today screen, outside the urgency order.
  Future<void> setPinned(String id, bool pinned) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        pinned: Value(pinned),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Picks or releases a task as focus of the day (design section 5.24).
  /// Passing null clears yesterday's focus so it never carries over.
  Future<void> setFocusDate(String id, int? focusDate) async {
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        focusDate: Value(focusDate),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Copies a task with its subtasks and tags in one tap (design section
  /// 5.9). The copy starts fresh: not done, not pinned, deadline unchanged.
  Future<Task> duplicateTask(String id) async {
    final source = await getTask(id);
    final now = DateTime.now().millisecondsSinceEpoch;
    final copy = source.copyWith(
      id: const Uuid().v4(),
      status: 'todo',
      pinned: false,
      focusDate: const Value(null),
      submittedAt: const Value(null),
      completedAt: const Value(null),
      createdAt: now,
      updatedAt: now,
      deletedAt: const Value(null),
    );
    await insertTask(copy);

    // The copy is all or nothing: subtasks and links join the task row in
    // one transaction instead of one commit each.
    await db.transaction(() async {
      final subtasks = await (db.select(db.subtasks)
            ..where((t) => t.taskId.equals(id) & t.deletedAt.isNull()))
          .get();
      for (final subtask in subtasks) {
        await db.into(db.subtasks).insert(subtask.copyWith(
              id: const Uuid().v4(),
              taskId: copy.id,
              done: false,
              updatedAt: now,
            ));
      }

      final links = await (db.select(db.taskTags)
            ..where((t) => t.taskId.equals(id)))
          .get();
      for (final link in links) {
        await db.into(db.taskTags).insert(
              TaskTag(taskId: copy.id, tagId: link.tagId),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
    return copy;
  }

  /// Builds a new task from a template: the name, type and estimate are
  /// copied and every subtask of the template is added, unchecked, so a new
  /// task comes pre filled (design section 5.9).
  Future<Task> createFromTemplate(
    TaskTemplate template, {
    String? spaceId,
    int? deadline,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final task = Task(
      id: const Uuid().v4(),
      spaceId: spaceId,
      title: template.name,
      type: template.type,
      estimateMinutes: template.estimateMinutes,
      deadline: deadline,
      priority: 1,
      status: 'todo',
      isGroup: false,
      pinned: false,
      inbox: spaceId == null,
      createdAt: now,
      updatedAt: now,
    );
    await insertTask(task);

    // A template either fills the task completely or not at all.
    await db.transaction(() async {
      var order = 0;
      for (final title in decodeSubtaskTitles(template.subtasksJson)) {
        await db.into(db.subtasks).insert(
              Subtask(
                id: const Uuid().v4(),
                taskId: task.id,
                title: title,
                done: false,
                sortOrder: order++,
                updatedAt: now,
              ),
            );
      }
    });
    return task;
  }

  Stream<List<Task>> watchInbox() {
    return _watch('inbox', () {
      return (db.select(db.tasks)
            ..where((t) => t.inbox.equals(true) & t.deletedAt.isNull()))
          .watch();
    });
  }

  /// Rows sitting in the trash: only the soft deleted ones, newest first.
  Stream<List<Task>> watchTrash() {
    return _watch('trash', () {
      return (db.select(db.tasks)
            ..where((t) => t.deletedAt.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
          .watch();
    });
  }

  /// Removes a trashed task for good. This one really deletes the row,
  /// which is what the trash screen promises to the user.
  ///
  /// The schema sets no `ON DELETE CASCADE`, so every child row has to go
  /// here or it is left behind as an orphan that still joins against a task
  /// that no longer exists.
  Future<void> deletePermanently(String id) async {
    // The row deletion hides the reminders from the reconciler, so cancel
    // their plugin alarms here before the rows disappear.
    final alarmIds = (await (db.select(db.reminders)
          ..where((t) => t.taskId.equals(id)))
        .get())
        .map((row) => row.notifId)
        .toList();
    await db.transaction(() async {
      await (db.delete(db.subtasks)..where((t) => t.taskId.equals(id))).go();
      await (db.delete(db.taskTags)..where((t) => t.taskId.equals(id))).go();
      await (db.delete(db.attachments)..where((t) => t.taskId.equals(id))).go();
      await (db.delete(db.reminders)..where((t) => t.taskId.equals(id))).go();
      await (db.delete(db.taskEvents)..where((t) => t.taskId.equals(id))).go();
      await (db.delete(db.focusSessions)..where((t) => t.taskId.equals(id))).go();
      await (db.delete(db.taskDeps)
            ..where((t) => t.taskId.equals(id) | t.dependsOn.equals(id)))
          .go();
      // A group task can hold children through `parent_id`; they move to the
      // inbox instead of dangling with a dead parent.
      await (db.update(db.tasks)..where((t) => t.parentId.equals(id))).write(
        const TasksCompanion(
          parentId: Value(null),
          inbox: Value(true),
        ),
      );
      await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();
    });
    // Widget tests and desktop have no notification plugin; a cancellation
    // failure there is harmless because there is no alarm to ring.
    for (final notifId in alarmIds) {
      try {
        await FlutterLocalNotificationsPlugin().cancel(notifId);
      } catch (_) {
        // No plugin channel: nothing to cancel.
      }
    }
  }

  Future<int> countInbox() async {
    // COUNT(*) in SQLite instead of loading every row into Dart.
    final count = db.tasks.id.count();
    final query = db.selectOnly(db.tasks)
      ..addColumns([count])
      ..where(db.tasks.inbox.equals(true) & db.tasks.deletedAt.isNull());
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
