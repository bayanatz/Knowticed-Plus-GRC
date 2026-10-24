import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/attatchment_widget.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/comment_section/data/models/comment_model.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({required this.comment, super.key});
  final CommentModel comment;
  @override
  Widget build(BuildContext context) {
    EmployeeEntityPro commenter = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities!
        .firstWhere((element) => element.email == comment.commenterId);
    return Column(
      spacing: 10.sp,
      textDirection: comment.commenterId ==
              Get.find<MainCoreEmployeeController>().employeeEntity!.email
          ? TextDirection.rtl
          : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 5.sp,
          textDirection: comment.commenterId ==
                  Get.find<MainCoreEmployeeController>().employeeEntity!.email
              ? TextDirection.rtl
              : TextDirection.ltr,
          children: [
            buildCommenterImage(commenter),
            Column(
              crossAxisAlignment: comment.commenterId ==
                      Get.find<MainCoreEmployeeController>()
                          .employeeEntity!
                          .email
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              spacing: 12.sp,
              children: [
                Text(
                  '${commenter.firstNameInArabic!} ${commenter.lastNameInArabic!}',
                  style: StyleText.fontSize14Weight600.copyWith(height: 1),
                ),
                Text(
                  commenter.titleInArabic!,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryBlack)
                      .copyWith(height: 1),
                ),
              ],
            )
          ],
        ),
        if (comment.commentText != null)
          Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: Text(
              comment.commentText!,
              style: StyleText.fontSize14Weight600.copyWith(height: 1.3.sp),
            ),
          ),
        if (comment.fileName != null)
          AttatchmentWidget(
            filePath: comment.commentLink!,
            fileName: comment.fileName!,
            fileSize: comment.fileSize!,
            showMinus: false,
          ),
        Text(formatDateTime(comment.commentDate.toDate()),
            style: StyleText.fontSize10Weight400
                .copyWith(color: AppColors.secondaryBlack)
                .copyWith(height: 1.2))
      ],
    );
  }

  Widget buildCommenterImage(EmployeeEntityPro commenter) {
    return CircleAvatar(
      radius: 17.5.sp,
      backgroundImage: commenter.photo != null
          ? appImageProvider((commenter.gender == 'female'
              ? "assets/icons_assets/qiyas_assets/ic_user_female.svg"
              : "assets/icons_assets/qiyas_assets/ic_user_male.svg"))
          : appImageProvider((commenter.gender == 'female'
              ? "assets/icons_assets/qiyas_assets/ic_user_female.svg"
              : "assets/icons_assets/qiyas_assets/ic_user_male.svg")),
    );
  }

  String formatDateTime(DateTime dateTime) {
    final datePart = intl.DateFormat('d MMM y', 'ar').format(dateTime);
    final timePart = intl.DateFormat('h:mm a', 'ar').format(dateTime);
    return '$datePart في $timePart';
  }
}
