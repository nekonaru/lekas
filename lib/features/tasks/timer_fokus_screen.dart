import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

class TimerFokusScreen extends ConsumerStatefulWidget {
  const TimerFokusScreen({super.key});

  @override
  ConsumerState<TimerFokusScreen> createState() => _TimerFokusScreenState();
}

class _TimerFokusScreenState extends ConsumerState<TimerFokusScreenState> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Timer Fokus')),
      body: const Center(child: Text('Timer fokus 25/5 menit (Pomodoro).')),
    );
  }
}
