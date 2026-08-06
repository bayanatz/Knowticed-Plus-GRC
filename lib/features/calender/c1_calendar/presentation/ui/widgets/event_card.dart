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

/// Single calendar event card, extracted from calendar_screen.dart.
class EventCard extends StatelessWidget {
  final CalendarEventModel event;

  const EventCard({Key? key, required this.event}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
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
      margin: EdgeInsets.only(bottom: 10.sp),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: moduleColor, width: 2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: moduleColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CustomSvgImage(
                          assetPath: _getModuleIcon(event.moduleName),
                          width: 24,
                          height: 24,
                          color: moduleColor,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    Text(
                      event.moduleName,
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 5.sp),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Show task name (service/document name)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTaskName,
                            style: StyleText.fontSize14Weight600.copyWith(
                              color: AppColors.text,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
                            decoration: BoxDecoration(

                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              event.status,
                              style: StyleText.fontSize10Weight500.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.sp),
                      // ✅ Show description
                      Text(
                        displayDescription,
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.sp),

                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 10.sp),
            child: Text(
              event.time,
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getModuleIcon(String moduleName) {
    String moduleKey = moduleName.toLowerCase().replaceAll(' ', '_');
    Modules? module;

    switch (moduleKey) {
      case 'approval':
      case 'approvals':
        module = Modules.services;
        break;
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
