import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({Key? key}) : super(key: key);

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
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

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  String _tempUnit = 'Celsius';
  final List<String> _selectedCategories = [];

  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      Get.snackbar('Hold on', 'Please select at least one category');
      return;
    }

    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', _nameCtrl.text.trim());
    await prefs.setString('temperatureUnit', _tempUnit);
    await prefs.setStringList('newsCategories', _selectedCategories);
    await prefs.setBool('onboarded', true);

    setState(() => _saving = false);

    // Close the dialog and tell caller we completed onboarding
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // prevent back dismiss so user must finish it once after signup
      onWillPop: () async => false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AbsorbPointer(
          absorbing: _saving,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Just a few quick preferences',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Temp unit
                    const Text('Temperature Unit', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('C'),
                            selected: _tempUnit == 'Celsius',
                            onSelected: (_) => setState(() => _tempUnit = 'Celsius'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('F'),
                            selected: _tempUnit == 'Fahrenheit',
                            onSelected: (_) => setState(() => _tempUnit = 'Fahrenheit'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Categories
                    Text(
                      'News Categories (${_selectedCategories.length}/$maxCategories)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.entries.map((e) {
                        final isSelected = _selectedCategories.contains(e.key);
                        return FilterChip(
                          label: Text(e.value),
                          selected: isSelected,
                          showCheckmark: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                if (_selectedCategories.length < maxCategories) {
                                  _selectedCategories.add(e.key);
                                } else {
                                  Get.snackbar('Limit reached',
                                      'You can only select up to $maxCategories categories');
                                }
                              } else {
                                _selectedCategories.remove(e.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Save & Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
