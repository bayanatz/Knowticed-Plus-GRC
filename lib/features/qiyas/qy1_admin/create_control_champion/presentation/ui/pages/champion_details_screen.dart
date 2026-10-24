import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/ui/widgets/employee_overview.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/presentation/presentation/ui/widgets/comment_section.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/ui/widgets/action_buttons.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/ui/widgets/document_selector.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/ui/widgets/user_tasks_section.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class ChampionDetailsScreen extends StatelessWidget {
  const ChampionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    ControlCoreCubit controller = context.read<ControlCoreCubit>();
    debugPrint("details page is Tablet: $isTablet");
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              start: isTablet ? 30.sp : 15.sp, end: 15.sp),
          child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(screensTitles: [
                    'سفراء التحول الرقمي',
                    controller.personDetails!.name
                  ]),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EmployeeOverview(),
                          SizedBox(height: 10.sp),
                          ActionButtons(),
                          SizedBox(height: 10.sp),
                          DocumentSelector(
                            unselectedColor: AppColors.card,
                          ),
                          SizedBox(height: 20.sp),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              BlocBuilder<ControlCoreCubit, ControlCoreState>(
                                bloc: controller,
                                buildWhen: (_, currentState) {
                                  return currentState is SectionViewUpdated;
                                },
                                builder: (context, state) {
                                  if (controller.selectedDocument != null) {
                                    return Container(
                                      padding: EdgeInsets.all(4.sp),
                                      decoration: BoxDecoration(
                                        color: AppColors.card,
                                        borderRadius:
                                            BorderRadius.circular(4.sp),
                                      ),
                                      child: Row(
                                        children: [
                                          customButton(
                                            title: 'المهام',
                                            function: () {
                                              controller
                                                  .toggleDiscussionsVisibility(
                                                      false);
                                            },
                                            color: !controller.isShowDiscissions
                                                ? AppColors.primary
                                                : AppColors.card,
                                            textStyle: StyleText
                                                .fontSize16Weight400
                                                .copyWith(
                                                    color: !controller
                                                            .isShowDiscissions
                                                        ? AppColors.textButton
                                                        : AppColors
                                                            .secondaryText),
                                          ),
                                          customButton(
                                            title: 'الاستفسارات',
                                            function: () {
                                              controller
                                                  .toggleDiscussionsVisibility(
                                                      true);
                                            },
                                            color: controller.isShowDiscissions
                                                ? AppColors.primary
                                                : AppColors.card,
                                            textStyle: StyleText
                                                .fontSize16Weight500
                                                .copyWith(
                                                    color: AppColors
                                                        .secondaryBlack)
                                                .copyWith(
                                                    color: controller
                                                            .isShowDiscissions
                                                        ? AppColors.textButton
                                                        : AppColors
                                                            .secondaryText),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10.sp),
                          BlocBuilder<ControlCoreCubit, ControlCoreState>(
                            bloc: controller,
                            buildWhen: (_, currentState) {
                              return currentState is SectionViewUpdated ||
                                  currentState is EvidenceSubmissionLoading ||
                                  currentState is EvidenceSubmissionLoaded;
                            },
                            builder: (context, state) {
                              if (controller.selectedCriterion == null) {
                                return Container();
                              }
                              if (controller.isShowDiscissions &&
                                  controller.selectedDocument != null) {
                                return CommentSection(
                                  isExpanded: false,
                                  criteriaNumber:
                                      controller.getSelectedCriteriaNumber(),
                                  evidenceNumber:
                                      controller.getSelectedEvidenceNumber(),
                                );
                              }

                              if (state is EvidenceSubmissionLoading) {
                                return Center(child: CircleProgressMaster());
                              }
                              return SizedBox(
                                height: 500.h,
                                child: UserTasksSection(isOwner: false),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
