import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class SaranWaktuKosongScreen extends ConsumerStatefulWidget {
  const SaranWaktuKosongScreen({super.key});

  @override
  ConsumerState<SaranWaktuKosongScreen> createState() => _SaranWaktuKosongScreenState();
}

class _SaranWaktuKosongScreenState extends ConsumerState<SaranWaktuKosongScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Saran Waktu Kosong')),
      body: const Center(child: Text('Saran celah waktu untuk fokus belajar.')),
    );
  }
}
