import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/components/lekas_logo.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_service.dart';
import 'backup_screen.dart';
import 'diagnostic_screen.dart';
import '../tasks/app_lock_screen.dart';
import '../tasks/duplicate_detection_screen.dart';
import '../tasks/export_gambar_pdf_screen.dart';
import '../semester/semester_screen.dart';
import '../tasks/import_merge_screen.dart';
import '../../core/version_checker.dart';
import 'update_dialog.dart';
import '../tasks/mode_demo_screen.dart';
import '../tasks/pintasan_ikon_screen.dart';
import '../tasks/tugas_berulang_screen.dart';
import '../tasks/tasks_screen.dart';
import '../tasks/exam_screen.dart';
import '../tasks/fokus_hari_ini_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _language;
  String _level = 'college';
  ThemeMode? _themeMode;
  Color? _accent;
  double _fontScale = 1.0;
  String _intensity = 'normal';
  int _budget = kDailyNotificationBudget;
  bool _overdueDigest = true;
  bool _morningSummary = true;
  bool _eveningSummary = true;
  bool _weeklySummary = true;
  bool _autoUpdateCheck = true;
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = ref.read(settingsRepositoryProvider);
    final language = await settings.getLanguage();
    final level = await ref.read(levelProvider.future);
    final themeMode = await ref.read(themeModeProvider.future);
    final accent = await ref.read(accentColorProvider.future);
    final fontScale = await ref.read(fontScaleProvider.future);
    final intensity = await settings.get('reminder_intensity');
    final budget = int.tryParse(await settings.get('notification_budget') ?? '');
    final digest = await settings.get('overdue_digest_enabled');
    final morning = await settings.get('summary_morning_enabled');
    final evening = await settings.get('summary_evening_enabled');
    final weekly = await settings.get('summary_weekly_enabled');
    final autoUpdate = await settings.get('auto_update_check');
    if (!mounted) return;
    setState(() {
      _language = language;
      _level = level;
      _themeMode = themeMode;
      _accent = accent;
      _fontScale = fontScale;
      _intensity = intensity ?? 'normal';
      _budget = budget ?? kDailyNotificationBudget;
      _overdueDigest = digest != '0';
      _morningSummary = morning != '0';
      _eveningSummary = evening != '0';
      _weeklySummary = weekly != '0';
      _autoUpdateCheck = autoUpdate != '0';
    });
  }

  Future<void> _pickLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.language),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'id'),
            child: Text(AppLocalizations.of(context)!.indonesian),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'en'),
            child: Text(AppLocalizations.of(context)!.english),
          ),
        ],
      ),
    );
    if (selected == null) return;
    await ref.read(settingsRepositoryProvider).setLanguage(selected);
    if (!mounted) return;
    ref.invalidate(localeProvider);
    setState(() => _language = selected);
  }

  /// College or school: stored as one setting and applied to every space
  /// at once, so switching never needs a reinstall.
  Future<void> _pickLevel() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.levelLabel),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'college'),
            child: Text(l10n.college),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'school'),
            child: Text(l10n.school),
          ),
        ],
      ),
    );
    if (selected == null || selected == _level || !mounted) return;
    await applyLevel(ref, selected);
    if (!mounted) return;
    setState(() => _level = selected);
  }

  Future<void> _pickThemeMode() async {
    final l10n = AppLocalizations.of(context)!;
    String label(ThemeMode mode) => switch (mode) {
          ThemeMode.system => l10n.themeModeSystem,
          ThemeMode.light => l10n.light,
          ThemeMode.dark => l10n.dark,
        };
    final current = _themeMode ?? ThemeMode.system;
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.darkMode),
        children: [
          for (final mode in const [ThemeMode.system, ThemeMode.light, ThemeMode.dark])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, mode),
              child: Text(label(mode)),
            ),
        ],
      ),
    );
    if (selected == null || selected == current) return;
    await ref.read(settingsRepositoryProvider).set('theme_mode', selected.name);
    if (!mounted) return;
    ref.invalidate(themeModeProvider);
    setState(() => _themeMode = selected);
  }

  /// Opens the accent picker. The result carries an optional color and an
  /// optional theme mode, because the presets set both at once.
  Future<void> _pickAccent() async {
    final pick = await showDialog<AccentPick>(
      context: context,
      builder: (dialogContext) =>
          _AccentPickerDialog(current: _accent ?? AppTheme.accentColor),
    );
    if (pick == null) return;
    if (pick.color == null && pick.mode == null) return;
    final repository = ref.read(settingsRepositoryProvider);
    await repository.set(
      'accent_color',
      pick.color == null ? '' : pick.color!.toARGB32().toString(),
    );
    if (pick.mode != null) {
      await repository.set('theme_mode', pick.mode!.name);
    }
    if (!mounted) return;
    ref.invalidate(accentColorProvider);
    ref.invalidate(themeModeProvider);
    setState(() {
      _accent = (pick.color == null || pick.color == AppTheme.accentColor)
          ? null
          : pick.color;
      if (pick.mode != null) _themeMode = pick.mode;
    });
  }

  /// Font size multiplies the system text scale, so the accessibility
  /// setting of the phone keeps working underneath it.
  Future<void> _pickFontScale() async {
    final l10n = AppLocalizations.of(context)!;
    final options = <String, double>{
      l10n.fontSmall: 0.85,
      l10n.fontNormal: 1.0,
      l10n.fontLarge: 1.15,
      l10n.fontXlarge: 1.3,
    };
    final selected = await showDialog<double>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.fontSize),
        children: [
          for (final entry in options.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, entry.value),
              child: Text(entry.key),
            ),
        ],
      ),
    );
    if (selected == null || selected == _fontScale) return;
    final key = switch (selected) {
      0.85 => 'small',
      1.15 => 'large',
      1.3 => 'xlarge',
      _ => 'normal',
    };
    await ref.read(settingsRepositoryProvider).set('font_scale', key);
    if (!mounted) return;
    ref.invalidate(fontScaleProvider);
    setState(() => _fontScale = selected);
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  String _intensityLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'calm':
        return l10n.intensityCalm;
      case 'eager':
        return l10n.intensityEager;
      default:
        return l10n.intensityNormal;
    }
  }

  /// Design section 5.21: calm, normal or eager reminders.
  Future<void> _pickIntensity() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.reminderIntensity),
        children: [
          for (final value in const ['calm', 'normal', 'eager'])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, value),
              child: Text(_intensityLabel(l10n, value)),
            ),
        ],
      ),
    );
    if (selected == null || selected == _intensity) return;
    await ref.read(settingsRepositoryProvider).set('reminder_intensity', selected);
    if (!mounted) return;
    setState(() => _intensity = selected);
    await ref.read(reminderServiceProvider).syncAll();
  }

  /// Design section 5.21: how many non critical notifications a day may use.
  Future<void> _pickBudget() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.notificationBudget),
        children: [
          for (final value in const [4, 8, 12, 16])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, value),
              child: Text(l10n.budgetPerDay(value)),
            ),
        ],
      ),
    );
    if (selected == null || selected == _budget) return;
    await ref.read(settingsRepositoryProvider).set('notification_budget', '$selected');
    if (!mounted) return;
    setState(() => _budget = selected);
    await ref.read(reminderServiceProvider).syncAll();
  }

  /// Any daily notification can be switched off (design sections 5.12 and
  /// 5.22); the flag is stored and the schedule is rebuilt right away.
  Future<void> _setFlag(
    String key,
    bool value,
    void Function(bool) assign,
  ) async {
    await ref.read(settingsRepositoryProvider).set(key, value ? '1' : '0');
    if (!mounted) return;
    setState(() => assign(value));
    await ref.read(reminderServiceProvider).syncAll();
  }

  /// The about dialog: what the app is, in one breath, and the license.
  Future<void> _showAbout() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lekas'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.aboutBody),
              const SizedBox(height: 14),
              Text(
                'v$appVersion · MIT License',
                style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                      color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.closeLabel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              openUpdateUrl('https://github.com/nekonaru/lekas');
            },
            child: Text(l10n.viewOnGithub),
          ),
        ],
      ),
    );
  }

  Future<void> _showLicense() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.licenseTitle),
        content: SingleChildScrollView(
          child: const Text(
            'MIT License\n'
            'Copyright (c) 2026 nekonaru\n\n'
            'Permission is hereby granted, free of charge, to any person '
            'obtaining a copy of this software and associated documentation '
            'files (the "Software"), to deal in the Software without '
            'restriction, including without limitation the rights to use, '
            'copy, modify, merge, publish, distribute, sublicense, and/or '
            'sell copies of the Software, and to permit persons to whom the '
            'Software is furnished to do so, subject to the following '
            'conditions: the Software is provided as is, without warranty '
            'of any kind.',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.closeLabel),
          ),
        ],
      ),
    );
  }

  /// The exam countdown widget tracks the course with the next deadline,
  /// so this tile opens the exam list of the course due next.
  Future<void> _openExamCountdown() async {
    final l10n = AppLocalizations.of(context)!;
    final tasks = await ref.read(taskRepositoryProvider).getTasks(
          includeInbox: false,
        );
    if (!mounted) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final upcoming = tasks
        .where((t) =>
            t.spaceId != null &&
            t.deadline != null &&
            t.deadline! > now)
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
    if (upcoming.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noExamsYet)),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExamScreen(spaceId: upcoming.first.spaceId!),
      ),
    );
  }

  /// Flips the once a day background update check; deliberately not wired
  /// into [_setFlag], because it has nothing to do with reminder syncing.
  Future<void> _setAutoUpdateCheck(bool value) async {
    await ref.read(settingsRepositoryProvider).set(
          'auto_update_check',
          value ? '1' : '0',
        );
    if (!mounted) return;
    setState(() => _autoUpdateCheck = value);
  }

  /// Asks GitHub for the newest release and, depending on the answer,
  /// opens the update dialog, celebrates being current, or says the
  /// check failed. The network call lives on the user's tap (or the once
  /// a day background check), never on its own.
  Future<void> _checkUpdate() async {
    if (_checkingUpdate) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _checkingUpdate = true);
    final result = await ref.read(versionCheckerProvider).check();
    if (!mounted) return;
    setState(() => _checkingUpdate = false);
    switch (result) {
      case UpToDate(:final version):
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.appUpToDate(version))),
        );
      case UpdateAvailable(:final version, :final url):
        await showUpdateAvailableDialog(
          context,
          version: version,
          url: url,
        );
      case UpdateCheckFailed():
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.updateCheckFailed)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final language = _language ?? 'id';
    final themeMode = _themeMode ?? ThemeMode.system;
    final colors = Theme.of(context).colorScheme;

    // No app bar here: the shell owns the tab title and the drawer, so
    // the settings list starts at the top of the body like other tabs.
    return Scaffold(
      body: ListView(
        children: [
          // The brand band echoes the drawer header.
          Container(
            decoration: BoxDecoration(gradient: AppTheme.brandGradient),
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Row(
                  children: [
                    const LekasLogo(size: 46),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lekas',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.splashTagline,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'v$appVersion',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- Appearance ---
          _settingsSection(l10n.sectionAppearance, Icons.palette_outlined),
          _groupCard(colors, [
            _tintedTile(
              Icons.language,
              Color(0xFF3B82F6),
              l10n.language,
              subtitle: language == 'id' ? l10n.indonesian : l10n.english,
              onTap: _pickLanguage,
            ),
            _tintedTile(
              Icons.school_outlined,
              Color(0xFF10B981),
              l10n.levelLabel,
              subtitle: _level == 'school' ? l10n.school : l10n.college,
              onTap: _pickLevel,
            ),
            _tintedTile(
              Icons.dark_mode_outlined,
              Color(0xFF8B5CF6),
              l10n.darkMode,
              subtitle: themeMode == ThemeMode.system
                  ? l10n.themeModeSystem
                  : themeMode == ThemeMode.dark
                      ? l10n.dark
                      : l10n.light,
              onTap: _pickThemeMode,
            ),
            _tintedTile(
              Icons.color_lens_outlined,
              Color(0xFFEC4899),
              l10n.accentColor,
              subtitle: _accent == null
                  ? l10n.colorDefault
                  : '#${_accent!.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              trailing: _accent == null
                  ? null
                  : Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                      ),
                    ),
              onTap: _pickAccent,
            ),
            _tintedTile(
              Icons.text_fields,
              Color(0xFF06B6D4),
              l10n.fontSize,
              subtitle: _fontScale == 0.85
                  ? l10n.fontSmall
                  : _fontScale == 1.15
                      ? l10n.fontLarge
                      : _fontScale == 1.3
                          ? l10n.fontXlarge
                          : l10n.fontNormal,
              onTap: _pickFontScale,
            ),
          ]),

          // --- Reminders ---
          _settingsSection(l10n.sectionReminders, Icons.notifications_outlined),
          _groupCard(colors, [
            _tintedTile(
              Icons.notifications_active_outlined,
              Color(0xFFF97316),
              l10n.reminderIntensity,
              subtitle: _intensityLabel(l10n, _intensity),
              onTap: _pickIntensity,
            ),
            _tintedTile(
              Icons.price_check_outlined,
              Color(0xFFEF4444),
              l10n.notificationBudget,
              subtitle: l10n.budgetPerDay(_budget),
              onTap: _pickBudget,
            ),
            _toggleTile(
              Icons.alarm,
              Color(0xFFEF4444),
              l10n.overdueTaskReminderTitle,
              l10n.overdueReminderToggle,
              _overdueDigest,
              (value) => _setFlag(
                'overdue_digest_enabled',
                value,
                (next) => _overdueDigest = next,
              ),
            ),
            _toggleTile(
              Icons.wb_sunny_outlined,
              Color(0xFFF59E0B),
              l10n.morningSummaryNotificationTitle,
              l10n.summaryMorningToggle,
              _morningSummary,
              (value) => _setFlag(
                'summary_morning_enabled',
                value,
                (next) => _morningSummary = next,
              ),
            ),
            _toggleTile(
              Icons.nights_stay_outlined,
              Color(0xFF6366F1),
              l10n.eveningSummaryTitle,
              l10n.summaryEveningToggle,
              _eveningSummary,
              (value) => _setFlag(
                'summary_evening_enabled',
                value,
                (next) => _eveningSummary = next,
              ),
            ),
            _toggleTile(
              Icons.calendar_month_outlined,
              Color(0xFF10B981),
              l10n.weeklySummaryTitle,
              l10n.summaryWeeklyToggle,
              _weeklySummary,
              (value) => _setFlag(
                'summary_weekly_enabled',
                value,
                (next) => _weeklySummary = next,
              ),
            ),
          ]),

          // --- Backup ---
          _settingsSection(l10n.sectionBackup, Icons.backup_outlined),
          _groupCard(colors, [
            _tintedTile(
              Icons.file_download_outlined,
              Color(0xFF6366F1),
              l10n.exportBackup,
              trailing: _chevron,
              onTap: () => _push(const BackupScreen()),
            ),
            _tintedTile(
              Icons.file_upload_outlined,
              Color(0xFF8B5CF6),
              l10n.importBackup,
              trailing: _chevron,
              onTap: () => _push(const BackupScreen()),
            ),
            _tintedTile(
              Icons.notifications_active_outlined,
              Color(0xFF06B6D4),
              l10n.checkReminder,
              trailing: _chevron,
              onTap: () => _push(const DiagnosticScreen()),
            ),
            _tintedTile(
              Icons.lock_outline,
              Color(0xFF6366F1),
              l10n.appLockTitle,
              trailing: _chevron,
              onTap: () => _push(const AppLockScreen()),
            ),
          ]),

          // --- Tools ---
          _settingsSection(l10n.toolsTitle, Icons.settings_outlined),
          _groupCard(colors, [
            _tintedTile(
              Icons.repeat,
              Color(0xFF10B981),
              l10n.simpleRecurringTasksTitle,
              trailing: _chevron,
              onTap: () => _push(const TugasBerulangScreen()),
            ),
            _tintedTile(
              Icons.copy_all_outlined,
              Color(0xFFF59E0B),
              l10n.duplicateDetectionTitle,
              trailing: _chevron,
              onTap: () => _push(const DuplicateDetectionScreen()),
            ),
            _tintedTile(
              Icons.merge_type,
              Color(0xFF06B6D4),
              l10n.mergeImportTitle,
              trailing: _chevron,
              onTap: () => _push(const ImportMergeScreen()),
            ),
            _tintedTile(
              Icons.share_outlined,
              Color(0xFFEC4899),
              l10n.exportImagePdfTitle,
              trailing: _chevron,
              onTap: () => _push(const ExportGambarPDFScreen()),
            ),
          ]),

          // --- Shortcuts ---
          _settingsSection(l10n.shortcutsTitle, Icons.bolt_outlined),
          _groupCard(colors, [
            _tintedTile(
              Icons.list_alt,
              Color(0xFF6366F1),
              l10n.taskListTitle,
              trailing: _chevron,
              onTap: () => _push(const TasksScreen()),
            ),
            _tintedTile(
              Icons.timer_outlined,
              Color(0xFFEF4444),
              l10n.widgetExamCountdown,
              trailing: _chevron,
              onTap: _openExamCountdown,
            ),
            _tintedTile(
              Icons.star_outline,
              Color(0xFFF59E0B),
              l10n.widgetTodayFocus,
              trailing: _chevron,
              onTap: () => _push(const FokusHariIniScreen()),
            ),
          ]),

          // --- School and demo ---
          _settingsSection(l10n.sectionSchool, Icons.school_outlined),
          _groupCard(colors, [
            _tintedTile(
              Icons.calendar_month_outlined,
              Color(0xFF10B981),
              l10n.semesterTitle,
              trailing: _chevron,
              onTap: () => _push(const SemesterScreen()),
            ),
            _tintedTile(
              Icons.notifications_outlined,
              Color(0xFF8B5CF6),
              l10n.iconShortcutsTitle,
              trailing: _chevron,
              onTap: () => _push(const PintasanIkonScreen()),
            ),
            _tintedTile(
              Icons.play_circle_outline,
              Color(0xFFEC4899),
              l10n.demoModeTitle,
              trailing: _chevron,
              onTap: () => _push(const ModeDemoScreen()),
            ),
          ]),

          // --- Sponsor ---
          _settingsSection(l10n.sponsorTitle, Icons.favorite_border),
          _groupCard(colors, [
            _sponsorRow(
              icon: Icons.favorite,
              color: const Color(0xFFEA4AAA),
              title: 'GitHub Sponsors',
              subtitle: 'github.com/sponsors/nekonaru',
              onTap: () =>
                  openUpdateUrl('https://github.com/sponsors/nekonaru'),
            ),
            _sponsorRow(
              icon: Icons.local_cafe_rounded,
              color: const Color(0xFFFFA726),
              title: 'Saweria',
              subtitle: 'saweria.co/nekonaruu',
              onTap: () => openUpdateUrl('https://saweria.co/nekonaruu'),
            ),
            _sponsorRow(
              icon: Icons.volunteer_activism,
              color: const Color(0xFFF472B6),
              title: 'SociaBuzz',
              subtitle: 'sociabuzz.com/nekonaru/donate',
              onTap: () =>
                  openUpdateUrl('https://sociabuzz.com/nekonaru/donate'),
            ),
            _sponsorRow(
              icon: Icons.card_giftcard,
              color: const Color(0xFF10B981),
              title: 'BagiBagi',
              subtitle: 'bagibagi.co/Nekonaru',
              onTap: () => openUpdateUrl('https://bagibagi.co/Nekonaru'),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
            child: Text(
              l10n.sponsorCaption,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),

          // --- About ---
          _settingsSection(l10n.aboutTitle, Icons.info_outline),
          _groupCard(colors, [
            _tintedTile(
              Icons.info_outline,
              Color(0xFF64748B),
              l10n.aboutLekas,
              trailing: _chevron,
              onTap: _showAbout,
            ),
            _tintedTile(
              Icons.code,
              Color(0xFF1F2937),
              l10n.sourceCodeTitle,
              subtitle: 'github.com/nekonaru/lekas',
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => openUpdateUrl('https://github.com/nekonaru/lekas'),
            ),
            _tintedTile(
              Icons.description_outlined,
              Color(0xFF06B6D4),
              l10n.licenseTitle,
              subtitle: 'MIT',
              onTap: _showLicense,
            ),
            _toggleTile(
              Icons.system_update_alt,
              Color(0xFF6366F1),
              l10n.autoUpdateCheckTitle,
              l10n.autoUpdateCheckSubtitle,
              _autoUpdateCheck,
              (value) => _setAutoUpdateCheck(value),
            ),
            _tintedTile(
              Icons.verified_outlined,
              Color(0xFF10B981),
              l10n.appVersionLabel,
              subtitle: 'v$appVersion · ${l10n.tapToCheckUpdates}',
              trailing: _checkingUpdate
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Icon(Icons.system_update_alt),
              onTap: _checkingUpdate ? null : _checkUpdate,
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static const _chevron = Icon(Icons.chevron_right);

  /// One section header: a small caps label with a tinted glyph to match
  /// the drawer, so the settings reads as the same family of menus.
  Widget _settingsSection(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// One tinted rounded tile: a colored glyph in a soft square, the label
  /// and optional subtitle, an optional trailing control.
  Widget _tintedTile(
    IconData icon,
    Color tint,
    String title, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 20, color: tint),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// One switch row with a tinted glyph, the same shape as the tinted
  /// tiles, so toggles sit inside the card as peers of taps.
  Widget _toggleTile(
    IconData icon,
    Color tint,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 20, color: tint),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  /// One rounded card that groups the rows below a section header.
  /// Paints with Material, not a DecoratedBox, so the ListTiles inside
  /// can paint their background and ink splashes.
  Widget _groupCard(ColorScheme colors, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (final child in children) child,
          ],
        ),
      ),
    );
  }

  /// The sponsor rows: colored circle + platform name + link.
  Widget _sponsorRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// What the accent dialog hands back: a color, a theme mode, or both.
class AccentPick {
  const AccentPick({this.color, this.mode});

  /// Null means the built in indigo.
  final Color? color;

  /// Null means keep the current mode.
  final ThemeMode? mode;
}

/// The accent picker: a light and dark preview toggle, swatches rendered
/// with the colors the seed actually produces, and one tap presets.
class _AccentPickerDialog extends StatefulWidget {
  const _AccentPickerDialog({required this.current});

  final Color current;

  @override
  State<_AccentPickerDialog> createState() => _AccentPickerDialogState();
}

class _AccentPickerDialogState extends State<_AccentPickerDialog> {
  bool? _darkPreview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _darkPreview ??= Theme.of(context).brightness == Brightness.dark;
    final previewBrightness =
        _darkPreview! ? Brightness.dark : Brightness.light;

    return AlertDialog(
      title: Text(l10n.accentColor),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.light_mode_outlined, size: 18),
                label: Text(l10n.previewLight),
              ),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.dark_mode_outlined, size: 18),
                label: Text(l10n.previewDark),
              ),
            ],
            selected: {_darkPreview!},
            onSelectionChanged: (selection) =>
                setState(() => _darkPreview = selection.first),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _previewSwatch(null, previewBrightness, l10n.colorDefault),
              for (final color in AppTheme.containerColors)
                _previewSwatch(color, previewBrightness, null),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: Text(l10n.colorDefault),
                onPressed: () => Navigator.pop(
                  context,
                  const AccentPick(color: null, mode: null),
                ),
              ),
              ActionChip(
                label: Text(l10n.presetMidnight),
                onPressed: () => Navigator.pop(
                  context,
                  const AccentPick(
                    color: Color(0xFF312E81),
                    mode: ThemeMode.dark,
                  ),
                ),
              ),
              ActionChip(
                label: Text(l10n.presetSunset),
                onPressed: () => Navigator.pop(
                  context,
                  const AccentPick(color: Color(0xFFF97316), mode: null),
                ),
              ),
              ActionChip(
                label: Text(l10n.presetForest),
                onPressed: () => Navigator.pop(
                  context,
                  const AccentPick(color: Color(0xFF10B981), mode: null),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.closeLabel),
        ),
      ],
    );
  }

  /// One swatch drawn with the container colors the seed produces in the
  /// previewed brightness, so what you tap is what the app becomes.
  Widget _previewSwatch(
    Color? color,
    Brightness previewBrightness,
    String? label,
  ) {
    final resolved = color ?? AppTheme.accentColor;
    final scheme = ColorScheme.fromSeed(
      seedColor: resolved,
      brightness: previewBrightness,
    );
    final chosen =
        widget.current.toARGB32() == resolved.toARGB32();
    return InkWell(
      onTap: () => Navigator.pop(
        context,
        AccentPick(color: color, mode: null),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Tooltip(
        message: label ?? '',
        child: Container(
          width: 72,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: chosen
                  ? scheme.onSurface
                  : scheme.outlineVariant,
              width: chosen ? 3 : 1,
            ),
          ),
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
