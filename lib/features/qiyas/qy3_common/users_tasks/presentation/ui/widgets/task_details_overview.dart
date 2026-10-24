/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_approvals_container_details.dart
/// Purpose: Displays the container for detailed Qiyas approval information,
///          including perspective, description, pillar, and standard.
///          Supports responsive layout for different screen sizes (mobile, pages).
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget provides a responsive layout for Qiyas approval
///              details, displaying key information such as perspective, description,
///              pillar, and standard. The layout adapts to various screen sizes
///              including mobile and pages, with an image preview and expandable content.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/entities/task_overview.dart';
import 'package:knowticed_plus/core/custom/cards/custom_title_value_widget.dart';

class TaskDetailsOverview extends StatelessWidget {
  const TaskDetailsOverview({required this.taskOverview, super.key});
  final TaskOverview taskOverview;
  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r), color: AppColors.card),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: isTablet ? 100.sp : 50.sp,
                height: isTablet ? 100.sp : 50.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.background,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons_assets/main_icons_assets/ic_module_service_approvals.svg",
                    width: 40.sp,
                    height: 40.sp,
                    colorFilter:
                        ColorFilter.mode(AppColors.text, BlendMode.srcIn),
                    fit: BoxFit.scaleDown,
                  ),
                )),
            SizedBox(width: 10.sp),
            Expanded(
              child: Column(
                spacing: 5.sp,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTitleValueWidget(
                      title: "المنظور", value: taskOverview.visionName),
                  CustomTitleValueWidget(
                    title: "الوصف",
                    value:
                        "يشمل المحور تطوير خطة إستراتيجية للتحول الرقمي وخارطة طريق تضعها الجهة الحكومية لتخطيط مسار تطوير الأنظمة والعمليات الأساسية، للوصول إلى رؤية الجهة والأهداف ا لإستراتيجية التي ترغب الجهة بتحقيقها من التحول الرقمي.",
                  ),
                  CustomTitleValueWidget(
                      title: "المحور", value: taskOverview.topicName),
                  CustomTitleValueWidget(
                      title: "المعيار", value: taskOverview.criteriaName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
