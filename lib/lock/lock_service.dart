import 'dart:math';

import '../data/settings_repository.dart';
import 'sha256.dart';

/// The app lock: a PIN that gates the app whenever it comes back to the
/// foreground. The PIN is never stored. Only a salted SHA-256 hash is kept
/// in settings, so reading the database cannot reveal it.
class LockService {
  LockService(this._settings);

  final SettingsRepository _settings;

  static const _enabledKey = 'app_lock_enabled';
  static const _saltKey = 'app_lock_salt';
  static const _pinKey = 'app_lock_pin';

  Future<bool> isEnabled() async =>
      await _settings.get(_enabledKey) == '1';

  /// True when [pin] matches the stored hash.
  Future<bool> verify(String pin) async {
    final salt = await _settings.get(_saltKey);
    final stored = await _settings.get(_pinKey);
    if (salt == null || salt.isEmpty || stored == null || stored.isEmpty) {
      return false;
    }
    return hashPin(pin, salt) == stored;
  }

  /// Stores a salted hash of a new PIN and enables the lock.
  Future<void> setPin(String pin) async {
    final salt = _randomSalt();
    await _settings.set(_saltKey, salt);
    await _settings.set(_pinKey, hashPin(pin, salt));
    await _settings.set(_enabledKey, '1');
  }

  /// Clears every lock value, so the lock is off and unforgeable.
  Future<void> disable() async {
    await _settings.set(_enabledKey, '0');
    await _settings.set(_pinKey, '');
    await _settings.set(_saltKey, '');
  }

  String _randomSalt() {
    final random = Random.secure();
    return List.generate(
        8, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
