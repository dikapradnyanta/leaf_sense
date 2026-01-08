import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._init();
  SettingsService._init();

  // Keys untuk SharedPreferences
  static const String _keyHapticFeedback = 'haptic_feedback';
  static const String _keySaveHistory = 'save_history';

  // === HAPTIC FEEDBACK ===
  Future<bool> getHapticFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHapticFeedback) ?? true; // Default: ON
  }

  Future<void> setHapticFeedback(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHapticFeedback, value);
  }

  // === SAVE HISTORY ===
  Future<bool> getSaveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySaveHistory) ?? true; // Default: ON
  }

  Future<void> setSaveHistory(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySaveHistory, value);
  }

  // === RESET SEMUA SETTINGS ===
  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}