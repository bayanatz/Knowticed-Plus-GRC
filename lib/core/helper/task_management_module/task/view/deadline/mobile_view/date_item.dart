import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class DateItem extends StatelessWidget {
  const DateItem({super.key, this.isClock = false, required this.date});
  final bool isClock;
  final String date;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
          color: AppColors.background, borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Text(
            date,
            style: AppTextStyles.font12BlackCairoRegular,
          ),
          Spacer(),
          SvgPicture.asset(
            isClock
                ? "assets/icons_assets/main_icons_assets/ClockCircleSmall.svg"
                : "assets/icons_assets/main_icons_assets/icons_calendar.svg",
            height: 16.h,
            width: 16.h,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}
