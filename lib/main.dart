import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Register shared preferences
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  // Check if the user is logged in
  final String? userId = prefs.getString('userId'); // Store user ID when logged in

  runApp(SkyFeed(initialRoute: userId != null ? AppRoutes.mainNavigation : AppRoutes.login));
}

class SkyFeed extends StatelessWidget {
  final String initialRoute;

  const SkyFeed({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SkyFeed',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute, // Navigate based on the user login state
      getPages: AppPages.pages,
    );
  }
}