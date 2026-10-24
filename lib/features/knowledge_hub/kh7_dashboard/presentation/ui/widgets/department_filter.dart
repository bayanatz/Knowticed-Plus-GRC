/// Module: knowledge_hub/kh7_dashboard/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: department_filter.dart
/// Description: Multi-select department filter on the Dashboard screen.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';

/// Item value of the "All" entry in the department list.
const String kAllDepartments = 'all';

/// [departmentNamesEn] / [departmentNamesAr] map department id -> name.
/// [onChanged] receives department ids; an empty list means all departments.
class DashboardDepartmentFilter extends StatelessWidget {
  const DashboardDepartmentFilter({
    super.key,
    required this.departmentNamesEn,
    required this.departmentNamesAr,
    required this.selectedDepartmentIds,
    required this.onChanged,
  });

  final Map<String, String> departmentNamesEn;
  final Map<String, String> departmentNamesAr;
  final List<String> selectedDepartmentIds;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<String> ids = departmentNamesEn.keys.toList();
    final Map<String, String> labels = {
      kAllDepartments: S.of(context).all,
      for (final String id in ids)
        id: KhLocale.pick(
          context,
          en: FormatHelper.capitalize(departmentNamesEn[id] ?? id),
          ar: departmentNamesAr[id] ?? '',
        ),
    };
    final bool allSelected =
        ids.isNotEmpty && selectedDepartmentIds.length == ids.length;

    final String displayText = selectedDepartmentIds.isEmpty
        ? S.of(context).select_department
        : selectedDepartmentIds.length == 1
        ? (labels[selectedDepartmentIds.first] ?? '')
        : '${KhLocale.digits(context, selectedDepartmentIds.length)} ${S.of(context).selected}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: ContextExtension(context).isPhone ? 200.w : 300.w,
          child: CustomMultiSelectFilter<String>(
            values: List<String>.from([
              if (allSelected) kAllDepartments,
              ...selectedDepartmentIds,
            ]),
            items: [
              for (final String i in [kAllDepartments, ...ids])
                MultiSelectDropdownItem<String>(
                  value: i,
                  label: (labels)[i] ?? i,
                ),
            ],
            onChanged: multiSelectToggleBridge(
              List<String>.from([
                if (allSelected) kAllDepartments,
                ...selectedDepartmentIds,
              ]),
              (String item) => ((dynamic item) {
                if (item == kAllDepartments) {
                  onChanged(allSelected ? <String>[] : List<String>.from(ids));
                  return;
                }
                final List<String> updated = List<String>.from(
                  selectedDepartmentIds,
                );
                if (!updated.remove(item)) updated.add(item as String);
                onChanged(updated);
              })(item),
            ),
            hint: (displayText),
            height: 36,
            fillColor: AppColors.card,
          ),
        ),
      ],
    );
  }
}
