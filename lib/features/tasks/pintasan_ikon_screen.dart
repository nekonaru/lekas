import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show MethodChannel, MissingPluginException, PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

/// The notification screen of this app: one entry point to the system
/// notification page where the user silences, blocks or uninstalls any
/// notification channel Lekas sends. The screen itself ships no toggles;
/// the OS owns notification policy.
class PintasanIkonScreen extends ConsumerStatefulWidget {
  const PintasanIkonScreen({super.key});

  @override
  ConsumerState<PintasanIkonScreen> createState() => _PintasanIkonScreenState();
}

class _PintasanIkonScreenState extends ConsumerState<PintasanIkonScreen> {
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
      appBar: AppBar(title: Text(l10n.notificationChannelsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.quickSettingsTile),
            subtitle: Text(l10n.quickSettingsTileSubtitle),
            leading: const Icon(Icons.settings),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openQuickSettings,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.notificationChannelsHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
