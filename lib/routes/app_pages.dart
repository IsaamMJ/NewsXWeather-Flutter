import 'package:get/get.dart';

import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../features/authentication/presentation/bindings/login_binding.dart';
import '../features/authentication/presentation/bindings/signup_binding.dart';
import '../features/common/splash/presentation/pages/splash_page.dart';
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
  ];
}
