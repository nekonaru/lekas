import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';

class ExamScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const ExamScreen({super.key, required this.spaceId});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  late Future<List<Task>> _examsFuture;
  bool _planning = false;

  @override
  void initState() {
    super.initState();
    _examsFuture = ref.read(taskRepositoryProvider).getTasks(spaceId: widget.spaceId);
  }

  Future<void> _createPlan(Task exam) async {
    if (_planning) return;
    _planning = true;
    final l10n = AppLocalizations.of(context)!;
    final deadline = exam.deadline == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(exam.deadline!);
    if (deadline == null) {
      _planning = false;
      return;
    }
    final now = DateTime.now();
    var created = 0;
    for (final lead in [7, 3, 1]) {
      final due = deadline.subtract(Duration(days: lead));
      if (!due.isAfter(now)) continue;
      final stamp = now.millisecondsSinceEpoch;
      await ref.read(taskRepositoryProvider).insertTask(Task(
            id: const Uuid().v4(),
            spaceId: exam.spaceId,
            title: l10n.examPlanTask(exam.title),
            priority: 1,
            status: 'todo',
            isGroup: false,
            pinned: false,
            inbox: false,
            deadline: due.millisecondsSinceEpoch,
            sourceText: 'lekas:exam-plan',
            createdAt: stamp,
            updatedAt: stamp,
          ));
      created += 1;
    }
    _planning = false;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.examPlanCreated(created))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.examStudyMaterialsTitle)),
      body: FutureBuilder<List<Task>>(
        future: _examsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final exams = snapshot.data?.where((t) =>
              t.type == 'quiz' || t.type == 'midterm' || t.type == 'final').toList() ?? [];

          if (exams.isEmpty) {
            return Center(child: Text(l10n.noExamsYet));
          }

          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              final deadline = exam.deadline != null
                  ? DateTime.fromMillisecondsSinceEpoch(exam.deadline!)
                  : null;
              final daysLeft = deadline?.difference(DateTime.now()).inDays;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(exam.title),
                  subtitle: Text(
                    deadline != null
                        ? '${DateUtil.formatDate(deadline, locale)}\n${l10n.daysRemaining(daysLeft!)}'
                        : l10n.examNoDeadline,
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        exam.type == 'quiz'
                            ? l10n.quizLabel
                            : exam.type == 'midterm'
                                ? l10n.midtermLabel
                                : l10n.finalExamLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (daysLeft != null && daysLeft < 14)
                        const Icon(Icons.warning, color: Colors.orange),
                      IconButton(
                        icon: const Icon(Icons.event_available_outlined),
                        tooltip: l10n.examPlanAction,
                        onPressed: () => _createPlan(exam),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
