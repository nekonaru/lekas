import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class WeightComponentScreen extends ConsumerStatefulWidget {
  final String spaceId;
  final String spaceName;
  const WeightComponentScreen({super.key, required this.spaceId, required this.spaceName});

  @override
  ConsumerState<WeightComponentScreen> createState() => _WeightComponentScreenState();
}

class _WeightComponentScreenState extends ConsumerState<WeightComponentScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final _components = ['midterm', 'final', 'assignment', 'quiz', 'attendance', 'other'];

  @override
  void initState() {
    super.initState();
    for (final key in _components) {
      _controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(gradeComponentRepositoryProvider);
    final labels = {
      'midterm': l10n.midtermLabel,
      'final': l10n.finalExamLabel,
      'assignment': l10n.assignmentLabel,
      'quiz': l10n.quizLabel,
      'attendance': l10n.attendanceLabel,
      'other': l10n.othersLabel,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.componentWeightTitle(widget.spaceName))),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _components.length,
              itemBuilder: (context, index) {
                final key = _components[index];
                return ListTile(
                  title: Text(labels[key] ?? key),
                  subtitle: TextField(
                    controller: _controllers[key],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.weightPercentFieldLabel,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                var total = 0.0;
                for (final key in _components) {
                  final val = double.tryParse(_controllers[key]!.text) ?? 0;
                  total += val;
                  await repo.insertGradeComponent(GradeComponent(
                    spaceId: widget.spaceId,
                    key: key,
                    weightPercent: val,
                  ));
                }
                if (total != 100) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.weightTotalMustBe100('$total')),
                    ),
                  );
                }
                navigator.pop();
              },
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }
}
