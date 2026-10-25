import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      appBar: AppBar(title: const Text('Kunci Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Aktifkan Kunci Aplikasi'),
            subtitle: const Text('Sidik jari atau PIN'),
            trailing: Switch(
              value: false,
              onChanged: (v) {},
            ),
          ),
          ListTile(
            title: const Text('Tema Mode SMA'),
            subtitle: const Text('Ubah terminologi ke SMA'),
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
