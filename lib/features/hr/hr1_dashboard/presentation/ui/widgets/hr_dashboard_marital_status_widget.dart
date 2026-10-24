// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_marital_status_widget.dart
// Purpose: Displays the employee marital-status distribution chart.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/hr/helpers/constants/hr_assets.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/hr/domain/entities/hr_dashboard_distribution_item.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/hr_fields/add_employee_marital_status_option.dart';
import 'package:knowticed_plus/features/hr/hr1_dashboard/presentation/controller/controller/hr_dashboard_cubit.dart';

class HRDashboardMaritalStatusWidget extends StatelessWidget {
  const HRDashboardMaritalStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();
    final data = state.demographicsData;
    final localization = S.of(context);
    return DonutChartCard(
      title: FormatHelper.capitalize(localization.maritalStatus),
      dotIcon: HRAssets.dashboardMaritalStatus,
      centerValue: data.filteredEmployeeTotal.toString(),
      centerLabel: FormatHelper.capitalize(localization.total),
      sections: [
        for (final item in data.maritalStatusDistribution)
          _chartData(item, localization),
      ],
    );
  }

  /// Method Name: [_chartData]
  ///
  /// Purpose: Converts an enum-backed marital-status item into chart data.
  ///
  /// Parameters:
  /// - [item]: Marital-status distribution item from the calculator.
  /// - [localization]: Current application localization.
  ///
  /// Returns: A localized and color-configured chart data item.
  ChartData _chartData(
    HrDashboardDistributionItem item,
    S localization,
  ) {
    final status = _statusFromCategory(item.category);
    final label = switch (status) {
      MaritalStatusOption.single => localization.single,
      MaritalStatusOption.married => localization.married,
      MaritalStatusOption.divorced => localization.divorced,
      MaritalStatusOption.widowed => localization.widowed,
      null => item.category,
    };
    final color = switch (status) {
      MaritalStatusOption.single => AppColors.primary,
      MaritalStatusOption.married => AppColors.greyDark,
      MaritalStatusOption.divorced => AppColors.disabledGrey,
      MaritalStatusOption.widowed => AppColors.grey,
      null => AppColors.grey,
    };

    return ChartData(
      label: FormatHelper.capitalize(label),
      value: item.count.toDouble(),
      color: color,
    );
  }

  /// Method Name: [_statusFromCategory]
  ///
  /// Purpose: Resolves a dashboard category to its marital-status enum.
  ///
  /// Parameters:
  /// - [category]: Stored enum category name.
  ///
  /// Returns: The matching marital-status option, or null for an unexpected category.
  MaritalStatusOption? _statusFromCategory(String category) {
    for (final option in MaritalStatusOption.values) {
      if (option.name == category) return option;
    }
    return null;
  }
}
