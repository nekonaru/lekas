import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class ProyekMilestoneScreen extends ConsumerStatefulWidget {
  const ProyekMilestoneScreen({super.key});

  @override
  ConsumerState<ProyekMilestoneScreen> createState() => _ProyekMilestoneScreenState();
}

class _ProyekMilestoneScreenState extends ConsumerState<ProyekMilestoneScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Proyek dan Milestone')),
      body: const Center(child: Text('Manajemen proyek dengan milestone dan rencana mundur.')),
    );
  }
}
