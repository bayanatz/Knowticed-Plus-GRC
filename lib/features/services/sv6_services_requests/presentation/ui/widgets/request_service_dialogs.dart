/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_service_dialogs.dart
/// Purpose: The dialogs of the "request a service" flow (confirm, please
///          wait, success, error) and [RequestServiceDialogs.run], which
///          chains them around NewRequestCubit.submit.
/// Author: Amr Mesbah
/// Created at: 02/02/2026
library;

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/new_request_cubit.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/my_request_toggle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/helpers/services_feedback.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

class RequestServiceDialogs {
  /// Function Name: [run]
  ///
  /// Purpose: Asks for confirmation, shows "please wait" while
  /// NewRequestCubit (read from [context]) saves the request, then shows the
  /// success dialog for two seconds and opens "My requests", or shows the
  /// error dialog.
  ///
  /// Parameters:
  /// - [context]: a context below the page's NewRequestCubit provider.
  /// - [service]: the service being requested.
  static Future<void> run(
    BuildContext context,
    ServicesHistoryModel service,
  ) async {
    final cubit = context.read<NewRequestCubit>();
    final confirmed = await showConfirmationDialog(context);
    if (confirmed != true || !context.mounted) return;

    showLoadingDialog(context);
    final result = await cubit.submit(service);
    if (!context.mounted) return;
    closeDialogWithRoot(context);

    if (result != NewRequestStatus.success) {
      showErrorDialog(context);
      return;
    }

    // SVC-REQ-08: saved, but the approver / confirmation was not sent.
    if (cubit.lastNotificationFailed) {
      ServicesFeedback.showWarning(
        ScaffoldMessenger.of(context),
        S.of(context).svcRequestSavedNotifyFailed,
      );
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    Future.delayed(const Duration(seconds: 2), () {
      if (navigator.canPop()) navigator.pop();
      if (context.mounted) navigateTo(context, MyRequestServicesToggle());
    });
    await showSuccessDialog(context);
  }

  /// Show confirmation dialog before creating request
  static Future<bool?> showConfirmationDialog(BuildContext context) {
    return showAppDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (confirmDialogContext) {
        return Dialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            width: 411.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  ServicesLottie.confirmation,
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 8.h),
                Text(
                  FormatHelper.capitalize(
                    S.of(confirmDialogContext).RequestService,
                  ),
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    FormatHelper.capitalize(
                      S
                          .of(confirmDialogContext)
                          .AreYouSureYouWantToRequestThisService,
                    ),
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customButton(
                      title: FormatHelper.capitalize(
                        S.of(confirmDialogContext).no,
                      ),
                      function: () => Navigator.of(
                        confirmDialogContext,
                        rootNavigator: true,
                      ).pop(false),
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.onSecondaryAction,
                      ),
                      width: 135.sp,
                      height: 38.sp,
                      color: AppColors.secondaryAction,
                    ),
                    SizedBox(width: 15.w),
                    customButton(
                      title: FormatHelper.capitalize(
                        S.of(confirmDialogContext).yes,
                      ),
                      function: () => Navigator.of(
                        confirmDialogContext,
                        rootNavigator: true,
                      ).pop(true),
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 135.sp,
                      height: 38.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show loading dialog while processing request
  static void showLoadingDialog(BuildContext context) {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleProgressMaster(),
                  SizedBox(height: 20.h),
                  Text(
                    FormatHelper.capitalize(S.of(loadingContext).pleaseWait),
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show success dialog after request is created
  static Future<void> showSuccessDialog(BuildContext context) {
    return showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (successContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.h),
              width: 411.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    ServicesLottie.approved,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.scaleDown,
                    repeat: false,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    FormatHelper.capitalize(
                      S.of(successContext).serviceRequested,
                    ),
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      FormatHelper.capitalize(
                        S
                            .of(successContext)
                            .YouSuccessfullyRequestedThisService,
                      ),
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show error dialog when request fails
  static void showErrorDialog(BuildContext context, {String? message}) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: ServicesLottie.error,
      title: S.of(context).error,
      subtitle: message ?? S.of(context).failedToCreateServiceRequest,
      closeAfter: const Duration(seconds: 5),
    );
  }

  /// Close any open dialog
  static void closeDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Close dialog with root navigator
  static void closeDialogWithRoot(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
