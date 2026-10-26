import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'l10n/app_localizations.dart';
import 'core/theme.dart';
import 'data/providers.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/share_intake/share_intake_screen.dart';
import 'reminders/reminder_service.dart';

/// Used by the share intake flow to push a screen before the first frame.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Text of the message shared into the app, waiting to be turned into tasks.
final pendingShareProvider = StateProvider<String?>((ref) => null);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LekasApp()));
}

/// One time start up: notification plugin, channels and the reminder
/// schedule for the current 14 day window.
final appInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(reminderServiceProvider);
  await service.init();
  await service.syncAll();
});

class LekasApp extends ConsumerStatefulWidget {
  const LekasApp({super.key});

  @override
  ConsumerState<LekasApp> createState() => _LekasAppState();
}

class _LekasAppState extends ConsumerState<LekasApp> with WidgetsBindingObserver {
  StreamSubscription<List<SharedMediaFile>>? _shareSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initShareIntent();
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Listens for text shared from other apps (design section 6.2).
  void _initShareIntent() {
    final intent = ReceiveSharingIntent.instance;
    _shareSubscription =
        intent.getMediaStream().listen(_onSharedMedia, onError: (Object _) {
      // A broken intent must never crash the app.
    });
    unawaited(intent.getInitialMedia().then((media) {
      _onSharedMedia(media);
      intent.reset();
    }));
  }

  void _onSharedMedia(List<SharedMediaFile> media) {
    final text = media
        .where((file) => file.type == SharedMediaType.text)
        .map((file) => file.path.trim())
        .where((value) => value.isNotEmpty)
        .join('\n');
    if (text.isEmpty) return;
    ref.read(pendingShareProvider.notifier).state = text;
    _pushShareIntake(text);
  }

  void _pushShareIntake(String text) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    ref.read(pendingShareProvider.notifier).state = null;
    navigator.push(MaterialPageRoute<void>(
      builder: (_) => ShareIntakeScreen(message: text),
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Covers the time zone change case: reconcile on every return to the
    // foreground (design section 4.6, point 7).
    if (state == AppLifecycleState.resumed) {
      ref.read(reminderServiceProvider).syncAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final startup = ref.watch(appInitProvider);
    final onboarded = ref.watch(onboardedProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Keeps the schedule in line with every task change.
    ref.watch(reminderSyncProvider);

    return MaterialApp(
      title: 'Lekas',
      navigatorKey: navigatorKey,
      locale: locale.value ?? const Locale('id'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode.value ?? ThemeMode.system,
      home: startup.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        // A notification failure must never keep the app from opening.
        error: (error, stack) => _Home(onboarded: onboarded),
        data: (_) => _Home(onboarded: onboarded),
      ),
    );
  }
}

class _Home extends ConsumerStatefulWidget {
  const _Home({required this.onboarded});

  final AsyncValue<bool> onboarded;

  @override
  ConsumerState<_Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<_Home> {
  @override
  void initState() {
    super.initState();
    // A share that arrived before the navigator existed is handled here.
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingShare());
  }

  void _consumePendingShare() {
    if (!mounted) return;
    final pending = ref.read(pendingShareProvider);
    if (pending == null) return;
    ref.read(pendingShareProvider.notifier).state = null;
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.push(MaterialPageRoute<void>(
      builder: (_) => ShareIntakeScreen(message: pending),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.onboarded.when(
      data: (value) => value ? const HomeShell() : const OnboardingScreen(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const OnboardingScreen(),
    );
  }
}
