import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool loading = false.obs;

  LoginController();

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
        Get.snackbar('Login Success', 'Welcome ${user.email}');
        // Optionally navigate to another page after login
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
