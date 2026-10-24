enum LateUnitEnum {
  hour,
  day,
  week,
  month;

  String get value {
    switch (this) {
      case LateUnitEnum.hour:
        return 'ساعة';
      case LateUnitEnum.day:
        return 'يوم';
      case LateUnitEnum.week:
        return 'أسبوع';
      case LateUnitEnum.month:
        return 'شهر';
    }
  }

  Duration subtractValue(int multiplier) {
    switch (this) {
      case LateUnitEnum.hour:
        return Duration(hours: 1 * multiplier);
      case LateUnitEnum.day:
        return Duration(days: 1 * multiplier);
      case LateUnitEnum.week:
        return Duration(days: 7 * multiplier);
      case LateUnitEnum.month:
        return Duration(days: 30 * multiplier);
    }
  }
}
