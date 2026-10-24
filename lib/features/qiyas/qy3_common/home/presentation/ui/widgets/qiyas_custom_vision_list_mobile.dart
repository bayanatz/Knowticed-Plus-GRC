/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_custom_vision_list_mobile.dart
/// Purpose: Displays a list of vision topics in a mobile view for the Qiyas module.
///          This widget allows users to navigate to detailed views for each vision and topic by tapping on them.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget displays a list of unique vision names with associated topics in a vertical layout.
///              Users can navigate to detailed views for both vision and topic by tapping on them.
///              The widget adapts to portrait and landscape modes, ensuring an optimal layout. It also dynamically fetches
///              vision and topic names using a controller and ensures seamless navigation between different screens.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/ui/tablet/qiyas_topic_details_tablet.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/qiyas_dashboard_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/ui/tablet/qiyas_vision_details_tablet.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class QiyasCustomVisionListMobile extends StatelessWidget {
  const QiyasCustomVisionListMobile({
    super.key,
    this.isDashBoard = false,
    this.isClickable = true,
  });

  final bool isClickable;

  final bool isDashBoard;

  @override
  Widget build(BuildContext context) {
    QiyasDashboardControllerCubit dashboardController =
        context.read<QiyasDashboardControllerCubit>();
    List<String> visionNames = sl<QiyasHomeCubit>().uniqueVisionNames;
    QiyasHomeCubit controller = sl();

    return BlocBuilder<QiyasDashboardControllerCubit,
        QiyasDashboardControllerState>(
      buildWhen: (_, currentState) {
        return currentState is QiyasDashboardControllerLoadedState;
      },
      builder: (context, state) {
        dashboardController.getTopicAssignStatus();
        return Column(
          children: [
            SizedBox(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: visionNames.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  bool isShowBadge = Get.find<MainCoreEmployeeController>()
                      .isHasPermission(
                          module: Modules.qiyas,
                          permission: QiyasPermissions.visionBadges,
                          section: QiyasPermissionsSections.qiyasPermissions);
                  final topicNames =
                      controller.getTopicNamesByVisionName(visionNames[index]);
                  return Column(
                    children: [
                      if (index != 0) SizedBox(height: 25.sp),
                      Column(
                        spacing: 15.sp,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customButton(
                            height: 30.h,
                            width: double.infinity,
                            title: visionNames[index],
                            function: () {
                              if (isClickable) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        QiyasVisionDetailsTablet(
                                      visionName: visionNames[index],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          Column(
                            spacing: 10.sp,
                            children: [
                              for (int topicIndex = 0;
                                  topicIndex < topicNames.length;
                                  topicIndex++)
                                GestureDetector(
                                  onTap: () {
                                    HapticController
                                        .low(); // list row: on the tap (X-117)
                                    if (isClickable) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              QiyasTopicDetailsTablet(
                                                  dashboardCubit:
                                                      dashboardController,
                                                  visionName:
                                                      visionNames[index],
                                                  topicName:
                                                      topicNames[topicIndex]),
                                        ),
                                      );
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 55.sp,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: (isShowBadge)
                                                ? dashboardController
                                                        .topicAssignStatus[controller
                                                            .getTopicNumberByVisionAndTopicName(
                                                                topicNames[
                                                                    topicIndex],
                                                                visionNames[
                                                                    index])]
                                                        ?.color ??
                                                    Colors.transparent
                                                : Colors.transparent,
                                          ),
                                          color: AppColors.card,
                                        ),
                                        child: Center(
                                          child: Text(topicNames[topicIndex],
                                              style: StyleText
                                                  .fontSize12Weight400
                                                  .copyWith(
                                                      color:
                                                          AppColors.fullBlack)),
                                        ),
                                      ),
                                      if (isShowBadge)
                                        Positioned(
                                          top: -2.sp,
                                          left: -25.sp,
                                          child: Transform.rotate(
                                            angle:
                                                -0.785398, // -45 degrees in radians
                                            child: Container(
                                              width: 120.sp,
                                              height: 20.sp,
                                              color: dashboardController
                                                      .topicAssignStatus[controller
                                                          .getTopicNumberByVisionAndTopicName(
                                                              topicNames[
                                                                  topicIndex],
                                                              visionNames[
                                                                  index])]
                                                      ?.color ??
                                                  Colors
                                                      .transparent, // Green color
                                              child: Row(
                                                children: [
                                                  Spacer(),
                                                  Text(
                                                    dashboardController
                                                            .topicAssignStatus[controller
                                                                .getTopicNumberByVisionAndTopicName(
                                                                    topicNames[
                                                                        topicIndex],
                                                                    visionNames[
                                                                        index])]
                                                            ?.value ??
                                                        "",
                                                    style: StyleText
                                                        .fontSize8Weight500
                                                        .copyWith(
                                                            color: AppColors
                                                                .secondaryBlack)
                                                        .copyWith(
                                                            color: AppColors
                                                                .white),
                                                  ),
                                                  SizedBox(width: 25.sp)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
