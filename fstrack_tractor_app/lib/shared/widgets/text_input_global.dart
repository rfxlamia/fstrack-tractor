import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Global text input widget following Bulldozer design pattern
class TextInputGlobal extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? hintText;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;

  const TextInputGlobal({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.onTap,
    this.readOnly = false,
    this.hintText,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.w500s12.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onTap: onTap,
          readOnly: readOnly,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: AppTextStyles.w500s12.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.w500s12.copyWith(
              color: AppColors.textSecondary,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: _buildBorder(),
            enabledBorder: _buildBorder(),
            focusedBorder: _focusedBorder(),
            errorBorder: _errorBorder(),
            focusedErrorBorder: _errorBorder(),
            errorText: errorText,
            errorStyle: AppTextStyles.w400s10.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFFBDBDBD),
        width: 1,
      ),
    );
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1,
      ),
    );
  }

  OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1,
      ),
    );
  }
}
