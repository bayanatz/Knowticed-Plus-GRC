/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: home_calendar_page.dart
/// Purpose: The compact calendar card on the home screen.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N06/N08/N09/N10/N11: the data service and the multi-step fetch
///          moved into `CalendarCubit`; the try/catch and `Get.find` went with
///          them; `package:get` is gone; the module palette is shared.
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/theme/calendar_module_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/pages/calendar_screen.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/widgets/calendar_package/controller.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/widgets/calendar_package/widget.dart';
import 'package:knowticed_plus/features/calendar/presentation/controller/calendar_cubit.dart';
import 'package:knowticed_plus/features/calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/widgets/day_timeline_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class HomeCalendarWidget extends StatefulWidget {
  const HomeCalendarWidget({
    super.key,
    this.onDateSelected,
    this.currentUserEmail,
    this.showDayTimeline = true,
    this.dayTimelineHeight,
    this.loadEvents = true,
  });

  /// False = a still picture of the calendar: no event fetch, no progress bar,
  /// no reload when the page opens. The Home Layout editor passes false — it
  /// only shows where the calendar sits (Owner 24/10/2026).
  final bool loadEvents;

  /// A fixed height for the day timeline, for parents that cannot give this
  /// widget a bounded one.
  ///
  /// ADDED 13/9/2026. The timeline sits in an `Expanded`, which needs a
  /// bounded height — fine in the tablet column, impossible inside the mobile
  /// home's `SingleChildScrollView`, which hands its child unbounded height.
  /// That is why the phone could only ever show the month grid.
  ///
  /// Pass a height and the `Expanded` is swapped for a `SizedBox` of exactly
  /// that size, so the timeline can live in a scroll view: it scrolls WITH the
  /// page down to its own height, and the half-hour rows scroll inside it.
  ///
  /// Null (the default) keeps `Expanded`, so the tablet column and the layout
  /// editor are unchanged.
  final double? dayTimelineHeight;

  /// Whether to draw the day timeline — the "Saturday, September 12, 2026"
  /// card with the half-hourly rows — beneath the month grid.
  ///
  /// ADDED 12/9/2026. The phone home page wants the month and nothing else:
  /// the timeline's own header Row overflows at 375px
  /// (`day_timeline_view.dart:68`, "RenderFlex overflowed by 51 pixels"), and
  /// a full day of half-hour rows is more page than a dashboard summary should
  /// spend.
  ///
  /// It also decides how this widget can be laid out. The timeline lives in an
  /// `Expanded`, so with it ON the widget needs a BOUNDED height from its
  /// parent; with it OFF the column is all intrinsic height and the widget
  /// sizes itself — which is what lets the mobile home drop it straight into a
  /// `SingleChildScrollView` with no height guess.
  ///
  /// Defaults to true, so the tablet column and the layout editor are
  /// unchanged.
  final bool showDayTimeline;

  final Function(DateTime)? onDateSelected;

  /// The signed-in user's email. Passed in rather than resolved with
  /// `Get.find<MainCoreEmployeeController>()` inside the load (§16,
  /// CR-SKEL-CAL-N09).
  final String? currentUserEmail;

  @override
  State<HomeCalendarWidget> createState() => _HomeCalendarWidgetState();
}

class _HomeCalendarWidgetState extends State<HomeCalendarWidget> {
  AdvancedCalendarController? _calendarController;
  DateTime _currentMonth = DateTime.now();
  Key _calendarKey = UniqueKey();

  /// The fetch orchestration lives in the cubit now; this page only reads its
  /// state (CR-SKEL-CAL-N06).
  late final CalendarCubit _calendarCubit;

  List<CalendarEventModel> get _allEvents => _calendarCubit.state.events;
  bool get _isLoading => _calendarCubit.state.isLoading;

  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _calendarCubit = CalendarCubit(
      departmentCubit: context.read<MainCoreDepartmentCubit>(),
    );
    _calendarController = AdvancedCalendarController(_currentMonth);
    if (widget.loadEvents) _loadCalendarData();
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
      if (switched && widget.loadEvents) {
        _loadCalendarData();
      }

      if (mounted) {
        setState(() {
          _calendarKey = UniqueKey();
        });
      }
    }
  }

  /// Function Name: [_loadCalendarData]
  ///
  /// Purpose: Ask the cubit to refresh.
  ///
  /// The seven sequential fetches, the `Get.find<MainCoreEmployeeController>()`
  /// and the `try` that used to sit here moved into `CalendarCubit`
  /// (CR-SKEL-CAL-N06/N08/N09).
  Future<void> _loadCalendarData() async {
    await _calendarCubit.load(
      currentUserEmail: widget.currentUserEmail ?? '',
    );
  }

  @override
  void dispose() {
    _calendarController?.dispose();
    _calendarCubit.close();
    super.dispose();
  }

  // ✅ UPDATED: Group events by unique MODULE (not color) to show only one dot per module
  List<Map<String, dynamic>> get events {
    Map<DateTime, Map<String, Color>> eventsByDate = {};

    for (var event in _allEvents) {
      final dateKey =
          DateTime(event.date.year, event.date.month, event.date.day);

      if (!eventsByDate.containsKey(dateKey)) {
        eventsByDate[dateKey] = {};
      }

      // ✅ KEY CHANGE: Group by MODULE NAME
      final moduleKey = event.moduleName.toLowerCase();

      // ✅ CRITICAL FIX: Use _getStandardModuleColor() to get standard module color
      if (!eventsByDate[dateKey]!.containsKey(moduleKey)) {
        final standardColor = _getStandardModuleColor(event.moduleName);
        eventsByDate[dateKey]![moduleKey] = standardColor;
      } else {}
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

    eventsByDate.forEach((date, modules) {});

    return calendarEvents;
  }

  /// Delegates to the shared palette. The sixteen inline `Color(0xFF…)`
  /// literals this held are in
  /// `presentation/ui/theme/calendar_module_palette.dart` (CR-SKEL-CAL-N11).
  Color _getStandardModuleColor(String moduleName) =>
      CalendarModulePalette.colorOf(moduleName);

  List<CalendarEventModel> getEventsForDate(DateTime date) {
    return _allEvents
        .where((event) =>
            event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day)
        .toList();
  }

  /// Month arrow size: 16 on the phone, 24 on large screens.
  double get _monthArrowSize => context.isPhone ? 16.r : 24.r;

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
    // Rebuilds when the cubit publishes: `_allEvents` and `_isLoading` read
    // straight off its state now.
    return BlocBuilder<CalendarCubit, CalendarState>(
      bloc: _calendarCubit,
      builder: (BuildContext context, CalendarState state) =>
          _buildBody(context),
    );
  }

  EdgeInsets _calendarPadding(BuildContext context) {
    final double side = 16.sp;
    final slack = AdvancedCalendar.edgeSlack(
      context,
      weekLineHeight: 52.0,
      lastRowDotRows: AdvancedCalendar.lastRowDotRows(
        eventDates: events
            .map<DateTime>((Map<String, dynamic> e) => e['date'] as DateTime),
        month: _currentMonth,
      ),
    );
    return EdgeInsets.fromLTRB(
      side,
      (side - slack.top).clamp(0.0, side),
      side,
      (side - slack.bottom).clamp(0.0, side),
    );
  }

  Widget _buildBody(BuildContext context) {
    MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.sp, 1.sp, 0.sp, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarHeader(),

            SizedBox(height: 10.h),

            // PERFORMANCE 22/8/2026 — "loading too much".
            //
            // The whole card used to be replaced by a 300h spinner until every
            // one of the seven event sources had returned. But the month grid
            // does not depend on the events at all: it is built from the
            // controller's date. Only the little coloured dots do. So the grid
            // is painted immediately and a slim progress bar sits above it
            // while the remaining sources land — the dots appear as each one
            // arrives (CalendarCubit publishes incrementally now).
            if (_isLoading)
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    minHeight: 3.h,
                    backgroundColor: AppColors.card,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              // SPACING 24/8/2026: was `symmetric(horizontal: 16.w,
              // vertical: 16.h)`. Under ScreenUtil `.w` scales with width and
              // `.h` with height, so those two 16s are different pixel counts
              // and the card was never square. `EdgeInsets.all(16.sp)` is.
              // R-11 "diagonal cut": the label line and the last dot row carry
              // empty space of their own, taken off the padding so the four
              // gaps are equal where you measure them (the ink), not where
              // the boxes are.
              padding: _calendarPadding(context),
              child: _calendarController == null
                  ? SizedBox(height: 300.h)
                  : AdvancedCalendar(
                      backgroundColorCalender: AppColors.transparent,
                      key: _calendarKey,
                      controller: _calendarController!,
                      events: events,
                      showNavigationArrows: false,
                      startWeekDay: 0,
                      weekLineHeight: 52.0,
                      innerDot: false,
                      viewMode: CalendarViewMode.month,
                      selectedDayColor: AppColors.secondaryPrimary,
                      selectedDayTextColor: AppColors.secondaryPrimaryText,
                      // Owner 22/10/2026 (R-11, "diagonal cut"): Sun and Sat
                      // sit on the card's padding line, not a column's slack
                      // inside it.
                      flushToPadding: true,
                      onHorizontalDrag: (DateTime date) {
                        setState(() {
                          _currentMonth = date;
                        });
                      },
                    ),
            ),

            if (widget.showDayTimeline) SizedBox(height: 10.h),

            if (widget.showDayTimeline)
              // Expanded when the parent bounds us (tablet column), a fixed
              // box when it cannot (mobile scroll view) — see
              // [dayTimelineHeight].
              _timelineSlot(
                // Owner 21/10/2026 13:07 (Figma): no grey box around the whole
                // Up Comings widget — its header sits OUTSIDE with no
                // background and only the list below it is the rounded box
                // (DayTimelineView draws that box itself).
                child: SizedBox(
                  width: double.infinity,
                  child: _calendarController == null
                      ? Center(
                          child: Text(
                            // Was a hardcoded English 'Loading...' (§13).
                            S.of(context).loading,
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
                              onTapDown: (_) => HapticController.low(),
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => const NotificationControlPage(),
                                //     ));
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
        ),
      ),
    );
  }

  /// Wraps the day timeline so it works under either kind of parent.
  ///
  /// `Expanded` needs a bounded height and throws without one; a `SizedBox`
  /// works anywhere but has to be told a size. Which one applies is the
  /// caller's knowledge, so it arrives as [HomeCalendarWidget.dayTimelineHeight].
  Widget _timelineSlot({required Widget child}) {
    final double? height = widget.dayTimelineHeight;
    if (height == null) return Expanded(child: child);
    return SizedBox(height: height, child: child);
  }

  Widget _buildCalendarHeader() {
    final isArabicMode = Localizations.localeOf(context).languageCode == 'ar';
    // Owner 21/10/2026 13:33: the month box takes the Calendar button's own
    // height (stretched in an IntrinsicHeight row), so they always share one
    // top and one bottom line — phone, iPad portrait and landscape alike.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy', _currentLocale?.languageCode)
                            .format(_currentMonth),
                        style: context.isPhone
                            ? StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.text)
                            : StyleText.fontSize16Weight700
                                .copyWith(color: AppColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Spacer(),
                  // Owner 22/10/2026 ("in the large screen … the icons is too
                  // small"): 24 on large screens, 16 stays on the phone.
                  InkWell(
                    onTapDown:
                        hapticDown(_navigateToPreviousMonth, HapticLevel.low),
                    onTap: _navigateToPreviousMonth,
                    // Owner item 206 (21/10/2026, 12:56 "by eye they are not
                    // the same"): ONE chevron glyph, mirrored for the other
                    // direction — two different drawings never match by eye.
                    child: Transform.flip(
                      flipX: !isArabicMode,
                      child: CustomSvgImage(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                        width: _monthArrowSize,
                        height: _monthArrowSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: context.isPhone ? 6.w : 12.w),
                  InkWell(
                    onTapDown:
                        hapticDown(_navigateToNextMonth, HapticLevel.low),
                    onTap: _navigateToNextMonth,
                    child: Transform.flip(
                      flipX: isArabicMode,
                      child: CustomSvgImage(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                        width: _monthArrowSize,
                        height: _monthArrowSize,
                        fit: BoxFit.contain,
                      ),
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
              height: 40.h,
              title: S.of(context).calendar,
              function: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarTestScreen(
                      currentUserEmail: widget.currentUserEmail,
                    ),
                  ),
                );
              },
              svgColor: AppColors.textButton,
              color: AppColors.primary,
              radius: 8.r,
              textStyle: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.textButton),
              image:
                  'assets/icons_assets/calendar_assets/ic_action_expand_fullscreen.svg',
              widthImage: 16,
              heightImage: 16,
              colorBorder: AppColors.transparent,
              space: 8.w,
            ),
          ),
        ],
      ),
    );
  }
}
