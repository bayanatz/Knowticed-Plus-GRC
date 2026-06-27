import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/calender/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/circle_progress.dart';
import 'package:demo_app/core/custom/circle_progress.dart';

import 'package:demo_app/features/calender/helper/data_grc_module/grc_module/grc_owner/presentation/ui/preview_creation.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/features/calender/calendar_screen.dart';
import 'package:demo_app/features/calender/src/controller.dart';
import 'package:demo_app/features/calender/src/widget.dart';
import 'package:demo_app/features/calender/services/calendar_data_service.dart';
import 'package:demo_app/features/calender/services/calendar_event_model.dart';
import 'package:lottie/lottie.dart';
import '../../generated/l10n.dart';
import '../notification/notification_control.dart';
import 'package:demo_app/features/calender/core_widgets/grc/custom_button_with_image.dart';
import '../employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';

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

  final CalendarDataService _calendarDataService = CalendarDataService();
  List<CalendarEventModel> _allEvents = [];
  bool _isLoading = true;
  String _currentUserEmail = '';

  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
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

      // ✅ Step 6: COMBINE ALL EVENTS
      print('🔍 [HOME] Step 6: Combining events...');
      final allEvents = [
        ...servicesEvents,
        ...approvalEvents,
        ...qiyasEvents,
        ...knowledgeHubEvents,
        ...todoEvents,
      ];

      // Sort by date
      allEvents.sort((a, b) => a.date.compareTo(b.date));

      print('🔍 [HOME] Step 7: Setting state with ${allEvents.length} total events...');
      print('   - Services events: ${servicesEvents.length}');
      print('   - Approval events: ${approvalEvents.length}');
      print('   - Qiyas events: ${qiyasEvents.length}');
      print('   - Knowledge Hub events: ${knowledgeHubEvents.length}');
      print('   - Todo events: ${todoEvents.length}');

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
      case 'form_builder':
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
                        child: DayTimelineViewHome(
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
                    child: CustomSvg(
                      assetPath: isArabicMode ? "assets/calender/right_arrow_calnder.svg" : "assets/calender/left_arrow_calnder.svg",
                      width: 15.w,
                      height: 15.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                SizedBox(width: 6.w),

                InkWell(
                  onTap: _navigateToNextMonth,
                  child: CustomSvg(
                    assetPath: isArabicMode ? "assets/calender/left_arrow_calnder.svg" : "assets/calender/right_arrow_calnder.svg",
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
          child: customButtonWithImageMas(
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
            image: 'assets/calender/expand_calender.svg',
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

class DayTimelineViewHome extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEventModel> events;

  const DayTimelineViewHome({
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

    return Column(
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
                DateFormat('EEEE, d MMMM  yyyy', locale).format(selectedDate),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                events.isEmpty
                    ? (locale == 'ar' ? 'لا توجد أحداث' : 'You\'re all clear')
                    : '${_toArabicNumber(events.length, context)} ${locale == 'ar' ? 'أحداث' : 'events'}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),

        events.isEmpty
            ? Expanded(
          child: Lottie.asset(
            "assets/lottie/calaender.json",
            fit: BoxFit.fill,
            repeat: true,
          ),
        )
            : Expanded(
          child: ListView.builder(
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
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
            width: 70.w,
            child: Padding(
              padding: EdgeInsets.only(top: 4.sp, right: 12.sp),
              child: Text(
                displayTime,
                style: TextStyle(
                  fontSize: 11.sp,
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
                    height: 30.h,
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
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: event.color,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: CustomSvg(
                assetPath: _getModuleIcon(event.moduleName),
                width: 16.sp,
                height: 16.sp,
                color: event.color,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayTaskName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  displayDescription,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ADD THIS METHOD: Get module icon
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
      case 'form_builder':
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