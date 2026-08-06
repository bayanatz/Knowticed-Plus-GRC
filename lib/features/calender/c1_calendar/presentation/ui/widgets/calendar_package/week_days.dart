part of './widget.dart';

/// Week day names line.
class WeekDays extends StatelessWidget {
  const WeekDays({
    Key? key,
    this.weekNames = const <String>['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.style,
    required this.keepLineSize,
  })  : assert(weekNames.length == 7, '`weekNames` must have length 7'),
        super(key: key);

  /// Week day names.
  final List<String> weekNames;

  /// Text style.
  final TextStyle? style;

  final bool keepLineSize;

  /// Get abbreviated day name based on available width
  String _getAbbreviatedName(String fullName, bool isArabic, bool useShort) {
    if (!useShort) return fullName;

    if (isArabic) {
      // Arabic single letter abbreviations
      final arabicShortNames = {
        'الأحد': 'ح',
        'الاثنين': 'ن',
        'الثلاثاء': 'ث',
        'الأربعاء': 'ع',
        'الخميس': 'خ',
        'الجمعة': 'ج',
        'السبت': 'س',
      };
      return arabicShortNames[fullName] ?? fullName.substring(0, 1);
    } else {
      // English 3-letter abbreviations
      return fullName.length > 3 ? fullName.substring(0, 3) : fullName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we should use short names based on available width
        final bool useShortNames = constraints.maxWidth < 350;

        // Check if current locale is Arabic
        final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

        return DefaultTextStyle(
          style: style!,
          child: Padding(
            padding: const EdgeInsets.only(top: 0.0, bottom: 0, right: 0, left: 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(weekNames.length, (index) {
                return Expanded(
                  child: Center(
                    child: Text(
                      _getAbbreviatedName(weekNames[index], isArabic, useShortNames),
                      style: style,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
