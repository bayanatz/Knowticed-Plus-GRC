/// Module: services / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: service_duration_unit.dart
/// Purpose: The fixed set of duration units a service can be measured in,
///          and the one parser that turns a stored unit (English or Arabic,
///          singular or plural) into that set.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

/// The unit a service duration is stored in.
enum ServiceDurationUnit {
  second,
  minute,
  hour,
  day,
  week,
  month,
  year;

  /// Abbreviations found on older records (H13: moved here from the
  /// service grid card so there is one unit parser).
  static const Map<String, ServiceDurationUnit> _shortForms = {
    's': second,
    'sec': second,
    'secs': second,
    'm': minute,
    'min': minute,
    'mins': minute,
    'h': hour,
    'hr': hour,
    'hrs': hour,
    'd': day,
    'w': week,
    'wk': week,
    'wks': week,
    'mo': month,
    'y': year,
    'yr': year,
    'yrs': year,
  };

  /// The key saved on a service for this unit (`minutes`, `hours`, `days`,
  /// `weeks`, …). Services store this key; the text search in [parse] is
  /// kept only for records saved before the key was used.
  String get key => '${name}s';

  /// Function Name: [fromKey]
  ///
  /// Purpose: The unit whose saved [key] is [raw], read directly.
  ///
  /// Parameters:
  /// - [raw]: the saved key.
  ///
  /// Returns: the unit, or `null` when [raw] is not a key.
  static ServiceDurationUnit? fromKey(String? raw) {
    final k = (raw ?? '').trim().toLowerCase();
    for (final unit in values) {
      if (unit.key == k) return unit;
    }
    return null;
  }

  /// Function Name: [normalizeKey]
  ///
  /// Purpose: The key to SAVE for any stored or typed unit (old Arabic text,
  /// abbreviations, singular forms); unknown text is kept as it is.
  static String normalizeKey(String? raw) => parse(raw)?.key ?? (raw ?? '');

  /// Function Name: [parse]
  ///
  /// Purpose: Reads a stored unit: the saved [key] directly, otherwise (old
  /// records only) text such as `Day`, `يوم` or `أسابيع`.
  ///
  /// Parameters:
  /// - [raw]: the unit as saved on the service.
  ///
  /// Returns: the matching unit, or `null` when the text is not a known unit.
  static ServiceDurationUnit? parse(String? raw) {
    final byKey = fromKey(raw);
    if (byKey != null) return byKey;

    // Old records: free text in either language.
    final u = (raw ?? '').trim().toLowerCase();
    if (u.isEmpty) return null;
    final short = _shortForms[u];
    if (short != null) return short;
    if (u.startsWith('second') || u.contains('ثاني')) return second;
    if (u.startsWith('minute') || u.contains('دقيق') || u.contains('دقائق')) {
      return minute;
    }
    if (u.startsWith('hour') || u.contains('ساع')) return hour;
    if (u.startsWith('day') || u.contains('يوم') || u.contains('أيام')) {
      return day;
    }
    if (u.startsWith('week') || u.contains('أسبوع') || u.contains('أسابيع')) {
      return week;
    }
    if (u.startsWith('month') || u.contains('شهر') || u.contains('أشهر')) {
      return month;
    }
    if (u.startsWith('year') || u.contains('سنة') || u.contains('سنوات')) {
      return year;
    }
    return null;
  }

  /// How many hours one of this unit counts as (a month is 730 hours, a
  /// year 8,760), used by every dashboard total.
  double get hours {
    switch (this) {
      case ServiceDurationUnit.second:
        return 1 / 3600;
      case ServiceDurationUnit.minute:
        return 1 / 60;
      case ServiceDurationUnit.hour:
        return 1;
      case ServiceDurationUnit.day:
        return 24;
      case ServiceDurationUnit.week:
        return 168;
      case ServiceDurationUnit.month:
        return 730;
      case ServiceDurationUnit.year:
        return 8760;
    }
  }
}
