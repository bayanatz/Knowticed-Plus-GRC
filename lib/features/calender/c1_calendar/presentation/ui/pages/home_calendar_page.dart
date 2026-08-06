import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/circle_progress.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/features/calender/c1_calendar/presentation/ui/pages/calendar_screen.dart';
import 'package:grc_module/features/calender/c1_calendar/presentation/ui/widgets/calendar_package/controller.dart';
import 'package:grc_module/features/calender/c1_calendar/presentation/ui/widgets/calendar_package/widget.dart';
import 'package:grc_module/features/calender/c1_calendar/data/data_source/calendar_data_service.dart';
import 'package:grc_module/features/calender/c1_calendar/data/models/calendar_event_model.dart';
import 'package:lottie/lottie.dart';
import 'package:grc_module/features/calender/c1_calendar/presentation/ui/widgets/day_timeline_view.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/notification/presentation/ui/pages/notification_control.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class HomeCalendarWidget extends StatefulWidget {
  final Function(DateTime)? onDateSelected;

  const HomeCalendarWidget({
    Key? key,
    this.onDateSelected,
  }) : super(key: key);

  @override
  State<HomeCalendarWidget> createState() => _HomeCalendarWidgetState();
}

class _HomeCalendarWidgetState extends State<HomeCalendarWidget> {
  AdvancedCalendarController? _calendarController;
  DateTime _currentMonth = DateTime.now();
  Key _calendarKey = UniqueKey();

  late final CalendarDataService _calendarDataService;
  List<CalendarEventModel> _allEvents = [];
  bool _isLoading = true;
  String _currentUserEmail = '';

  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _calendarDataService = CalendarDataService(
      departmentCubit: context.read<MainCoreDepartmentCubit>(),
    );
    _calendarController = AdvancedCalendarController(_currentMonth);
    _loadCalendarData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);

    if (_currentLocale != locale) {
      print('🌍 [HOME] Locale changed from $_currentLocale to $locale');
      _currentLocale = locale;

      if (mounted) {
        setState(() {
          _calendarKey = UniqueKey();
        });
      }
    }
  }

  // ✅ UPDATED: Load all calendar data sources
  Future<void> _loadCalendarData() async {
    print('\n');
    print('🔥🔥🔥 ========================================');
    print('🔥 [HOME] _loadCalendarData() STARTED');
    print('🔥🔥🔥 ========================================');

    setState(() {
      _isLoading = true;
    });

    try {
      final employeeController = Get.find<MainCoreEmployeeController>();
      _currentUserEmail = employeeController.employeeEntity?.email ?? '';

      print('🔍 [HOME] Loading calendar data for user: $_currentUserEmail');

      if (_currentUserEmail.isEmpty) {
        print('❌❌❌ [HOME] ERROR: User email is EMPTY!');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // ✅ Step 1: FETCH SERVICES EVENTS
      print('🔍 [HOME] Step 1: Calling getServicesCalendarEvents...');
      final servicesEvents = await _calendarDataService.getServicesCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      // ✅ Step 2: FETCH APPROVAL EVENTS
      print('🔍 [HOME] Step 2: Calling getApprovalCalendarEvents...');
      final approvalEvents = await _calendarDataService.getApprovalCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      // ✅ Step 3: FETCH QIYAS EVENTS
      print('🔍 [HOME] Step 3: Calling getQiyasCalendarEvents...');
      final qiyasEvents = await _calendarDataService.getQiyasCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      // ✅ Step 4: FETCH KNOWLEDGE HUB EVENTS
      print('🔍 [HOME] Step 4: Calling getKnowledgeHubCalendarEvents...');
      final knowledgeHubEvents = await _calendarDataService.getKnowledgeHubCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      // ✅ Step 5: FETCH TODO EVENTS
      print('🔍 [HOME] Step 5: Calling getTodoCalendarEvents...');
      final todoEvents = await _calendarDataService.getTodoCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      // ✅ Step 6: FETCH ROLE MANAGEMENT EVENTS
      print('🔍 [HOME] Step 6: Calling getRoleManagementCalendarEvents...');
      final roleManagementEvents =
          await _calendarDataService.getRoleManagementCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      // ✅ Step 7: FETCH USER ACCESS EVENTS
      print('🔍 [HOME] Step 7: Calling getUserAccessCalendarEvents...');
      final userAccessEvents =
          await _calendarDataService.getUserAccessCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      // ✅ Step 8: COMBINE ALL EVENTS
      print('🔍 [HOME] Step 8: Combining events...');
      final allEvents = [
        ...servicesEvents,
        ...approvalEvents,
        ...qiyasEvents,
        ...knowledgeHubEvents,
        ...todoEvents,
        ...roleManagementEvents,
        ...userAccessEvents,
      ];

      // Sort by date
      allEvents.sort((a, b) => a.date.compareTo(b.date));

      print('🔍 [HOME] Step 7: Setting state with ${allEvents.length} total events...');
      print('   - Services events: ${servicesEvents.length}');
      print('   - Approval events: ${approvalEvents.length}');
      print('   - Qiyas events: ${qiyasEvents.length}');
      print('   - Knowledge Hub events: ${knowledgeHubEvents.length}');
      print('   - Todo events: ${todoEvents.length}');
      print('   - Role Management events: ${roleManagementEvents.length}');
      print('   - User Access events: ${userAccessEvents.length}');

      setState(() {
        _allEvents = allEvents;
        _isLoading = false;
      });

      print('✅✅✅ [HOME] Loaded ${_allEvents.length} total events');

      if (_allEvents.isNotEmpty) {
        print('📋 [HOME] Events loaded:');
        for (var event in _allEvents.take(10)) {
          print('   - [${event.moduleName}] ${event.status}: ${event.taskName} on ${event.date}');
        }
      } else {
        print('⚠️ [HOME] No events found for this user');
      }

    } catch (e, stackTrace) {
      print('❌❌❌ [HOME] Error loading calendar data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }

    print('🔥🔥🔥 ========================================');
    print('🔥 [HOME] _loadCalendarData() COMPLETED');
    print('🔥🔥🔥 ========================================');
    print('\n');
  }

  @override
  void dispose() {
    _calendarController?.dispose();
    super.dispose();
  }

  // ✅ UPDATED: Group events by unique MODULE (not color) to show only one dot per module
  List<Map<String, dynamic>> get events {
    Map<DateTime, Map<String, Color>> eventsByDate = {};

    print('\n🔍 [HOME] Building calendar dots...');

    for (var event in _allEvents) {
      final dateKey = DateTime(event.date.year, event.date.month, event.date.day);

      if (!eventsByDate.containsKey(dateKey)) {
        eventsByDate[dateKey] = {};
      }

      // ✅ KEY CHANGE: Group by MODULE NAME
      final moduleKey = event.moduleName.toLowerCase();

      // ✅ CRITICAL FIX: Use _getStandardModuleColor() to get standard module color
      if (!eventsByDate[dateKey]!.containsKey(moduleKey)) {
        final standardColor = _getStandardModuleColor(event.moduleName);
        eventsByDate[dateKey]![moduleKey] = standardColor;
        print('   📍 [HOME] Added dot for date: $dateKey, module: $moduleKey, color: $standardColor');
      } else {
        print('   ⏭️ [HOME] Skipped duplicate dot for date: $dateKey, module: $moduleKey');
      }
    }

    List<Map<String, dynamic>> calendarEvents = [];

    eventsByDate.forEach((date, modulesMap) {
      modulesMap.forEach((moduleName, color) {
        calendarEvents.add({
          'date': date,
          'color': color,
        });
      });
    });

    print('✅ [HOME] Total calendar dots: ${calendarEvents.length}');
    print('📊 [HOME] Breakdown by date:');
    eventsByDate.forEach((date, modules) {
      print('   Date: $date → Modules: ${modules.keys.join(', ')}');
    });

    return calendarEvents;
  }

  // ✅ ADD THIS METHOD: Get standard module colors
  Color _getStandardModuleColor(String moduleName) {
    final normalizedName = moduleName.toLowerCase().trim();

    switch (normalizedName) {
      case 'approval':
      case 'approvals':
      case 'الموافقات':
        return const Color(0xFFFF814A);

      case 'service':
      case 'services':
      case 'الخدمات':
        return const Color(0xFF0095FF);

      case 'form':
      case 'services_app':
      case 'form builder':
      case 'منشئ النماذج':
        return const Color(0xFF4BB609);

      case 'inventory':
      case 'المخزون':
        return const Color(0xFFDF1C1C);

      case 'qiyas':
      case 'قياس':
        return const Color(0xFF9FADAF);

      case 'time_tracker':
      case 'time tracker':
      case 'tracking':
      case 'التتبع':
        return const Color(0xFFFF814A);

      case 'database':
      case 'قاعدة البيانات':
        return const Color(0xFFBE8F3D);

      case 'events':
      case 'event':
      case 'الأحداث':
        return const Color(0xFF586E73);

      case 'risk_register':
      case 'risk register':
        return const Color(0xFF3DA282);

      case 'task':
      case 'tasks':
      case 'المهام':
        return const Color(0xFFFFCD00);

      case 'grc':
      case ' الحوكمة و المخاطر و الآلتزام':
        return const Color(0xFFB5AF3D);

      case 'hr':
      case 'employees':
      case 'org chart':
      case 'الموظفين':
        return const Color(0xFF405162);

      case 'knowledge_hub':
      case 'knowledge hub':
      case 'مركز المعرفة':
        return const Color(0xFFCD7F32);

      case 'messages':
      case 'الرسائل':
        return const Color(0xFF7B68EE);

      case 'roles':
      case 'الصلاحيات':
        return const Color(0xFFE91E63);

      case 'todo':
      case 'to do':
      case 'قائمة المهام':
        return const Color(0xFF00BCD4);

      case 'all':
      case 'الكل':
        return Colors.blue;

      default:
        return const Color(0xFF0095FF);
    }
  }

  List<CalendarEventModel> getEventsForDate(DateTime date) {
    return _allEvents
        .where((event) =>
    event.date.year == date.year &&
        event.date.month == date.month &&
        event.date.day == date.day)
        .toList();
  }

  void _navigateToPreviousMonth() {
    final previousMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    setState(() {
      _currentMonth = previousMonth;
      _calendarController?.dispose();
      _calendarController = AdvancedCalendarController(previousMonth);
      _calendarKey = UniqueKey();
    });
  }

  void _navigateToNextMonth() {
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    setState(() {
      _currentMonth = nextMonth;
      _calendarController?.dispose();
      _calendarController = AdvancedCalendarController(nextMonth);
      _calendarKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return SizedBox(
      width: double.infinity,
      //height: isPortrait ? null : 699.h,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(5.sp, 0, 15.sp, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarHeader(),

            SizedBox(height: 10.h),

            if (_isLoading)
              Container(
                width: double.infinity,
                height: 300.h,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                    child: CircleProgressMaster()
                ),
              )
            else ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: _calendarController == null
                    ? SizedBox(height: 300.h)
                    : AdvancedCalendar(
                  backgroundColorCalender: Colors.transparent,
                  key: _calendarKey,
                  controller: _calendarController!,
                  events: events,
                  showNavigationArrows: false,
                  startWeekDay: 0,
                  weekLineHeight: 48.0,
                  innerDot: false,
                  viewMode: CalendarViewMode.month,
                  selectedDayColor: AppColors.secondaryPrimary,
                  selectedDayTextColor: AppColors.secondaryPrimaryText,
                  onHorizontalDrag: (DateTime date) {
                    setState(() {
                      _currentMonth = date;
                    });
                  },
                ),
              ),

              SizedBox(height: 10.h),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: _calendarController == null
                      ? Center(
                    child: Text(
                      'Loading...',
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  )
                      : ValueListenableBuilder<DateTime>(
                    valueListenable: _calendarController!,
                    builder: (context, selectedDate, _) {
                      final dayEvents = getEventsForDate(selectedDate);
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationControlPage(),
                              ));
                        },
                        child: DayTimelineView(
                          selectedDate: selectedDate,
                          events: dayEvents,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final isArabicMode = Localizations.localeOf(context).languageCode == 'ar';
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 38.h,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                SizedBox(width: 10.w),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy', _currentLocale?.languageCode).format(_currentMonth),
                      style: StyleText.fontSize16Weight700.copyWith(
                          color: AppColors.text
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                Spacer(),

                InkWell(
                  onTap: _navigateToPreviousMonth,
                  child: SizedBox(
                    child: CustomSvgImage(
                      assetPath: isArabicMode ? "assets/icons_assets/calendar_assets/chevron_right.svg" : "assets/icons_assets/calendar_assets/chevron_left.svg",
                      width: 15.w,
                      height: 15.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                SizedBox(width: 6.w),

                InkWell(
                  onTap: _navigateToNextMonth,
                  child: CustomSvgImage(
                    assetPath: isArabicMode ? "assets/icons_assets/calendar_assets/chevron_left.svg" : "assets/icons_assets/calendar_assets/chevron_right.svg",
                    width: 15.w,
                    height: 15.h,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: 10.w),
              ],
            ),
          ),
        ),

        SizedBox(width: 10.sp),

        Expanded(
          flex: 1,
          child: customButtonWithSvg(
            width: 150.w,
            height: 38.h,
            title: S.of(context).calendar,
            function: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarTestScreen(),
                ),
              );
            },
            svgColor: AppColors.textButton,
            color: AppColors.primary,
            radius: 8.r,
            textStyle: StyleText.fontSize14Weight600.copyWith(color: AppColors.textButton),
            image: 'assets/icons_assets/calendar_assets/expand_fullscreen.svg',
            widthImage: 16,
            heightImage: 16,
            colorBorder: Colors.transparent,
            space: 8.w,
          ),
        ),
      ],
    );
  }
}
