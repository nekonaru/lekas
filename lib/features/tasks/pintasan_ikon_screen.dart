import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show MethodChannel, MissingPluginException, PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

class PintasanIkonScreen extends ConsumerStatefulWidget {
  const PintasanIkonScreen({super.key});

  @override
  ConsumerState<PintasanIkonScreen> createState() => _PintasanIkonScreenState();
}

class _PintasanIkonScreenState extends ConsumerState<PintasanIkonScreen> {
  static const _shortcutsKey = 'launcher_shortcuts_enabled';
  static const _persistentKey = 'persistent_notification';

  bool _shortcutsEnabled = false;
  bool _persistentEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final shortcuts = await repo.get(_shortcutsKey);
    final persistent = await repo.get(_persistentKey);
    if (!mounted) return;
    setState(() {
      _shortcutsEnabled = shortcuts == 'true';
      _persistentEnabled = persistent == 'true';
    });
  }

  Future<void> _toggleShortcuts() async {
    final l10n = AppLocalizations.of(context)!;
    final next = !_shortcutsEnabled;
    await ref.read(settingsRepositoryProvider).set(_shortcutsKey, next ? 'true' : 'false');
    if (!mounted) return;
    setState(() => _shortcutsEnabled = next);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l10n.appIconShortcut}: ${next ? l10n.enabledLabel : l10n.disabledLabel}',
        ),
      ),
    );
  }

  Future<void> _togglePersistentNotification(bool value) async {
    await ref.read(settingsRepositoryProvider).set(_persistentKey, value ? 'true' : 'false');
    if (!mounted) return;
    setState(() => _persistentEnabled = value);
  }

  /// The quick settings tile lives in the notification shade, so the system
  /// notification screen of this app is where the user manages it.
  Future<void> _openQuickSettings() async {
    try {
      await const MethodChannel('lekas/platform').invokeMethod<void>(
        'openNotificationSettings',
      );
    } on PlatformException {
      // Vendor removed the screen; there is nothing else to open.
    } on MissingPluginException {
      // Not running on Android.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.iconShortcutsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.appIconShortcut),
            subtitle: Text(l10n.appIconShortcutSubtitle),
            trailing: Icon(
              _shortcutsEnabled ? Icons.check_circle : Icons.shortcut,
              color: _shortcutsEnabled ? Colors.green : null,
            ),
            onTap: _toggleShortcuts,
          ),
          ListTile(
            title: Text(l10n.quickSettingsTile),
            subtitle: Text(l10n.quickSettingsTileSubtitle),
            trailing: const Icon(Icons.settings),
            onTap: _openQuickSettings,
          ),
          ListTile(
            title: Text(l10n.optionalPersistentNotification),
            subtitle: Text(l10n.optionalPersistentNotificationSubtitle),
            trailing: Switch(
              value: _persistentEnabled,
              onChanged: _togglePersistentNotification,
            ),
          ),
        ],
      ),
    );
  }
}
