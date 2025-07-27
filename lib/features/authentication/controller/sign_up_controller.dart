import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/constants/strings.dart';
import '../../settings/presentation/widget/onboarding_dialog.dart';
import '../domain/usecase/login_usecase.dart';
import '../domain/usecase/signup_usecase.dart';

class SignUpController extends GetxController {
  final SignUpUseCase signUpUseCase;
  final LoginUseCase loginUseCase;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  SignUpController(this.signUpUseCase, this.loginUseCase);

  final isLoading = false.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final reEnterPasswordController = TextEditingController();

  // Handle Email SignUp
  Future<void> signUpWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final reEnterPassword = reEnterPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || reEnterPassword.isEmpty) {
      Get.snackbar(Strings.validationError, Strings.emailAndPasswordRequired);
      return;
    }

    if (password != reEnterPassword) {
      Get.snackbar(Strings.validationError, Strings.passwordMismatch);
      return;
    }

    isLoading.value = true;

    try {
      await signUpUseCase.execute(email, password); // Use the SignUpUseCase to sign up the user
      Get.snackbar(Strings.success, Strings.accountCreatedSuccess);

      final user = _auth.currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.uid);

        // Optionally, show onboarding dialog here
        final completed = await Get.dialog<bool>(
          const OnboardingDialog(),
          barrierDismissible: false,
        );

        if (completed == true) {
          Get.offAllNamed(AppRoutes.mainNavigation);
        }
      }
    } catch (e) {
      Get.snackbar(Strings.error, 'Failed to create account: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Handle Email Login
  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(Strings.validationError, Strings.emailAndPasswordRequired);
      return;
    }

    isLoading.value = true;

    try {
      final user = await loginUseCase.execute(email, password); // Use the LoginUseCase to login
      if (user != null) {
        Get.offAllNamed(AppRoutes.mainNavigation);
      } else {
        Get.snackbar(Strings.error, 'Invalid credentials');
      }
    } catch (e) {
      Get.snackbar(Strings.error, 'Failed to login: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    reEnterPasswordController.dispose();
    super.onClose();
  }
}
