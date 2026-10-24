/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: department_filter_chips_widget.dart
/// Purpose: The owning-department chips of the "Service requests" page.
///          Chips are keyed by department id; labels come from the
///          department directory in the reader's language.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/data/department_count_model.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/request_services_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class DepartmentFilterChipsWidget extends StatelessWidget {
  /// Selected department id, or [RequestServicesCubit.allDepartments].
  final String selectedDepartment;

  /// Number of services per department id.
  final DepartmentCountModel departmentCounts;
  final ValueChanged<String> onDepartmentChanged;

  const DepartmentFilterChipsWidget({
    required this.selectedDepartment,
    required this.departmentCounts,
    required this.onDepartmentChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StatusChipFilter(
      selectedKey: selectedDepartment,
      onSelected: onDepartmentChanged,
      items: [
        StatusChipItem(
          key: RequestServicesCubit.allDepartments,
          label: FormatHelper.capitalize(S.of(context).all),
          count: departmentCounts.total,
        ),
        for (final entry in departmentCounts.departmentCounts.entries)
          StatusChipItem(
            key: entry.key,
            label: FormatHelper.capitalize(
              context.svcDepartmentName(entry.key),
            ),
            count: entry.value,
          ),
      ],
    );
  }
}
