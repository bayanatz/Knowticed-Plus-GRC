part of 'widget.dart';

class WeekView extends StatelessWidget {
  WeekView({
    Key? key,
    required this.dates,
    required this.selectedDate,
    required this.lineHeight,
    this.highlightMonth,
    this.onChanged,
    this.events,
    required this.innerDot,
    required this.keepLineSize,
    this.textStyle,
    this.selectedDayColor,
    this.selectedDayTextColor,
  }) : super(key: key);

  final DateTime todayDate = DateTime.now().toZeroTime();
  final List<DateTime> dates;
  final double lineHeight;
  final int? highlightMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onChanged;
  final dynamic events;
  final bool innerDot;
  final bool keepLineSize;
  final TextStyle? textStyle;
  final Color? selectedDayColor;
  final Color? selectedDayTextColor;

  // ✅ Helper method to convert numbers to Arabic-Indic numerals
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
    final theme = Theme.of(context);
    return SizedBox(
      height: lineHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List<Widget>.generate(
          7,
              (dayIndex) {
            final date = dates[dayIndex];
            final isToday = date.isAtSameMomentAs(todayDate);
            final isSelected = date.isAtSameMomentAs(selectedDate);
            final isHighlight = highlightMonth == date.month;

            // Get events for this date with support for custom event objects
            List<dynamic> dateEvents = [];
            if (events != null) {
              if (events is List<DateTime>) {
                dateEvents = (events as List<DateTime>)
                    .where((element) => element.isSameDate(date))
                    .toList();
              } else if (events is List) {
                dateEvents = (events as List)
                    .where((element) {
                  if (element is Map && element['date'] != null) {
                    final eventDate = element['date'] as DateTime;
                    return eventDate.isSameDate(date);
                  } else if (element is DateTime) {
                    return element.isSameDate(date);
                  }
                  return false;
                })
                    .toList();
              }
            }
            final hasEvent = dateEvents.isNotEmpty;

            if (keepLineSize) {
              return Expanded(
                child: InkResponse(
                  onTap: onChanged != null ? () => onChanged!(date) : null,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (selectedDayColor ?? theme.primaryColor)
                          : isToday
                          ? AppColors.primary
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _toArabicNumber(date.day, context), // ✅ CHANGED: Use Arabic numbers
                          style: textStyle?.copyWith(
                            fontSize: 16,
                            color: isSelected
                                ? (selectedDayTextColor ?? theme.colorScheme.onPrimary)
                                : isToday
                                ? AppColors.textButton
                                : isHighlight || highlightMonth == null
                                ? Colors.black87
                                : Colors.black.withOpacity(0.25),
                            fontWeight:
                            isSelected && textStyle?.fontWeight != null
                                ? FontWeight
                                .values[textStyle!.fontWeight!.index + 2]
                                : FontWeight.w500,
                          ),
                        ),
                        if (hasEvent)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: SizedBox(
                              width: 28,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 2,
                                runSpacing: 1,
                                children: List.generate(
                                  dateEvents.length,
                                      (index) {
                                    Color dotColor = isSelected
                                        ? (selectedDayTextColor ?? theme.colorScheme.onPrimary)
                                        : theme.colorScheme.secondary;

                                    if (dateEvents[index] is Map &&
                                        dateEvents[index]['color'] != null) {
                                      dotColor = dateEvents[index]['color'] as Color;
                                    }

                                    return Container(
                                      height: 2,
                                      width: 2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(1),
                                        color: dotColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DateBox(
                  width: innerDot ? 32 : 24,
                  height: innerDot ? 32 : 24,
                  showDot: innerDot,
                  onPressed: onChanged != null ? () => onChanged!(date) : null,
                  isSelected: isSelected,
                  isToday: isToday,
                  hasEvent: hasEvent,
                  selectedDayColor: selectedDayColor,
                  selectedDayTextColor: selectedDayTextColor,
                  child: Text(
                    _toArabicNumber(date.day, context), // ✅ CHANGED: Use Arabic numbers
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? (selectedDayTextColor ?? theme.colorScheme.onPrimary)
                          : isToday
                          ? AppColors.textButton
                          : isHighlight || highlightMonth == null
                          ? Colors.black87
                          : Colors.black.withOpacity(0.6),
                    ),
                  ),
                ),
                if (!innerDot && hasEvent)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SizedBox(
                      width: 28,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 2,
                        runSpacing: 1,
                        children: List.generate(
                          dateEvents.length,
                              (index) {
                            Color dotColor = theme.primaryColor;

                            if (dateEvents[index] is Map &&
                                dateEvents[index]['color'] != null) {
                              dotColor = dateEvents[index]['color'] as Color;
                            }

                            return Container(
                              height: 6,
                              width: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(1),
                                color: dotColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          growable: false,
        ),
      ),
    );
  }
}