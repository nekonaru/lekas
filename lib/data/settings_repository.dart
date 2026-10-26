import 'database.dart';

class SettingsRepository {
  final AppDatabase db;
  SettingsRepository(this.db);

  Future<String?> get(String key) async {
    final row = await (db.select(db.settings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await db.customStatement('''
      INSERT INTO settings (key, value) VALUES (?, ?)
      ON CONFLICT(key) DO UPDATE SET value = excluded.value
    ''', [key, value]);
  }

  Future<String> getLanguage() async {
    final value = await get('language');
    return value ?? 'id';
  }

  Future<void> setLanguage(String language) async {
    await set('language', language);
  }

  Future<bool> getDarkMode() async {
    final value = await get('dark_mode');
    return value == 'true';
  }

  Future<void> setDarkMode(bool enabled) async {
    await set('dark_mode', enabled ? 'true' : 'false');
  }
}
