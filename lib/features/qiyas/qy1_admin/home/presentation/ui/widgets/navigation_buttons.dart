import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';
import 'package:page_transition/page_transition.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champigan_core/presentation/controller/champigan_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/ui/pages/champigan_tasks_page.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/presentation/ui/pages/qiyas_approvals_screen.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/ui/pages/qiyas_dashboard.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';

class NavigationButtons extends StatelessWidget {
  NavigationButtons({super.key});
  final MainCoreEmployeeController mainCoreEmployeeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mainCoreEmployeeController.isHasPermission(
            module: Modules.qiyas,
            permission: null,
            section: QiyasPermissionsSections.approvals))
          customButton(
              width: 135,
              title: "الموافقات",
              textStyle: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.textButton),
              function: () {
                QiyasLogService.log('navigate to qiyas approvals');
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: QiyasApprovalsScreen(),
                  ),
                );
              }),
        Spacer(),
        Column(
          spacing: 10.sp,
          children: [
            if (mainCoreEmployeeController.isHasPermission(
                module: Modules.qiyas,
                permission: null,
                section: QiyasPermissionsSections.dashboard))
              customButton(
                  width: 135,
                  title: "لوحة المعلومات",
                  textStyle: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.textButton),
                  function: () {
                    QiyasLogService.log('navigate to qiyas dashboard');
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: QiyasDashboard(),
                      ),
                    );
                  }),
            // if (mainCoreEmployeeController.employeeEntity?.isManager() == true)
            //   customButton(
            //       width: 135,
            //       title: 'المعايير المكلفه',
            //       textStyle: StyleText.fontSize16Weight600.copyWith(
            //         color: AppColors.textButton,
            //       ),
            //       function: () {
            //         {
            //           Navigator.push(context, MaterialPageRoute(builder: (_) {
            //             return OwnerTasksPage();
            //           }));
            //         }
            //       }),
            if (mainCoreEmployeeController.employeeEntity?.isManager() ==
                    false &&
                sl<ChampiganCoreCubit>().champiganAccessList.isNotEmpty)
              customButton(
                  width: 135,
                  title: 'المعايير المكلفه',
                  function: () {
                    QiyasLogService.log('navigate to qiyas champion tasks');
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return ChampiganTasksPage();
                    }));
                  }),
          ],
        )
      ],
    );
  }
}
