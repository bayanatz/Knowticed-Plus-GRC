/// ***************************** FILE INFO ***************************** ///
/// File Name: champion_nav_down_buttons.dart
/// Purpose: Defines the navigation buttons (Cancel and Submit) for the Qiyas Create Control Champion form.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `ChampionNavDownButtons` widget, which renders two buttons for cancelling or submitting the form
///              in the "Qiyas Create Control Champion" process. The Cancel button clears the form and pops the current screen, while
///              the Submit button adds a new Qiyas Champion and shows a confirmation dialog. It also handles form reset and refreshes the data.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';

class ChampionNavDownButtons extends StatelessWidget {
  ChampionNavDownButtons({super.key, this.onSuccessCallback});

  final Future<void> Function()? onSuccessCallback;
  final QiyasCreateChampionControllerCubit controller = sl();

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return Column(
      children: [
        SizedBox(height: 20.sp),
        Row(
          textDirection: TextDirection
              .ltr, // X-73: Cancel left, action right in both languages

          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            customButton(
                width: isTablet ? 150 : 130,
                title: "إلغاء",
                color: !(AppTheme.isDark) ? AppColors.grey : AppColors.darkGrey,
                textStyle: StyleText.fontSize16Weight400,
                function: () {
                  controller.clearAllControllers();
                  Navigator.of(context).pop();
                }),
            customButton(
                width: isTablet ? 150 : 130,
                title: "إرسال",
                function: () {
                  if (!controller.formKey.currentState!.validate()) return;
                  if (controller.selectedPerson == null) {
                    CustomDialogManager.showMessage(
                      context: context,
                      lottiePath:
                          'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
                      title: 'خطأ',
                      subtitle: 'يرجي اختيار سفير',
                    );
                    return;
                  }
                  CustomDialogManager.showDialogFlow(
                    context: context,
                    confirmLottie:
                        "assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json",
                    confirmTitle: "إضافة سفير التحول الرقمي جديد",
                    confirmSubtitle:
                        "هل أنت متأكد أنك تريد إضافة سفير التحول الرقمي هذا؟",
                    confirmYesText: "نعم",
                    confirmNoText: "لا",
                    onConfirm: () async {
                      bool succeeded = false;
                      await controller.addQiyasChampion(onSuccess: () {
                        succeeded = true;
                        // Trigger dashboard refresh after successful assignment
                        onSuccessCallback?.call();
                      });
                      return succeeded;
                    },
                    successLottie:
                        'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
                    successTitle: 'تم التعيين بنجاح',
                    successSubtitle: 'لقد نجحت في تعيين المهام',
                    onSuccessComplete: () {
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  );
                }),
          ],
        ),
      ],
    );
  }
}
