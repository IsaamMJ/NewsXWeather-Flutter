import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool loading = false.obs;

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
      // Sign in with email and password using Firebase Authentication
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Store user data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', user.uid); // Save user ID

        Get.snackbar('Login Success', 'Welcome ${user.email}');
        Get.offNamed(AppRoutes.mainNavigation); // Navigate to main screen
      } else {
        Get.snackbar('Login Failed', 'Invalid email or password.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to login. Please try again.');
    } finally {
      loading.value = false;
    }
  }

  void reset() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}