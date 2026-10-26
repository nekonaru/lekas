import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_service.dart';
import 'backup_screen.dart';
import 'diagnostic_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _language;
  ThemeMode? _themeMode;
  String _intensity = 'normal';
  int _budget = kDailyNotificationBudget;
  bool _overdueDigest = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = ref.read(settingsRepositoryProvider);
    final language = await settings.getLanguage();
    final themeMode = await ref.read(themeModeProvider.future);
    final intensity = await settings.get('reminder_intensity');
    final budget = int.tryParse(await settings.get('notification_budget') ?? '');
    final digest = await settings.get('overdue_digest_enabled');
    if (!mounted) return;
    setState(() {
      _language = language;
      _themeMode = themeMode;
      _intensity = intensity ?? 'normal';
      _budget = budget ?? kDailyNotificationBudget;
      _overdueDigest = digest != '0';
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
    ref.invalidate(localeProvider);
    setState(() => _language = selected);
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
    ref.invalidate(themeModeProvider);
    setState(() => _themeMode = selected);
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

  /// Design section 5.22: the daily overdue digest can be switched off.
  Future<void> _setOverdueDigest(bool value) async {
    await ref.read(settingsRepositoryProvider).set(
          'overdue_digest_enabled',
          value ? '1' : '0',
        );
    if (!mounted) return;
    setState(() => _overdueDigest = value);
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
            title: Text(l10n.darkMode),
            subtitle: Text(themeMode.name),
            onTap: _pickThemeMode,
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
            onChanged: _setOverdueDigest,
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
        ],
      ),
    );
  }
}
