/// Module: core/custom/pickers
/// Description: Date range as two fields — From and To — with "To is not
///              before From" validation; side by side on the iPad, stacked on
///              the phone. MOVED 17/10/2026 from the Time Tracker
///              (CustomDateRangeFields). Moataz: "use what we did in the time
///              tracker". For a one-slot toolbar filter use
///              CustomRangeCalendar instead.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/layout/custom_field_pair.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/helper/localized_date.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// From Date · To Date, side by side; "To" before "From" shows the error
/// under To (the caller disables Apply through [isValid]).
class CustomDateRangeFields extends StatelessWidget {
  const CustomDateRangeFields({
    super.key,
    required this.from,
    required this.to,
    required this.onFrom,
    required this.onTo,
  });

  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime?> onFrom;
  final ValueChanged<DateTime?> onTo;

  /// Function Name: [isValid]
  ///
  /// Purpose: To is not before From (either may be empty).
  ///
  /// Return type: [bool]
  static bool isValid(DateTime? from, DateTime? to) =>
      from == null ||
      to == null ||
      !DateTime(to.year, to.month, to.day)
          .isBefore(DateTime(from.year, from.month, from.day));

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    Widget field(
            String label, DateTime? value, ValueChanged<DateTime?> onChanged,
            {String? error}) =>
        CustomDateField(
          label: label,
          hint: s.chooseDate,
          value: value,
          height: 36,
          errorText: error,
          dateFormatter: (DateTime d) => LocalizedDate.of(context, d),
          onChanged: onChanged,
        );
    return CustomFieldPair(
      start: field(s.timeTrackerDateFrom, from, onFrom),
      end: field(s.timeTrackerDateTo, to, onTo,
          error: isValid(from, to) ? null : s.timeTrackerDateRangeError),
    );
  }
}
