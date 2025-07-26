import 'package:get/get.dart';

import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../features/authentication/presentation/bindings/login_binding.dart';
import '../features/authentication/presentation/bindings/signup_binding.dart';
import '../features/common/main/presentation/pages/main_navigation_screen.dart';
import '../features/common/splash/presentation/pages/splash_page.dart';
import '../../features/settings/presentation/pages/settings_screen.dart'; // Import the Settings screen
import '../features/common/main/presentation/pages/home_screen.dart';
import '../routes/app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignUpPage(),
      binding: SignUpBinding(),
    ),
    // Add MainNavigationScreen (which contains the Bottom Navigation)
    GetPage(
      name: AppRoutes.mainNavigation,
      page: () => const MainNavigationScreen(),
      // binding: HomeBinding(), // Bind Home controller for the initial tab
    ),
    // Additional pages that could be accessed via tabs in the BottomNavigationBar
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      // binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      // binding: SettingsBinding(),
    ),
  ];
}
