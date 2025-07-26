import 'package:flutter/material.dart';
import '../../controller/settings_controller.dart';

class TemperatureToggle extends StatelessWidget {
  final TemperatureUnit value;
  final ValueChanged<TemperatureUnit> onChanged;
  final Color primary;

  const TemperatureToggle({
    super.key,
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
