/// Module: services / sv5_service_details / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: export_file_name_dialog.dart
/// Purpose: The "Export" file-name dialog used by the service-details page.
///          The CSV itself is built and saved by DetailsServicesCubit
///          (rule H8); the unused widget-side exporter, its try/catch and its
///          hardcoded English texts were removed (H18, H21, H22, H45).
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

Future<String?> showFileNameDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();

  return await showAppDialog<String>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          width: 411.sp, // 🔵 Set your desired width
          height: 213.sp,
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image & export
                Row(
                  children: [
                    Container(
                      width: 30.sp,
                      height: 30.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Center(
                        child: CustomSvgImage.natural(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                          width: 13.sp,
                          height: 13.sp,
                          color: AppColors.textButton,
                          fit: BoxFit.fill,
                        ),
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
                ),
                // space
                SizedBox(height: 20.sp),

                // File Name title
                Text(
                  S.of(context).fileName,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),

                SizedBox(height: 8.sp),

                Container(
                  height: 36.sp,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: CustomTextField(
                    controller: controller,
                    hint: S.of(context).Texthere,
                    fillColor: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 9.sp,
                      vertical: 13.sp,
                    ),
                    valueStyle: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.blackButton,
                    ),
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),

                // space
                SizedBox(height: 20.sp),
                // Discard and Download
                Row(
                  textDirection: TextDirection
                      .ltr, // X-73: Cancel left, action right in both languages

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customButton(
                      title: S.of(context).discard,
                      width: 120.w,
                      color: AppColors.secondaryAction,
                      height: 38.h,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.onSecondaryAction,
                      ),
                      radius: 8.r,
                      function: () {
                        Navigator.pop(context);
                      },
                    ),
                    customButton(
                      title: S.of(context).download,
                      width: 120.w,
                      color: AppColors.primary,
                      height: 38.h,
                      textStyle: StyleText.fontSize18Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      radius: 8.r,
                      function: () {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          Navigator.pop(context, name);
                        }
                      },
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

OverlayEntry? _overlayEntry;
Future<void> showLoadingIndicator(BuildContext context) async {
  // Services mobile QA p.21 ("remove this loading"): the dark 70pt spinner
  // box stayed on screen behind the phone's Save sheet for as long as the
  // sheet was open. The save sheet (and the Export button's own busy state)
  // is the feedback now, so no overlay is shown.
  // Intentionally empty; kept so the existing callers (and
  // hideLoadingIndicator) stay unchanged.
}

void hideLoadingIndicator() {
  _overlayEntry?.remove();
  _overlayEntry = null;
}
