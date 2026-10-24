/// Module: knowledge_hub/kh7_dashboard/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: monthly_comparison_knowledge_chart.dart
/// Description: Published vs removed documents per department.
/// Author: Amr Mesbah
/// Created at: 06/10/2025
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/domain/use_cases/dashboard_statistics.dart';

/// Figures come from the cubit (per department id: published / removed);
/// this widget only draws them.
class MonthlyComparisonKnowledgeChart extends StatelessWidget {
  const MonthlyComparisonKnowledgeChart({
    super.key,
    required this.data,
    required this.departmentNamesEn,
    required this.departmentNamesAr,
  });

  final Map<String, Map<String, int>> data;
  final Map<String, String> departmentNamesEn;
  final Map<String, String> departmentNamesAr;

  String _name(BuildContext context, String id) => KhLocale.pick(
    context,
    en: FormatHelper.capitalize(departmentNamesEn[id] ?? id),
    ar: departmentNamesAr[id] ?? '',
  );

  int _value(String id, String status) => data[id]?[status] ?? 0;

  @override
  Widget build(BuildContext context) {
    final List<String> ids = data.keys.toList()
      ..sort(
        (a, b) => _name(
          context,
          a,
        ).toLowerCase().compareTo(_name(context, b).toLowerCase()),
      );
    final int totalPublished = ids.fold(
      0,
      (sum, id) => sum + _value(id, DashboardStatus.published),
    );
    final int totalRemoved = ids.fold(
      0,
      (sum, id) => sum + _value(id, DashboardStatus.removed),
    );

    return Container(
      padding: EdgeInsets.only(
        top: 15.sp,
        right: 15.w,
        left: 15.w,
        bottom: 10.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26.sp,
                height: 26.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Center(
                  child: Icon(
                    Icons.insights,
                    size: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
              ),
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  S.of(context).knowledge_monthly_comparison,
                  style: StyleText.fontSize14Weight600.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.sp),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _legend(
                context,
                AppColors.lightGreen,
                S.of(context).published,
                totalPublished,
              ),
              _legend(
                context,
                AppColors.redLight,
                S.of(context).removed,
                totalRemoved,
              ),
            ],
          ),
          SizedBox(height: 20.sp),
          if (totalPublished == 0 && totalRemoved == 0)
            SizedBox(
              height: 200.h,
              child: Center(
                child: Text(
                  S.of(context).no_data_available,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            )
          else
            SizedBox(height: 300.h - 28.sp, child: _chart(context, ids)),
        ],
      ),
    );
  }

  Widget _legend(BuildContext context, Color color, String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.sp,
          height: 12.sp,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          '$label: ${KhLocale.digits(context, count)}',
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  Widget _chart(BuildContext context, List<String> ids) {
    int tallest = 0;
    for (final String id in ids) {
      for (final String s in [
        DashboardStatus.published,
        DashboardStatus.removed,
      ]) {
        if (_value(id, s) > tallest) tallest = _value(id, s);
      }
    }
    final double interval = _interval(tallest);
    final double top = (tallest / interval).ceil() * interval;
    final double maxY = (top == 0 ? interval * 4 : top) + interval * 0.4;

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceEvenly,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border.withValues(alpha: .4),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        barTouchData: _touchData(context),
        titlesData: _titles(context, ids, interval),
        barGroups: [for (int i = 0; i < ids.length; i++) _group(i, ids[i])],
      ),
    );
  }

  /// The value above each bar (no box), hidden for empty bars.
  BarTouchData _touchData(BuildContext context) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipPadding: EdgeInsets.zero,
        tooltipMargin: 8.sp,
        getTooltipColor: (_) => AppColors.transparent,
        getTooltipItem: (group, groupIndex, rod, rodIndex) => rod.toY > 0
            ? BarTooltipItem(
                KhLocale.digits(context, rod.toY.toInt()),
                CardStyles.value(10),
              )
            : null,
      ),
    );
  }

  /// Value axis on the reading-start side, department names underneath.
  FlTitlesData _titles(
    BuildContext context,
    List<String> ids,
    double interval,
  ) {
    final AxisTitles valueAxis = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 34.w,
        interval: interval,
        getTitlesWidget: (double value, _) {
          if (value % interval != 0) return const SizedBox.shrink();
          return Text(
            KhLocale.digits(context, value.toInt()),
            style: CardStyles.label(9),
          );
        },
      ),
    );
    const AxisTitles hidden = AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    );
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return FlTitlesData(
      leftTitles: rtl ? hidden : valueAxis,
      rightTitles: rtl ? valueAxis : hidden,
      topTitles: hidden,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          // 15/10/2026 — KH large-screen report: a wider label box (wraps
          // between words, not inside one) and room for 2 lines.
          reservedSize: 40.sp,
          getTitlesWidget: (double value, _) {
            final int i = value.toInt();
            if (i < 0 || i >= ids.length) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 3.sp),
              child: SizedBox(
                width: 130.sp,
                child: Text(
                  _name(context, ids[i]),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CardStyles.label(9),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Published (green) and removed (red) bars of one department.
  BarChartGroupData _group(int x, String id) {
    BarChartRodData rod(String status, Color color) => BarChartRodData(
      toY: _value(id, status).toDouble(),
      width: 20.sp,
      color: color,
      borderRadius: BorderRadius.circular(4.r),
    );
    return BarChartGroupData(
      x: x,
      barsSpace: 4.sp,
      showingTooltipIndicators: const [0, 1],
      barRods: [
        rod(DashboardStatus.published, AppColors.lightGreen),
        rod(DashboardStatus.removed, AppColors.redLight),
      ],
    );
  }

  /// A whole-number step giving at most about five gridlines.
  double _interval(int max) {
    if (max <= 5) return 1;
    if (max <= 10) return 2;
    if (max <= 20) return 5;
    if (max <= 50) return 10;
    if (max <= 100) return 20;
    if (max <= 250) return 50;
    return (max / 5).ceilToDouble();
  }
}
