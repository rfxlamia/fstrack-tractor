import 'package:flutter/material.dart';

import '../constants/ui_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class OfflineBanner extends StatelessWidget {
  final VoidCallback? onTap;

  /// Controls accessibility - when false, semantics are excluded.
  /// Note: Pointer events are handled by parent AnimatedBanner's IgnorePointer.
  final bool isVisible;

  const OfflineBanner({
    super.key,
    required this.onTap,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: !isVisible,
      child: Semantics(
        label: UIStrings.offlineBannerSemanticsLabel,
        button: true,
        child: Material(
          color: AppColors.bannerWarning,
          child: InkWell(
            onTap: onTap, // IgnorePointer in AnimatedBanner handles visibility
            child: SizedBox(
              height: AppSpacing.touchTargetMin,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 20,
                      color: AppColors.onPrimary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        UIStrings.offlineBannerText,
                        style: AppTextStyles.w500s12.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
