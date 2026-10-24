/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_charts_section.dart
/// Purpose: Charts section for Admin Dashboard (services offered, monthly
///          counts, comparison)
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/charts/comparison_chart.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_cubit.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/charts/horizontal_bar_chart_widget.dart';

import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/build_number_services.dart';

class AdminDashboardChartsSection extends StatelessWidget {
  final DashboardAdminState state;

  const AdminDashboardChartsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = context.svcIsArabic;

    return Column(
      children: [
        // ── Services Offered Bar Chart ─────────────────────────────────────
        _buildServicesOfferedWidget(context, lightMode, isArabic),

        SizedBox(height: 15.sp),

        // ── Monthly Comparison Chart ───────────────────────────────────────
        MonthlyComparisonChart(
          lightMode: lightMode,
          cancelledByMonth: state.cancelledByMonth,
          rejectedByMonth: state.rejectedByMonth,
        ),

        SizedBox(height: 15.sp),

        // ── Number of Services / Hours Card ───────────────────────────────
        NumberOfServicesCardDashBoard(
          monthCounts: state.monthCounts,
          monthHours: state.monthHours,
          isLoading: state.isLoading,
          showServiceCount: state.showServiceCount,
          // ✅ FIX (bug report p8/p12): both callbacks were empty closures, so
          // tapping "Total Hours" did nothing at all — the chart never
          // switched datasets. Wire them to the cubit's toggleServiceCount,
          // which flips the flag and loads the matching series.
          onToggleServiceCount: () =>
              context.read<DashboardAdminCubit>().toggleServiceCount(true),
          onToggleToHours: () =>
              context.read<DashboardAdminCubit>().toggleServiceCount(false),
        ),
      ],
    );
  }

  Widget _buildServicesOfferedWidget(
    BuildContext context,
    bool lightMode,
    bool isArabic,
  ) {
    final labels = <String>[];
    final values = <double>[];

    for (int i = 0; i < state.serviceNames.length; i++) {
      final label = isArabic &&
              i < state.serviceNamesArabic.length &&
              state.serviceNamesArabic[i].isNotEmpty
          ? state.serviceNamesArabic[i]
          : state.serviceNames[i];
      labels.add(label);
      values.add(state.serviceUsageCounts[i] ?? 0.0);
    }

    return CustomHorizontalBarChartWidget(
      title: S.of(context).servicesOffered,
      iconAsset:
          "assets/icons_assets/main_icons_assets/ic_module_support_headset.svg",
      labels: labels,
      values: values,
      lightMode: lightMode,
      height: 310,
      backgroundColor: AppColors.card,
      barColor: AppColors.primary,
    );
  }
}
