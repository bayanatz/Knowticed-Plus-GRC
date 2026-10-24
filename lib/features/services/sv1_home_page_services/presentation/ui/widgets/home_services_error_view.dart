/// Module: services / sv1_home_page_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: home_services_error_view.dart
/// Purpose: Full-screen error state (with retry) shown on the home services
///          page when the initial data load fails.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: AppColors, StyleText, customButtonWithIcon
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from home_page_services.dart
///     (fix item 1c — build-method decomposition).
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HomeServicesErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const HomeServicesErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.red),
            const SizedBox(height: 16),
            Text(
              title,
              style: StyleText.fontSize16Weight500.copyWith(
                color: lightMode
                    ? AppColors.black.withValues(alpha: 0.87)
                    : AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.black.withValues(alpha: 0.54)
                    : AppColors.white.withValues(alpha: 0.70),
              ),
            ),
            const SizedBox(height: 24),
            // CHANGED 17/10/2026: was customButtonWithIcon with a font icon;
            // no SVG refresh icon exists in the assets, so plain Retry.
            customButton(
              title: S.of(context).retry,
              function: onRetry,
              color: AppColors.primary,
              textColor: AppColors.textButton,
            ),
          ],
        ),
      ),
    );
  }
}
