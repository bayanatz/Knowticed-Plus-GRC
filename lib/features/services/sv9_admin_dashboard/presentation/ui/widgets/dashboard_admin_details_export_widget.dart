/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_admin_details_export_widget.dart
/// Purpose: The file-name dialog of the dashboard details export. The CSV
///          itself is written by DashboardRequestsCsv.
/// Author: Amr Mesbah
/// Created At: 30/08/2025
library;

import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ServiceRequestExportHelper {
  /// Show file name dialog and return the entered name
  Future<String?> showFileNameDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    return await showAppDialog<String>(
      context: context,
      builder: (context) {
        final lightMode = Theme.of(context).brightness == Brightness.light;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            width: 411.sp,
            height: 210.sp,
            child: Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildDialogHeader(context, lightMode),
                  SizedBox(height: 10.sp),

                  // File name label
                  Text(
                    S.of(context).fileName,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                  SizedBox(height: 8.sp),

                  // Text field
                  _buildTextField(context, controller, lightMode),
                  SizedBox(height: 20.sp),

                  // Buttons
                  _buildDialogButtons(context, controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(BuildContext context, bool lightMode) {
    return Row(
      children: [
        Container(
          width: 30.sp,
          height: 30.sp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: CustomSvgImage.natural(
            assetPath:
                "assets/icons_assets/main_icons_assets/ic_action_export.svg",
            width: 12.sp,
            height: 12.sp,
            fit: BoxFit.scaleDown,
            color: lightMode ? AppColors.textButton : AppColors.textButton,
            semanticsLabel: 'Export',
          ),
        ),
        SizedBox(width: 8.sp),
        Text(
          S.of(context).export,
          style: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.blackButton,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    bool lightMode,
  ) {
    return CustomTextField(
      controller: controller,
      fillColor: AppColors.background,
      hint: S.of(context).Texthere,
    );
  }

  Widget _buildDialogButtons(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Discard button
        GestureDetector(
          onTapDown: (_) => HapticController.medium(),
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
                S.of(context).discard,
                style: StyleText.fontSize14Weight600.copyWith(
                  color: AppColors.onSecondaryAction,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.sp),

        // Download button
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
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                S.of(context).download,
                style: StyleText.fontSize14Weight600.copyWith(
                  color: AppColors.textButton,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
