import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/features/calender/c1_calendar/presentation/ui/widgets/calendar_package/controller.dart';
import 'package:grc_module/features/calender/c1_calendar/presentation/ui/widgets/calendar_package/widget.dart';
import 'package:grc_module/features/calender/c1_calendar/data/data_source/calendar_data_service.dart';
import 'package:grc_module/features/calender/c1_calendar/data/models/calendar_event_model.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';

import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Month/day view toggle, extracted from calendar_screen.dart.
class CalendarViewToggle extends StatelessWidget {
  final bool isMonthView;
  final VoidCallback onToggle;
  final String dayText;
  final String monthText;
  final Color activeColor;
  final Color inactiveColor;
  final Color textActiveColor;
  final Color textInactiveColor;

  const CalendarViewToggle({
    Key? key,
    required this.isMonthView,
    required this.onToggle,
    this.dayText = 'Day',
    this.monthText = 'Month',
    required this.activeColor,
    this.inactiveColor = const Color(0xFFF5F5F5),
    this.textActiveColor = Colors.white,
    this.textInactiveColor = Colors.black87,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 240.w,
        height: 40.h,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: isMonthView ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 116.w,
                height: 36.h,
                margin: EdgeInsets.all(2.sp),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      dayText,
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: isArabic ? isMonthView ? AppColors.textButton : AppColors.text : !isMonthView ? AppColors.textButton : AppColors.text,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      monthText,
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: isArabic ?!isMonthView ? AppColors.textButton : AppColors.text : isMonthView ? AppColors.textButton : AppColors.text,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
