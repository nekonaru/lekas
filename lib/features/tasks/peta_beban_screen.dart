import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      appBar: AppBar(title: const Text('Peta Beban Mingguan')),
      body: const Center(child: Text('Peta beban mingguan dan jam efektif tersedia.')),
    );
  }
}
