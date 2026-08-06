import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/helper/main_helper/date_time_helper.dart';
import 'package:grc_module/core/helper/main_helper/spacing_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';

class MessageDate extends StatelessWidget {
  final DateTime date;

  const MessageDate({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              DateTimeHelper.formatChatDate(date),
              style: AppTextStyles.font12SecondaryBlackCairoRegular.copyWith(
                color: AppColors.inverseBase,
              ),
            ),
          ),
        ),
        verticalSpace(16),
      ],
    );
  }
}