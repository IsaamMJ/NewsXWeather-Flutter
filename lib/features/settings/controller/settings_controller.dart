import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/storage/shared_prefs_keys.dart';

enum TemperatureUnit { celsius, fahrenheit }

extension TemperatureUnitX on TemperatureUnit {
  String get label => this == TemperatureUnit.celsius ? 'Celsius (\u00B0C)' : 'Fahrenheit (\u00B0F)';

  static TemperatureUnit fromString(String value) {
    switch (value.toLowerCase()) {
      case 'fahrenheit':
        return TemperatureUnit.fahrenheit;
      case 'celsius':
      default:
        return TemperatureUnit.celsius;
    }
  }

  String get storageValue => this == TemperatureUnit.celsius ? 'Celsius' : 'Fahrenheit';
}

class SettingsController extends GetxController {
  static const int maxCategories = 5;

  final Rx<TemperatureUnit> temperatureUnit = TemperatureUnit.celsius.obs;
  final RxList<String> selectedCategories = <String>[].obs; // Reactive list
  final RxBool isDarkMode = false.obs;
  final RxnString userId = RxnString();

  final Map<String, String> allCategories = const {
    'business': 'Business',
    'crime': 'Crime',
    'domestic': 'Domestic',
    'education': 'Education',
    'entertainment': 'Entertainment',
    'environment': 'Environment',
    'food': 'Food',
    'health': 'Health',
    'lifestyle': 'Lifestyle',
    'other': 'Other',
    'politics': 'Politics',
    'science': 'Science',
    'sports': 'Sports',
    'technology': 'Technology',
    'top': 'Top',
    'tourism': 'Tourism',
    'world': 'World',
  };

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    userId.value = prefs.getString(SharedPrefsKeys.userId);
    temperatureUnit.value = TemperatureUnitX.fromString(
      prefs.getString(SharedPrefsKeys.temperatureUnit) ?? 'Celsius',
    );
    selectedCategories.assignAll(
      prefs.getStringList(SharedPrefsKeys.newsCategories) ?? [],
    );

    // Get and apply the theme preference, default to system theme if not available
    if (prefs.containsKey(SharedPrefsKeys.isDarkMode)) {
      isDarkMode.value = prefs.getBool(SharedPrefsKeys.isDarkMode)!;
    } else {
      final systemBrightness = WidgetsBinding.instance.window.platformBrightness;
      isDarkMode.value = systemBrightness == Brightness.dark;
    }


    // Apply the theme (light or dark based on the value of `isDarkMode`)
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Set the temperature unit and save it to SharedPreferences
  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPrefsKeys.temperatureUnit, unit.storageValue);
    temperatureUnit.value = unit;
  }

  // Toggle category selection and save the updated list to SharedPreferences
  Future<void> toggleCategory(String categoryKey) async {
    if (selectedCategories.contains(categoryKey)) {
      selectedCategories.remove(categoryKey);
    } else {
      if (selectedCategories.length < maxCategories) {
        selectedCategories.add(categoryKey);
      } else {
        Get.snackbar('Limit Reached', 'You can only select up to 5 categories.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(SharedPrefsKeys.newsCategories, selectedCategories);
  }

  // Toggle dark mode, save it to SharedPreferences, and apply the theme
  Future<void> toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefsKeys.isDarkMode, value);
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // Logout the user, clear preferences and navigate to login screen
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }
}
