// ****************** FILE INFO ******************
// File Name: crm_request_dialogs.dart
// Purpose: Confirmation and Reason dialogs for Request approval/rejection workflows matching Figma design
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

abstract class CrmRequestDialogs {
  static Future<bool> showApproveConfirmationDialog({
    required BuildContext context,
  }) async {
    final bool? confirmed = await showAppDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 24.sp),
            child: SizedBox(
              width: 380.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Header with Yellow Check/Approve Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                        size: 26.sp,
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        FormatHelper.localizedString(
                          englishName: 'Approve Request',
                          arabicName: 'اعتماد الطلب',
                        ),
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.sp),

                  // Subtitle
                  Text(
                    FormatHelper.localizedString(
                      englishName:
                          'Are you sure you want to approve this quote?',
                      arabicName: 'هل أنت متأكد من اعتماد عرض الأسعار هذا؟',
                    ),
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),

                  SizedBox(height: 24.sp),

                  // Action Buttons: Cancel / Approve
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    children: <Widget>[
                      Expanded(
                        child: customButton(
                          title: FormatHelper.localizedString(
                            englishName: 'Cancel',
                            arabicName: 'إلغاء',
                          ),
                          function: () => Navigator.of(ctx).pop(false),
                          color: AppColors.background,
                          textColor: AppColors.black,
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackButton,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Expanded(
                        child: customButton(
                          title: FormatHelper.localizedString(
                            englishName: 'Approve',
                            arabicName: 'اعتماد',
                          ),
                          function: () => Navigator.of(ctx).pop(true),
                          color: AppColors.primary,
                          textColor: AppColors.black,
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackButton,
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
    return confirmed ?? false;
  }

  /// Shows "Reject Request" confirmation dialog (Screenshot 1)
  static Future<bool> showRejectConfirmationDialog({
    required BuildContext context,
  }) async {
    final bool? confirmed = await showAppDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 24.sp),
            child: SizedBox(
              width: 380.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Header with Yellow Warning/Reject Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.cancel_outlined,
                        color: AppColors.primary,
                        size: 26.sp,
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        FormatHelper.localizedString(
                          englishName: 'Reject Request',
                          arabicName: 'رفض الطلب',
                        ),
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.sp),

                  // Subtitle
                  Text(
                    FormatHelper.localizedString(
                      englishName: 'Are you sure to reject this request?',
                      arabicName: 'هل أنت متأكد من رفض هذا الطلب؟',
                    ),
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),

                  SizedBox(height: 24.sp),

                  // Action Buttons: Cancel / Reject
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    children: <Widget>[
                      Expanded(
                        child: customButton(
                          title: FormatHelper.localizedString(
                            englishName: 'Cancel',
                            arabicName: 'إلغاء',
                          ),
                          function: () => Navigator.of(ctx).pop(false),
                          color: AppColors.background,
                          textColor: AppColors.black,
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackButton,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Expanded(
                        child: customButton(
                          title: FormatHelper.localizedString(
                            englishName: 'Reject',
                            arabicName: 'رفض',
                          ),
                          function: () => Navigator.of(ctx).pop(true),
                          color: AppColors.primary,
                          textColor: AppColors.black,
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackButton,
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
    return confirmed ?? false;
  }

  /// Shows "Reason to Reject" dialog with multiline text area (Screenshot 2)
  static Future<String?> showRejectReasonDialog({
    required BuildContext context,
  }) async {
    final TextEditingController controller = TextEditingController();
    String? errorText;

    final String? reason = await showAppDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.sp, vertical: 24.sp),
                child: SizedBox(
                  width: 380.sp,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Header with Yellow Warning/Reject Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.cancel_outlined,
                            color: AppColors.primary,
                            size: 26.sp,
                          ),
                          SizedBox(width: 8.sp),
                          Text(
                            FormatHelper.localizedString(
                              englishName: 'Reason to Reject',
                              arabicName: 'سبب الرفض',
                            ),
                            style: StyleText.fontSize16Weight600.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 18.sp),

                      // Field Label
                      Text(
                        FormatHelper.localizedString(
                          englishName: 'Reason',
                          arabicName: 'السبب',
                        ),
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 8.sp),

                      // Text Field
                      CustomTextField(
                        controller: controller,
                        hint: 'Text here',
                        maxLines: 4,
                        minLines: 4,
                        maxLength: 500,
                        fillColor: AppColors.background,
                        errorText: errorText,
                      ),

                      SizedBox(height: 24.sp),

                      // Action Buttons: Cancel / Submit
                      Row(
                        textDirection: TextDirection
                            .ltr, // X-73: Cancel left, action right in both languages

                        children: <Widget>[
                          Expanded(
                            child: customButton(
                              title: FormatHelper.localizedString(
                                englishName: 'Cancel',
                                arabicName: 'إلغاء',
                              ),
                              function: () => Navigator.of(ctx).pop(),
                              color: AppColors.background,
                              textColor: AppColors.black,
                              textStyle: StyleText.fontSize14Weight500.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackButton,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.sp),
                          Expanded(
                            child: customButton(
                              title: FormatHelper.localizedString(
                                englishName: 'Submit',
                                arabicName: 'إرسال',
                              ),
                              function: () {
                                final String text = controller.text.trim();
                                if (text.isEmpty) {
                                  setDialogState(
                                    () => errorText =
                                        FormatHelper.localizedString(
                                      englishName: 'Reason is required',
                                      arabicName: 'سبب الرفض مطلوب',
                                    ),
                                  );
                                  return;
                                }
                                Navigator.of(ctx).pop(text);
                              },
                              color: AppColors.primary,
                              textColor: AppColors.black,
                              textStyle: StyleText.fontSize14Weight500.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.blackButton,
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
      },
    );

    controller.dispose();
    return reason;
  }
}
