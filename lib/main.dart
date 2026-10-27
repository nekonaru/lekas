import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'l10n/app_localizations.dart';
import 'core/theme.dart';
import 'data/providers.dart';
import 'features/home/home_shell.dart';
import 'features/home/home_widget_sync.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/quick_add/quick_add_sheet.dart';
import 'features/share_intake/share_intake_screen.dart';
import 'features/tasks/fokus_hari_ini_screen.dart';
import 'features/tasks/attendance_screen.dart';
import 'reminders/reminder_service.dart';

/// Used by the share intake flow to push a screen before the first frame.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Text of the message shared into the app, waiting to be turned into tasks.
final pendingShareProvider = StateProvider<String?>((ref) => null);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // A checkbox tap on a home screen widget runs this in its own isolate
  // (design section 7.8).
  unawaited(
    HomeWidget.registerInteractivityCallback(widgetBackgroundCallback)
        .catchError((Object error) {
      debugPrint('widget callback registration failed: $error');
      return false;
    }),
  );
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
  StreamSubscription<Uri?>? _widgetSubscription;

  /// Keeps the stored notification route from being pushed twice when the
  /// start up frame and the resumed event race each other.
  bool _consumingRoute = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initShareIntent();
    _initWidgetClicks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A tap on a notification action while the app was killed stores its
      // route before the app finishes starting (design section 5.24).
      _consumeStoredRoute();
    });
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    _widgetSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handles the launch uri of a home screen widget: the add button opens
  /// quick add, everything else simply lands in the app (design 7.8).
  void _initWidgetClicks() {
    _widgetSubscription = HomeWidget.widgetClicked.listen(
      (uri) {
        if (uri != null) _onWidgetUri(uri);
      },
      onError: (Object _) {
        // A missing widget platform must never break start up.
      },
    );
    unawaited(
      HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
        if (uri != null) _onWidgetUri(uri);
      }).catchError((Object _) {}),
    );
  }

  void _onWidgetUri(Uri uri) {
    if (uri.host != 'quickadd') return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) return;
      showModalBottomSheet<void>(
        context: navigator.context,
        isScrollControlled: true,
        builder: (_) => const QuickAddSheet(),
      );
    });
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
      // A background action button may have stored a route while paused.
      _consumeStoredRoute();
      // The widgets may have been tapped while the app was away.
      unawaited(syncHomeWidgets(ref.read(appDatabaseProvider)).catchError(
        (Object error, StackTrace stack) {
          debugPrint('widget sync failed: $error\n$stack');
        },
      ));
    }
  }

  /// Opens the screen a notification action asked for, once the navigator
  /// exists (design sections 5.19 and 5.24).
  void _pushNotificationRoute(String route) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    if (route == kRouteFocus) {
      navigator.push(MaterialPageRoute<void>(
        builder: (_) => const FokusHariIniScreen(),
      ));
      return;
    }
    if (route.startsWith(kRouteAttendancePrefix)) {
      final spaceId = route.substring(kRouteAttendancePrefix.length);
      if (spaceId.isEmpty) return;
      navigator.push(MaterialPageRoute<void>(
        builder: (_) => AttendanceScreen(spaceId: spaceId),
      ));
    }
  }

  /// Reads the route the background isolate stored in settings and clears
  /// it, so the picker opens exactly once.
  Future<void> _consumeStoredRoute() async {
    if (_consumingRoute) return;
    _consumingRoute = true;
    try {
      final settings = ref.read(settingsRepositoryProvider);
      final route = await settings.get(kPendingRouteKey);
      if (route == null || route.isEmpty) return;
      await settings.set(kPendingRouteKey, '');
      if (!mounted) return;
      _pushNotificationRoute(route);
    } finally {
      _consumingRoute = false;
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
    // Keeps the home screen widgets in line with the data (design 7.8).
    ref.watch(homeWidgetSyncProvider);

    // A tap on the action button while the app was already alive lands
    // here instead of in settings (design section 5.24).
    ref.listen(pendingNotificationRouteProvider, (previous, next) {
      if (next == null) return;
      ref.read(pendingNotificationRouteProvider.notifier).state = null;
      _pushNotificationRoute(next);
    });

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
