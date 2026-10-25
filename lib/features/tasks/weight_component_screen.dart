import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uuid/uuid.dart';
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
  final _labels = {
    'midterm': 'UTS',
    'final': 'UAS',
    'assignment': 'Tugas',
    'quiz': 'Kuis',
    'attendance': 'Kehadiran',
    'other': 'Lainnya',
  };

  @override
  void initState() {
    super.initState();
    for (final key in _components) {
      _controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(gradeComponentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Bobot Komponen - ${widget.spaceName}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _components.length,
              itemBuilder: (context, index) {
                final key = _components[index];
                return ListTile(
                  title: Text(_labels[key] ?? key),
                  subtitle: TextField(
                    controller: _controllers[key],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Bobot (%)',
                      border: OutlineInputBorder(),
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
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Total bobot: $total%, harus 100%')),
                    );
                  }
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
