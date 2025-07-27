import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';
import '../domain/usecase/login_usecase.dart';

class LoginController extends GetxController {
  final LoginUseCase loginUseCase;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool loading = false.obs;

  LoginController(this.loginUseCase);

  // Login with Email and Password
  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Input Error', 'Email and Password are required.');
      return;
    }

    loading.value = true;

    try {
      final user = await loginUseCase.execute(email, password);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', user.id); // Save user ID

        Get.snackbar('Login Success', 'Welcome ${user.phone}');
        Get.offNamed(AppRoutes.mainNavigation);
      } else {
        Get.snackbar('Login Failed', 'Invalid email or password.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to login. Please try again.');
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
