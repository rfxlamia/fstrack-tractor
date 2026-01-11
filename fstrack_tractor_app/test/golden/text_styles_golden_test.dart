import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:fstrack_tractor/core/theme/app_text_styles.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';

void main() {
  group('Text Styles Golden Tests', () {
    testGoldens('All Bulldozer text style tokens render with Poppins font',
        (tester) async {
      await loadAppFonts();

      await tester.pumpWidgetBuilder(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: AppColors.background,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: AppColors.primary,
                    child: const Text(
                      'Bulldozer Text Style Tokens',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // w400 styles
                  const Text('w400s8 - Micro (8px)', style: AppTextStyles.w400s8),
                  const SizedBox(height: 8),
                  const Text('w400s10 - Caption (10px)', style: AppTextStyles.w400s10),
                  const SizedBox(height: 8),
                  const Text('w400s12 - Body Small (12px)',
                      style: AppTextStyles.w400s12),
                  const SizedBox(height: 16),

                  // w500 styles
                  const Text('w500s10 - Caption Medium (10px)',
                      style: AppTextStyles.w500s10),
                  const SizedBox(height: 8),
                  const Text('w500s12 - Body (12px)', style: AppTextStyles.w500s12),
                  const SizedBox(height: 16),

                  // w600 styles
                  const Text('w600s12 - Subtitle (12px)',
                      style: AppTextStyles.w600s12),
                  const SizedBox(height: 16),

                  // w700 styles
                  const Text('w700s13 - Title Small (13px)',
                      style: AppTextStyles.w700s13),
                  const SizedBox(height: 8),
                  const Text('w700s20 - Title (20px)', style: AppTextStyles.w700s20),
                  const SizedBox(height: 24),

                  // Semantic aliases section
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: AppColors.buttonOrange,
                    child: const Text(
                      'Semantic Aliases',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('headline1 → w700s20', style: AppTextStyles.headline1),
                  const SizedBox(height: 8),
                  const Text('bodyLarge → w500s12', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 8),
                  const Text('caption → w400s8', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'text_styles_poppins');
    });

    testGoldens('Button text styles render correctly', (tester) async {
      await loadAppFonts();

      await tester.pumpWidgetBuilder(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: AppColors.background,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Button Large
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.buttonOrange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Button Large (16px, w600)',
                        style: AppTextStyles.buttonLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button Medium
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.buttonBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Button Medium (14px, w600)',
                        style: AppTextStyles.buttonMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        surfaceSize: const Size(400, 200),
      );

      await screenMatchesGolden(tester, 'button_styles');
    });
  });
}
