import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../settings/controller/settings_controller.dart';
import '../data/models/feedback_model.dart';

class FeedbackController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Reactive variables
  final Rx<FeedbackType> selectedType = FeedbackType.general.obs;
  final Rx<FeedbackPriority> selectedPriority = FeedbackPriority.medium.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _testFirestoreConnection();
  }

  Future<void> _testFirestoreConnection() async {
    try {
      print('Testing Firestore connection...');
      await _firestore.collection('test').doc('test').get();
      print('Firestore connection successful!');
    } catch (e) {
      print('Firestore connection failed: $e');
    }
  }

  // Simple test method
  void testMethod() {
    print('Controller method called successfully!');
    Get.snackbar('Test', 'Controller is working!');
  }

  void setFeedbackType(FeedbackType type) {
    selectedType.value = type;
  }

  void setPriority(FeedbackPriority priority) {
    selectedPriority.value = priority;
  }

  Future<void> submitFeedback() async {
    if (!formKey.currentState!.validate()) return;

    if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please fill in both title and description',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      // Get user info
      final user = _auth.currentUser;
      final settingsController = Get.find<SettingsController>();

      // Get device info
      final deviceInfo = await _getDeviceInfo();
      final appInfo = await _getAppInfo();
      final userSettings = _getUserSettings(settingsController);

      // Create feedback model
      final feedback = FeedbackModel(
        userId: settingsController.userId.value ?? user?.uid ?? 'anonymous',
        userEmail: user?.email,
        displayName: settingsController.displayName.value.isNotEmpty
            ? settingsController.displayName.value
            : 'Anonymous User',
        type: selectedType.value,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        priority: selectedPriority.value,
        deviceInfo: deviceInfo,
        appInfo: appInfo,
        userSettings: userSettings,
        timestamp: DateTime.now(),
      );

      // Submit to Firestore
      final docRef = await _firestore
          .collection('feedback')
          .add(feedback.toMap());

      // Generate tracking ID
      final trackingId = '#FB${DateTime.now().year}${docRef.id.substring(0, 6).toUpperCase()}';

      isSubmitting.value = false;

      // Show success dialog
      await _showSuccessDialog(trackingId);

      // Clear form and navigate back after dialog closes
      _clearForm();
      _navigateBack();

    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar(
        'Submission Failed',
        'Unable to submit feedback. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    selectedType.value = FeedbackType.general;
    selectedPriority.value = FeedbackPriority.medium;
  }

  void _navigateBack() {
    try {
      // Use a small delay to ensure dialog is fully closed
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.currentRoute == '/feedback') {
          Get.offNamed('/settings');
        }
      });
    } catch (e) {
      print('Navigation error: $e');
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'osVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'osVersion': iosInfo.systemVersion,
        };
      }
    } catch (e) {
      // Fallback if device info fails
    }

    return {
      'platform': Platform.operatingSystem,
      'error': 'Could not retrieve device info',
    };
  }

  Future<Map<String, dynamic>> _getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };
    } catch (e) {
      return {
        'appName': 'SkyFeed',
        'error': 'Could not retrieve app info',
      };
    }
  }

  Map<String, dynamic> _getUserSettings(SettingsController settingsController) {
    return {
      'temperatureUnit': settingsController.temperatureUnit.value.storageValue,
      'selectedCategories': settingsController.selectedCategories.toList(),
      'isDarkMode': settingsController.isDarkMode.value,
      'categoriesCount': settingsController.selectedCategories.length,
    };
  }

  Future<void> _showSuccessDialog(String trackingId) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 40,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thank You!',
                style: Get.theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your feedback has been submitted successfully.',
                style: Get.theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tracking ID: $trackingId',
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Just close the dialog, navigation is handled separately
                    Navigator.of(Get.overlayContext!).pop();
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}