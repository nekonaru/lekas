import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  /// Details of one grading component with an explicit delete step
  /// (design section 7.7).
  Future<void> _showComponent(GradeComponent component) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(component.key),
        content: Text(
          l10n.weightPercentLabel(
            component.weightPercent.toStringAsFixed(0),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(gradeComponentRepositoryProvider)
        .deleteGradeComponent(widget.spaceId, component.key);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(gradeComponentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.gradePredictionTitle)),
      body: FutureBuilder<List<GradeComponent>>(
        future: repo.getGradeComponents(widget.spaceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final components = snapshot.data ?? [];

          if (components.isEmpty) {
            return Center(child: Text(l10n.noGradeComponents));
          }

          return ListView.builder(
            itemCount: components.length,
            itemBuilder: (context, index) {
              final component = components[index];
              return ListTile(
                title: Text(component.key),
                subtitle: Text(
                  l10n.weightPercentLabel(component.weightPercent.toStringAsFixed(0)),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComponent(component),
              );
            },
          );
        },
      ),
    );
  }
}
