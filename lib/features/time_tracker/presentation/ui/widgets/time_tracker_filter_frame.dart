/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_filter_frame.dart
/// Purpose: Declares the module's ONE filter-popup pattern: `TtFilterFrame`
///          (header · rows of fields · Reset / Apply), `TtFilterDropdown`
///          (a labelled "All"-first dropdown) and `CustomDateRangeFields`
///          (From Date – To Date with its validation).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — owner finding 13:45 #3: "the
///            same professional pattern" for the Requests, Approvals and
///            Attendance filters)
///
/// House rules: filters are compact dropdowns (values text only), dependent
/// fields ordered parent → child, fields side by side top-aligned (an error
/// never misaligns the row), field title 14 / value 12, validation = red
/// text under the field with Apply disabled (grey) while invalid; Reset grey
/// on the start side, Apply yellow on the end side (Cancel-left / Save-right
/// rule). Haptics: Reset LOW, Apply MEDIUM (core button). Scale-in (dialog
/// animation standard).
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Header "Filter", the field [rows] (each a `CustomFieldPair` or a single field),
/// then Reset (start) · Apply (end).
// MOVED 17/10/2026 to core (custom_filter_frame.dart) — Form Builder
// and every other module use the same filter pop-up now.
typedef TtFilterFrame = CustomFilterFrame;

/// A labelled dropdown whose first entry is "All" (= null).
class TtFilterDropdown<T> extends StatelessWidget {
  const TtFilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;

  /// (value, text) in display order.
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return CustomDropdown<T?>(
      label: label,
      hint: s.timeTrackerAll,
      height: 36,
      itemStyle: StyleText.fontSize12Weight400,
      value: value,
      items: <DropdownItem<T?>>[
        DropdownItem<T?>(value: null, label: s.timeTrackerAll),
        for (final (T v, String text) in items)
          DropdownItem<T?>(value: v, label: text),
      ],
      onChanged: (T? v) {
        HapticController.low();
        onChanged(v);
      },
    );
  }
}

/// 13/10/2026 (owner): a MULTI-select filter field (core
/// `CustomMultiSelectFilter`) — nothing picked reads "All"; one pick shows
/// its name; several read "Label (3)" (never a cut-off list).
class TtFilterMultiDropdown<T> extends StatelessWidget {
  const TtFilterMultiDropdown({
    super.key,
    required this.label,
    required this.values,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final Set<T> values;

  /// (value, text) in display order.
  final List<(T, String)> items;
  final ValueChanged<Set<T>> onChanged;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return CustomMultiSelectFilter<T>(
      label: label,
      hint: s.timeTrackerAll,
      // Same grey field as the single-choice filters beside it.
      fillColor: kDropdownFillColor,
      height: 36,
      heightSizesWholeTrigger: true,
      // Same hint colour as the single-choice dropdowns beside it.
      hintStyle:
          StyleText.fontSize12Weight400.copyWith(color: kDropdownHintColor),
      itemStyle: StyleText.fontSize12Weight400,
      values: <T>[
        for (final (T v, String _) in items)
          if (values.contains(v)) v
      ],
      items: <MultiSelectDropdownItem<T>>[
        for (final (T v, String text) in items)
          MultiSelectDropdownItem<T>(value: v, label: text),
      ],
      selectedTextBuilder: (List<MultiSelectDropdownItem<T>> picked) =>
          picked.length == 1
              ? picked.single.label
              : '$label (${picked.length})',
      onChanged: (List<T> v) {
        HapticController.low();
        onChanged(v.toSet());
      },
    );
  }
}

/// MOVED 13/10/2026 from the HR dashboard (owner: every Department filter is
/// multi-select): a toolbar multi-select — toolbar height + radius, card
/// fill; "Department (2)" when several are picked; nothing picked = all.
class TtToolbarMultiFilter extends StatelessWidget {
  const TtToolbarMultiFilter({
    super.key,
    required this.hint,
    required this.values,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final Set<String> values;

  /// Id → name.
  final Map<String, String> items;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomMultiSelectFilter<String>(
      hint: hint,
      height: TtToolbar.height,
      heightSizesWholeTrigger: true,
      borderRadius: TtToolbar.radius,
      // 13/10/2026 (owner): the same corners and hint colour as the other
      // toolbar dropdowns (Employee, Year).
      triggerBorderRadius: TtToolbar.radius,
      hintStyle:
          StyleText.fontSize12Weight400.copyWith(color: kDropdownHintColor),
      valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      fillColor: AppColors.card,
      itemStyle: StyleText.fontSize12Weight400,
      values: <String>[
        for (final String v in values)
          if (items.containsKey(v)) v
      ],
      items: <MultiSelectDropdownItem<String>>[
        for (final MapEntry<String, String> e in items.entries)
          MultiSelectDropdownItem<String>(value: e.key, label: e.value),
      ],
      selectedTextBuilder: (List<MultiSelectDropdownItem<String>> picked) =>
          picked.length == 1 ? picked.single.label : '$hint (${picked.length})',
      onChanged: (List<String> v) {
        HapticController.low();
        onChanged(v.toSet());
      },
    );
  }
}
