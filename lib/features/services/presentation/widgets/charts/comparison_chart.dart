/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: comparison_chart.dart
/// Purpose: The Admin Dashboard's monthly cancelled vs rejected chart, with
///          a department picker on phones. The numbers come from the cubit
///          (cancelledByMonth / rejectedByMonth); this widget only keeps the
///          chosen department.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): no longer downloads every request itself, or
///     again for each department picked (Dashboards rule 2, SVC-DASH-15);
///     month names from intl (rule 7); one file (the part file is gone).
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/charts/vertical_bar_chart_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [MonthlyComparisonChart]
///
/// Purpose: Cancelled and rejected requests per month.
class MonthlyComparisonChart extends StatefulWidget {
  const MonthlyComparisonChart({
    super.key,
    required this.lightMode,
    required this.cancelledByMonth,
    required this.rejectedByMonth,
  });

  final bool lightMode;

  /// 12 values per department English name; '' is every department.
  final Map<String, List<int>> cancelledByMonth;
  final Map<String, List<int>> rejectedByMonth;

  @override
  State<MonthlyComparisonChart> createState() => _MonthlyComparisonChartState();
}

class _MonthlyComparisonChartState extends State<MonthlyComparisonChart> {
  /// The picked department id; '' is every department.
  String _departmentId = '';

  @override
  Widget build(BuildContext context) {
    final departments = context.read<MainCoreDepartmentCubit>();
    final isMobile = ContextExtension(context).isPhone;

    final key = _departmentId.isEmpty
        ? ''
        : departments.getEnglishDepartmentNameFromDepartmentId(
              departmentId: _departmentId,
            ) ??
            '';
    List<double> series(Map<String, List<int>> byDepartment) =>
        (byDepartment[key] ?? List.filled(12, 0))
            .map((v) => v.toDouble())
            .toList();

    return CustomVerticalBarChartWidget(
      title: S.of(context).monthlyComparison,
      iconAsset:
          'assets/icons_assets/main_icons_assets/ic_module_support_headset.svg',
      labels: List.generate(12, (i) => context.svcMonthShort(i + 1)),
      values: series(widget.cancelledByMonth),
      secondaryValues: series(widget.rejectedByMonth),
      legendLabel: S.of(context).Canceled,
      secondaryLegendLabel: S.of(context).Rejected,
      barColor: AppColors.orange,
      secondaryBarColor: AppColors.block,
      height: isMobile ? 385 : 330,
      lightMode: widget.lightMode,
      backgroundColor: AppColors.card,
      // QA p.43: the department picker spans the card on phones.
      headerWidget: isMobile
          ? SizedBox(
              width: double.infinity,
              child: CustomDropdown<String>(
                value: _departmentId,
                items: [
                  DropdownItem<String>(
                    value: '',
                    label: S.of(context).all_departments,
                  ),
                  for (final id in departments.departmentIds)
                    DropdownItem<String>(
                      value: id,
                      label: context.svcPick(
                        departments.getEnglishDepartmentNameFromDepartmentId(
                          departmentId: id,
                        ),
                        departments.getArabicDepartmentNameFromDepartmentId(
                          departmentId: id,
                        ),
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _departmentId = value),
                hint: S.of(context).selectDepartment,
                hintStyle: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
                label: S.of(context).department,
              ),
            )
          : null,
    );
  }
}
