import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class TimeLimit extends StatelessWidget {
  const TimeLimit({
    super.key,
    required this.date,
    required this.time,
    this.isEnd = false,
    this.isExceeded = false,
  });
  final String date;
  final String time;
  final bool isEnd;
  final bool isExceeded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              "assets/icons_assets/main_icons_assets/icons_calendar.svg",
              height: 16.h,
              width: 16.w,
              color: isExceeded ? AppColors.red : AppColors.black,
            ),
            SizedBox(width: 6),
            Text(
              isEnd ? "End Date:" : "Start Date:",
              style: AppTextStyles.font12BlackCairo
                  .copyWith(color: isExceeded ? AppColors.red : null),
            ),
            Text(
              date,
              style: AppTextStyles.font12BlackCairo
                  .copyWith(color: isExceeded ? AppColors.red : null),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            SvgPicture.asset(
              "assets/icons/time_icon.svg",
              height: 16.h,
              width: 16.w,
              color: AppColors.black,
            ),
            SizedBox(width: 6),
            Text(
              "$time PM",
              style: AppTextStyles.font12BlackCairo,
            ),
            SizedBox(width: 7),
            isExceeded
                ? Text(
              "Exceeded deadline",
              style: AppTextStyles.font10WhiteSemiBoldCairo
                  .copyWith(color: AppColors.red),
            )
                : SizedBox()
          ],
        ),
      ],
    );
  }
}
