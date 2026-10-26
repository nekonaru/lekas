import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class TimerFokusScreen extends ConsumerStatefulWidget {
  const TimerFokusScreen({super.key});

  @override
  ConsumerState<TimerFokusScreen> createState() => _TimerFokusScreenState();
}

class _TimerFokusScreenState extends ConsumerState<TimerFokusScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.timerFocusTitle)),
      body: Center(child: Text(l10n.timerFocusBody)),
    );
  }
}
