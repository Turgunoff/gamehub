import 'package:shared_preferences/shared_preferences.dart';

/// Sozlamalarni boshqarish uchun service
/// SharedPreferences dan foydalanadi (oddiy sozlamalar uchun)
class SettingsService {
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyLanguage = 'language';
  static const String _keyTournamentReminders = 'tournament_reminders';

  SharedPreferences? _prefs;

  /// SharedPreferences ni ishga tushirish
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Notifications
  bool get notificationsEnabled => _prefs?.getBool(_keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool(_keyNotificationsEnabled, value);
  }

  /// Vibration (Haptic feedback)
  bool get vibrationEnabled => _prefs?.getBool(_keyVibrationEnabled) ?? true;
  Future<void> setVibrationEnabled(bool value) async {
    await _prefs?.setBool(_keyVibrationEnabled, value);
  }

  /// Language (uz, en)
  String get language => _prefs?.getString(_keyLanguage) ?? 'uz';
  Future<void> setLanguage(String value) async {
    await _prefs?.setString(_keyLanguage, value);
  }

  /// Tournament Reminders
  bool get tournamentReminders => _prefs?.getBool(_keyTournamentReminders) ?? true;
  Future<void> setTournamentReminders(bool value) async {
    await _prefs?.setBool(_keyTournamentReminders, value);
  }

  /// Barcha sozlamalarni tozalash
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
