import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// The app lock settings: turn it on (with a new PIN), change the PIN, or
/// turn it off. Disabling and changing always ask for the current PIN
/// first, so the lock cannot be silently stripped.
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await ref.read(lockServiceProvider).isEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _loading = false;
    });
  }

  /// Enables the lock: a new PIN arrives from the dialog, is hashed, and
  /// only then is the switch flipped on.
  Future<void> _enable() async {
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => const _PinSetupDialog(),
    );
    if (pin == null || !mounted) return;
    await ref.read(lockServiceProvider).setPin(pin);
    if (!mounted) return;
    setState(() => _enabled = true);
    ref.invalidate(appLockEnabledProvider);
  }

  /// Disabling asks for the current PIN first, so the lock cannot be
  /// silently stripped.
  Future<void> _disable() async {
    if (!await _verifyStep()) return;
    await ref.read(lockServiceProvider).disable();
    if (!mounted) return;
    setState(() => _enabled = false);
    ref.invalidate(appLockEnabledProvider);
  }

  /// The current PIN step: one entry, verified before any change.
  Future<bool> _verifyStep() async {
    final l10n = AppLocalizations.of(context)!;
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => const _PinEntryDialog(),
    );
    if (pin == null || !mounted) return false;
    final ok = await ref.read(lockServiceProvider).verify(pin);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.wrongPin)),
      );
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appLockTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: Text(l10n.enableAppLock),
                  subtitle: Text(l10n.appLockMethod),
                  value: _enabled,
                  onChanged: (value) => value ? _enable() : _disable(),
                ),
                if (_enabled)
                  ListTile(
                    leading: const Icon(Icons.key_outlined),
                    title: Text(l10n.changePinLabel),
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      if (!await _verifyStep()) return;
                      if (!mounted) return;
                      final pin = await navigator.push<String>(
                        MaterialPageRoute(builder: (_) => const _PinSetupDialog()),
                      );
                      if (pin == null || !mounted) return;
                      await ref.read(lockServiceProvider).setPin(pin);
                      if (!mounted) return;
                      ref.invalidate(appLockEnabledProvider);
                    },
                  ),
              ],
            ),
    );
  }
}

/// The new PIN step: enter, then confirm. Only a matching pair of 4 to 6
/// digit PINs pops with the PIN.
class _PinSetupDialog extends StatefulWidget {
  const _PinSetupDialog();

  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// Validates the two entries and pops with the PIN when they agree.
  void _confirm2() {
    final l10n = AppLocalizations.of(context)!;
    if (_pin.text.length < 4 || _pin.text.length > 6) {
      setState(() => _error = l10n.pinTooShort);
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(() => _error = l10n.pinMismatch);
      return;
    }
    Navigator.pop(context, _pin.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.appLockTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pin,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.pinLabel,
              border: const OutlineInputBorder(),
              counter: const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.pinConfirmLabel,
              border: const OutlineInputBorder(),
              errorText: _error,
              counter: const SizedBox.shrink(),
            ),
            onSubmitted: (_) => _confirm2(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _confirm2,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// The current PIN step: one entry that pops with the typed PIN.
class _PinEntryDialog extends StatefulWidget {
  const _PinEntryDialog();

  @override
  State<_PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<_PinEntryDialog> {
  final _pin = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.pinLabel),
      content: TextField(
        controller: _pin,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: InputDecoration(
          labelText: l10n.pinLabel,
          border: const OutlineInputBorder(),
          counter: const SizedBox.shrink(),
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _pin.text),
          child: Text(l10n.unlockLabel),
        ),
      ],
    );
  }
}
