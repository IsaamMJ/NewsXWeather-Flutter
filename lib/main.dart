import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/storage/shared_prefs_keys.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();

  // Load SharedPreferences and inject into GetX
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  // Read theme and login status from SharedPreferences
  final bool isDark = prefs.getBool(SharedPrefsKeys.isDarkMode) ?? false;
  final String? userId = prefs.getString(SharedPrefsKeys.userId);

  // Check system's theme setting
  final Brightness systemBrightness = WidgetsBinding.instance.window.platformBrightness;
  final ThemeMode systemThemeMode = systemBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

  runApp(SkyFeed(
    initialRoute: userId != null ? AppRoutes.mainNavigation : AppRoutes.login,
    initialThemeMode: isDark ? ThemeMode.dark : systemThemeMode, // Use saved preference or system default
  ));
}

class SkyFeed extends StatelessWidget {
  final String initialRoute;
  final ThemeMode initialThemeMode;

  const SkyFeed({
    Key? key,
    required this.initialRoute,
    required this.initialThemeMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SkyFeed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode, // Set the initial theme mode
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
