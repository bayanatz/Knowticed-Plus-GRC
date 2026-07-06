part of '../calendar_date_picker2.dart';

/// Displays the days of a given month and allows choosing a day.
///
/// The days are arranged in a rectangular grid with one column for each day of
/// the week.
class _DayPicker extends StatefulWidget {
  /// Creates a day picker.
  const _DayPicker({
    required this.config,
    required this.displayedMonth,
    required this.selectedDates,
    required this.onChanged,
    required this.isHome,
    Key? key,
  }) : super(key: key);

  /// The calendar configurations
  final CalendarDatePicker2Config config;

  final bool isHome;

  /// The currently selected dates.
  ///
  /// Selected dates are highlighted in the picker.
  final List<DateTime> selectedDates;

  /// Called when the user picks a day.
  final ValueChanged<DateTime> onChanged;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<_DayPicker> {
  /// List of [FocusNode]s, one for each day of the month.
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    print('initState');
    final int daysInMonth = DateUtils.getDaysInMonth(
        widget.displayedMonth.year, widget.displayedMonth.month);
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (int index) =>
          FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  bool isDateWithinServiceRange(
      {required DateTime startDate,
      required String durationType,
      required int durationValue,
      required DateTime selectedDate}) {
    // Calculate end date based on duration type and value
    DateTime endDate;

    switch (durationType) {
      case 'hours':
        endDate = startDate.add(Duration(hours: durationValue));
        break;
      case 'days':
        endDate = startDate.add(Duration(days: durationValue));
        break;
      case 'weeks':
        endDate = startDate.add(Duration(days: durationValue * 7));
        break;
      case 'months':
        endDate = DateTime(
            startDate.year, startDate.month + durationValue, startDate.day);
        break;
      default:
        throw ArgumentError('Invalid duration type');
    }

    // Check if the selected date is between the start and end date
    return selectedDate.isAfter(startDate) && selectedDate.isBefore(endDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check to see if the focused date is in this month, if so focus it.
    final DateTime? focusedDate = _FocusedDate.maybeOf(context);
    if (focusedDate != null &&
        DateUtils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  ///
  /// ┌ Sunday is the first day of week in the US (en_US)
  /// |
  /// S M T W T F S  <-- the returned list contains these widgets
  /// _ _ _ _ _ 1 2
  /// 3 4 5 6 7 8 9
  ///
  /// ┌ But it's Monday in the UK (en_GB)
  /// |
  /// M T W T F S S  <-- the returned list contains these widgets
  /// _ _ _ _ 1 2 3
  /// 4 5 6 7 8 9 10
  ///
  List<Widget> _dayHeaders(
      TextStyle? headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    final weekdays =
        widget.config.weekdayLabels ?? localizations.narrowWeekdays;
    final firstDayOfWeek =
        widget.config.firstDayOfWeek ?? localizations.firstDayOfWeekIndex;
    assert(firstDayOfWeek >= 0 && firstDayOfWeek <= 6,
        'firstDayOfWeek must between 0 and 6');
    for (int i = firstDayOfWeek; true; i = (i + 1) % 7) {
      final String weekday = weekdays[i];
      result.add(ExcludeSemantics(
        child: Center(
          child: Text(
            weekday,
            style: widget.config.weekdayLabelTextStyle ?? headerStyle,
          ),
        ),
      ));
      if (i == (firstDayOfWeek - 1) % 7) break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    _DayPickerGridDelegate dayPickerGridDelegate =
        _DayPickerGridDelegate(isPortrait, widget.isHome);

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? headerStyle = textTheme.bodySmall?.apply(
      color: colorScheme.onSurface.withOpacity(0.60),
    );
    final TextStyle dayStyle = textTheme.bodySmall!;
    final Color enabledDayColor = colorScheme.onSurface.withOpacity(0.87);
    final Color disabledDayColor = colorScheme.onSurface.withOpacity(0.38);
    final Color selectedDayColor = colorScheme.onPrimary;
    final Color selectedDayBackground = colorScheme.primary;
    final Color todayColor = colorScheme.primary;

    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;

    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int dayOffset = getMonthFirstDayOffset(year, month,
        widget.config.firstDayOfWeek ?? localizations.firstDayOfWeekIndex);

    final List<Widget> dayItems = _dayHeaders(headerStyle, localizations);
    // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
    // a leap year.
    int day = -dayOffset;
    while (day < daysInMonth) {
      day++;
      if (day < 1) {
        dayItems.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool isDisabled = dayToBuild.isAfter(widget.config.lastDate) ||
            dayToBuild.isBefore(widget.config.firstDate) ||
            !(widget.config.selectableDayPredicate?.call(dayToBuild) ?? true);
        final bool isSelectedDay =
            widget.selectedDates.any((d) => DateUtils.isSameDay(d, dayToBuild));

        final bool isToday =
            DateUtils.isSameDay(widget.config.currentDate, dayToBuild);

        BoxDecoration? decoration;
        Color dayColor = enabledDayColor;
        if (isSelectedDay) {
          // The selected day gets a circle background highlight, and a
          // contrasting text color.
          dayColor = selectedDayColor;
          decoration = BoxDecoration(
            borderRadius: widget.config.dayBorderRadius,
            color: widget.config.selectedDayHighlightColor ??
                selectedDayBackground,
            shape: widget.config.dayBorderRadius != null
                ? BoxShape.rectangle
                : BoxShape.circle,
          );
        } else if (isDisabled) {
          dayColor = disabledDayColor;
        } else if (isToday) {
          // The current day gets a different text color and a circle stroke
          // border.
          dayColor = widget.config.selectedDayHighlightColor ?? todayColor;
          decoration = BoxDecoration(
            borderRadius: widget.config.dayBorderRadius,
            border: Border.all(color: dayColor),
            shape: widget.config.dayBorderRadius != null
                ? BoxShape.rectangle
                : BoxShape.circle,
          );
        }

        var customDayTextStyle =
            widget.config.dayTextStylePredicate?.call(date: dayToBuild) ??
                widget.config.dayTextStyle;

        if (isToday && widget.config.todayTextStyle != null) {
          customDayTextStyle = widget.config.todayTextStyle;
        }

        if (isDisabled) {
          customDayTextStyle = customDayTextStyle?.copyWith(
            color: disabledDayColor,
            fontWeight: FontWeight.normal,
          );
          if (widget.config.disabledDayTextStyle != null) {
            customDayTextStyle = widget.config.disabledDayTextStyle;
          }
        }

        final isFullySelectedRangePicker =
            widget.config.calendarType == CalendarDatePicker2Type.range &&
                widget.selectedDates.length == 2;
        var isDateInBetweenRangePickerSelectedDates = false;

        if (isFullySelectedRangePicker) {
          final startDate = DateUtils.dateOnly(widget.selectedDates[0]);
          final endDate = DateUtils.dateOnly(widget.selectedDates[1]);

          isDateInBetweenRangePickerSelectedDates =
              !(dayToBuild.isBefore(startDate) ||
                      dayToBuild.isAfter(endDate)) &&
                  !DateUtils.isSameDay(startDate, endDate);
        }

        if (isDateInBetweenRangePickerSelectedDates &&
            widget.config.selectedRangeDayTextStyle != null) {
          customDayTextStyle = widget.config.selectedRangeDayTextStyle;
        }

        if (isSelectedDay) {
          customDayTextStyle = widget.config.selectedDayTextStyle;
        }

        final dayTextStyle =
            customDayTextStyle ?? dayStyle.apply(color: dayColor);

        Widget dayWidget = widget.config.dayBuilder?.call(
              date: dayToBuild,
              textStyle: dayTextStyle,
              decoration: decoration,
              isSelected: isSelectedDay,
              isDisabled: isDisabled,
              isToday: isToday,
            ) ??
            _buildDefaultDayWidgetContent(
              decoration,
              localizations,
              day,
              dayTextStyle,
              isPortrait,
              widget.isHome,
              isToday,
              isSelectedDay,
            );

        if (isDateInBetweenRangePickerSelectedDates) {
          final rangePickerIncludedDayDecoration = BoxDecoration(
            color: widget.config.selectedRangeHighlightColor ??
                (widget.config.selectedDayHighlightColor ??
                        selectedDayBackground)
                    .withOpacity(0.15),
          );

          if (DateUtils.isSameDay(
            DateUtils.dateOnly(widget.selectedDates[0]),
            dayToBuild,
          )) {
            dayWidget = Stack(
              children: [
                Row(children: [
                  const Spacer(),
                  Expanded(
                    child: Container(
                      decoration: rangePickerIncludedDayDecoration,
                    ),
                  ),
                ]),
                dayWidget,
              ],
            );
          } else if (DateUtils.isSameDay(
            DateUtils.dateOnly(widget.selectedDates[1]),
            dayToBuild,
          )) {
            dayWidget = Stack(
              children: [
                Row(children: [
                  Expanded(
                    child: Container(
                      decoration: rangePickerIncludedDayDecoration,
                    ),
                  ),
                  const Spacer(),
                ]),
                dayWidget,
              ],
            );
          } else {
            dayWidget = Stack(
              children: [
                Container(
                  decoration: rangePickerIncludedDayDecoration,
                ),
                dayWidget,
              ],
            );
          }
        }

        dayWidget = Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: dayWidget,
        );

        if (isDisabled) {
          dayWidget = ExcludeSemantics(
            child: dayWidget,
          );
        } else {
          dayWidget = InkResponse(
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            hoverColor: Colors.transparent,
            focusNode: _dayFocusNodes[day - 1],
            onTap: () => widget.onChanged(dayToBuild),
            radius: _dayPickerRowHeight / 2 + 4,
            splashColor: selectedDayBackground.withOpacity(0.38),
            child: Semantics(
              // We want the day of month to be spoken first irrespective of the
              // locale-specific preferences or TextDirection. This is because
              // an accessibility user is more likely to be interested in the
              // day of month before the rest of the date, as they are looking
              // for the day of month. To do that we prepend day of month to the
              // formatted full date.
              label:
                  '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
              selected: isSelectedDay,
              excludeSemantics: true,
              child: dayWidget,
            ),
          );
        }

        dayItems.add(dayWidget);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _monthPickerHorizontalPadding,
      ),
      child: GridView.custom(
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        gridDelegate: dayPickerGridDelegate,
        childrenDelegate: SliverChildListDelegate(
          dayItems,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }

//  TaskController taskController = Get.put(TaskController());

  Widget _buildDefaultDayWidgetContent(
    BoxDecoration? decoration,
    MaterialLocalizations localizations,
    int day,
    TextStyle dayTextStyle,
    bool isPortrait,
    bool isHome,
    bool isToday,
    bool isSelected,
  ) {


    final DateTime currentDate =
        DateTime(widget.displayedMonth.year, widget.displayedMonth.month, day);

    // Lists of dates to check
    final bool hasTodoItems =
        Get.find<ScheduleController>().isDayHasToDo(currentDate);

    final bool hasInviteEvents =
        Get.find<ScheduleController>().isDayHasEvent(currentDate);

    final bool hasRequestedServices =
        Get.find<ScheduleController>().isDayHasRequestServices(currentDate);

    final bool hasCards = Get.find<ScheduleController>().isDayHasTasks(
      selectedDate: currentDate,
      memberId: Get.find<EmployeeController>().employee!.email!.last!,
    );

// Assume selectedDate is a DateTime object representing the selected date
    final DateTime? selectedDate =
        widget.selectedDates.isNotEmpty ? widget.selectedDates.first : null;
    bool isLargeTablet = MediaQuery.of(context).size.width >= 1024;

    // default marker
    return Container(
      height: 35.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isToday
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              color: isSelected
                  ? AppColors.primary
                  : Colors.transparent,
            ),
            child: Container(
          //   color: Colors.green,
              child: Text(
                Get.locale.toString().contains('en')
                    ? localizations.formatDecimal(day)
                    : convertNumberToArabic(day.toString()),
                style:dayTextStyle.copyWith(height:1.45),
              ),
            ),
          ),
          if (isHome && selectedDate != currentDate)

             Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasInviteEvents == true) _buildDot(AppColors.unBlock),
                  if (hasTodoItems == true) _buildDot(AppColors.warning),
                  if (hasCards == true) _buildDot(AppColors.primary),
                  if (hasRequestedServices == true)
                    _buildDot(const Color(0xFF73A2FF)),
                ],

            ),
        ],
      ),
    );
  }
 // dot marker
  Widget _buildDot(Color color) {
    return Padding(
      padding: EdgeInsets.only(top: 0.002.w,bottom: 0.002.w),
      child: Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  final bool isPortrait;
  final bool isHome;

  _DayPickerGridDelegate(this.isPortrait, this.isHome);

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = math.max(32.w,constraints.crossAxisExtent / columnCount);

    // Adjust height based on the isPortrait flag
    final double tileHeight = 32.w ;/* math.min(
      _dayPickerRowHeight,
      constraints.viewportMainAxisExtent /
          (_maxDayPickerRowCount + .2), // Modify calculation
    );*/

    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight + (isHome == false ? (isPortrait ? 8 : 9) : 0),
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) =>
      isPortrait != oldDelegate.isPortrait;
}
