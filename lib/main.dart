import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_trade_manager/screens/home/dashboard_screen.dart';
import 'package:smart_trade_manager/screens/login_screen.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
final localeNotifier = ValueNotifier<Locale>(const Locale('en'));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Enable offline persistence for instant UI updates
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  await NotificationService.init();
  
  final isDark = await SettingsService.getDarkMode();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  
  final langCode = await SettingsService.getLanguage();
  localeNotifier.value = Locale(langCode);

  runApp(const SmartTradeApp());
}

class SmartTradeApp extends StatelessWidget {
  const SmartTradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (_, locale, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: "Smart Trade Manager",
              initialRoute: '/',
              themeMode: mode,
              locale: locale,
              supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routes: {
                '/login': (context) => const LoginScreen(),
                '/dashboard': (context) => const DashboardScreen(),
              },
              theme: ThemeData(
                useMaterial3: true,
                primaryColor: const Color(0xFF1565C0),
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
                appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1565C0), foregroundColor: Colors.white, centerTitle: true),
                scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0), brightness: Brightness.dark),
              ),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
