/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_approvals_details_screen.dart
/// Purpose: Displays the detailed view for Qiyas approvals on pages,
///          including toggleable sections, document info, and tab switching.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This screen provides a pages-optimized ui for viewing
///              Qiyas approval details, with support for expandable content,
///              document previews, and switching between approvals and comments.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/presentation/controller/qiyas_manager_approval_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/presentation/presentation/ui/widgets/comment_section.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/presentation/ui/widgets/submission_details.dart';

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/presentation/ui/widgets/task_details_overview.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';

class QiyasApprovalsDetailsScreen extends StatelessWidget {
  QiyasApprovalsDetailsScreen({super.key});
  final QiyasManagerApprovalCubit controller = sl();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QiyasLogService.log('qiyas approval details');
    });
    final controllerPermission = Get.find<MainCoreEmployeeController>();
    final bool isTablet = !kpIsPhoneLayout(context);
    return Scaffold(
      body: SafeArea(
          child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.only(
            start: isTablet ? 30.sp : 15.sp, end: 15.sp),
        child: Directionality(
            textDirection: TextDirection.rtl,
            child: BlocProvider.value(
              value: controller,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                    screensTitles: [
                      'قياس التحول الرقمي',
                      'الموافقات',
                      controller.selectedTask!.visionName
                    ],
                  ),
                  TaskDetailsOverview(taskOverview: controller.selectedTask!),
                  SizedBox(height: 20.sp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الموافقات', style: StyleText.fontSize20Weight500),
                      const Spacer(),
                      BlocBuilder<QiyasManagerApprovalCubit,
                          QiyasManagerApprovalState>(
                        buildWhen: (_, currentState) {
                          return currentState is SectionViewUpdated;
                        },
                        builder: (context, state) {
                          return Container(
                            padding: EdgeInsets.all(4.sp),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(4.sp),
                            ),
                            child: Row(
                              children: [
                                customButton(
                                  title: 'تقديمات',
                                  function: () {
                                    controller
                                        .toggleDiscussionsVisibility(false);
                                  },
                                  color: !controller.isShowDiscissions
                                      ? AppColors.primary
                                      : AppColors.card,
                                  textStyle: StyleText.fontSize16Weight400
                                      .copyWith(
                                          color: !controller.isShowDiscissions
                                              ? AppColors.textButton
                                              : AppColors.secondaryText),
                                ),
                                customButton(
                                  title: 'الاستفسارات',
                                  function: () {
                                    controller
                                        .toggleDiscussionsVisibility(true);
                                  },
                                  color: controller.isShowDiscissions
                                      ? AppColors.primary
                                      : AppColors.card,
                                  textStyle: StyleText.fontSize16Weight500
                                      .copyWith(color: AppColors.blackButton)
                                      .copyWith(
                                          color: controller.isShowDiscissions
                                              ? AppColors.textButton
                                              : AppColors.secondaryText),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp),
                  BlocBuilder<QiyasManagerApprovalCubit,
                      QiyasManagerApprovalState>(builder: (_, state) {
                    if (controller.isShowDiscissions) {
                      return CommentSection(
                        criteriaNumber: controller.selectedTask!.criteriaNumber,
                        evidenceNumber: controller.selectedTask!.evidenceNumber,
                      );
                      //d
                    }

                    return SubmissionDetails(
                        isOwner: controllerPermission.isHasPermission(
                          module: Modules.qiyas,
                          section:
                              QiyasPermissionsSections.changeSubmissionStatus,
                          permission: null,
                        ),
                        isChampion: false,
                        isManager: true,
                        submissions: controller.evidenceSubmissions);
                  })
                ],
              ),
            )),
      )),
    );
  }
// controllerPermission.isHasPermission(
//   module: Modules.qiyas,
//   section: QiyasPermissionsSections.changeSubmissionStatus,
//   permission: null,
// ),
}
