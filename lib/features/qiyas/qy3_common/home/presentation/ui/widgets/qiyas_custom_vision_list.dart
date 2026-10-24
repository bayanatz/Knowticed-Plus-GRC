/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_custom_vision_list.dart
/// Purpose: Displays a list of vision names and associated topic names in a horizontal scrollable view,
///          each with clickable buttons to navigate to their respective details screens.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget creates a list of vision names, each with associated topics that can be clicked to
///              navigate to detailed views of either the vision or the topic. The layout adapts to various screen
///              sizes, adjusting based on whether the app is running on desktop, pages, or mobile.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/qiyas_dashboard_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/ui/tablet/qiyas_topic_details_tablet.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/vision_details/presentation/ui/tablet/qiyas_vision_details_tablet.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class QiyasCustomVisionList extends StatefulWidget {
  const QiyasCustomVisionList(
      {super.key,
      this.isDashBoard = false,
      this.isAdminHome = false,
      this.isClickable = true});
  final bool isClickable;
  final bool isDashBoard;
  final bool isAdminHome;

  @override
  State<QiyasCustomVisionList> createState() => _QiyasCustomVisionListState();
}

class _QiyasCustomVisionListState extends State<QiyasCustomVisionList> {
  late QiyasDashboardControllerCubit dashboardController;

  @override
  Widget build(BuildContext context) {
    dashboardController = context.read<QiyasDashboardControllerCubit>();
    List<String> visionNames = sl<QiyasHomeCubit>().uniqueVisionNames;
    //  // // ////////print("Vision Names: $visionNames");
    return BlocBuilder<QiyasDashboardControllerCubit,
        QiyasDashboardControllerState>(
      buildWhen: (_, currentState) {
        return currentState is QiyasDashboardControllerLoadedState;
      },
      builder: (context, state) {
        if (widget.isDashBoard) {
          dashboardController
              .getVisionAndCriteriaData(); // For topicColor (submission status)
          dashboardController
              .getTopicAssignStatus(); // ✅ ADD THIS - For topicAssignStatus (assignment badges)
        } else {
          dashboardController.getTopicAssignStatus();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.sp,
            children: [
              for (int index = 0; index < visionNames.length; index++)
                buildVisionSection(index, context)
            ],
          ),
        );
      },
    );
  }

  Widget buildVisionSection(int index, BuildContext context) {
    QiyasHomeCubit controller = sl();

    final visionNames = controller.uniqueVisionNames;
    final topicNames = controller.getTopicNamesByVisionName(visionNames[index]);
    return Column(
      spacing: 15.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customButton(
          width: 205,
          title: visionNames[index],
          function: () {
            // // ////////print("Vision Name: ${visionNames[index]}");
            if (widget.isClickable) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      QiyasVisionDetailsTablet(visionName: visionNames[index]),
                ),
              );
            }
          },
        ),
        SizedBox(
            width: 205.w,
            height: _calculateHeight(),
            child: Column(
              spacing: 10.sp,
              children: [
                for (int x = 0; x < topicNames.length; x++)
                  topicWidget(
                      visionNames, index, context, topicNames, x, controller),
              ],
            )),
      ],
    );
  }

  /// ✅ CRITICAL FIX: Extract topic number from criterion number
  /// This ensures consistency with dashboard logic
  /// Example: For topic "5.20", finds a criterion like "5.20.1" and extracts "5.20"
  String _extractTopicFromCriterion(
      QiyasHomeCubit controller, String topicName, String visionName) {
    // Find any vision that matches this topic and vision
    for (var vision in controller.visionsList) {
      if (vision.visionName.trim() == visionName.trim() &&
          vision.topicName.trim() == topicName.trim()) {
        // Extract topic from criterion number (e.g., "5.20.1" → "5.20")
        String criterionNumber = vision.criterionNumber.trim();
        List<String> parts = criterionNumber.split('.');

        if (parts.length >= 2) {
          String extractedTopic = '${parts[0]}.${parts[1]}';
          ////////print('🔧 EXTRACTED: Criterion "$criterionNumber" → Topic "$extractedTopic"');
          return extractedTopic;
        }
      }
    }

    ////////print('⚠️ FALLBACK: Could not extract topic for "$topicName" in "$visionName"');
    return '';
  }

  Expanded topicWidget(
      List<String> visionNames,
      int index,
      BuildContext context,
      List<String> topicNames,
      int x,
      QiyasHomeCubit controller) {
    bool isShowBadge = Get.find<MainCoreEmployeeController>().isHasPermission(
        module: Modules.qiyas,
        permission: QiyasPermissions.visionBadges,
        section: QiyasPermissionsSections.qiyasPermissions);

    // ✅ FIX: Extract topic number from criterion number (not topicNumber field)
    // This ensures consistency with dashboard logic
    String topicNumber = _extractTopicFromCriterion(
        controller, topicNames[x], visionNames[index]);

    // Get status from dashboard
    var assignStatus = dashboardController.topicAssignStatus[topicNumber];
    Color borderColor = Colors.red;

    if (widget.isDashBoard) {
      borderColor = assignStatus?.color ?? Colors.transparent;
    } else if (widget.isAdminHome && isShowBadge) {
      borderColor = assignStatus?.color ?? Colors.transparent;
    }

    // 🎨 COMPREHENSIVE DEBUG
    ////////print('\n🎨 ========== UI TOPIC WIDGET ==========');
    ////////print('   Vision: "${visionNames[index]}"');
    ////////print('   Topic: "${topicNames[x]}"');
    ////////print('   Topic Number: "$topicNumber"');
    ////////print('   ---');
    ////////print('   isDashBoard: $isDashBoard');
    ////////print('   isAdminHome: $isAdminHome');
    ////////print('   isShowBadge: $isShowBadge');
    ////////print('   ---');
    ////////print('   Assign Status Object: $assignStatus');
    ////////print('   Status Color: ${assignStatus?.color}');
    ////////print('   Border Color (final): $borderColor');
    ////////print('   ---');
    ////////print('   Condition Check:');
    ////////print('      widget.isDashBoard? $isDashBoard');
    ////////print('      widget.isAdminHome && isShowBadge? ${widget.isAdminHome && isShowBadge}');
    ////////print('      Will show border? ${borderColor != Colors.transparent}');
    ////////print('   ---');
    ////////print('   Dashboard Status Map Keys: ${dashboardController.topicAssignStatus.keys.toList()}');
    ////////print('   Status for "$topicNumber": ${dashboardController.topicAssignStatus[topicNumber]}');
    ////////print('========================================\n');

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => HapticController.low(),
        onTap: () {
          if (widget.isClickable) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QiyasTopicDetailsTablet(
                  dashboardCubit: dashboardController,
                  topicName: topicNames[x],
                  visionName: visionNames[index],
                ),
              ),
            );
          }
        },
        child: Stack(
          children: [
            Container(
              width: 205.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color:
                    widget.isDashBoard ? AppColors.background : AppColors.card,
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  topicNames[x],
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.secondaryBlack),
                ),
              ),
            ),
            // Diagonal Ribbon
            if (isShowBadge && assignStatus != null)
              Positioned(
                top: 15.sp,
                left: -55.sp,
                child: Transform.rotate(
                  angle: -0.785398,
                  child: Container(
                    width: 150.sp,
                    height: 14.sp,
                    color: assignStatus.color,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          assignStatus.value,
                          style: StyleText.fontSize8Weight500
                              .copyWith(color: AppColors.secondaryBlack)
                              .copyWith(
                                color: getBadgeTextColor(assignStatus.color),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateHeight() {
    QiyasHomeCubit controller = sl();
    // // // ////////print("max number of topics is ${controller.maxNumberOfTopics}");
    double height = 0;
    height += 10 * controller.maxNumberOfTopics;
    height += (controller.maxNumberOfTopics * 90);
    return height;
  }

  Color getBadgeTextColor(Color badgeColor) {
    return badgeColor.computeLuminance() > 0.5
        ? AppColors.black
        : AppColors.white;
  }
}
