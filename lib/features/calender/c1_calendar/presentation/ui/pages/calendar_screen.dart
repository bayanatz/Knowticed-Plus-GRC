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
import 'package:grc_module/features/calender/c1_calendar/presentation/ui/widgets/calendar_view_toggle.dart';
import 'package:grc_module/features/calender/c1_calendar/presentation/ui/widgets/event_card.dart';
import 'package:grc_module/features/calender/c1_calendar/presentation/ui/widgets/day_timeline_view.dart';

class CalendarTestScreen extends StatefulWidget {
  const CalendarTestScreen({Key? key}) : super(key: key);

  @override
  State<CalendarTestScreen> createState() => _CalendarTestScreenState();
}

class _CalendarTestScreenState extends State<CalendarTestScreen> {
  late AdvancedCalendarController _calendarController;
  String selectedModule = 'All';
  String selectedStatus = 'All';
  CalendarViewMode currentViewMode = CalendarViewMode.month;
  DateTime displayedMonth = DateTime.now();
  Key _calendarKey = UniqueKey();

  late final CalendarDataService _calendarDataService;
  List<CalendarEventModel> eventDetails = [];
  bool _isLoading = true;
  String _currentUserEmail = '';

  Locale? _currentLocale;

  final AppDrawerCubit _drawerController = Get.find<AppDrawerCubit>();

  @override
  void initState() {
    super.initState();
    _calendarDataService = CalendarDataService(
      departmentCubit: context.read<MainCoreDepartmentCubit>(),
    );

    print('\n\n');
    print('🎬🎬🎬 ========================================');
    print('🎬 CalendarTestScreen initState() CALLED');
    print('🎬🎬🎬 ========================================');
    print('\n');

    _calendarController = AdvancedCalendarController(displayedMonth);

    print('📅 About to call _loadCalendarData()...');

    _loadCalendarData();

    print('✅ _loadCalendarData() has been called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);

    if (_currentLocale != locale) {
      print('🌍 Locale changed from $_currentLocale to $locale');
      _currentLocale = locale;

      if (mounted) {
        setState(() {
          _calendarKey = UniqueKey();
        });
      }
    }
  }

  String _toArabicNumber(int number) {
    if (_currentLocale?.languageCode != 'ar') return number.toString();

    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return int.tryParse(digit) != null ? arabicNumbers[int.parse(digit)] : digit;
    }).join();
  }

// In _CalendarTestScreenState class

// 1. ✅ ADD TODO COLOR to getModuleColor method (around line 220)
  Color getModuleColor(String moduleName) {
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

    // ✅ ADD THIS - TODO MODULE COLOR (PURPLE)
      case 'todo':
      case 'to do':
      case 'قائمة المهام':
        return const Color(0xFF00BCD4); // PURPLE COLOR

      case 'all':
      case 'الكل':
        return Colors.blue;

      default:
        return const Color(0xFF0095FF);
    }
  }

// 2. ✅ ADD TODO EVENTS to _loadCalendarData method (around line 150)
  Future<void> _loadCalendarData() async {
    print('\n');
    print('🔥🔥🔥 ========================================');
    print('🔥 _loadCalendarData() STARTED');
    print('🔥🔥🔥 ========================================');

    setState(() {
      _isLoading = true;
    });

    try {
      final employeeController = Get.find<MainCoreEmployeeController>();
      _currentUserEmail = employeeController.employeeEntity?.email ?? '';

      if (_currentUserEmail.isEmpty) {
        print('❌❌❌ ERROR: User email is EMPTY!');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🔍 Step 1: Calling getServicesCalendarEvents...');
      final servicesEvents = await _calendarDataService.getServicesCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      print('🔍 Step 2: Calling getApprovalCalendarEvents...');
      final approvalEvents = await _calendarDataService.getApprovalCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      print('🔍 Step 3: Calling getQiyasCalendarEvents...');
      final qiyasEvents = await _calendarDataService.getQiyasCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      print('🔍 Step 4: Calling getKnowledgeHubCalendarEvents...');
      final knowledgeHubEvents = await _calendarDataService.getKnowledgeHubCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      // ✅ ADD THIS - Step 5: Get Todo events
      print('🔍 Step 5: Calling getTodoCalendarEvents...');
      final todoEvents = await _calendarDataService.getTodoCalendarEvents(
        currentUserEmail: _currentUserEmail,
      );

      print('🔍 Step 6: Combining events...');
      final allEvents = [
        ...servicesEvents,
        ...approvalEvents,
        ...qiyasEvents,
        ...knowledgeHubEvents,
        ...todoEvents, // ✅ ADD THIS
      ];

      allEvents.sort((a, b) => a.date.compareTo(b.date));

      print('🔍 Step 7: Setting state with ${allEvents.length} total events...');
      print('   - Services events: ${servicesEvents.length}');
      print('   - Approval events: ${approvalEvents.length}');
      print('   - Qiyas events: ${qiyasEvents.length}');
      print('   - Knowledge Hub events: ${knowledgeHubEvents.length}');
      print('   - Todo events: ${todoEvents.length}'); // ✅ ADD THIS

      setState(() {
        eventDetails = allEvents;
        _isLoading = false;
      });

      print('✅✅✅ Loaded ${eventDetails.length} total events');

    } catch (e, stackTrace) {
      print('❌❌❌ ERROR in _loadCalendarData: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isLoading = false;
      });
    }

    print('🔥🔥🔥 ========================================');
    print('🔥 _loadCalendarData() COMPLETED');
    print('🔥🔥🔥 ========================================');
    print('\n');
  }

  List<String> get statusTypes {
    final isArabic = _currentLocale?.languageCode == 'ar';
    return [
      isArabic ? 'الكل' : 'All',
      isArabic ? 'مجدول' : 'Scheduled',
      isArabic ? 'معين' : 'Assigned',
      isArabic ? 'مستحق' : 'Due',
      isArabic ? 'متأخر' : 'Overdue',
      isArabic ? 'تذكيرات' : 'Reminders',
      'SLA',
      isArabic ? 'معلم' : 'Milestone',
      isArabic ? 'منتهي الصلاحية' : 'Expiring',
      isArabic ? 'تجديد' : 'Renewal',
      isArabic ? 'إصدار' : 'Release',
      isArabic ? 'المدة' : 'Duration',
      isArabic ? 'دورات الفوترة' : 'Billing Cycles',
      isArabic ? 'الموافقة المعلقة' : 'Pending Approval',
      isArabic ? 'التكرار' : 'Frequency',
    ];
  }

// 4. ✅ UPDATE _getEnglishStatusName to handle Frequency (around line 360)
  String _getEnglishStatusName(String displayStatus) {
    final isArabic = _currentLocale?.languageCode == 'ar';
    if (!isArabic) return displayStatus;

    final statusMap = {
      'الكل': 'All',
      'مجدول': 'Scheduled',
      'معين': 'Assigned',
      'مستحق': 'Due',
      'متأخر': 'Overdue',
      'تذكيرات': 'Reminders',
      'معلم': 'Milestone',
      'منتهي الصلاحية': 'Expiring',
      'تجديد': 'Renewal',
      'إصدار': 'Release',
      'المدة': 'Duration',
      'دورات الفوترة': 'Billing Cycles',
      'الطلبات المعلقة': 'Pending Requests',
      'التكرار': 'Frequency', // ✅ ADD THIS
    };

    return statusMap[displayStatus] ?? displayStatus;
  }

// 5. ✅ UPDATE _getLocalizedStatusName to handle Frequency (around line 380)
  String _getLocalizedStatusName(String englishStatus) {
    final isArabic = _currentLocale?.languageCode == 'ar';
    if (!isArabic) return englishStatus;

    final statusMap = {
      'All': 'الكل',
      'Scheduled': 'مجدول',
      'Assigned': 'معين',
      'Due': 'مستحق',
      'Overdue': 'متأخر',
      'Reminders': 'تذكيرات',
      'Milestone': 'معلم',
      'Expiring': 'منتهي الصلاحية',
      'Renewal': 'تجديد',
      'Release': 'إصدار',
      'Duration': 'المدة',
      'Billing Cycles': 'دورات الفوترة',
      'Pending Requests': 'الطلبات المعلقة',
      'Frequency': 'التكرار', // ✅ ADD THIS
    };

    return statusMap[englishStatus] ?? englishStatus;
  }

  List<Map<String, dynamic>> get events {
    Map<DateTime, Map<String, Color>> eventsByDate = {};

    print('\n🔍 Building calendar dots...');

    for (var event in eventDetails) {
      final dateKey = DateTime(event.date.year, event.date.month, event.date.day);

      if (!eventsByDate.containsKey(dateKey)) {
        eventsByDate[dateKey] = {};
      }

      final moduleKey = event.moduleName.toLowerCase();

      if (!eventsByDate[dateKey]!.containsKey(moduleKey)) {
        final standardColor = getModuleColor(event.moduleName);
        eventsByDate[dateKey]![moduleKey] = standardColor;
        print('   📍 Added dot for date: $dateKey, module: $moduleKey, color: $standardColor');
      } else {
        print('   ⏭️ Skipped duplicate dot for date: $dateKey, module: $moduleKey');
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

    print('✅ Total calendar dots: ${calendarEvents.length}');
    print('📊 Breakdown by date:');
    eventsByDate.forEach((date, modules) {
      print('   Date: $date → Modules: ${modules.keys.join(', ')}');
    });

    return calendarEvents;
  }

  List<CalendarEventModel> getEventsForDate(DateTime date) {
    var filtered = eventDetails.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();

    if (selectedModule != 'All' && selectedModule != 'الكل') {
      final englishModuleName = _getEnglishModuleName(selectedModule);
      filtered = filtered.where((event) =>
      event.moduleName.toLowerCase() == englishModuleName.toLowerCase()
      ).toList();
    }

    if (selectedStatus != 'All' && selectedStatus != 'الكل') {
      final englishStatus = _getEnglishStatusName(selectedStatus);

      if (englishStatus == 'Duration') {
        filtered = filtered.where((event) =>
        event.status.toLowerCase() == 'inprogress' ||
            event.status.toLowerCase() == 'done'
        ).toList();
      } else {
        filtered = filtered.where((event) => event.status == englishStatus).toList();
      }
    }

    return filtered;
  }

  List<Map<String, String>> getUniqueModulesWithMapping() {
    final isArabic = _currentLocale?.languageCode == 'ar';

    final allowedModules = _drawerController.allowedDrawerModules;

    print('🔍 Calendar: Allowed modules from drawer: ${allowedModules.map((m) => m.name).join(', ')}');

    final eventModules = eventDetails.map((e) => e.moduleName.toLowerCase()).toSet();

    print('🔍 Calendar: Modules from events: ${eventModules.join(', ')}');

    List<Map<String, String>> modulesList = [
      {'display': isArabic ? 'الكل' : 'All', 'english': 'All'},
    ];

    final allModulesMap = {
      'services': {'display': isArabic ? 'الخدمات' : 'Services', 'english': 'Services'},
      'services_app': {'display': isArabic ? 'منشئ النماذج' : 'Form Builder', 'english': 'Form Builder'},
      'formbuilder': {'display': isArabic ? 'منشئ النماذج' : 'Form Builder', 'english': 'Form Builder'},
      'inventory': {'display': isArabic ? 'المخزون' : 'Inventory', 'english': 'Inventory'},
      'database': {'display': isArabic ? 'قاعدة البيانات' : 'Database', 'english': 'Database'},
      'events': {'display': isArabic ? 'الأحداث' : 'Events', 'english': 'Events'},
      'tracking': {'display': isArabic ? 'التتبع' : 'Tracking', 'english': 'Tracking'},
      'employees': {'display': isArabic ? 'الموظفين' : 'Org Chart', 'english': 'HR'},
      'knowledgehub': {'display': isArabic ? 'مركز المعرفة' : 'Knowledge Hub', 'english': 'Knowledge Hub'},
      'tasks': {'display': isArabic ? 'المهام' : 'Tasks', 'english': 'Tasks'},
      'todo': {'display': isArabic ? 'قائمة المهام' : 'To Do', 'english': 'To Do'},
      'grc': {'display': isArabic ? ' الحوكمة و المخاطر و الآلتزام' : 'GRC', 'english': 'GRC'},
      'qiyas': {'display': isArabic ? 'قياس' : 'Qiyas', 'english': 'Qiyas'},
      'messages': {'display': isArabic ? 'الرسائل' : 'Messages', 'english': 'Messages'},
      'roles': {'display': isArabic ? 'الصلاحيات' : 'Roles', 'english': 'Roles'},
    };

    for (var module in allowedModules) {
      if (module == Modules.home || module == Modules.settings) {
        continue;
      }

      String moduleName = module.name.toLowerCase();

      if (allModulesMap.containsKey(moduleName)) {
        modulesList.add(allModulesMap[moduleName]!);
        print('✅ Calendar: Added module ${allModulesMap[moduleName]!['english']} (allowed in drawer)');
      } else {
        print('⚠️ Calendar: Skipped module $moduleName (not in translation map)');
      }
    }

    print('📱 Calendar: Final modules list (${modulesList.length}): ${modulesList.map((m) => m['english']).join(', ')}');

    return modulesList;
  }

  Map<String, int> getStatusCounts() {
    Map<String, int> counts = {};

    for (var event in eventDetails) {
      String statusKey;

      if (event.status.toLowerCase() == 'inprogress' ||
          event.status.toLowerCase() == 'done') {
        statusKey = _getLocalizedStatusName('Duration');
      } else {
        statusKey = _getLocalizedStatusName(event.status);
      }

      counts[statusKey] = (counts[statusKey] ?? 0) + 1;
    }

    return counts;
  }

  void _navigateToPreviousMonth() {
    final previousMonth = DateTime(displayedMonth.year, displayedMonth.month - 1, displayedMonth.day);
    setState(() {
      displayedMonth = previousMonth;
      _calendarController.dispose();
      _calendarController = AdvancedCalendarController(previousMonth);
      _calendarKey = UniqueKey();
    });
  }

  void _navigateToNextMonth() {
    final nextMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, displayedMonth.day);
    setState(() {
      displayedMonth = nextMonth;
      _calendarController.dispose();
      _calendarController = AdvancedCalendarController(nextMonth);
      _calendarKey = UniqueKey();
    });
  }

  Widget _statusChip(String count, String status, BuildContext context) {
    bool isSelected = selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = status;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 45.sp,
            height: 45.sp,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: isSelected ? AppColors.textButton : AppColors.secondaryText,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            status,
            style: StyleText.fontSize16Weight600.copyWith(
              color: isSelected ? AppColors.text : AppColors.secondaryText,
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }

  String _getEnglishModuleName(String localizedName) {
    final moduleMapping = getUniqueModulesWithMapping();

    for (var module in moduleMapping) {
      if (module['display'] == localizedName) {
        return module['english']!;
      }
    }

    return localizedName;
  }

  @override
  Widget build(BuildContext context) {
    final statusCounts = getStatusCounts();
    final totalEvents = eventDetails.length;
    final isArabic = _currentLocale?.languageCode == 'ar';

    final List<String> statusTypes = [
      isArabic ? 'الكل' : 'All',
      isArabic ? 'مجدول' : 'Scheduled',
      isArabic ? 'معين' : 'Assigned',
      isArabic ? 'مستحق' : 'Due',
      isArabic ? 'متأخر' : 'Overdue',
      isArabic ? 'تذكيرات' : 'Reminders',
      'SLA',
      isArabic ? 'معلم' : 'Milestone',
      isArabic ? 'منتهي الصلاحية' : 'Expiring',
      isArabic ? 'تجديد' : 'Renewal',
      isArabic ? 'إصدار' : 'Release',
      isArabic ? 'المدة' : 'Duration',
      isArabic ? 'دورات الفوترة' : 'Billing Cycles',
      isArabic ? 'الموافقة المعلقة' : 'Pending Approval',
    ];

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).home,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).calendar,
          child: _isLoading
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleProgress(),
              ],
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Container(
                height: 55.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statusTypes.map((status) {
                      final count = status == (isArabic ? 'الكل' : 'All')
                          ? _toArabicNumber(totalEvents)
                          : _toArabicNumber(statusCounts[status] ?? 0);

                      return _statusChip(count, status, context);
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                height: 38.h,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: getUniqueModulesWithMapping().map((moduleMap) {
                      final displayName = moduleMap['display']!;
                      final englishName = moduleMap['english']!;

                      final isSelected = selectedModule == displayName || selectedModule == englishName;
                      final moduleColor = getModuleColor(englishName);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedModule = displayName;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 28.h,
                              decoration: BoxDecoration(
                                color: moduleColor,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Center(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.sp),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('MMMM yyyy', _currentLocale?.languageCode).format(displayedMonth),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: _navigateToPreviousMonth,
                              child: SizedBox(
                                child: CustomSvgImage(
                                  assetPath: isArabic
                                      ? "assets/icons_assets/calendar_assets/chevron_right.svg"
                                      : "assets/icons_assets/calendar_assets/chevron_left.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(width: 15.w),
                            GestureDetector(
                              onTap: _navigateToNextMonth,
                              child: SizedBox(
                                child: CustomSvgImage(
                                  assetPath: isArabic
                                      ? "assets/icons_assets/calendar_assets/chevron_left.svg"
                                      : "assets/icons_assets/calendar_assets/chevron_right.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 15.sp),

                  CalendarViewToggle(
                    isMonthView: currentViewMode == CalendarViewMode.month,
                    onToggle: () {
                      setState(() {
                        currentViewMode = currentViewMode == CalendarViewMode.month
                            ? CalendarViewMode.day
                            : CalendarViewMode.month;
                      });
                    },
                    dayText: isArabic ? 'يوم' : 'Day',
                    monthText: isArabic ? 'شهر' : 'Month',
                    activeColor: AppColors.secondaryPrimary,
                    inactiveColor: AppColors.card,
                    textActiveColor: AppColors.secondaryPrimaryText,
                    textInactiveColor: AppColors.text,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: currentViewMode == CalendarViewMode.month
                    ? _buildMonthView()
                    : _buildDayView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthView() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              AdvancedCalendar(
                backgroundColorCalender: AppColors.card,
                key: _calendarKey,
                controller: _calendarController,
                events: events,
                showNavigationArrows: false,
                startWeekDay: 1,
                weekLineHeight: 48.0,
                innerDot: false,
                viewMode: CalendarViewMode.month,
                selectedDayColor: AppColors.secondaryPrimary,
                selectedDayTextColor: AppColors.secondaryPrimaryText,
                onHorizontalDrag: (DateTime date) {
                  setState(() {
                    displayedMonth = date;
                  });
                },
              ),
            ],
          ),
        ),

        SizedBox(width: 10.sp),

        Container(
          width: 400.w,
          decoration: BoxDecoration(
            color: AppColors.background,
          ),
          child: ValueListenableBuilder<DateTime>(
            valueListenable: _calendarController,
            builder: (context, selectedDate, _) {
              final dayEvents = getEventsForDate(selectedDate);

              if (dayEvents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
                      CustomSvgImage(
                        assetPath: "assets/icons_assets/calendar_assets/calendar_desk_illustration.svg",
                        width: 250.w,
                        height: 250.h,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: dayEvents.length,
                itemBuilder: (context, index) {
                  return EventCard(event: dayEvents[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayView() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _calendarController,
      builder: (context, selectedDate, _) {
        final dayEvents = getEventsForDate(selectedDate);

        return Column(
          children: [
            AdvancedCalendar(
              backgroundColorCalender: AppColors.card,
              key: _calendarKey,
              controller: _calendarController,
              events: events,
              showNavigationArrows: false,
              startWeekDay: 1,
              weekLineHeight: 48.0,
              innerDot: false,
              viewMode: CalendarViewMode.day,
              selectedDayColor: AppColors.secondaryPrimary,
              selectedDayTextColor: AppColors.secondaryPrimaryText,
              onHorizontalDrag: (DateTime date) {
                setState(() {
                  displayedMonth = date;
                });
              },
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: DayTimelineView(
                selectedDate: selectedDate,
                events: dayEvents,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
}

