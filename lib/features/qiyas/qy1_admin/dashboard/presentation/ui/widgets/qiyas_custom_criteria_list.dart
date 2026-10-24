/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_custom_criteria_list.dart
/// Purpose: Displays a hierarchical list of visions, topics, and criteria, each with clickable buttons to
///          navigate to detailed views. The widget adapts dynamically based on screen orientation (portrait/landscape),
///          platform (pages, desktop, or mobile), and adjusts the width and layout of buttons accordingly.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget renders a list of vision names, each containing related topics and criteria. The criteria
///              are shown under their respective topics, and both topics and criteria have clickable buttons. The layout
///              adapts to different screen sizes, and the text width is calculated dynamically based on the longest text.
/// ********************************************************************* ///
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/qiyas_dashboard_controller_cubit.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';

class QiyasCustomCriteriaList extends StatefulWidget {
  const QiyasCustomCriteriaList({super.key});

  @override
  State<QiyasCustomCriteriaList> createState() =>
      _QiyasCustomCriteriaListState();
}

class _QiyasCustomCriteriaListState extends State<QiyasCustomCriteriaList> {
  late QiyasDashboardControllerCubit controller;
  late double height;

  @override
  Widget build(BuildContext context) {
    controller = context.read<QiyasDashboardControllerCubit>();
    Map<String, Map<String, List<Map<String, String>>>> data =
        controller.getCriteriaValuesMap();

    // ✅ Calculate unified height for ALL visions
    height = _calculateUnifiedHeight(data);

    debugPrint("Unified Height for all visions: $height");

    return SizedBox(
        height: height,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 20.sp,
            children: [
              for (String vision in data.keys)
                buildVisionColumn(
                  vision: vision,
                  topics: data[vision]!,
                  context: context,
                ),
            ],
          ),
        ));
  }

  /// ✅ NEW: Calculate unified height based on maximum criteria count
  double _calculateUnifiedHeight(
      Map<String, Map<String, List<Map<String, String>>>> data) {
    int maxCriteriaCount = 0;

    // Find the maximum number of criteria in any single topic
    data.forEach((vision, topics) {
      topics.forEach((topic, criteriaList) {
        if (criteriaList.length > maxCriteriaCount) {
          maxCriteriaCount = criteriaList.length;
        }
      });
    });

    debugPrint(
        '📊 Maximum criteria count across all topics: $maxCriteriaCount');

    // Calculate height:
    // Vision header (30) + Topic buttons (36) + Spacing (15 + 15) +
    // Criteria boxes (100 per box) + Spacing between boxes (10 per gap)
    double calculatedHeight = 30.sp +
        36.sp +
        30.sp +
        (maxCriteriaCount * 100.sp) +
        ((maxCriteriaCount - 1) * 10.sp);

    return calculatedHeight;
  }

  Widget buildVisionColumn(
      {required String vision,
      required Map<String, List<Map<String, String>>> topics,
      required BuildContext context}) {
    return Column(
      spacing: 15.sp,
      children: [
        // Vision Header
        Container(
          alignment: Alignment.center,
          height: 30.sp,
          width: 500.sp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.sp),
            color: const Color(0xff797979),
          ),
          child: Text(vision,
              textAlign: TextAlign.center,
              style: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.white)),
        ),

        // Topic Buttons Row
        SizedBox(
          width: 500.sp,
          child: Row(
            spacing: 25.sp,
            children: [
              for (String topic in topics.keys)
                Expanded(
                    child: customButton(
                        height: 36.sp, title: topic, function: () {}))
            ],
          ),
        ),

        // ✅ Criteria Boxes with EQUAL distribution
        SizedBox(
          width: 500.sp,
          height:
              height - 30.sp - 36.sp - 30.sp, // Subtract headers and spacing
          child: Row(
            spacing: 25.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (String topic in topics.keys)
                Expanded(
                  child: Column(
                    spacing: 10.sp,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (Map<String, String> criteria in topics[topic]!)
                        Expanded(
                          // ✅ BACK TO EXPANDED for equal distribution
                          child: buildCriteriaWidget(criteria, context),
                        ),
                    ],
                  ),
                )
            ],
          ),
        )
      ],
    );
  }

  /// ✅ Build criteria widget with border colors and badges
  Widget buildCriteriaWidget(
      Map<String, String> criteria, BuildContext context) {
    bool isShowBadge = Get.find<MainCoreEmployeeController>().isHasPermission(
        module: Modules.qiyas,
        permission: QiyasPermissions.visionBadges,
        section: QiyasPermissionsSections.qiyasPermissions);

    String criteriaNumber = criteria.values.first;

    // Get assignment status
    var assignStatus = controller.criteriaAssignStatus[criteriaNumber];

    // Use assignment status color for dashboard
    Color borderColor = assignStatus?.color ?? Colors.transparent;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.sp),
            color: AppColors.background,
            border: Border.all(
              color: borderColor,
              width: 2.sp,
            ),
          ),
          child: Center(
            child: Text(
              criteria.keys.first,
              textAlign: TextAlign.center,
              maxLines: 4, // ✅ Limit lines to prevent overflow
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize14Weight400.copyWith(height: 1.2),
            ),
          ),
        ),
        // Diagonal Ribbon Badge
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
    );
  }

  /// Helper function for badge text color
  Color getBadgeTextColor(Color badgeColor) {
    return badgeColor.computeLuminance() > 0.5
        ? AppColors.black
        : AppColors.white;
  }
}
