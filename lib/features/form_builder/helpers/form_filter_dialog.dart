/// Module: core/helper/form_builder
///
/// FILE INFO
/// File Name   : form_filter_dialog.dart
/// Description: `FormFilterDialog` widget, state and UI of the `FormFilterDialog` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Objective   : Filter dialog of the Form Builder home list (bug report #11 —
///               the Filter button did nothing because
///               `AppDialogs.filterDialog` was an empty stub). Same shape as
///               the Knowticed Admin filter dialogs: header, fields, Reset
///               (darkGrey / white) and Apply. Filters by Access Management
///               and Published Date, using the filter state HomeCubit already
///               had (`currentDropDownValue`, `currentDate`, `setFilter`,
///               `reset`).
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:knowticed_plus/core/custom/layout/custom_field_pair.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class FormFilterDialog extends StatefulWidget {
  const FormFilterDialog({super.key, required this.cubit});

  final HomeCubit cubit;

  static Future<void> show(BuildContext context, HomeCubit cubit) {
    // CHANGED 17/10/2026: opened like every Time Tracker filter — same
    // dialog manager, same 600 width.
    return CustomDialogManager.showContent<void>(
      context: context,
      width: 600,
      child: FormFilterDialog(cubit: cubit),
    );
  }

  @override
  State<FormFilterDialog> createState() => _FormFilterDialogState();
}

class _FormFilterDialogState extends State<FormFilterDialog> {
  /// The stored access-type values, one per [AccessManagement] value.
  static final List<String> _accessValues = <String>[
    for (final AccessManagement a in AccessManagement.values) a.name,
  ];

  late String? _access = widget.cubit.currentDropDownValue;
  DateTime? _date;

  /// CHANGED 17/10/2026 (Moataz: the arrow is not aligned with the
  /// calendar, the colours differ, "see the size of the buttons … in Time
  /// Tracker it's not like this"): the core CustomFilterFrame — the Time
  /// Tracker filter — with its 36-high fields (D-18) side by side on iPad,
  /// stacked on the phone, and Reset left / Apply right at one width (X-73).
  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return CustomFilterFrame(
      onReset: () {
        Navigator.of(context).pop();
        widget.cubit.resetFilters();
      },
      onApply: () {
        widget.cubit.onChangeFilterDropDownValue(_access);
        widget.cubit.onChangeDateValue(
          _date == null ? null : FormDateTimeHelper.formatDate(_date!),
        );
        Navigator.of(context).pop();
        widget.cubit.applyFilter();
      },
      rows: <Widget>[
        CustomFieldPair(
          start: CustomDropdown<String>(
            label: s.accessManagement,
            hint: s.accessManagement,
            value: _access,
            height: 36,
            itemStyle: StyleText.fontSize12Weight400,
            items: <DropdownItem<String>>[
              for (final String v in _accessValues)
                DropdownItem<String>(
                  value: v,
                  label: AccessManagementExtension.labelFor(v),
                ),
            ],
            onChanged: (String v) => setState(() => _access = v),
          ),
          end: CustomDateField(
            label: s.published_date,
            hint: s.published_date,
            height: 36,
            value: _date,
            onChanged: (DateTime? d) => setState(() => _date = d),
          ),
        ),
      ],
    );
  }
}
