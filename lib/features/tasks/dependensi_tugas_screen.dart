import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      appBar: AppBar(title: const Text('Dependensi Tugas')),
      body: const Center(child: Text('Tugas yang menunggu tugas lain selesai.')),
    );
  }
}
