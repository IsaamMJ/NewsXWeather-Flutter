import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  // Sign up with Email and Password
  Future<void> signUpWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Validation Error', 'Email and Password are required');
      return;
    }

    isLoading.value = true;

    try {
      // Create user with email and password
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      Get.snackbar('Success', 'Account created successfully');

      final user = _auth.currentUser;
      if (user != null) {
        // Save user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', user.uid); // Store user ID

        Get.offNamed(AppRoutes.mainNavigation);  // Navigate to the main screen
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create account: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}