part of './widget.dart';

/// Unit of calendar.
class DateBox extends StatelessWidget {
  const DateBox({
    Key? key,
    required this.child,
    this.color,
    this.width = 24.0,
    this.height = 24.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.onPressed,
    this.showDot = false,
    this.isSelected = false,
    this.isToday = false,
    this.hasEvent = false,
    this.selectedDayColor,
    this.selectedDayTextColor,
  }) : super(key: key);

  final Widget child;
  final Color? color;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback? onPressed;
  final bool showDot;
  final bool isToday;
  final bool isSelected;
  final bool hasEvent;
  final Color? selectedDayColor;
  final Color? selectedDayTextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UnconstrainedBox(
      alignment: Alignment.center,
      child: InkResponse(
        onTap: onPressed,
        radius: 16.0,
        borderRadius: borderRadius,
        highlightShape: BoxShape.rectangle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (selectedDayColor ?? theme.primaryColor)
                : isToday
                ? AppColors.primary  // ✅ CHANGED: Use AppColors.primary instead of theme.highlightColor
                : null,
            borderRadius: borderRadius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child,
              if (showDot && hasEvent)
                Container(
                  margin: const EdgeInsets.all(2.0),
                  height: 4,
                  width: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? (selectedDayTextColor ?? theme.colorScheme.onPrimary)
                        : isToday
                        ? AppColors.textButton  // ✅ CHANGED: Use AppColors.textButton for today's dot
                        : theme.colorScheme.secondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}