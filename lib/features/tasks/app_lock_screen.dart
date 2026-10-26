import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appLockTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.enableAppLock),
            subtitle: Text(l10n.appLockMethod),
            trailing: Switch(
              value: false,
              onChanged: (v) {},
            ),
          ),
          ListTile(
            title: Text(l10n.schoolModeTheme),
            subtitle: Text(l10n.schoolModeThemeSubtitle),
            trailing: Switch(
              value: false,
              onChanged: (v) {},
            ),
          ),
        ],
      ),
    );
  }
}
