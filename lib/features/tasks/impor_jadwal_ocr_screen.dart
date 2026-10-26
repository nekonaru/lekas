import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: Text(l10n.importScheduleOcrTitle)),
      body: Center(child: Text(l10n.importScheduleOcrBody)),
    );
  }
}
