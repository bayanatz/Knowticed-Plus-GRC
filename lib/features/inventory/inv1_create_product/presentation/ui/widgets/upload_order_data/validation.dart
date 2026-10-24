import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class ValidationDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> missingFields;

  const ValidationDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.missingFields,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 400.sp,
        padding: EdgeInsets.all(24.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json',
              width: 70.w,
              height: 70.h,
              fit: BoxFit.scaleDown,
            ),

            SizedBox(height: 16.sp),

            // Title
            Text(
              title,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.blackButton,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8.sp),

            // Subtitle
            Text(
              subtitle,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.sp),

            // Missing fields list
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: missingFields
                    .map(
                      (field) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.sp),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6.sp,
                              color: AppColors.red,
                            ),
                            SizedBox(width: 8.sp),
                            Expanded(
                              child: Text(
                                field,
                                style: StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.blackButton,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Enhanced validation method
class ValidationResult {
  final bool isValid;
  final List<String> missingFields;
  final String? storageError;

  ValidationResult({
    required this.isValid,
    required this.missingFields,
    this.storageError,
  });
}
