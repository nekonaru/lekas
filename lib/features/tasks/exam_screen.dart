import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(taskRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.examStudyMaterialsTitle)),
      body: FutureBuilder<List<Task>>(
        future: repo.getTasks(spaceId: widget.spaceId),
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
