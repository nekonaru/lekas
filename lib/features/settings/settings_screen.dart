import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_service.dart';
import 'backup_screen.dart';
import 'diagnostic_screen.dart';
import '../tasks/app_lock_screen.dart';
import '../tasks/backup_auto_screen.dart';
import '../tasks/duplicate_detection_screen.dart';
import '../tasks/export_gambar_pdf_screen.dart';
import '../tasks/ganti_semester_screen.dart';
import '../tasks/import_merge_screen.dart';
import '../tasks/mode_demo_screen.dart';
import '../tasks/pintasan_ikon_screen.dart';
import '../tasks/tugas_berulang_screen.dart';
import '../tasks/widget_lanjutan_screen.dart';

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
    final current = _themeMode ?? ThemeMode.system;
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.darkMode),
        children: [
          for (final mode in const [ThemeMode.system, ThemeMode.light, ThemeMode.dark])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, mode),
              child: Text(mode.name),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final language = _language ?? 'id';
    final themeMode = _themeMode ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(language == 'id' ? l10n.indonesian : l10n.english),
            onTap: _pickLanguage,
          ),
          ListTile(
            title: Text(l10n.levelLabel),
            subtitle: Text(
                _level == 'school' ? l10n.school : l10n.college),
            onTap: _pickLevel,
          ),
          ListTile(
            title: Text(l10n.darkMode),
            subtitle: Text(themeMode.name),
            onTap: _pickThemeMode,
          ),
          ListTile(
            title: Text(l10n.accentColor),
            subtitle: Text(
              _accent == null
                  ? l10n.colorDefault
                  : '#${_accent!.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            ),
            leading: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _accent ?? AppTheme.accentColor,
                shape: BoxShape.circle,
              ),
            ),
            onTap: _pickAccent,
          ),
          ListTile(
            title: Text(l10n.fontSize),
            subtitle: Text(
              _fontScale == 0.85
                  ? l10n.fontSmall
                  : _fontScale == 1.15
                      ? l10n.fontLarge
                      : _fontScale == 1.3
                          ? l10n.fontXlarge
                          : l10n.fontNormal,
            ),
            onTap: _pickFontScale,
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.reminderIntensity),
            subtitle: Text(_intensityLabel(l10n, _intensity)),
            onTap: _pickIntensity,
          ),
          ListTile(
            title: Text(l10n.notificationBudget),
            subtitle: Text(l10n.budgetPerDay(_budget)),
            onTap: _pickBudget,
          ),
          SwitchListTile(
            title: Text(l10n.overdueTaskReminderTitle),
            subtitle: Text(l10n.overdueReminderToggle),
            value: _overdueDigest,
            onChanged: (value) => _setFlag(
              'overdue_digest_enabled',
              value,
              (next) => _overdueDigest = next,
            ),
          ),
          SwitchListTile(
            title: Text(l10n.morningSummaryNotificationTitle),
            subtitle: Text(l10n.summaryMorningToggle),
            value: _morningSummary,
            onChanged: (value) => _setFlag(
              'summary_morning_enabled',
              value,
              (next) => _morningSummary = next,
            ),
          ),
          SwitchListTile(
            title: Text(l10n.eveningSummaryTitle),
            subtitle: Text(l10n.summaryEveningToggle),
            value: _eveningSummary,
            onChanged: (value) => _setFlag(
              'summary_evening_enabled',
              value,
              (next) => _eveningSummary = next,
            ),
          ),
          SwitchListTile(
            title: Text(l10n.weeklySummaryTitle),
            subtitle: Text(l10n.summaryWeeklyToggle),
            value: _weeklySummary,
            onChanged: (value) => _setFlag(
              'summary_weekly_enabled',
              value,
              (next) => _weeklySummary = next,
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.exportBackup),
            trailing: const Icon(Icons.file_download),
            onTap: () => _push(const BackupScreen()),
          ),
          ListTile(
            title: Text(l10n.importBackup),
            trailing: const Icon(Icons.file_upload),
            onTap: () => _push(const BackupScreen()),
          ),
          ListTile(
            title: Text(l10n.checkReminder),
            trailing: const Icon(Icons.notifications),
            onTap: () => _push(const DiagnosticScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(l10n.appLockTitle),
            onTap: () => _push(const AppLockScreen()),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: Text(l10n.simpleRecurringTasksTitle),
            onTap: () => _push(const TugasBerulangScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: Text(l10n.duplicateDetectionTitle),
            onTap: () => _push(const DuplicateDetectionScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.autoBackupTitle),
            onTap: () => _push(const BackupAutoScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.merge_type),
            title: Text(l10n.mergeImportTitle),
            onTap: () => _push(const ImportMergeScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.exportImagePdfTitle),
            onTap: () => _push(const ExportGambarPDFScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(l10n.changeSemesterTitle),
            onTap: () => _push(const GantiSemesterScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.widgets_outlined),
            title: Text(l10n.advancedWidgetsTitle),
            onTap: () => _push(const WidgetLanjutanScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.shortcut),
            title: Text(l10n.iconShortcutsTitle),
            onTap: () => _push(const PintasanIkonScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: Text(l10n.demoModeTitle),
            onTap: () => _push(const ModeDemoScreen()),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appVersionLabel),
            subtitle: Text(appVersion),
          ),
        ],
      ),
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
