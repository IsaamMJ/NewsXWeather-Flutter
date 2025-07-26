import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final Widget child;
  final Color? color;

  const SectionCard({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (theme.brightness == Brightness.light)
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