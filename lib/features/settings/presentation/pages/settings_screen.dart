import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/storage/shared_prefs_keys.dart';

/// Use an enum instead of raw strings
enum TemperatureUnit { celsius, fahrenheit }

extension TemperatureUnitX on TemperatureUnit {
  String get label => this == TemperatureUnit.celsius
      ? 'Celsius (°C)'
      : 'Fahrenheit (°F)';

  static TemperatureUnit fromString(String v) {
    switch (v.toLowerCase()) {
      case 'fahrenheit':
        return TemperatureUnit.fahrenheit;
      case 'celsius':
      default:
        return TemperatureUnit.celsius;
    }
  }

  String get storageValue =>
      this == TemperatureUnit.celsius ? 'Celsius' : 'Fahrenheit';
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const int _maxCategories = 5;

  static const Map<String, String> _categories = {
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

  String? _userId;
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  List<String> _selectedCategories = [];
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userId = prefs.getString(SharedPrefsKeys.userId);
      _temperatureUnit = TemperatureUnitX.fromString(
        prefs.getString(SharedPrefsKeys.temperatureUnit) ?? 'Celsius',
      );
      _selectedCategories =
          prefs.getStringList(SharedPrefsKeys.newsCategories) ?? [];
      _isDarkMode = prefs.getBool(SharedPrefsKeys.isDarkMode) ?? false;
    });

    // apply the stored theme instantly
    Get.changeThemeMode(_isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _saveTemperatureUnit(TemperatureUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPrefsKeys.temperatureUnit, unit.storageValue);
    setState(() => _temperatureUnit = unit);
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        SharedPrefsKeys.newsCategories, _selectedCategories);
  }

  Future<void> _saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPrefsKeys.isDarkMode, isDark);
    setState(() => _isDarkMode = isDark);
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // removes every saved key
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? (isDark ? theme.cardColor : Colors.white);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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

              // Temperature
              _SectionCard(
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Temperature Unit'),
                    const SizedBox(height: 12),
                    _TemperatureToggle(
                      value: _temperatureUnit,
                      onChanged: _saveTemperatureUnit,
                      primary: primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Categories
              _SectionCard(
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      'News Categories (${_selectedCategories.length}/$_maxCategories)',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Select up to $_maxCategories news categories you're interested in",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.entries.map((e) {
                        final isSelected = _selectedCategories.contains(e.key);
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
                          backgroundColor:
                          theme.colorScheme.surfaceVariant.withOpacity(0.4),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (_selectedCategories.length < _maxCategories) {
                                  _selectedCategories.add(e.key);
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
                                _selectedCategories.remove(e.key);
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

              // About
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
                    _Bullet(
                        text:
                        'News articles are filtered based on current weather conditions:'),
                    SizedBox(height: 8),
                    _Bullet(text: 'Cold weather: Serious and dramatic news'),
                    _Bullet(text: 'Hot weather: Safety and danger-related news'),
                    _Bullet(text: 'Warm weather: Positive and uplifting news'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dark mode toggle
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
                      value: _isDarkMode,
                      onChanged: _saveDarkMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_userId != null) ...[
                Center(
                  child: Text(
                    'User ID: $_userId',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
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
          if (Theme.of(context).brightness == Brightness.light)
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
  final TemperatureUnit value;
  final ValueChanged<TemperatureUnit> onChanged;
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
        _pill(
          TemperatureUnit.celsius.label,
          value == TemperatureUnit.celsius,
              () => onChanged(TemperatureUnit.celsius),
          primary,
          theme,
        ),
        const SizedBox(width: 12),
        _pill(
          TemperatureUnit.fahrenheit.label,
          value == TemperatureUnit.fahrenheit,
              () => onChanged(TemperatureUnit.fahrenheit),
          primary,
          theme,
        ),
      ],
    );
  }

  Widget _pill(
      String label,
      bool selected,
      VoidCallback onTap,
      Color primary,
      ThemeData theme,
      ) {
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
