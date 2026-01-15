import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/ui_strings.dart';

class SessionWarningBanner extends StatelessWidget {
  final int daysRemaining;
  final VoidCallback? onDismiss;

  const SessionWarningBanner({
    super.key,
    required this.daysRemaining,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${UIStrings.sessionExpiringBannerText.replaceAll('{days}', daysRemaining.toString())}. Tap X untuk menutup.',
      child: Container(
        height: 56.0,
        width: double.infinity,
        color: AppColors.bannerWarning,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                UIStrings.sessionExpiringBannerText
                    .replaceAll('{days}', daysRemaining.toString()),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ],
        ),
      ),
    );
  }
}
