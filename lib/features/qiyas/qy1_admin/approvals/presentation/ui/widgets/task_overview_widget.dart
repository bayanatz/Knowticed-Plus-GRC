import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/entities/task_overview.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/utils/task_helper.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/cards/custom_title_value_widget.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';

class TaskOverviewWidget extends StatelessWidget {
  const TaskOverviewWidget({required this.taskOverview, super.key});
  final TaskOverview taskOverview;
  @override
  Widget build(BuildContext context) {
    String championImage =
        TaskHelper().getChampionImage(taskOverview.championId!);
    String championName =
        TaskHelper().getChampionName(taskOverview.championId!);
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
                title: "تاريخ تقديم",
                value: taskOverview.submissionDate == null
                    ? '-'
                    : DateFormat('d MMMM y', 'ar')
                        .format(taskOverview.submissionDate!),
                titleStyle: StyleText.fontSize10Weight400
                    .copyWith(color: AppColors.secondaryBlack)
                    .copyWith(height: 1, color: taskOverview.status.color),
                valueStyle: StyleText.fontSize10Weight400
                    .copyWith(height: 1)
                    .copyWith(color: taskOverview.status.color),
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
          SizedBox(height: 8.sp),
          Row(
            children: [
              Text(
                'سفير التحول الرقمي:  ',
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.secondaryBlack),
              ),
              CircleAvatar(
                radius: 15.sp,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: championImage.contains('http')
                        ? Image.network(championImage)
                        : appImageWidget(championImage)),
              ),
              Text(
                ' $championName',
                style: StyleText.fontSize10Weight400,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
          SizedBox(height: 10.sp),
          CustomTitleValueWidget(
            title: "الموعد النهائي لتقديم المستند",
            value:
                DateFormat('d MMMM y', 'ar').format(taskOverview.deadLineDate),
          ),
          SizedBox(height: 10.sp),
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
