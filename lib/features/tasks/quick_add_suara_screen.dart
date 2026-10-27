import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../voice/voice_input.dart';
import '../quick_add/quick_add_sheet.dart';

/// Quick Add with voice (design section 7.1): a screen that only speaks, so
/// the sentence can be checked before it reaches the Quick Add parser and
/// its chips.
class QuickAddSuaraScreen extends ConsumerStatefulWidget {
  const QuickAddSuaraScreen({super.key});

  @override
  ConsumerState<QuickAddSuaraScreen> createState() =>
      _QuickAddSuaraScreenState();
}

class _QuickAddSuaraScreenState extends ConsumerState<QuickAddSuaraScreen> {
  final TextEditingController _controller = TextEditingController();
  final VoiceInput _voice = VoiceInput();
  bool _listening = false;
  String _voiceBase = '';

  @override
  void dispose() {
    _voice.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    if (_listening) {
      await _voice.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final language =
        ref.read(localeProvider).valueOrNull?.languageCode ?? 'id';
    _voiceBase = _controller.text.trim();
    final started = await _voice.start(
      localeId: language == 'id' ? 'id_ID' : 'en_US',
      onText: _onVoiceText,
      onError: _onVoiceError,
    );
    if (!mounted) return;
    if (started) {
      setState(() => _listening = true);
    } else {
      _showMessage(l10n.micUnavailable);
    }
  }

  void _onVoiceText(String text, bool isFinal) {
    if (!mounted) return;
    final heard = text.trim();
    final base = _voiceBase;
    final next =
        heard.isEmpty ? base : (base.isEmpty ? heard : '$base $heard');
    if (_controller.text != next) {
      _controller.text = next;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
    if (isFinal) setState(() => _listening = false);
  }

  void _onVoiceError(String errorCode, bool permanent) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    setState(() => _listening = false);
    _showMessage(errorCode == 'error_permission'
        ? l10n.micPermissionDenied
        : l10n.micUnavailable);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Hands the sentence over to Quick Add, where the parser shows it as
  /// chips before anything is saved (design section 7.1).
  void _openQuickAdd() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => QuickAddSheet(initialText: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canContinue = _controller.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.voiceQuickAddTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: IconButton(
                  iconSize: 64,
                  tooltip: l10n.startRecording,
                  color: _listening
                      ? Theme.of(context).colorScheme.error
                      : Colors.grey,
                  icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                  onPressed: _toggle,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _listening ? l10n.voiceListening : l10n.voiceQuickAddHint,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: l10n.quickAddHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: canContinue ? _openQuickAdd : null,
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.quickAddMenuLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
