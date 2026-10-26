import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class ImporJadwalOCRScreen extends ConsumerStatefulWidget {
  const ImporJadwalOCRScreen({super.key});

  @override
  ConsumerState<ImporJadwalOCRScreen> createState() => _ImporJadwalOCRScreenState();
}

class _ImporJadwalOCRScreenState extends ConsumerState<ImporJadwalOCRScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Impor Jadwal dari Tangkapan Layar')),
      body: const Center(child: Text('Impor jadwal KRS dari tangkapan layar atau teks portal.')),
    );
  }
}
