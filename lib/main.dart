import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme.dart';
import 'data/providers.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  runApp(const ProviderScope(child: LekasApp()));
}

class LekasApp extends ConsumerWidget {
  const LekasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appDatabaseProvider);
    final onboarded = ref.watch(onboardedProvider);

    return MaterialApp(
      title: 'Lekas',
      locale: const Locale('id'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: onboarded.when(
        data: (v) => v ? const HomeShell() : const OnboardingScreen(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const OnboardingScreen(),
      ),
    );
  }
}
