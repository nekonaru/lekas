import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class BagikanTeksScreen extends ConsumerStatefulWidget {
  const BagikanTeksScreen({super.key});

  @override
  ConsumerState<BagikanTeksScreen> createState() => _BagikanTeksScreenState();
}

class _BagikanTeksScreenState extends ConsumerState<BagikanTeksScreenState> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Bagikan sebagai Teks')),
      body: const Center(child: Text('Bagikan tugas atau daftar mingguan ke WhatsApp.')),
    );
  }
}
