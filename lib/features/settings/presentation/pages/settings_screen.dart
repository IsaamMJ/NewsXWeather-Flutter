import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const int maxCategories = 5;
  final Map<String, String> _categories = const {
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

  String? userId;
  String selectedTemperatureUnit = 'Celsius';
  List<String> selectedCategories = [];
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPreferences();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTemperatureUnit = prefs.getString('temperatureUnit') ?? 'Celsius';
      selectedCategories = prefs.getStringList('newsCategories') ?? [];
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveTemperatureUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temperatureUnit', unit);
    setState(() => selectedTemperatureUnit = unit);
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('newsCategories', selectedCategories);
  }

  Future<void> _saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() => isDarkMode = isDark);
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.brightness == Brightness.dark
        ? theme.cardColor
        : Colors.white;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.scaffoldBackgroundColor
          : const Color(0xFFF7F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),

              _SectionCard(
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Temperature Unit'),
                    const SizedBox(height: 12),
                    _TemperatureToggle(
                      value: selectedTemperatureUnit,
                      onChanged: _saveTemperatureUnit,
                      primary: primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                        'News Categories (${selectedCategories.length}/$maxCategories)'),
                    const SizedBox(height: 4),
                    Text(
                      "Select up to 5 news categories you're interested in",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                        theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.entries.map((e) {
                        final isSelected =
                        selectedCategories.contains(e.key);
                        return FilterChip(
                          label: Text(
                            e.value,
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          showCheckmark: isSelected,
                          selectedColor: primary,
                          backgroundColor: theme.colorScheme.surfaceVariant
                              .withOpacity(0.4),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (selectedCategories.length < maxCategories) {
                                  selectedCategories.add(e.key);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'You can only select up to 5 categories.',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                selectedCategories.remove(e.key);
                              }
                            });
                            _saveCategories();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _SectionTitle('About'),
                    SizedBox(height: 8),
                    Text(
                      'Weather-Based News Filtering',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    _Bullet(text: 'News articles are filtered based on current weather conditions:'),
                    SizedBox(height: 8),
                    _Bullet(text: 'Cold weather: Serious and dramatic news'),
                    _Bullet(text: 'Hot weather: Safety and danger-related news'),
                    _Bullet(text: 'Warm weather: Positive and uplifting news'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _SectionCard(
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
                      value: isDarkMode,
                      onChanged: _saveDarkMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (userId != null) ...[
                Center(
                  child: Text(
                    'User ID: $userId',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                      theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Center(
                child: TextButton(
                  onPressed: _logout,
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
    );
  }
}

/// --- UI Helpers ---

class _SectionCard extends StatelessWidget {
  final Widget child;
  final Color color;

  const _SectionCard({required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _TemperatureToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final Color primary;

  const _TemperatureToggle({
    required this.value,
    required this.onChanged,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _pill('Celsius (°C)', value == 'Celsius', () => onChanged('Celsius'), primary, theme),
        const SizedBox(width: 12),
        _pill('Fahrenheit (°F)', value == 'Fahrenheit', () => onChanged('Fahrenheit'), primary, theme),
      ],
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap, Color primary, ThemeData theme) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? primary
                : theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}