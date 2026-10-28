import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class SubmissionScreen extends ConsumerStatefulWidget {
  final String taskId;
  const SubmissionScreen({super.key, required this.taskId});

  @override
  ConsumerState<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends ConsumerState<SubmissionScreen> {
  String? _submitMethod;
  final _submitTargetController = TextEditingController();
  final _filenamePatternController = TextEditingController();

  @override
  void dispose() {
    _submitTargetController.dispose();
    _filenamePatternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(taskRepositoryProvider);

    return FutureBuilder<Task>(
      future: repo.getTask(widget.taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final task = snapshot.data;
        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.submissionMethodTitle)),
            body: Center(child: Text(l10n.recordNotFound)),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.submissionMethodTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _submitMethod,
                decoration: InputDecoration(labelText: l10n.submissionMethodLabel),
                items: [
                  const DropdownMenuItem(value: 'email', child: Text('Email')),
                  const DropdownMenuItem(value: 'lms', child: Text('LMS / Classroom')),
                  DropdownMenuItem(value: 'paper', child: Text(l10n.submitMethodPaper)),
                  const DropdownMenuItem(value: 'drive', child: Text('Google Drive')),
                  DropdownMenuItem(value: 'other', child: Text(l10n.othersLabel)),
                ],
                onChanged: (v) => setState(() => _submitMethod = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _submitTargetController,
                decoration: InputDecoration(labelText: l10n.submitTargetLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _filenamePatternController,
                decoration: InputDecoration(
                  labelText: l10n.filenamePatternLabel,
                  hintText: '{nim}_{nama}_{matkul}_{judul}',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await repo.updateTask(task.copyWith(
                        submitMethod: Value(_submitMethod),
                        submitTarget: Value(_submitTargetController.text.isEmpty
                            ? null
                            : _submitTargetController.text),
                        filenamePattern: Value(_filenamePatternController.text.isEmpty
                            ? null
                            : _filenamePatternController.text),
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      ));
                      navigator.pop();
                    },
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
