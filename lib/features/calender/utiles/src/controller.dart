import 'package:flutter/widgets.dart';

import 'package:demo_app/features/calender/utiles/src/datetime_util.dart';

/// Advanced Calendar controller that manage selection date state.
class AdvancedCalendarController extends ValueNotifier<DateTime> {
  /// Generates controller with custom date selected.
  AdvancedCalendarController(DateTime value) : super(value);

  /// Generates controller with today date selected.
  AdvancedCalendarController.today() : this(DateTime.now().toZeroTime());

  @override
  set value(DateTime newValue) => super.value = newValue.toZeroTime();
}
