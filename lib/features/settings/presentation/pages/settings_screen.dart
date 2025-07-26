import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/settings_controller.dart';
import '../widget/bullet.dart';
import '../widget/category_selector.dart';
import '../widget/section_card.dart';
import '../widget/section_title.dart';
import '../widget/temperature_toggle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? (isDark ? theme.cardColor : Colors.white);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Obx(
                () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),

                SectionCard(
                  color: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Temperature Unit'),
                      const SizedBox(height: 12),
                      TemperatureToggle(
                        value: controller.temperatureUnit.value,
                        onChanged: controller.setTemperatureUnit,
                        primary: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SectionCard(
                  color: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle('News Categories (${controller.selectedCategories.length}/${SettingsController.maxCategories})'),
                      const SizedBox(height: 4),
                      Text(
                        "Select up to 5 news categories you're interested in",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CategorySelector(
                        allCategories: controller.allCategories,
                        selected: controller.selectedCategories,
                        onToggle: controller.toggleCategory,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SectionCard(
                  color: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SectionTitle('About'),
                      SizedBox(height: 8),
                      Text(
                        'Weather-Based News Filtering',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Bullet(text: 'News articles are filtered based on current weather conditions:'),
                      SizedBox(height: 8),
                      Bullet(text: 'Cold weather: Serious and dramatic news'),
                      Bullet(text: 'Hot weather: Safety and danger-related news'),
                      Bullet(text: 'Warm weather: Positive and uplifting news'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SectionCard(
                  color: cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dark Mode',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: controller.isDarkMode.value,
                        onChanged: controller.toggleDarkMode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (controller.userId.value != null) ...[
                  Center(
                    child: Text(
                      'User ID: \${controller.userId.value}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Center(
                  child: TextButton(
                    onPressed: controller.logout,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}