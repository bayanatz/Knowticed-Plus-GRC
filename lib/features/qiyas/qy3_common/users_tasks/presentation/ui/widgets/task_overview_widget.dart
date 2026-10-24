import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/entities/task_overview.dart';
import 'package:knowticed_plus/core/custom/cards/custom_title_value_widget.dart';

class TaskOverviewWidget extends StatelessWidget {
  const TaskOverviewWidget({required this.taskOverview, super.key});
  final TaskOverview taskOverview;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomTitleValueWidget(
                title: "تاريخ التسليم",
                value: DateFormat('d MMMM y', 'ar')
                    .format(taskOverview.deadLineDate),
                titleStyle: StyleText.fontSize10Weight400
                    .copyWith(color: AppColors.secondaryBlack)
                    .copyWith(height: 1, color: AppColors.text),
                valueStyle: StyleText.fontSize10Weight400
                    .copyWith(height: 1, color: AppColors.secondaryText),
              )
            ],
          ),
          Expanded(
              child: Row(
            children: [
              Text(
                taskOverview.visionName,
                style: StyleText.fontSize12Weight600,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )),
          SizedBox(
            height: 8.sp,
          ),
          CustomTitleValueWidget(
              title: "المحور", value: taskOverview.topicName),
          SizedBox(height: 8.sp),
          CustomTitleValueWidget(
            title: "المعيار",
            value: taskOverview.criteriaName,
          ),
          SizedBox(
            height: 8.sp,
          ),
          CustomTitleValueWidget(
            title: "تاريخ تقديم المستند",
            value: (taskOverview.submissionDate == null)
                ? '-'
                : DateFormat('d MMMM y', 'ar')
                    .format(taskOverview.submissionDate!),
          ),
          SizedBox(
            height: 10.sp,
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4.sp),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border:
                    Border.all(color: taskOverview.status.color, width: 1.sp),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 8.sp,
                    backgroundColor: taskOverview.status.color,
                    child: SvgPicture.asset(taskOverview.status.icon),
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    taskOverview.status.value,
                    style: StyleText.fontSize10Weight400
                        .copyWith(color: taskOverview.status.color),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
