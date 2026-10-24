/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_screen.dart
/// Description: The full calendar screen — month, week and day views with filters.
/// Author: Amr Mesbah
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N06/N07/N08/N09/N11: the data service and fetch moved into
///          `CalendarCubit` (which also fixes this screen fetching only five of
///          the seven event sources); `Get.find<AppDrawerCubit>()` became
///          `context.read`; the module palette is shared.
/// Updated: 7/10/2026 - To-Do chip reads "To-Do List"; the status chips come
///          from the one `statusTypes` getter (adds the missing "Frequency").
/// Updated: 7/10/2026 - To-Do "Task Due" (statusCode 'Due') files under the
///          existing "Due" chip; month-view To-Do cards open the to-do.
///
/// REMAINING (CR-SKEL-CAL-N07): still over the 800-LOC gate.
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/theme/calendar_module_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/widgets/calendar_package/controller.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/widgets/calendar_package/widget.dart';
import 'package:knowticed_plus/features/calendar/presentation/controller/calendar_cubit.dart';
import 'package:knowticed_plus/features/calendar/data/models/calendar_event_model.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_tab_with_container.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/widgets/event_card.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/widgets/day_timeline_view.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part '../widgets/calendar_screen/calendar_test_screen_builders.dart';
part '../widgets/calendar_screen/calendar_test_screen_logic.dart';

class CalendarTestScreen extends StatefulWidget {
  const CalendarTestScreen({super.key, this.currentUserEmail});

  /// The signed-in user's email. Passed in rather than resolved with
  /// `Get.find<MainCoreEmployeeController>()` inside the load (§16,
  /// CR-SKEL-CAL-N09).
  final String? currentUserEmail;

  @override
  State<CalendarTestScreen> createState() => _CalendarTestScreenState();
}

class _CalendarTestScreenState extends State<CalendarTestScreen> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  late AdvancedCalendarController _calendarController;
  String selectedModule = 'All';
  String selectedStatus = 'All';
  CalendarViewMode currentViewMode = CalendarViewMode.month;
  DateTime displayedMonth = DateTime.now();
  Key _calendarKey = UniqueKey();

  /// The month grid's own height, measured after layout, so the empty-state
  /// picture can sit in the middle of THAT height beside it (tablet / desktop).
  final GlobalKey _monthGridKey = GlobalKey();
  double? _monthGridHeight;

  /// The fetch orchestration lives in the cubit now (CR-SKEL-CAL-N06).
  late final CalendarCubit _calendarCubit;

  List<CalendarEventModel> get eventDetails => _calendarCubit.state.events;

  /// Spinner only while there is nothing to show yet. Owner 22/10/2026 (phone:
  /// "the loading for the calendar it's too much"): the page used to wait for
  /// ALL fourteen event sources (each may take up to 12 s) although the first
  /// ones land in well under a second — "535 All" was already counted behind
  /// the spinner. The cubit publishes as each source returns, so the page
  /// shows what has arrived and the rest fill in.
  ///
  /// 22/10/2026 (Moataz: "a lag, then the data reloads — show a loading
  /// indicator, load the data, then show it, but not too long"): showing each
  /// source as it landed made the counts and dots jump after the page was
  /// already on screen. The spinner now stays until every source is in, or
  /// for at most [_kLoadCap], whichever is first; after the cap whatever has
  /// arrived is shown and the rest still fill in.
  bool get _isLoading =>
      _calendarCubit.state.isLoading &&
      (_calendarCubit.state.events.isEmpty || !_loadCapReached);

  static const Duration _kLoadCap = Duration(milliseconds: 2500);
  bool _loadCapReached = false;
  Timer? _loadCapTimer;

  Locale? _currentLocale;

  /// FIXED 22/8/2026 — this is what made the Calendar button open a blank
  /// grey page.
  ///
  /// It read `context.read<AppDrawerCubit>()`. `AppDrawerCubit` is never put
  /// into the widget tree: `main.dart`'s MultiBlocProvider provides
  /// ThemeAndLocalizationsCubit, CompanyCubit, AppHomeCubit and
  /// MainCoreDepartmentCubit — and nothing else — while every AppDrawerCubit
  /// registration in the app goes through GetX (`Get.put` in
  /// custom_drawer.dart, home_responsive_page.dart, main_responsive.dart).
  /// So `context.read` found no provider and threw ProviderNotFoundException
  /// out of `getUniqueModulesWithMapping()` during build. In a release build
  /// Flutter's default ErrorWidget is a plain grey rectangle — exactly what
  /// the screen showed.
  ///
  /// Resolved from the registry that actually owns it, with the same
  /// register-if-missing guard custom_drawer.dart uses, so opening the
  /// calendar directly (deep link, mobile layout where the drawer cubit was
  /// deleted) cannot crash the page.
  AppDrawerCubit get _drawerController => Get.isRegistered<AppDrawerCubit>()
      ? Get.find<AppDrawerCubit>()
      : Get.put(AppDrawerCubit());

  @override
  void initState() {
    super.initState();
    _calendarCubit = CalendarCubit(
      departmentCubit: context.read<MainCoreDepartmentCubit>(),
    );

    _calendarController = AdvancedCalendarController(displayedMonth);

    _loadCapTimer = Timer(_kLoadCap, () {
      if (mounted) setState(() => _loadCapReached = true);
    });

    _loadCalendarData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);

    if (_currentLocale != locale) {
      // The event texts are built in the language active at load time, so a
      // language switch must rebuild them (a card was left half English in
      // Arabic mode — Moataz 22/10/2026). Not on the very first call.
      final bool switched = _currentLocale != null;
      _currentLocale = locale;
      if (switched) {
        _loadCalendarData();
      }

      if (mounted) {
        setState(() {
          _calendarKey = UniqueKey();
        });
      }
    }
  }

  String _toArabicNumber(int number) {
    if (_currentLocale?.languageCode != 'ar') return number.toString();

    const arabicNumbers = [
      // D-145: Western digits in Arabic too.
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ];
    return number.toString().split('').map((digit) {
      return int.tryParse(digit) != null
          ? arabicNumbers[int.parse(digit)]
          : digit;
    }).join();
  }

  // In _CalendarTestScreenState class

  // 1. ✅ ADD TODO COLOR to getModuleColor method (around line 220)
  /// Delegates to the shared palette. The sixteen inline `Color(0xFF…)`
  /// literals this held — duplicated in the other calendar page — moved to
  /// `presentation/ui/theme/calendar_module_palette.dart` (CR-SKEL-CAL-N11).
  Color getModuleColor(String moduleName) =>
      CalendarModulePalette.colorOf(moduleName);

  /// Function Name: [_loadCalendarData]
  ///
  /// Purpose: Ask the cubit to refresh.
  ///
  /// The fetches, the `Get.find<MainCoreEmployeeController>()` and the `try`
  /// moved into `CalendarCubit` (CR-SKEL-CAL-N06/N08/N09). This screen used to
  /// fetch only five of the seven sources — role-management and user-access
  /// events were missing here but present on the home card. The cubit fetches
  /// all seven for both.
  Future<void> _loadCalendarData() async {
    await _calendarCubit.load(currentUserEmail: widget.currentUserEmail ?? '');
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
      // The chip itself is built as 'الموافقة المعلقة' / 'Pending Approval'
      // (see [statusTypes]), but only 'Pending Requests' was mapped — so in
      // Arabic the round trip fell through to the English string and no event
      // ever matched the chip. Both spellings are mapped rather than renaming
      // the chip, because 'Pending Requests' may already be persisted.
      'الموافقة المعلقة': 'Pending Approval',
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
      // Mirror of the addition in [_getEnglishStatusName]. This is the
      // direction that matters for the new catalog: ServicesCalendarEvent
      // .pendingApproval sets statusCode 'Pending Approval', and without this
      // pair the card is dropped from every chip in Arabic.
      'Pending Approval': 'الموافقة المعلقة',
      'Frequency': 'التكرار', // ✅ ADD THIS
    };

    return statusMap[englishStatus] ?? englishStatus;
  }

  List<Map<String, dynamic>> get events {
    Map<DateTime, Map<String, Color>> eventsByDate = {};

    for (var event in _applyChipFilters(eventDetails)) {
      final dateKey = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      if (!eventsByDate.containsKey(dateKey)) {
        eventsByDate[dateKey] = {};
      }

      final moduleKey = event.moduleName.toLowerCase();

      if (!eventsByDate[dateKey]!.containsKey(moduleKey)) {
        final standardColor = getModuleColor(event.moduleName);
        eventsByDate[dateKey]![moduleKey] = standardColor;
      } else {}
    }

    List<Map<String, dynamic>> calendarEvents = [];

    eventsByDate.forEach((date, modulesMap) {
      modulesMap.forEach((moduleName, color) {
        calendarEvents.add({'date': date, 'color': color});
      });
    });

    eventsByDate.forEach((date, modules) {});

    return calendarEvents;
  }

  List<CalendarEventModel> getEventsForDate(DateTime date) {
    final List<CalendarEventModel> sameDay = eventDetails.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
    return _applyChipFilters(sameDay);
  }

  /// The module chip and the status chip applied to [source]. Shared by the
  /// day list and the month-grid dots, so pressing a chip changes both —
  /// 22/10/2026 (Moataz: "when I press Milestone ..."): the dots used to be
  /// built from ALL events and ignored the chip you pressed.
  List<CalendarEventModel> _applyChipFilters(List<CalendarEventModel> source) {
    var filtered = source;

    if (selectedModule != 'All' && selectedModule != 'الكل') {
      final englishModuleName = _getEnglishModuleName(selectedModule);
      final Set<String> wanted = _moduleNamesForChip(englishModuleName);
      filtered = filtered
          .where(
            (event) => wanted.contains(event.moduleName.toLowerCase().trim()),
          )
          .toList();
    }

    if (selectedStatus != 'All' && selectedStatus != 'الكل') {
      final englishStatus = _getEnglishStatusName(selectedStatus);

      if (englishStatus == 'Duration') {
        filtered = filtered
            .where(
              (event) =>
                  event.status.toLowerCase() == 'inprogress' ||
                  event.status.toLowerCase() == 'done',
            )
            .toList();
      } else {
        filtered = filtered
            .where((event) => _chipStatusOf(event.status) == englishStatus)
            .toList();
      }
    }

    return filtered;
  }

  /// 22/10/2026 (Moataz: "why is there no reminders, no expiring"): the chips
  /// match the status text exactly, but several modules tag their events
  /// "Reminder" (GRC, Messages, Form Builder) and "Expiring Soon" (Knowledge
  /// Hub), so those events never landed under the "Reminders" / "Expiring"
  /// chips. This maps those spellings to the chip they belong to.
  String _chipStatusOf(String status) {
    switch (status.trim().toLowerCase()) {
      case 'reminder':
        return 'Reminders';
      case 'expiring soon':
        return 'Expiring';
      default:
        return status;
    }
  }

  Map<String, int> getStatusCounts() {
    Map<String, int> counts = {};

    for (var event in eventDetails) {
      String statusKey;

      if (event.status.toLowerCase() == 'inprogress' ||
          event.status.toLowerCase() == 'done') {
        statusKey = _getLocalizedStatusName('Duration');
      } else {
        statusKey = _getLocalizedStatusName(_chipStatusOf(event.status));
      }

      counts[statusKey] = (counts[statusKey] ?? 0) + 1;
    }

    return counts;
  }

  void _navigateToPreviousMonth() {
    final previousMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month - 1,
      displayedMonth.day,
    );
    setState(() {
      displayedMonth = previousMonth;
      _calendarController.dispose();
      _calendarController = AdvancedCalendarController(previousMonth);
      _calendarKey = UniqueKey();
    });
  }

  void _navigateToNextMonth() {
    final nextMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      displayedMonth.day,
    );
    setState(() {
      displayedMonth = nextMonth;
      _calendarController.dispose();
      _calendarController = AdvancedCalendarController(nextMonth);
      _calendarKey = UniqueKey();
    });
  }

  /// ══════════════════════════════════════════════════════════════════
  ///  MODULE CHIP → EVENT MODULE NAMES        FIXED 30/8/2026
  ///
  ///  `getEventsForDate` filtered with
  ///      `event.moduleName.toLowerCase() == englishModuleName.toLowerCase()`
  ///  where `englishModuleName` is the `'english'` value out of
  ///  [getUniqueModulesWithMapping] and `event.moduleName` is written by
  ///  `CalendarEventModel.fromType` from `AppModule.labelEn`. Those two lists
  ///  were never reconciled — only the entries that happened to spell the
  ///  label identically ever matched:
  ///
  ///      chip 'english'      AppModule.labelEn            matched?
  ///      'Services'          'Service Management'         ✗
  ///      'Roles'             'Role Management'            ✗
  ///      'To Do'             'To-Do List'                 ✗
  ///      'Database'          'Database Management'        ✗
  ///      'Settings'          'Settings'                   ✓
  ///      'Knowledge Hub'     'Knowledge Hub'              ✓
  ///
  ///  which is why picking the Services or the Roles chip emptied the day —
  ///  the events were loaded and sitting under "All", and no chip could
  ///  reach them. (The Settings entry added 25/8/2026 carries a comment
  ///  saying `english` must equal the labelEn; that rule was right and was
  ///  simply never applied to the entries that predate it.)
  ///
  ///  The role area additionally needs a SET rather than a string: Role
  ///  Management, User Access and User Management & Permissions are three
  ///  `AppModule`s sharing one drawer entry and therefore one chip (the same
  ///  grouping `CalendarModulePalette` and `event_card._moduleFor` already
  ///  make), so one chip has to match three labels.
  /// ══════════════════════════════════════════════════════════════════
  static const Map<String, Set<String>> _chipModuleNames =
      <String, Set<String>>{
    // AppModule.roleManagement / userAccess / userManagement.
    'role management': <String>{
      'role management',
      'user access',
      'user management & permissions',
    },
    // Owner item 223 (21/10/2026): the chip reads "Time Tracker"; its events
    // may still carry the old long module name.
    'time tracker': <String>{
      'time tracker',
      'time tracker & attendance',
    },
  };

  /// Function Name: [_moduleNamesForChip]
  ///
  /// Purpose: The `event.moduleName` values one chip should show, lowercased.
  ///
  /// Defaults to the chip's own English name, so a chip that maps 1:1 onto an
  /// `AppModule.labelEn` needs no entry in [_chipModuleNames].
  Set<String> _moduleNamesForChip(String englishModuleName) {
    final String key = englishModuleName.toLowerCase().trim();
    return _chipModuleNames[key] ?? <String>{key};
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
    // Rebuilds when the cubit publishes: `eventDetails` and `_isLoading` read
    // straight off its state now.
    return BlocBuilder<CalendarCubit, CalendarState>(
      bloc: _calendarCubit,
      builder: (BuildContext context, CalendarState state) =>
          _buildBody(context),
    );
  }

  /// The calendar card's inner padding — 15 on all four sides.
  ///
  /// REPLACED the measured inset of 24/8/2026. That version matched the top and
  /// bottom to the gap the seven centred day columns already create at the
  /// sides (~60px on a desktop window). It was symmetric, and far too tall: the
  /// day view in particular became a thin week strip floating in a deep empty
  /// band.
  ///
  /// A flat 15 is what the rest of the app's cards use. The side gap is still
  /// wider than 15 because the columns centre their contents — that is the grid
  /// working as intended, not padding to be compensated for.

  /// The month / day grid itself.
  ///
  /// EXTRACTED 12/9/2026. Four call sites now need it — month and day, each in
  /// a bounded and a self-sizing flavour — and it was already duplicated
  /// verbatim between the first two but for `viewMode`. `_calendarKey` being
  /// shared is safe: exactly one of the four is built at a time.
  Widget _advancedCalendar(CalendarViewMode mode) {
    final bool month = mode == CalendarViewMode.month;
    // Owner item 212 (21/10/2026): the grid sits in its card with the 16
    // inset on every side (diagonal cut), like the Home calendar card.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      // Owner 23/10/2026 ("the diagonal cut on Monday, same as outside"): the
      // same equal-gap treatment as the Home card (R-11, R-35). The month grid
      // is widened so Mon / Sun sit exactly on the 16 line; the label line and
      // the last dot row carry empty space of their own, taken off the
      // padding so top = left = right = bottom where you measure them. The day
      // strip has five columns, so it keeps the plain 16 inset.
      padding: month
          ? () {
              final double side = 16.sp;
              final slack = AdvancedCalendar.edgeSlack(
                context,
                weekLineHeight: 52.0,
                lastRowDotRows: AdvancedCalendar.lastRowDotRows(
                  eventDates: events.map<DateTime>(
                      (Map<String, dynamic> e) => e['date'] as DateTime),
                  month: displayedMonth,
                  startWeekDay: 1,
                ),
              );
              return EdgeInsets.fromLTRB(
                side,
                (side - slack.top).clamp(0.0, side),
                side,
                (side - slack.bottom).clamp(0.0, side),
              );
            }()
          : EdgeInsets.all(16.sp),
      child: AdvancedCalendar(
        // Owner 21/10/2026 13:55 (rule, everywhere): the selected day sits on
        // the brand colour and its number takes the READABLE colour for it —
        // black on a light brand, white on a dark one (AppTheme.readableOn),
        // the same as today's "21".
        selectedDayColor: AppColors.secondaryPrimary,
        selectedDayTextColor: AppTheme.readableOn(AppColors.secondaryPrimary),
        backgroundColorCalender: AppColors.transparent,
        key: _calendarKey,
        controller: _calendarController,
        events: events,
        showNavigationArrows: false,
        startWeekDay: 1,
        weekLineHeight:
            52.0, // 22/10/2026: number 24 + 2 + three dot rows (22) + 4
        // ADDED 13/9/2026 — the DAY strip only. 48 is a month-grid row
        // height: it has to separate six stacked weeks. A single strip
        // holds a 24px date box plus one 8px dot row, so at 48 a third of
        // it was empty card under the numbers. The month grid keeps 48.
        dayStripLineHeight: 50.0, // 22/10/2026: room for three dot rows
        innerDot: false,
        viewMode: mode,
        // `.sp` on both axes: `15.w` and `15.h` are different pixel counts, so a
        // symmetric() built from them is not square.
        // Owner 21/10/2026 14:01 ("why no diagonal cut from Monday"): the
        // widget's own inner padding is off — the card's 8 inset is the only
        // inset, equal on all four sides (the labels still centre in their
        // columns, which is what shows left of "Mon").
        contentPadding: EdgeInsets.zero,
        flushToPadding: month,
        onHorizontalDrag: (DateTime date) {
          setState(() {
            displayedMonth = date;
          });
        },
      ),
    );
  }

  /// The selected day's events.
  ///
  /// [shrinkWrap] is what separates the two parents: inside a bounded box the
  /// list scrolls itself, and inside the mobile frame's scroll view it must
  /// size to its content and let the PAGE scroll — two scrollables on one axis
  /// would fight, and an unbounded self-scrolling list cannot lay out at all.
  Widget _dayEventsList({required bool shrinkWrap}) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _calendarController,
      builder: (context, selectedDate, _) {
        final dayEvents = getEventsForDate(selectedDate);

        if (dayEvents.isEmpty) {
          // 23/10/2026 (Moataz): on iPad / desktop the picture used to sit in
          // the middle of the whole page height, far below the calendar it
          // belongs to. It now centres in the grid card's height (measured in
          // [_buildMonthView]), a little smaller than the old 250. The phone
          // stacks the pieces, so it keeps its own top gap.
          final Widget picture = CustomSvgImage(
            assetPath:
                "assets/icons_assets/calendar_assets/img_calendar_empty_state.svg",
            width: 210.sp,
            height: 210.sp,
            fit: BoxFit.contain,
          );
          if (shrinkWrap) {
            // 23/10/2026 (Moataz, phone): the picture ended flush against the
            // bottom nav. Less above it, and clear space below it, so it
            // sits higher and the scroll ends with air above the nav.
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: 24.h, bottom: 32.sp),
                child: picture,
              ),
            );
          }
          final double? gridHeight = _monthGridHeight;
          return gridHeight == null
              ? Align(alignment: Alignment.topCenter, child: picture)
              : SizedBox(
                  height: gridHeight,
                  child: Center(child: picture),
                );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          itemCount: dayEvents.length,
          itemBuilder: (context, index) {
            return EventCard(event: dayEvents[index]);
          },
        );
      },
    );
  }

  /// Month view, tablet and desktop: grid on the left, the day's events in a
  /// fixed 400 column on the right. Needs a bounded height from its parent.
  Widget _buildMonthView() {
    // Owner item 218 (21/10/2026): on iPad portrait the grid and the list
    // share the width 50 / 50 (landscape keeps the 400-wide list), 16 apart.
    final bool portrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final Widget list = Container(
      width: portrait ? null : 400.w,
      decoration: BoxDecoration(color: AppColors.background),
      child: _dayEventsList(shrinkWrap: false),
    );
    // Measure the grid card after this frame; one setState when it changes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final double? h = _monthGridKey.currentContext?.size?.height;
      if (h != null && h != _monthGridHeight) {
        setState(() => _monthGridHeight = h);
      }
    });
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: portrait ? 1 : 2,
          child: Column(
            children: [
              KeyedSubtree(
                key: _monthGridKey,
                child: _advancedCalendar(CalendarViewMode.month),
              ),
            ],
          ),
        ),
        SizedBox(width: 16.sp),
        if (portrait) Expanded(child: list) else list,
      ],
    );
  }

  /// Month view, phone: the same two pieces STACKED.
  ///
  /// Not merely a narrower version of [_buildMonthView] — that one is a Row
  /// whose right-hand column is a hard `400.w`, which on a 402pt phone is
  /// wider than the screen on its own, before the grid beside it. Stacking is
  /// the only arrangement that fits, and it makes the whole thing
  /// intrinsic-height, which is what the frame's scroll view needs.
  Widget _buildMonthViewMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _advancedCalendar(CalendarViewMode.month),
        SizedBox(height: 16.h),
        _dayEventsList(shrinkWrap: true),
      ],
    );
  }

  /// Day view, tablet and desktop: week strip above, timeline filling the rest.
  Widget _buildDayView() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _calendarController,
      builder: (context, selectedDate, _) {
        final dayEvents = getEventsForDate(selectedDate);

        return Column(
          children: [
            _advancedCalendar(CalendarViewMode.day),
            SizedBox(height: 16.h),
            Expanded(
              child: DayTimelineView(
                selectedDate: selectedDate,
                events: dayEvents,
                // The phone already shows a screen title, the Day/Month
                // toggle and the week strip above this; a fourth header bar
                // is chrome between the user and the schedule.
                showHeader: false,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Day view, phone.
  ///
  /// `DayTimelineView` puts its own list in an `Expanded`, so it only lays out
  /// inside a bounded height — the exact constraint this page could not give
  /// it on mobile. It gets a window of its own here and scrolls within it.
  /// A fixed window rather than a shrink-wrap on purpose: the timeline is
  /// forty-eight half-hour rows whatever the day holds, so letting it size to
  /// its content would bury the calendar under a screen and a half of empty
  /// slots.
  Widget _buildDayViewMobile() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _calendarController,
      builder: (context, selectedDate, _) {
        final dayEvents = getEventsForDate(selectedDate);

        return Column(
          children: [
            _advancedCalendar(CalendarViewMode.day),
            SizedBox(height: 16.h),
            SizedBox(
              height: 420.h,
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
    _loadCapTimer?.cancel();
    _calendarCubit.close();
    _calendarController.dispose();
    super.dispose();
  }
}
