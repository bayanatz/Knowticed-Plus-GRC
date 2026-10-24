import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/utils/task_helper.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class EmployeeNameAndImage extends StatelessWidget {
  const EmployeeNameAndImage({required this.employeeId, super.key});

  final String? employeeId;
  @override
  Widget build(BuildContext context) {
    if (employeeId == null || employeeId!.isEmpty) {
      debugPrint("Employee ID is null");
      return Text(
        '-',
        style: StyleText.fontSize12Weight500,
      );
    } else {
      String image = TaskHelper().getChampionImage(employeeId!);
      String name = TaskHelper().getChampionName(employeeId!);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10.sp,
        children: [
          CircleAvatar(
            radius: 20.r,
            child: (image.contains('http'))
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: 40.sp,
                      height: 40.sp,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: 40.sp,
                      height: 40.sp,
                    ),
                  ),
          ),
          Text(
            name,
            style: StyleText.fontSize12Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ],
      );
    }
  }
}
