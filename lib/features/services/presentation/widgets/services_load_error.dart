/// Module: services_management_module
/// ******************* FILE INFO *******************
/// File Name: services_load_error.dart
/// Description: Inline error state with a Retry button for the Services
///              screens. Used where a failed load used to look like "no data"
///              or "0" (SVC-HOME-05, SVC-PROV-11, SVC-DASH-01). Unlike
///              HomeServicesErrorView it is not a Scaffold, so it can sit
///              inside a tab, a card or a page body.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
/// *************************************************
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ServicesLoadError extends StatelessWidget {
  /// Translated message to show; defaults to "Error loading data".
  final String? message;

  /// Called by the Retry button. When null, no button is drawn.
  final VoidCallback? onRetry;

  const ServicesLoadError({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.red),
            SizedBox(height: 12.sp),
            Text(
              message ?? S.of(context).errorLoadingData,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.sp),
              customButton(
                title: S.of(context).retry,
                function: onRetry!,
                color: AppColors.primary,
                textColor: AppColors.textButton,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
