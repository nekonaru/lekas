import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class DependensiTugasScreen extends ConsumerStatefulWidget {
  const DependensiTugasScreen({super.key});

  @override
  ConsumerState<DependensiTugasScreen> createState() => _DependensiTugasScreenState();
}

class _DependensiTugasScreenState extends ConsumerState<DependensiTugasScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.taskDependenciesTitle)),
      body: Center(child: Text(l10n.taskDependenciesBody)),
    );
  }
}
