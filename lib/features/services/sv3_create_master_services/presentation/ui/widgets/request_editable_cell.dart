/// Module: services / sv3_create_master_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_editable_cell.dart
/// Purpose: Reusable editable table cell for the master-upload request table.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';

/// Q04: extracted from upload_details.dart — a generic, reusable editable cell
/// used in the request-preview table (§17: shared widgets live in ui/widgets/).
class RequestEditableCell extends StatelessWidget {
  const RequestEditableCell({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.errorText,
    required this.onChanged,
    this.width = 220,
    this.height = 48, // the shared text field is ~48 tall
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final String? errorText;
  final VoidCallback onChanged;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isEmailField = placeholder.toLowerCase().contains('email') ||
        placeholder.toLowerCase().contains('provider') ||
        placeholder.toLowerCase().contains('approver');

    return SizedBox(
      width: errorText != null ? width + 40 : width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: CustomTextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (_) => onChanged(),
              hint: placeholder,
              // Error is signalled by the external error icon next to the cell
              // (kept below); no inline errorText here to avoid overflowing the
              // fixed-height table cell.
              fillColor: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 5.h,
              ),
              valueStyle: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.text,
              ),
              hintStyle: StyleText.fontSize14Weight400.copyWith(
                fontSize: 13,
                color: AppColors.mediumGrey,
              ),
              inputFormatters: isEmailField
                  ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
                  : null,
            ),
          ),
          if (errorText != null) SizedBox(width: 8.sp),
          if (errorText != null)
            GestureDetector(
              onTap: () {
                HapticController.low(); // list row: on the tap (X-117)
                showAppDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 24.sp,
                      horizontal: 16.sp,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    content: SizedBox(
                      width: 410.sp,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            ServicesLottie.rejected,
                            width: 70.sp,
                            height: 70.sp,
                          ),
                          SizedBox(height: 16.sp),
                          Text(
                            '${S.of(dialogCtx).warning} $placeholder',
                            style: StyleText.fontSize20Weight600.copyWith(
                              color: AppColors.text,
                              height: 1.7,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.sp),
                          Text(
                            errorText!,
                            style: StyleText.fontSize14Weight400.copyWith(
                              color: AppColors.mediumGrey,
                              height: 1.7,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                width: 20.sp,
                height: height,
                alignment: Alignment.center,
                child: CustomSvgImage.natural(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_warning_exclamation_circle.svg',
                  width: 20.sp,
                  height: 20.sp,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
