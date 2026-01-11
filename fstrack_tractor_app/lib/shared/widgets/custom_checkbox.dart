import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Custom checkbox widget following Bulldozer design pattern
class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final bool enabled;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: AppColors.primary,
              checkColor: AppColors.onPrimary,
              side: const BorderSide(
                color: Color(0xFFBDBDBD),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.w500s12.copyWith(
                color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
