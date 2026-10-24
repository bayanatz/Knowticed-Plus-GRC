enum TimeFilter {
  all,
  month,
  quarter,
  year;

  String get label {
    switch (this) {
      case TimeFilter.all:
        return 'الكل';
      case TimeFilter.month:
        return 'الشهر';
      case TimeFilter.quarter:
        return 'الربع';
      case TimeFilter.year:
        return 'السنة';
    }
  }
}
