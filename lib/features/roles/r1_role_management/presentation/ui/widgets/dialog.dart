import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/generated/l10n.dart'; // ✅ Add this import

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/core/custom/loading.dart';

class RoleDialogs {
  /// Show save for later confirmation dialog
  ///
  /// Parameters:
  ///   - pagesToPop: Number of services_management_module to pop after saving (default: 2)
  ///     * Use 2 for RolePermissionSwitches page
  ///     * Use 3 for SettingsSwitchesPage
  static void showSaveForLaterDialog({
    required BuildContext context,
    required RoleCubit controller,
    int pagesToPop = 2,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.all(15.sp),
        content: Container(
          color: AppColors.card,
          width: 411.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie_assets/roles_lottie_assets/Edit Document.json',
                width: 70.sp,
                height: 70.sp,
                repeat: true,
                fit: BoxFit.scaleDown,
              ),
              SizedBox(height: 10.h),
              Text(
                S.of(context).saveDraft,
                style: AppTextStyles.font16BlackRegularCairo.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.text
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                S.of(context).doYouWantToSaveThisRoleAsDraft,
                style: AppTextStyles.font14BlackRegularCairo.copyWith(
                    color: AppColors.text
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customButton(
                    title: S.of(context).no,
                    color: AppColors.secondaryButton,
                    textStyle: AppTextStyles.font14BlackRegularCairo.copyWith(
                        color: Colors.black
                    ),
                    width: 100.w,
                    function: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  SizedBox(width: 20.w),
                  customButton(
                    title: S.of(context).yes,
                    color: AppColors.primary,
                    textStyle: AppTextStyles.font14BlackRegularCairo.copyWith(
                      color: AppColors.textButton,
                    ),
                    width: 100.w,
                    function: () async {
                      Navigator.of(dialogContext).pop();
                      await _saveDraftAndShowSuccess(context, controller, pagesToPop);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Save draft and show success dialog with auto-navigation to home
  ///
  /// Parameters:
  ///   - pagesToPop: Number of services_management_module to pop after showing success
  static Future<void> _saveDraftAndShowSuccess(
      BuildContext context,
      RoleCubit controller,
      int pagesToPop,
      ) async {
    try {
      // Show loading
      showLoadingIndicator();

      // Save the draft
      await controller.saveDraft();

      // Hide loading
      hideLoadingIndicator();

      // Check if context is still valid
      if (!context.mounted) {
        return;
      }

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (successDialogContext) {
          // Auto-close after 2 seconds and navigate back
          Future.delayed(Duration(seconds: 2), () {
            if (successDialogContext.mounted) {
              Navigator.of(successDialogContext).pop();
            }

            if (context.mounted) {
              for (int i = 0; i < pagesToPop; i++) {
                Navigator.of(context).pop();
              }
            }
          });

          return PopScope(
            canPop: false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.all(20.sp),
              content: SizedBox(
                width: 411.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie_assets/main_lottie_assets/approved.json',
                      width: 70.sp,
                      height: 70.sp,
                      repeat: false,
                      fit: BoxFit.scaleDown,
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      S.of(context).success,
                      style: AppTextStyles.font16BlackRegularCairo.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      S.of(context).roleSavedAsDraftSuccessfully,
                      style: AppTextStyles.font14BlackRegularCairo,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

    } catch (e, stackTrace) {

      hideLoadingIndicator();

      if (context.mounted) {
        Get.snackbar(
          S.of(context).error,
          S.of(context).failedToSaveDraftPleaseTryAgain,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
        );
      }
    }
  }
}