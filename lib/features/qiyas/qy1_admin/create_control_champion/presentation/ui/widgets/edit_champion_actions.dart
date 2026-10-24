import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';

class EditChampionActions extends StatelessWidget {
  const EditChampionActions({super.key});

  @override
  Widget build(BuildContext context) {
    QiyasCreateChampionControllerCubit controllerCubit =
        context.read<ControlCoreCubit>() as QiyasCreateChampionControllerCubit;
    bool isTablet = !kpIsPhoneLayout(context);
    return Row(
      textDirection: TextDirection
          .ltr, // X-73: Cancel left, action right in both languages

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
            width: isTablet ? 150 : 135,
            title: 'إلغاء',
            function: () {
              Navigator.of(context).pop();
            },
            color: AppColors.secondaryButton,
            textStyle: StyleText.fontSize16Weight400),
        customButton(
          width: isTablet ? 150 : 135,
          title: 'حفظ',
          function: () {
            /// ===== Validate all form fields before save =====
            final formState = controllerCubit.formKey.currentState;
            if (formState == null || !formState.validate()) {
              debugPrint('🔴 Form validation failed');
              return;
            }
            debugPrint('🟢 Form validation passed');

            CustomDialogManager.showDialogFlow(
              context: context,
              confirmLottie:
                  "assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json",
              confirmTitle: "حفظ التعديلات",
              confirmSubtitle: "هل انت متاكد من انك تريد حفظ التعديلات؟",
              confirmYesText: "نعم",
              confirmNoText: "لا",
              onConfirm: () async {
                bool succeeded = false;
                await controllerCubit.saveEdits(onSuccess: () {
                  succeeded = true;
                });
                return succeeded;
              },
              successLottie:
                  'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
              successTitle: 'تم التعديل بنجاح',
              successSubtitle: 'لقد نجحت في تعديل المهام لهذا السفير',
              onSuccessComplete: () {
                if (!context.mounted) return;
                Navigator.of(context).pop();
                if (!isTablet) Navigator.of(context).pop();
              },
            );
          },
        ),
      ],
    );
  }
}
