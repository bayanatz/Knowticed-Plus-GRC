import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class AppBarDate extends StatelessWidget {
  const AppBarDate({super.key});

  String _getFormattedDate() {
    // Get current locale from GetX
    bool isArabic = Get.locale?.languageCode == 'ar';

    try {
      // Format date based on current locale
      return DateFormat(
        'dd MMMM yyyy',
        isArabic ? 'ar' : 'en_US',
      ).format(DateTime.now());
    } catch (e) {
      // Fallback to English if Arabic locale is not initialized
      return DateFormat('dd MMMM yyyy', 'en_US').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons_assets/home_assets/homeCalen.svg",
          height: 20.sp,
          color: AppColors.icon,
        ),
        SizedBox(width: 10.sp),
        Text(
          _getFormattedDate(),
          style: AppTextStyles.font18BlackCairoRegular,
        ),
      ],
    );
  }
}