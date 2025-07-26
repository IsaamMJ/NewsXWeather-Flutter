import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategorySelector extends StatelessWidget {
  final Map<String, String> allCategories;
  final RxList<String> selected;
  final Function(String) onToggle;

  const CategorySelector({
    super.key,
    required this.allCategories,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Obx(
          () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: allCategories.entries.map((entry) {
          final isSelected = selected.contains(entry.key);
          return FilterChip(
            label: Text(
              entry.value,
              style: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: isSelected,
            showCheckmark: isSelected,
            selectedColor: primary,
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            onSelected: (_) => onToggle(entry.key),
          );
        }).toList(),
      ),
    );
  }
}
