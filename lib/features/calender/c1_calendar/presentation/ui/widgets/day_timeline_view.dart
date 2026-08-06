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

/// Day timeline column, extracted from calendar_screen.dart.
class DayTimelineView extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEventModel> events;

  const DayTimelineView({
    Key? key,
    required this.selectedDate,
    required this.events,
  }) : super(key: key);

  String _toArabicNumber(int number, BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (!isArabic) return number.toString();

    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return int.tryParse(digit) != null ? arabicNumbers[int.parse(digit)] : digit;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = _generateTimeSlots();
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, yyyy', locale).format(selectedDate),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  events.isEmpty
                      ? (locale == 'ar' ? 'لا توجد أحداث' : 'You\'re all clear')
                      : '${_toArabicNumber(events.length, context)} ${locale == 'ar' ? 'أحداث' : 'events'}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = timeSlots[index];
                final eventsAtThisTime = _getEventsAtTime(timeSlot);

                return _buildTimeSlot(
                  context: context,
                  timeSlot: timeSlot,
                  events: eventsAtThisTime,
                  showDivider: index < timeSlots.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateTimeSlots() {
    List<String> slots = [];
    for (int hour = 0; hour < 24; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }
    return slots;
  }

  List<CalendarEventModel> _getEventsAtTime(String timeSlot) {
    return events.where((event) {
      final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(event.time);
      if (timeMatch == null) return false;

      int eventHour = int.parse(timeMatch.group(1)!);
      final eventMinute = int.parse(timeMatch.group(2)!);

      if (event.time.contains('PM') && eventHour != 12) {
        eventHour += 12;
      } else if (event.time.contains('AM') && eventHour == 12) {
        eventHour = 0;
      }

      final roundedMinute = eventMinute < 15 ? 0 : (eventMinute < 45 ? 30 : 60);

      if (roundedMinute == 60) {
        eventHour += 1;
      }

      final finalMinute = roundedMinute == 60 ? 0 : roundedMinute;

      final eventTime = '${eventHour.toString().padLeft(2, '0')}:${finalMinute.toString().padLeft(2, '0')}';
      return eventTime == timeSlot;
    }).toList();
  }

  Widget _buildTimeSlot({
    required BuildContext context,
    required String timeSlot,
    required List<CalendarEventModel> events,
    required bool showDivider,
  }) {
    final hasEvents = events.isNotEmpty;
    final locale = Localizations.localeOf(context).languageCode;

    final timeParts = timeSlot.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts[1];

    String displayTime;
    if (locale == 'ar') {
      final arabicHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final period = hour < 12 ? 'ص' : 'م';
      displayTime = '${_toArabicNumber(arabicHour, context)}:${_toArabicNumber(int.parse(minute), context)} $period';
    } else {
      displayTime = hour == 0
          ? '12:$minute AM'
          : hour < 12
          ? '${hour.toString().padLeft(2, '0')}:$minute AM'
          : hour == 12
          ? '12:$minute PM'
          : '${(hour - 12).toString().padLeft(2, '0')}:$minute PM';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Padding(
              padding: EdgeInsets.only(top: 4.sp, right: 12.sp),
              child: Text(
                displayTime,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasEvents)
                  ...events.map((event) => Padding(
                    padding: EdgeInsets.only(bottom: 8.sp),
                    child: _buildEventCard(event, context),
                  ))
                else
                  Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEventModel event, BuildContext context) {
    final moduleColor = _getModuleColor(event.moduleName);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // ✅ Extract bilingual task name
    String displayTaskName = event.taskName;
    if (event.taskName.contains(' / ')) {
      final parts = event.taskName.split(' / ');
      displayTaskName = isArabic && parts.length > 1 ? parts[1] : parts[0];
    }

    // ✅ Extract bilingual description
    String displayDescription = event.description;
    if (event.description.contains(' / ')) {
      final parts = event.description.split(' / ');
      displayDescription = isArabic && parts.length > 1 ? parts[1] : parts[0];
    }

    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: moduleColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: moduleColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: CustomSvgImage(
                assetPath: _getModuleIcon(event.moduleName),
                width: 20.w,
                height: 20.h,
                color: moduleColor,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ Show task name (service/document name)
                    Expanded(
                      child: Text(
                        displayTaskName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                      decoration: BoxDecoration(
                        color: moduleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        event.status,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                          color: moduleColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // ✅ Show description
                Text(
                  displayDescription,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getModuleColor(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'service':
      case 'services':
        return const Color(0xFF0095FF);
      case 'form':
      case 'services_app':
        return const Color(0xFF4BB609);
      case 'inventory':
        return const Color(0xFFDF1C1C);
      case 'qiyas':
        return const Color(0xFF9FADAF);
      case 'time_tracker':
      case 'time tracker':
      case 'tracking':
        return const Color(0xFFFF814A);
      case 'database':
        return const Color(0xFFBE8F3D);
      case 'events':
      case 'event':
        return const Color(0xFF586E73);
      case 'risk_register':
      case 'risk register':
        return const Color(0xFF3DA282);
      case 'task':
      case 'tasks':
        return const Color(0xFFFFCD00);
      case 'grc':
        return const Color(0xFFB5AF3D);
      case 'hr':
      case 'employees':
        return const Color(0xFF405162);
      case 'knowledge_hub':
      case 'knowledge hub':
        return const Color(0xFFCD7F32);
      case 'messages':
        return const Color(0xFF7B68EE);
      case 'roles':
        return const Color(0xFFE91E63);
      case 'todo':
      case 'to do':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF0095FF);
    }
  }

  String _getModuleIcon(String moduleName) {
    String moduleKey = moduleName.toLowerCase().replaceAll(' ', '_');
    Modules? module;

    switch (moduleKey) {
      case 'service':
      case 'services':
        module = Modules.services;
        break;
      case 'form':
      case 'services_app':
        module = Modules.formBuilder;
        break;
      case 'inventory':
        module = Modules.inventory;
        break;
      case 'database':
        module = Modules.database;
        break;
      case 'events':
      case 'event':
        module = Modules.qiyas;
        break;
      case 'time_tracker':
      case 'time tracker':
      case 'tracking':
        module = Modules.tracking;
        break;
      case 'hr':
      case 'employees':
        module = Modules.employees;
        break;
      case 'knowledge_hub':
      case 'knowledge hub':
        module = Modules.knowledgeHub;
        break;
      case 'task':
      case 'tasks':
        module = Modules.tasks;
        break;
      case 'grc':
        module = Modules.grc;
        break;
      case 'risk_register':
      case 'risk register':
        module = Modules.grc;
        break;
      case 'todo':
        module = Modules.todo;
        break;
      case 'messages':
        module = Modules.messages;
        break;
      case 'roles':
        module = Modules.roles;
        break;
      case 'qiyas':
        module = Modules.qiyas;
        break;
      default:
        module = Modules.services;
    }

    return module.iconPath;
  }
}
