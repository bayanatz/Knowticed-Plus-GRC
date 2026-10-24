/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_approvals_screen.dart
/// Purpose: Manages the Qiyas approvals screen for mobile view,
///          including filtering, search, and navigation to details.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: Tablet screen widget for Qiyas approvals, implementing
///              ui components like search, filters, and animated list display
///              using GetX architecture and controller bindings.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_bar_item.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_tasks/presentation/controller/qiyas_owner_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/presentation/ui/pages/qiyas_approvals_details_screen.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/presentation/controller/qiyas_manager_approval_cubit.dart'
    hide QiyasTasksStatusUpdated;
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/presentation/ui/widgets/submission_time_filter.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/approvals/presentation/ui/widgets/task_overview_widget.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class QiyasApprovalsScreen extends StatelessWidget {
  QiyasApprovalsScreen({super.key});

  final QiyasManagerApprovalCubit controller =
      sl.registerSingletonIfAbsent(() => QiyasManagerApprovalCubit());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QiyasLogService.log('qiyas approvals');
    });
    bool isTablet = !kpIsPhoneLayout(context);
    controller.initCubit();
    return Scaffold(
      body: SafeArea(
          child: BlocProvider.value(
        value: controller,
        child: Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.only(
                start: isTablet ? 30.sp : 15.sp, end: 15.sp),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PaginationAppBar(
                      screensTitles: ["قياس التحول الرقمي", "الموافقات"]),
                  BlocBuilder<QiyasManagerApprovalCubit,
                      QiyasManagerApprovalState>(
                    buildWhen: (_, currentState) {
                      return currentState is QiyasTasksStatusUpdated ||
                          currentState is QiyasTasksDataLoaded;
                    },
                    builder: (context, state) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 30.sp,
                          children: [
                            for (EvidenceSubmissionStatus status
                                in EvidenceSubmissionStatus.values)
                              FilterBarItem(
                                isSelected: status == controller.selectedStatus,
                                title: status.value,
                                numberOfItems:
                                    controller.taskStatusMap[status]?.length ??
                                        0,
                                onTap: () {
                                  controller.updateSelectedStatus(status);
                                },
                                color: status.color,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 15.sp),
                  Row(
                    spacing: ButtonSizing.toolbarGap(context),
                    children: [
                      AppSearchTextField(
                        hintText: "بحث",
                        onChanged: (value) {
                          controller.searchTasks();
                        },
                        controller: controller.searchController,
                      ),
                      customButtonWithSvg(
                        width: isTablet ? 100 : 36,
                        title: isTablet ? 'الفرز' : '',
                        function: () {
                          SubmissionTimeFilterDialog().show(context);
                        },
                        color: AppColors.card,
                        textStyle: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.blackButton)
                            .copyWith(
                              color: AppColors.secondaryText,
                            ),
                        image:
                            'assets/icons_assets/main_icons_assets/ic_action_filter.svg',
                        svgColor: AppColors.secondaryText,
                        colorBorder: AppColors.transparent,
                        widthImage: 20.sp,
                        heightImage: 20.sp,
                      )
                    ],
                  ),
                  SizedBox(height: 15.sp),
                  BlocBuilder<QiyasManagerApprovalCubit,
                      QiyasManagerApprovalState>(
                    buildWhen: (_, currentState) {
                      return currentState is QiyasTasksStatusUpdated ||
                          currentState is QiyasTasksDataLoaded;
                    },
                    builder: (context, state) {
                      if (controller.filteredTasks.isEmpty) {
                        return Expanded(
                          child: Center(
                            child: CustomEmptyState(
                              lottiePath:
                                  'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                              size: 300,
                              verticalPadding: 0,
                            ),
                          ),
                        );
                      }
                      return Expanded(
                          child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: CrossAxisCountHelper
                              .getCrossAxisCountForDefaultTablet2(context),
                          mainAxisExtent: 210.sp,
                          mainAxisSpacing: 10.sp,
                          crossAxisSpacing: 10.sp,
                        ),
                        itemCount: controller.filteredTasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              HapticController
                                  .low(); // list row: on the tap (X-117)
                              try {
                                QiyasOwnerTasksCubit controlTask = sl();
                                controlTask.selectTask(
                                    controller.filteredTasks[index]);
                              } catch (e) {
                                debugPrint("error");
                              }
                              controller
                                  .selectTask(controller.filteredTasks[index]);
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) {
                                return QiyasApprovalsDetailsScreen();
                              }));
                            },
                            child: TaskOverviewWidget(
                              taskOverview: controller.filteredTasks[index],
                            ),
                          );
                        },
                      ));
                    },
                  )
                ],
              ),
            )),
      )),
    );
  }
}
