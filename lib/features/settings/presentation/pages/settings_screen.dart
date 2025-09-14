import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/settings_controller.dart';
import '../widget/bullet.dart';
import '../widget/category_selector.dart';
import '../widget/section_card.dart';
import '../widget/section_title.dart';
import '../widget/temperature_toggle.dart';
import '../../../../routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildPersonalizedHeader(BuildContext context, SettingsController controller) {
    final theme = Theme.of(context);
    final displayName = controller.displayName.value;
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, ${displayName.isNotEmpty ? displayName : 'there'}!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize your news experience',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                // Personalized Header
                _buildPersonalizedHeader(context, controller),
                const SizedBox(height: 32),

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
                        'News & Weather App',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Bullet(text: 'Stay informed with the latest news updates'),
                      Bullet(text: 'Get current weather conditions and forecasts'),
                      Bullet(text: 'Clean, easy-to-use interface for daily updates'),
                      Bullet(text: 'Quick access to both news and weather information'),
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
                const SizedBox(height: 16),

                // Help & Feedback Section
                SectionCard(
                  color: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Help & Feedback'),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => Get.toNamed(AppRoutes.feedback),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.feedback_outlined,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Send Feedback',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Report bugs, suggest features, or share your thoughts',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (controller.userId.value != null) ...[
                  Center(
                    child: Text(
                      'User ID: ${controller.userId.value}',
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