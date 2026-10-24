/// Module: knowledge_hub/kh7_dashboard/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_monthly_chart.dart
/// Description: One configurable month-by-month bar chart with a tab per
///              series (Published/Removed, Views/Downloads).
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_tab_with_container.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/domain/use_cases/dashboard_statistics.dart';

/// One tab of a [DashboardMonthlyChart].
class DashboardChartSeries {
  const DashboardChartSeries({
    required this.tabLabel,
    required this.title,
    required this.icon,
    required this.data,
  });

  final String tabLabel;
  final String title;
  final String icon;

  /// Count per month, keyed by the first day of the month.
  final Map<DateTime, int> data;
}

/// The last 12 months, oldest first, labelled in the UI language
/// (DateFormat.MMM), with one tab per [series].
class DashboardMonthlyChart extends StatefulWidget {
  const DashboardMonthlyChart({
    super.key,
    required this.series,
    this.initialIndex = 0,
  });

  final List<DashboardChartSeries> series;
  final int initialIndex;

  @override
  State<DashboardMonthlyChart> createState() => _DashboardMonthlyChartState();
}

class _DashboardMonthlyChartState extends State<DashboardMonthlyChart> {
  late int _selected = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final DashboardChartSeries current = widget.series[_selected];
    final List<DateTime> months = DashboardStatistics.lastTwelveMonths(
      DateTime.now(),
    );

    return BarChartCard(
      key: ValueKey<int>(_selected),
      title: current.title,
      dotIcon: current.icon,
      dotColor: AppColors.primary,
      trailing: CustomSegmentedTabs(
        tabs: widget.series.map((s) => s.tabLabel).toList(),
        selectedIndex: _selected,
        onTabSelected: (int i) => setState(() => _selected = i),
        containerColor: AppColors.greyBack,
        selectedColor: AppColors.primary,
        unselectedColor: AppColors.transparent,
        selectedTextColor: AppColors.textButton,
        unselectedTextColor: AppColors.secondaryText,
        textStyle: StyleText.fontSize12Weight500,
        spacing: 4.sp,
        tabHorizontalPadding: 8.w,
        tabVerticalPadding: 6.h,
      ),
      bars: months
          .map(
            (DateTime month) => ChartData(
              label: KhLocale.formatDate(context, month, 'MMM'),
              value: (current.data[month] ?? 0).toDouble(),
            ),
          )
          .toList(),
      chartHeight: 300,
      barWidth: 20.sp,
      barColor: AppColors.primary,
    );
  }
}
