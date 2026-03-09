// lib/widgets/loading_button.dart
// Full-width ElevatedButton that shows a spinner while isLoading is true.

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class LoadingButton extends StatelessWidget {
  final String   label;
  final bool     isLoading;
  final VoidCallback? onPressed;
  final Color?   color;

  const LoadingButton({
    super.key,
    required this.label,
    required this.isLoading,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(label, style: AppTextStyles.button),
      ),
    );
  }
}
