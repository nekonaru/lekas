import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class PetaBebanScreen extends ConsumerStatefulWidget {
  const PetaBebanScreen({super.key});

  @override
  ConsumerState<PetaBebanScreen> createState() => _PetaBebanScreenState();
}

class _PetaBebanScreenState extends ConsumerState<PetaBebanScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.weeklyLoadMapTitle)),
      body: Center(child: Text(l10n.weeklyLoadMapBody)),
    );
  }
}
