/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: export_widget.dart
/// Purpose: The file-name dialog of the department dashboard export. The
///          CSV itself is written by DashboardRequestsCsv.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

// =============================================
// FileNameDialog Widget - Shows dialog to enter file name
// =============================================
class FileNameDialog {
  static Future<String?> show(
    BuildContext context, {
    required String exportText,
    required String fileNameText,
    required String textHereHint,
    required String discardText,
    required String downloadText,
    Color? primaryColor,
    Color? backgroundColor,
    Color? textColor,
    Color? buttonTextColor,
  }) async {
    final TextEditingController controller = TextEditingController();
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final bgColor =
        backgroundColor ?? (lightMode ? AppColors.white : AppColors.darkGrey);
    final txtColor = textColor ??
        (lightMode
            ? AppColors.black.withValues(alpha: 0.87)
            : AppColors.white.withValues(alpha: 0.70));
    final btnTxtColor = buttonTextColor ?? AppColors.white;
    final primColor = primaryColor ?? Theme.of(context).primaryColor;

    return await showAppDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            width: 411.sp,
            child: Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primColor,
                        ),
                        child: SizedBox(
                          child: CustomSvgImage(
                            assetPath:
                                "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                            color: AppColors.textButton,
                            width: 10.w,
                            height: 10.h,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        exportText,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: txtColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp),

                  // File name label
                  Text(
                    fileNameText,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: txtColor,
                    ),
                  ),
                  SizedBox(height: 8.sp),

                  // Text field
                  CustomTextField(
                    controller: controller,
                    fillColor: AppColors.background,
                    hint: textHereHint,
                  ),
                  SizedBox(height: 20.sp),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Discard
                      GestureDetector(
                        onTapDown: (_) => HapticController.low(),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 130.sp,
                          height: 38.sp,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryAction,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Center(
                            child: Text(
                              discardText,
                              style: StyleText.fontSize14Weight600.copyWith(
                                color: AppColors.onSecondaryAction,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.sp),

                      // Download
                      GestureDetector(
                        onTapDown: (_) => HapticController.low(),
                        onTap: () {
                          final name = controller.text.trim();
                          if (name.isNotEmpty) {
                            Navigator.pop(context, name);
                          }
                        },
                        child: Container(
                          width: 130.sp,
                          height: 38.sp,
                          decoration: BoxDecoration(
                            color: primColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Center(
                            child: Text(
                              downloadText,
                              style: StyleText.fontSize14Weight600.copyWith(
                                color: btnTxtColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
