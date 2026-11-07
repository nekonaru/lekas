import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/components/lekas_logo.dart';
import '../core/theme.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';

/// The gate that appears when the app lock is on: the brand band, a hint
/// and a PIN field. A wrong PIN shows the error and stays; there is no
/// way past the gate except the right PIN.
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key, required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _controller = TextEditingController();
  bool _busy = false;
  bool _wrong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The gate credential: only the right PIN opens the app. Wrong guesses
  /// answer with the error message and a cleared field.
  Future<void> _tryPin() async {
    if (_busy) return;
    final pin = _controller.text;
    setState(() {
      _busy = true;
      _wrong = false;
    });
    final ok = await ref.read(lockServiceProvider).verify(pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _wrong = !ok;
    });
    if (ok) {
      widget.onUnlock();
    } else {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: const Center(child: LekasLogo(size: 72)),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.unlockTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.appLockMethod,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: l10n.pinLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: _wrong
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                  errorText: _wrong ? l10n.wrongPin : null,
                  counter: const SizedBox.shrink(),
                ),
                onSubmitted: (_) => _tryPin(),
                onChanged: (_) {
                  if (_wrong) setState(() => _wrong = false);
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _tryPin,
                child: Text(l10n.unlockLabel),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
