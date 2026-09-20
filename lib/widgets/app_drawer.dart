import 'package:flutter/material.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../services/translation_data.dart';
import '../main.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        final lang = locale.languageCode;
        
        return Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF1565C0)),
                child: Center(
                  child: Text(
                    TranslationData.translate('app_title', lang),
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: Text(TranslationData.translate('welcome', lang)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(TranslationData.translate('settings', lang)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
