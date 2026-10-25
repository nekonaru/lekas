import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class SimulatorNilaiScreen extends ConsumerStatefulWidget {
  const SimulatorNilaiScreen({super.key});

  @override
  ConsumerState<SimulatorNilaiScreen> createState() => _SimulatorNilaiScreenState();
}

class _SimulatorNilaiScreenState extends ConsumerState<SimulatorNilaiScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Simulator Nilai')),
      body: const Center(child: Text('Simulator nilai "bagaimana jika".')),
    );
  }
}
