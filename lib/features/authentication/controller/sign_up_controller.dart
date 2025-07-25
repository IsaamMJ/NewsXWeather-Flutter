import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  SignUpController();

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
      // Optionally navigate to another page after sign-up
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
