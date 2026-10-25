import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';

class PrediksiNilaiScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const PrediksiNilaiScreen({super.key, required this.spaceId});

  @override
  ConsumerState<PrediksiNilaiScreen> createState() => _PrediksiNilaiScreenState();
}

class _PrediksiNilaiScreenState extends ConsumerState<PrediksiNilaiScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(gradeComponentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prediksi Nilai')),
      body: FutureBuilder<List<GradeComponent>>(
        future: repo.getGradeComponents(widget.spaceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final components = snapshot.data ?? [];

          if (components.isEmpty) {
            return const Center(child: Text('Belum ada komponen penilaian.'));
          }

          return ListView.builder(
            itemCount: components.length,
            itemBuilder: (context, index) {
              final component = components[index];
              return ListTile(
                title: Text(component.key),
                subtitle: Text('Bobot: ${component.weightPercent.toStringAsFixed(0)}%'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
