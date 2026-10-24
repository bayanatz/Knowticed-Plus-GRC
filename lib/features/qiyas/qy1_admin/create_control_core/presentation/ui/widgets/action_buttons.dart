import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/pages/reassign_page.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/champions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/pages/edit_champion_page.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/widgets/edit_champion_dialog.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';

class ActionButtons extends StatelessWidget {
  ActionButtons({super.key});
  final MainCoreEmployeeController mainCoreEmployeeController = Get.find();

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    final QiyasCreateChampionControllerCubit controllerCubit =
        context.read<ControlCoreCubit>() as QiyasCreateChampionControllerCubit;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 10.sp,
      children: [
        if (mainCoreEmployeeController.isHasPermission(
          module: Modules.qiyas,
          permission: Champions.reassignChampion,
          section: QiyasPermissionsSections.champions,
        ))
          customButton(
              title: 'إعادة تعيين',
              function: () {
                controllerCubit.initChampionReassignControllers();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return ReassignPage();
                }));
              }),
        Spacer(),
        if (mainCoreEmployeeController.isHasPermission(
          module: Modules.qiyas,
          permission: Champions.editEvidence,
          section: QiyasPermissionsSections.champions,
        ))
          customButtonWithSvg(
              title: isTablet ? "تعديل" : "",
              image: "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
              widthImage: 16.sp,
              heightImage: 16.sp,
              function: () {
                controllerCubit.initChampionEditControllers();
                bool isTablet = !kpIsPhoneLayout(context);
                if (isTablet) {
                  EditChampionDialog().show(context);
                } else {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return EditChampionPage();
                  }));
                }
              }),
        if (mainCoreEmployeeController.isHasPermission(
          module: Modules.qiyas,
          permission: Champions.removeChampion,
          section: QiyasPermissionsSections.champions,
        ))
          customButtonWithSvg(
              color: AppColors.red,
              colorBorder: AppColors.transparent,
              width: isTablet ? 130 : 38,
              svgColor: AppColors.white,
              widthImage: 20.sp,
              heightImage: 20.sp,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.white),
              // empty title on phone → icon-only button, matching the old
              // DynamicIconButton's responsive behaviour
              title: isTablet ? "إزالة" : "",
              image:
                  "assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg",
              function: () {
                CustomDialogManager.showDialogFlow(
                  context: context,
                  confirmLottie:
                      "assets/lottie_assets/main_lottie_assets/lot_action_delete.json",
                  confirmTitle: "حذف مهام سفير التحول الرقمي",
                  confirmSubtitle: "هل انت متاكد من انك تريد حذف مهام السفير؟",
                  confirmYesText: "نعم",
                  confirmNoText: "لا",
                  onConfirm: () async {
                    // Delete all criteria assignments for this champion
                    await controllerCubit.deleteQiyasChampionList(
                        controllerCubit.getSelectedUserChampionEntities());

                    // ✅ FIX: Only reload Firestore data to refresh the
                    // details page — do NOT call initCubit() which would
                    // remove the champion card from the list entirely.
                    await controllerCubit.readDataFromFirestore();

                    // Reset the detail view selections since
                    // the champion no longer has any assignments
                    controllerCubit.selectedVision = null;
                    controllerCubit.selectedTopic = null;
                    controllerCubit.selectedCriterion = null;
                    controllerCubit.selectedDocument = null;

                    return true;
                  },
                  successLottie:
                      "assets/lottie_assets/main_lottie_assets/lot_status_success.json",
                  successTitle: "حذف مهام سفير التحول الرقمي",
                  successSubtitle: "تم حذف مهام سفير التحول الرقمي",
                  onSuccessComplete: () {
                    if (context.mounted) Navigator.of(context).pop();
                  },
                );
              }),
      ],
    );
  }
}
