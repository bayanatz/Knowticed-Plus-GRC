// ****************** FILE INFO ******************
/// Description: `CrmControlDialogs`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

// File Name: crm_control_dialogs.dart
// Purpose: Reusable custom dialogs for CRM Controls (Remove, Save, and Success)
// Author: Mohand Adel
// Created At: 04/08/2026

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/validation/validator.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'dart:ui' as ui;

part 'crm_control_dialogs/crm_control_dialogs_statics.dart';

abstract class CrmControlDialogs {
  static Future<bool> showBlacklistConfirmationDialog({
    required BuildContext context,
    required bool isRemoval,
  }) async {
    final bool? confirmed = await showAppDialog<bool>(
      destructive: true,
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.sp),
          child: SizedBox(
            width: 380.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomSvgImage(
                      assetPath: AppAssets.crmBlacklist,
                      width: 36.sp,
                      height: 36.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      isRemoval ? 'Remove from Blacklist' : 'Add to Blacklist',
                      style: StyleText.fontSize18Weight600.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.sp),
                Text(
                  isRemoval
                      ? 'Are you sure to remove this client from blacklist?'
                      : 'Are you sure to add this client to blacklist?',
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 28.sp),
                Row(
                  textDirection: TextDirection
                      .ltr, // X-73: Cancel left, action right in both languages

                  children: <Widget>[
                    Expanded(
                      child: customButton(
                        title: 'Cancel',
                        function: () => Navigator.of(dialogContext).pop(false),
                        color: AppColors.darkGrey,
                        textColor: AppColors.text,
                        textStyle: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    Expanded(
                      child: customButton(
                        title: isRemoval ? 'Remove' : 'Add',
                        function: () => Navigator.of(dialogContext).pop(true),
                        color: AppColors.primary,
                        textColor: AppColors.black,
                        textStyle: StyleText.fontSize16Weight600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }

  static Future<String?> showBlacklistReasonDialog({
    required BuildContext context,
    required bool isRemoval,
  }) async {
    final TextEditingController controller = TextEditingController();
    String? errorText;
    final String? reason = await showAppDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) => Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SizedBox(
              width: 380.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomSvgImage(
                        assetPath: AppAssets.crmBlacklist,
                        width: 36.sp,
                        height: 36.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        isRemoval
                            ? 'Remove from Blacklist'
                            : 'Add to Blacklist',
                        style: StyleText.fontSize18Weight600.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.sp),
                  Text('Reason', style: StyleText.fontSize14Weight500),
                  SizedBox(height: 8.sp),
                  CustomTextField(
                    controller: controller,
                    hint: 'Text here',
                    maxLines: 4,
                    maxLength: 500,
                    errorText: errorText,
                  ),
                  SizedBox(height: 24.sp),
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    children: <Widget>[
                      Expanded(
                        child: customButton(
                          title: 'Cancel',
                          function: () => Navigator.of(dialogContext).pop(),
                          color: AppColors.darkGrey,
                          textColor: AppColors.text,
                          textStyle: StyleText.fontSize16Weight600.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Expanded(
                        child: customButton(
                          title: 'Send Request',
                          function: () {
                            final String value = controller.text.trim();
                            if (value.isEmpty) {
                              setDialogState(
                                () => errorText = 'Reason is required',
                              );
                              return;
                            }
                            Navigator.of(dialogContext).pop(value);
                          },
                          color: AppColors.primary,
                          textColor: AppColors.black,
                          textStyle: StyleText.fontSize16Weight600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    controller.dispose();
    return reason;
  }

  /// Shows Success Dialog with illustration (Screenshot 3 & 4)
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
    VoidCallback? onComplete,
  }) async {
    BuildContext? dialogContext;
    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        dialogContext = ctx;
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: SizedBox(
              width: 380.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize18Weight600.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CustomSvgImage(
                    assetPath: AppAssets.crmSuccessfulSvgDialog,
                    width: 220.sp,
                    height: 160.sp,
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
    if (dialogContext != null &&
        dialogContext!.mounted &&
        Navigator.canPop(dialogContext!)) {
      Navigator.pop(dialogContext!);
    }
    onComplete?.call();
  }

  /// Shows Custom Error / Alert Dialog (No SnackBar)
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
  }) async {
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SizedBox(
              width: 380.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomSvgImage(
                    assetPath: AppAssets.minusCircle,
                    width: 48.sp,
                    height: 48.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize18Weight600.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  customButton(
                    title: Localizations.localeOf(context).languageCode == 'ar'
                        ? 'حسناً'
                        : 'OK',
                    function: () => Navigator.of(ctx).pop(),
                    color: AppColors.primary,
                    textColor: AppColors.black,
                    width: 110.sp,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows Remove Field / Type Confirmation Dialog (Screenshot 1)
  static Future<void> showRemoveDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onConfirm,
  }) async {
    showAppDialog(
      destructive: true,
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SizedBox(
              width: 380.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSvgImage(
                        assetPath: AppAssets.crmTrush,
                        width: 24.sp,
                        height: 24.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        title,
                        style: StyleText.fontSize18Weight600.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    children: [
                      Expanded(
                        child: customButtonWithSvg(
                          title: S.current.crmDiscard,
                          function: () => Navigator.pop(ctx),
                          textStyle: StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.text,
                          ),
                          color: AppColors.darkGrey,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: customButtonWithSvg(
                          title: S.current.crmRemove,
                          function: () {
                            Navigator.pop(ctx);
                            onConfirm();
                          },
                          textStyle: StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.blackButton,
                          ),
                          color: AppColors.primary,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
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

  /// Shows Save Changes Confirmation Dialog (Screenshot 2)
  static Future<void> showSaveDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
    required FutureOr<void> Function() onConfirm,
  }) async {
    await showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SizedBox(
              width: 400.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize18Weight600.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomSvgImage(
                    assetPath: AppAssets.crmSaveSvgDialog,
                    width: 220.sp,
                    height: 160.sp,
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    children: [
                      Expanded(
                        child: customButtonWithSvg(
                          title: S.current.crmDiscard,
                          function: () => Navigator.pop(ctx),
                          textStyle: StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.text,
                          ),
                          color: AppColors.darkGrey,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: customButtonWithSvg(
                          title: S.current.crmSave,
                          function: () async {
                            Navigator.pop(ctx);
                            await onConfirm();
                          },
                          textStyle: StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.blackButton,
                          ),
                          color: AppColors.primary,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
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

  static Future<void> showChangeStatusDialog({
    required BuildContext context,
    required Future<void> Function() onConfirm,
  }) async {
    await showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SizedBox(
              width: 400.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSvgImage(
                        assetPath: AppAssets.crmStatus,
                        width: 28.sp,
                        height: 28.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        'Change Status',
                        style: StyleText.fontSize18Weight600.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    'Are you sure to change this status?',
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 24.sp),
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    children: [
                      Expanded(
                        child: customButtonWithSvg(
                          title: 'Cancel',
                          function: () => Navigator.pop(ctx),
                          textStyle: StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.text,
                          ),
                          color: AppColors.darkGrey,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Expanded(
                        child: customButtonWithSvg(
                          title: 'Change',
                          function: () {
                            Navigator.pop(ctx);
                            onConfirm();
                          },
                          textStyle: StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.blackButton,
                          ),
                          color: AppColors.primary,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
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

  /// Shows Add/Create Template Dialog
  static Future<void> showAddTemplateDialog({
    required BuildContext context,
    required void Function(String nameEn, String nameAr) onConfirm,
  }) =>
      _CrmControlDialogsStatics.showAddTemplateDialog(
        context: context,
        onConfirm: onConfirm,
      );

  static Future<void> showEditTemplateDialog({
    required BuildContext context,
    required String nameEn,
    required String nameAr,
    required void Function(String nameEn, String nameAr) onConfirm,
  }) =>
      _CrmControlDialogsStatics.showEditTemplateDialog(
        context: context,
        nameEn: nameEn,
        nameAr: nameAr,
        onConfirm: onConfirm,
      );
}
