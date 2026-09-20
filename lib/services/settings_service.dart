import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("darkMode", value);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("darkMode") ?? false;
  }

  static Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("language", value);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("language") ?? "en";
  }

  static Future<void> setSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("sound", value);
  }

  static Future<bool> getSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("sound") ?? true;
  }

  static Future<void> setVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("vibration", value);
  }

  static Future<bool> getVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("vibration") ?? true;
  }
}
