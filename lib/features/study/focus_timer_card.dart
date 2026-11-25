import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// The Pomodoro-style focus timer that finally records focus sessions
/// (the table has existed since schema 1, but nothing wrote to it).
/// A session ties to one focus task; ending under 30 seconds discards it.
class FocusTimerCard extends ConsumerStatefulWidget {
  const FocusTimerCard({super.key, required this.focusTaskId});

  /// Null when no focus task is picked; the timer then stays disabled.
  final String? focusTaskId;

  @override
  ConsumerState<FocusTimerCard> createState() => _FocusTimerCardState();
}

class _FocusTimerCardState extends ConsumerState<FocusTimerCard> {
  static const _presets = [15, 25, 45];

  Timer? _ticker;
  int _selectedMinutes = 25;
  static const int _breakSeconds = 5 * 60;
  late int _remainingSeconds = _selectedMinutes * 60;
  bool _running = false;
  bool _onBreak = false;
  DateTime? _startedAt;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int get _selectedSeconds => _selectedMinutes * 60;
  int get _durationSeconds => _onBreak ? _breakSeconds : _selectedSeconds;
  int get _elapsedSeconds => _durationSeconds - _remainingSeconds;

  String _format(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _pickPreset(int minutes) {
    if (_running || _onBreak) return;
    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
      _startedAt = null;
    });
  }

  /// The shared one-second ticker for both focus and break phases.
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _complete();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  void _start() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.focusTaskId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.focusNeedsTask)),
      );
      return;
    }
    setState(() {
      _running = true;
      _startedAt ??= DateTime.now();
    });
    _startTicker();
  }

  void _resume() {
    setState(() => _running = true);
    _startTicker();
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _onBreak = false;
      _remainingSeconds = _selectedSeconds;
      _startedAt = null;
    });
  }

  /// When the break ends, simply return to a fresh focus timer.
  Future<void> _complete() async {
    if (_onBreak) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      setState(() {
        _onBreak = false;
        _running = false;
        _remainingSeconds = _selectedSeconds;
        _startedAt = null;
      });
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.heavyImpact();
    final taskId = widget.focusTaskId;
    final startedAt = _startedAt?.millisecondsSinceEpoch ??
        DateTime.now().subtract(Duration(seconds: _selectedSeconds)).millisecondsSinceEpoch;
    if (taskId != null) {
      await ref.read(focusSessionRepositoryProvider).insertFocusSession(
            FocusSession(
              id: const Uuid().v4(),
              taskId: taskId,
              startedAt: startedAt,
              durationSec: _selectedSeconds,
            ),
          );
    }
    if (!mounted) return;
    // Reward a finished session with an automatic five-minute break.
    setState(() {
      _onBreak = true;
      _running = true;
      _remainingSeconds = _breakSeconds;
      _startedAt = null;
    });
    _startTicker();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.focusSessionSaved)),
    );
  }

  Future<void> _endEarly() async {
    final l10n = AppLocalizations.of(context)!;
    final elapsed = _elapsedSeconds;
    _ticker?.cancel();
    setState(() => _running = false);
    if (elapsed >= 30) {
      final taskId = widget.focusTaskId;
      if (taskId != null) {
        await ref.read(focusSessionRepositoryProvider).insertFocusSession(
              FocusSession(
                id: const Uuid().v4(),
                taskId: taskId,
                startedAt: _startedAt?.millisecondsSinceEpoch ??
                    DateTime.now().millisecondsSinceEpoch,
                durationSec: elapsed,
              ),
            );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.focusSessionSaved)),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.focusSessionTooShort)),
      );
    }
    if (!mounted) return;
    setState(() {
      _remainingSeconds = _selectedSeconds;
      _startedAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final canInteract = widget.focusTaskId != null;
    final progress = 1 - (_remainingSeconds / _durationSeconds);
    final accent = _onBreak ? const Color(0xFFF59E0B) : colors.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    _onBreak ? Icons.local_cafe_outlined : Icons.timer_outlined,
                    size: 18,
                    color: accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (_onBreak ? l10n.breakTimerTitle : l10n.focusTimerTitle)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: accent,
                    ),
                  ),
                  const Spacer(),
                  if (!_onBreak)
                    for (final minutes in _presets)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text('$minutes'),
                          selected: _selectedMinutes == minutes,
                          onSelected:
                              _running ? null : (_) => _pickPreset(minutes),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Text(
                  _format(_remainingSeconds),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _onBreak
                          ? (_running ? _pause : _resume)
                          : (canInteract ? (_running ? _pause : _start) : _start),
                      icon: Icon(
                        _running ? Icons.pause : Icons.play_arrow_rounded,
                      ),
                      label: Text(
                        _running
                            ? l10n.pauseFocus
                            : (_remainingSeconds != _selectedSeconds &&
                                    _remainingSeconds != 0
                                ? l10n.resumeFocus
                                : l10n.startFocus),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _reset,
                    tooltip: l10n.resetFocus,
                    icon: const Icon(Icons.refresh),
                  ),
                  if (_onBreak) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _complete,
                      child: Text(l10n.skipBreak),
                    ),
                  ] else if (_elapsedSeconds > 0) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _endEarly,
                      child: Text(l10n.endFocusEarly),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
