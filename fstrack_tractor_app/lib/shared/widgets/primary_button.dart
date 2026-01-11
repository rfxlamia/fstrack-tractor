import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Primary button widget with loading state support
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final bool enabled;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 60,
    this.width,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.buttonOrange;
    final txtColor = textColor ?? AppColors.onPrimary;

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: txtColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: AppTextStyles.buttonLarge.copyWith(
                  color: txtColor,
                ),
              ),
      ),
    );
  }
}
