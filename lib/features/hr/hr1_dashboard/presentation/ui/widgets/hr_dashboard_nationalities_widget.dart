// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_nationalities_widget.dart
// Purpose: Displays the employee nationality distribution chart.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/hr/helpers/constants/hr_assets.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/hr/hr1_dashboard/presentation/controller/controller/hr_dashboard_cubit.dart';

class HRDashboardNationalitiesWidget extends StatelessWidget {
  const HRDashboardNationalitiesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HrDashboardCubit>().state;
    if (state is! HrDashboardLoaded) return const SizedBox.shrink();

    return BarChartCard(
      title: FormatHelper.capitalize(S.of(context).nationalities),
      dotIcon: HRAssets.dashboardNationalities,
      bars: [
        for (final item in state.nationalityDistribution)
          ChartData(
            label: FormatHelper.capitalize(item.category),
            value: item.count.toDouble(),
            color: AppColors.primary,
          ),
      ],
      barColor: AppColors.primary,
    );
  }
}
