// lib/widgets/app_text_field.dart
// Reusable text field that enforces the app's design system.
// Used in auth screens and listing form screens.

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String  label;
  final String? hint;
  final bool    obscureText;
  final IconData?   prefixIcon;
  final Widget?     suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)?     onChanged;
  final void Function(String)?     onFieldSubmitted;
  final int?    maxLines;
  final bool    readOnly;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller:        controller,
          obscureText:       obscureText,
          keyboardType:      keyboardType,
          validator:         validator,
          onChanged:         onChanged,
          onFieldSubmitted:  onFieldSubmitted,
          maxLines:          obscureText ? 1 : maxLines,
          readOnly:          readOnly,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
