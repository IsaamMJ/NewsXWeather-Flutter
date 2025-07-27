import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';

class FormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final String hintText;
  final IconData icon;
  final String? Function(String?) validator;
  final FocusNode? nextFocusNode;

  const FormFieldWidget({
    required this.controller,
    required this.focusNode,
    this.obscureText = false,
    required this.hintText,
    required this.icon,
    required this.validator,
    this.nextFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.getPrimary(context); // Primary color based on theme

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(196, 135, 198, .3)),
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade700),
          prefixIcon: Icon(icon, color: primaryColor),
        ),
        validator: validator,
        onFieldSubmitted: (value) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }
}
