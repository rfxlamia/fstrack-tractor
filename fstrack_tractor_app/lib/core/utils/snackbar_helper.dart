import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Helper class for showing snackbar messages
class SnackbarHelper {
  static void showError(
    BuildContext context, {
    required String message,
    VoidCallback? onAction,
    String actionLabel = 'Tutup',
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    VoidCallback? onAction,
    String actionLabel = 'Tutup',
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    VoidCallback? onAction,
    String actionLabel = 'Tutup',
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: AppColors.primary,
      icon: Icons.info_outline,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void _showSnackbar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    VoidCallback? onAction,
    required String actionLabel,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final snackbar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: AppColors.onPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.w500s12.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.fixed,
      action: onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: AppColors.onPrimary,
              onPressed: onAction,
            )
          : null,
      duration: const Duration(seconds: 4),
    );

    scaffoldMessenger.showSnackBar(snackbar);
  }

  /// Close any currently displayed snackbar
  static void hideCurrentSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
