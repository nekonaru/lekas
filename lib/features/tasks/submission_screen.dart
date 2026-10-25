import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        final task = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text('Cara Kumpul')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                value: _submitMethod,
                decoration: const InputDecoration(labelText: 'Cara Kumpul'),
                items: const [
                  DropdownMenuItem(value: 'email', child: Text('Email')),
                  DropdownMenuItem(value: 'lms', child: Text('LMS / Classroom')),
                  DropdownMenuItem(value: 'paper', child: Text('Kertas / Hard Copy')),
                  DropdownMenuItem(value: 'drive', child: Text('Google Drive')),
                  DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                ],
                onChanged: (v) => setState(() => _submitMethod = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _submitTargetController,
                decoration: const InputDecoration(labelText: 'Tujuan (email, kelas LMS, ruangan)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _filenamePatternController,
                decoration: const InputDecoration(
                  labelText: 'Pola Nama Berkas',
                  hintText: '{nim}_{nama}_{matkul}_{judul}',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      await repo.updateTask(task.copyWith(
                        submitMethod: _submitMethod,
                        submitTarget: _submitTargetController.text.isEmpty
                            ? null
                            : _submitTargetController.text,
                        filenamePattern: _filenamePatternController.text.isEmpty
                            ? null
                            : _filenamePatternController.text,
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      ));
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Simpan'),
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
