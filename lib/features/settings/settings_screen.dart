import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final language =
        await ref.read(settingsRepositoryProvider).getLanguage();
    final themeMode = await ref.read(themeModeProvider.future);
    if (!mounted) return;
    setState(() {
      _language = language;
      _themeMode = themeMode;
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
