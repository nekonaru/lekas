import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'data/providers.dart';
import 'features/home/home_shell.dart';

void main() {
  runApp(const ProviderScope(child: LekasApp()));
}

class LekasApp extends ConsumerWidget {
  const LekasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appDatabaseProvider);
    return MaterialApp(
      title: 'Lekas',
      locale: const Locale('id'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const HomeShell(),
    );
  }
}