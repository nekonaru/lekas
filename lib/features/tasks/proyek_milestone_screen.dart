import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: Text(l10n.projectMilestoneTitle)),
      body: Center(child: Text(l10n.projectMilestoneBody)),
    );
  }
}
