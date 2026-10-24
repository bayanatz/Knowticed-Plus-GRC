// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_gender_widget.dart
// Purpose: Displays the employee gender distribution chart.
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
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/hr_fields/add_employee_gender_option.dart';
import 'package:knowticed_plus/features/hr/hr1_dashboard/presentation/controller/controller/hr_dashboard_cubit.dart';

class HRDashboardGenderWidget extends StatelessWidget {
  const HRDashboardGenderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();
    final data = state.demographicsData;
    final localization = S.of(context);
    return DonutChartCard(
      title: FormatHelper.capitalize(localization.gender),
      dotIcon: HRAssets.dashboardGender,
      centerValue: data.filteredEmployeeTotal.toString(),
      centerLabel: FormatHelper.capitalize(localization.total),
      sections: [
        for (final item in data.genderDistribution)
          _chartData(item, localization),
      ],
    );
  }

  /// Method Name: [_chartData]
  ///
  /// Purpose: Converts an enum-backed gender item into chart data.
  ///
  /// Parameters:
  /// - [item]: Gender distribution item from the dashboard calculator.
  /// - [localization]: Current application localization.
  ///
  /// Returns: A localized and color-configured chart data item.
  ChartData _chartData(HrDashboardDistributionItem item, S localization) {
    final gender = _genderFromCategory(item.category);
    final label = switch (gender) {
      GenderOption.male => localization.male,
      GenderOption.female => localization.female,
      null => item.category,
    };
    final color = switch (gender) {
      GenderOption.male => AppColors.primary,
      GenderOption.female => AppColors.greyDark,
      null => AppColors.grey,
    };

    return ChartData(
      label: FormatHelper.capitalize(label),
      value: item.count.toDouble(),
      color: color,
    );
  }

  /// Method Name: [_genderFromCategory]
  ///
  /// Purpose: Resolves a dashboard category to its gender enum.
  ///
  /// Parameters:
  /// - [category]: Stored enum category name.
  ///
  /// Returns: The matching gender option, or null for an unexpected category.
  GenderOption? _genderFromCategory(String category) {
    for (final option in GenderOption.values) {
      if (option.name == category) return option;
    }
    return null;
  }
}
