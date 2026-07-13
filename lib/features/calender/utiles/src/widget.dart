import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/features/calender/utiles/src/controller.dart';
import 'package:demo_app/features/calender/utiles/src/datetime_util.dart';

part 'date_box.dart';
part 'handlebar.dart';
part 'header.dart';
part 'month_view.dart';
part 'month_view_bean.dart';
part 'week_days.dart';
part 'week_view.dart';

enum CalendarViewMode {
  day,
  month,
}

class AdvancedCalendar extends StatefulWidget {
  const AdvancedCalendar({
    Key? key,
    this.controller,
    this.startWeekDay,
    this.events,
    this.weekLineHeight = 32.0,
    this.preloadMonthViewAmount = 13,
    this.preloadWeekViewAmount = 21,
    this.weeksInMonthViewAmount = 6,
    this.todayStyle,
    this.headerStyle,
    this.onHorizontalDrag,
    this.backgroundColorCalender,
    this.innerDot = false,
    this.keepLineSize = false,
    this.calendarTextStyle,
    this.navigationArrowColor,
    this.showNavigationArrows = false,
    this.viewMode = CalendarViewMode.month,
    this.selectedDayColor,
    this.selectedDayTextColor,
  })  : assert(
  keepLineSize && innerDot ||
      innerDot && !keepLineSize ||
      !innerDot && !keepLineSize,
  'keepLineSize should be used only when innerDot is true',
  ),
        super(key: key);

  final AdvancedCalendarController? controller;
  final Function(DateTime)? onHorizontalDrag;
  final double weekLineHeight;
  final int preloadMonthViewAmount;
  final int preloadWeekViewAmount;
  final int weeksInMonthViewAmount;
  final dynamic events;
  final int? startWeekDay;
  final TextStyle? headerStyle;
  final TextStyle? todayStyle;
  final bool innerDot;
  final Color? backgroundColorCalender;
  final bool keepLineSize;
  final TextStyle? calendarTextStyle;
  final bool showNavigationArrows;
  final Color? navigationArrowColor;
  final CalendarViewMode viewMode;
  final Color? selectedDayColor;
  final Color? selectedDayTextColor;

  @override
  _AdvancedCalendarState createState() => _AdvancedCalendarState();
}

class _AdvancedCalendarState extends State<AdvancedCalendar>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<int> _monthViewCurrentPage;
  late AnimationController _animationController;
  late AdvancedCalendarController _controller;
  late double _animationValue;
  late List<ViewRange> _monthRangeList;
  late List<List<DateTime>> _weekRangeList;

  PageController? _monthPageController;
  PageController? _weekPageController;
  Offset? _captureOffset;
  DateTime? _todayDate;
  List<String>? _weekNames;

  @override
  void initState() {
    super.initState();

    final monthPageIndex = widget.preloadMonthViewAmount ~/ 2;
    _monthViewCurrentPage = ValueNotifier(monthPageIndex);
    _monthPageController = PageController(initialPage: monthPageIndex);

    final weekPageIndex = widget.preloadWeekViewAmount ~/ 2;
    _weekPageController = PageController(initialPage: weekPageIndex);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.viewMode == CalendarViewMode.month ? 1.0 : 0.0,
    );

    _animationValue = widget.viewMode == CalendarViewMode.month ? 1.0 : 0.0;

    _controller = widget.controller ?? AdvancedCalendarController.today();
    _todayDate = _controller.value;

    _monthRangeList = List.generate(
      widget.preloadMonthViewAmount,
          (index) => ViewRange.generateDates(
        _todayDate!,
        _todayDate!.month + (index - _monthPageController!.initialPage),
        widget.weeksInMonthViewAmount,
        startWeekDay: widget.startWeekDay,
      ),
    );

    _weekRangeList = _controller.value.generateWeeks(
      widget.preloadWeekViewAmount,
      startWeekDay: widget.startWeekDay,
    );

    _controller.addListener(() {
      _weekRangeList = _controller.value.generateWeeks(
        widget.preloadWeekViewAmount,
        startWeekDay: widget.startWeekDay,
      );
      if (_weekPageController != null && _weekPageController!.hasClients) {
        _weekPageController!.jumpToPage(widget.preloadWeekViewAmount ~/ 2);
      }
    });

    if (widget.startWeekDay != null && widget.startWeekDay! < 7) {
      final time = _controller.value.subtract(
        Duration(days: _controller.value.weekday - widget.startWeekDay!),
      );
      final list = List<DateTime>.generate(
        8,
            (index) => time.add(Duration(days: index * 1)),
      ).toList();
      _weekNames = List<String>.generate(7, (index) {
        return DateFormat("EEE").format(list[index]); // ✅ NEW: First 3 characters (Sun, Mon, Tue, etc.)
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _animationController.value = widget.viewMode == CalendarViewMode.month ? 1.0 : 0.0;
          _animationValue = widget.viewMode == CalendarViewMode.month ? 1.0 : 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Material(
        color: widget.backgroundColorCalender,
        child: DefaultTextStyle.merge(
          style: theme.textTheme.bodyMedium,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: _monthViewCurrentPage,
                builder: (_, value, __) {
                  return Header(
                    monthDate: _monthRangeList[_monthViewCurrentPage.value].firstDay,
                    onPressed: _handleTodayPressed,
                    dateStyle: widget.headerStyle,
                    todayStyle: widget.todayStyle,
                    showArrows: widget.showNavigationArrows,
                    onPrevMonth: _handlePrevPressed,
                    onNextMonth: _handleNextPressed,
                    arrowColor: widget.navigationArrowColor,
                  );
                },
              ),
              WeekDays(
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ),
                keepLineSize: widget.keepLineSize,
                weekNames: _weekNames != null
                    ? _weekNames!
                    : const <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'],
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (_, __) {
                  final height = widget.viewMode == CalendarViewMode.day
                      ? widget.weekLineHeight
                      : widget.weekLineHeight * widget.weeksInMonthViewAmount;

                  return SizedBox(
                    height: height,
                    child: ValueListenableBuilder<DateTime>(
                      valueListenable: _controller,
                      builder: (_, selectedDate, __) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            IgnorePointer(
                              ignoring: widget.viewMode == CalendarViewMode.day,
                              child: Opacity(
                                opacity: widget.viewMode == CalendarViewMode.month ? 1.0 : 0.0,
                                child: PageView.builder(
                                  onPageChanged: (pageIndex) {
                                    if (widget.onHorizontalDrag != null) {
                                      widget.onHorizontalDrag!(_monthRangeList[pageIndex].firstDay);
                                    }
                                    _monthViewCurrentPage.value = pageIndex;
                                  },
                                  controller: _monthPageController,
                                  physics: widget.viewMode == CalendarViewMode.month
                                      ? const AlwaysScrollableScrollPhysics()
                                      : const NeverScrollableScrollPhysics(),
                                  itemCount: _monthRangeList.length,
                                  itemBuilder: (_, pageIndex) {
                                    return MonthView(
                                      innerDot: widget.innerDot,
                                      monthView: _monthRangeList[pageIndex],
                                      todayDate: _todayDate,
                                      selectedDate: selectedDate,
                                      weekLineHeight: widget.weekLineHeight,
                                      weeksAmount: widget.weeksInMonthViewAmount,
                                      onChanged: _handleDateChanged,
                                      events: widget.events,
                                      keepLineSize: widget.keepLineSize,
                                      textStyle: widget.calendarTextStyle,
                                      selectedDayColor: widget.selectedDayColor,
                                      selectedDayTextColor: widget.selectedDayTextColor,
                                    );
                                  },
                                ),
                              ),
                            ),
                            ValueListenableBuilder<int>(
                              valueListenable: _monthViewCurrentPage,
                              builder: (_, pageIndex, __) {
                                final offset = widget.viewMode == CalendarViewMode.day
                                    ? 0.0
                                    : () {
                                  final index = selectedDate.findWeekIndex(
                                    _monthRangeList[_monthViewCurrentPage.value].dates,
                                  );
                                  return index / (widget.weeksInMonthViewAmount - 1) * 2 - 1.0;
                                }();

                                return Align(
                                  alignment: Alignment(0.0, offset),
                                  child: IgnorePointer(
                                    ignoring: widget.viewMode == CalendarViewMode.month,
                                    child: Opacity(
                                      opacity: widget.viewMode == CalendarViewMode.day ? 1.0 : 0.0,
                                      child: SizedBox(
                                        height: widget.weekLineHeight,
                                        child: PageView.builder(
                                          onPageChanged: (indexPage) {
                                            final pageIndex = _monthRangeList.indexWhere(
                                                  (index) => index.firstDay.month == _weekRangeList[indexPage].first.month,
                                            );

                                            if (widget.onHorizontalDrag != null) {
                                              widget.onHorizontalDrag!(_monthRangeList[pageIndex].firstDay);
                                            }
                                            _monthViewCurrentPage.value = pageIndex;
                                          },
                                          controller: _weekPageController,
                                          itemCount: _weekRangeList.length,
                                          physics: widget.viewMode == CalendarViewMode.day
                                              ? const AlwaysScrollableScrollPhysics()
                                              : const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return WeekView(
                                              innerDot: widget.innerDot,
                                              dates: _weekRangeList[index],
                                              selectedDate: selectedDate,
                                              lineHeight: widget.weekLineHeight,
                                              onChanged: _handleWeekDateChanged,
                                              events: widget.events,
                                              keepLineSize: widget.keepLineSize,
                                              textStyle: widget.calendarTextStyle,
                                              selectedDayColor: widget.selectedDayColor,
                                              selectedDayTextColor: widget.selectedDayTextColor,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _monthPageController!.dispose();
    _monthViewCurrentPage.dispose();

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _handleWeekDateChanged(DateTime date) {
    _handleDateChanged(date);
    _monthViewCurrentPage.value = _monthRangeList
        .lastIndexWhere((monthRange) => monthRange.dates.contains(date));
  }

  void _handleDateChanged(DateTime date) {
    _controller.value = date;
  }

  void _handleTodayPressed() {
    _controller.value = DateTime.now().toZeroTime();
    _monthPageController!.jumpToPage(widget.preloadMonthViewAmount ~/ 2);
    _weekPageController!.jumpToPage(widget.preloadWeekViewAmount ~/ 2);
  }

  void _handlePrevPressed() {
    final isMonthView = widget.viewMode == CalendarViewMode.month;

    if (isMonthView) {
      _monthPageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _weekPageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNextPressed() {
    final isMonthView = widget.viewMode == CalendarViewMode.month;

    if (isMonthView) {
      _monthPageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _weekPageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}