import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../../services/settings_service.dart';
import '../../services/notification_service.dart';
import '../../services/translation_data.dart';
import '../../services/audio_service.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool sound = true;
  bool vibration = true;
  String languageCode = "en";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    darkMode = await SettingsService.getDarkMode();
    sound = await SettingsService.getSound();
    vibration = await SettingsService.getVibration();
    languageCode = await SettingsService.getLanguage();
    setState(() {});
  }

  void _testVibration() async {
    if (vibration && (await Vibration.hasVibrator() ?? false)) {
      Vibration.vibrate(duration: 300);
    }
  }

  void _testSound() async {
    await AudioService.playSuccessSound();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        final lang = locale.languageCode;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(TranslationData.translate('settings', lang)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(TranslationData.translate('appearance', lang)),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: Text(TranslationData.translate('dark_mode', lang)),
                value: darkMode,
                onChanged: (v) async {
                  await SettingsService.setDarkMode(v);
                  themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                  setState(() => darkMode = v);
                },
              ),
              const Divider(),
              _buildSectionHeader(TranslationData.translate('language', lang)),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(TranslationData.translate('language', lang)),
                trailing: DropdownButton<String>(
                  value: languageCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: "en", child: Text("English")),
                    DropdownMenuItem(value: "fr", child: Text("Français")),
                    DropdownMenuItem(value: "ar", child: Text("العربية")),
                  ],
                  onChanged: (val) async {
                    if (val != null) {
                      await SettingsService.setLanguage(val);
                      localeNotifier.value = Locale(val);
                      setState(() => languageCode = val);
                    }
                  },
                ),
              ),
              const Divider(),
              _buildSectionHeader(TranslationData.translate('feedback', lang)),
              SwitchListTile(
                secondary: const Icon(Icons.volume_up),
                title: Text(TranslationData.translate('sound', lang)),
                value: sound,
                onChanged: (v) async {
                  await SettingsService.setSound(v);
                  setState(() => sound = v);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.vibration),
                title: Text(TranslationData.translate('vibration', lang)),
                value: vibration,
                onChanged: (v) async {
                  await SettingsService.setVibration(v);
                  setState(() => vibration = v);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edgesensor_high),
                title: Text(TranslationData.translate('test_vibration', lang)),
                onTap: _testVibration,
              ),
              ListTile(
                leading: const Icon(Icons.volume_down_alt),
                title: const Text("Test Sound"), // Added test sound
                onTap: _testSound,
              ),
              const Divider(),
              _buildSectionHeader(TranslationData.translate('system', lang)),
              ListTile(
                leading: const Icon(Icons.notifications_active),
                title: Text(TranslationData.translate('test_notif', lang)),
                onTap: () => NotificationService.show(
                  TranslationData.translate('app_title', lang),
                  "Notifications active!",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF1565C0),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
