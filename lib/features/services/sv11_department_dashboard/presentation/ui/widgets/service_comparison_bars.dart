/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: service_comparison_bars.dart
/// Purpose: Draws the twelve-month cancelled / rejected bars of the
///          monthly comparison card. Wide screens show all months; a phone
///          shows three at a time with a fixed value axis and scrolls.
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/service_comparison_state.dart';

class ServiceComparisonBars extends StatelessWidget {
  /// month (1-12) -> {'canceled': count, 'rejected': count}
  final Map<int, Map<String, int>> monthlyData;
  final bool lightMode;

  const ServiceComparisonBars({
    super.key,
    required this.monthlyData,
    required this.lightMode,
  });

  /// How many bars a phone shows at once before the plot scrolls.
  static const int _kMobileVisibleBars = 3;

  /// Width of the fixed value-axis strip on a phone.
  static const double _kMobileAxisWidth = 14.0;

  /// Space under the plot for the month row.
  static const double _kBottomTitlesSize = 28.0;

  /// Colour of the text that annotates the plot (axis numbers, months).
  Color get _plotLabelColor => AppColors.colorGrey;

  Color get _gridColor => lightMode ? AppColors.background : AppColors.darkGrey;

  int _count(int month, String key) => monthlyData[month]?[key] ?? 0;

  double _maxY() {
    var tallest = 0;
    for (var month = 1; month <= 12; month++) {
      // The two bars stand side by side, so the axis follows the taller one.
      final canceled = _count(month, ServiceComparisonData.canceledKey);
      final rejected = _count(month, ServiceComparisonData.rejectedKey);
      final top = canceled > rejected ? canceled : rejected;
      if (top > tallest) tallest = top;
    }
    if (tallest == 0) return 10.0;

    final int ceiling;
    if (tallest <= 5) {
      ceiling = 5;
    } else if (tallest <= 10) {
      ceiling = 10;
    } else if (tallest <= 20) {
      ceiling = 20;
    } else if (tallest <= 50) {
      ceiling = (tallest / 10).ceil() * 10;
    } else if (tallest <= 100) {
      ceiling = (tallest / 20).ceil() * 20;
    } else if (tallest <= 500) {
      ceiling = (tallest / 50).ceil() * 50;
    } else {
      ceiling = (tallest / 100).ceil() * 100;
    }
    // A whole number of grid steps, so the top number sits on a grid line.
    final step = _interval(ceiling.toDouble());
    return (ceiling / step).ceilToDouble() * step;
  }

  double _interval(double maxY) {
    if (maxY <= 5) return 1.0;
    if (maxY <= 10) return 2.0;
    if (maxY <= 20) return 5.0;
    if (maxY <= 50) return 10.0;
    if (maxY <= 100) return 20.0;
    if (maxY <= 200) return 50.0;
    if (maxY <= 500) return 100.0;
    return (maxY / 5).ceilToDouble();
  }

  /// The month drawn at column [index]; right-to-left readers see December
  /// first on the left so January sits on the reading start.
  int _monthAt(BuildContext context, int index) =>
      context.svcIsArabic ? 12 - index : index + 1;

  List<BarChartGroupData> _groups(BuildContext context) => [
        for (var i = 0; i < 12; i++)
          BarChartGroupData(
            x: i,
            barsSpace: 4.sp,
            barRods: [
              BarChartRodData(
                toY: _count(
                  _monthAt(context, i),
                  ServiceComparisonData.canceledKey,
                ).toDouble(),
                width: 12.sp,
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(4.r),
              ),
              BarChartRodData(
                toY: _count(
                  _monthAt(context, i),
                  ServiceComparisonData.rejectedKey,
                ).toDouble(),
                width: 12.sp,
                color: AppColors.block,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
            showingTooltipIndicators: [0, 1],
          ),
      ];

  BarTouchData _touchData(BuildContext context) => BarTouchData(
        enabled: true,
        // The value labels are always shown; built-in touches would replace
        // them with only the touched rod's number.
        handleBuiltInTouches: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8.sp,
          getTooltipColor: (_) => AppColors.transparent,
          tooltipBorder: BorderSide.none,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            if (rod.toY <= 0) return null;
            return BarTooltipItem(
              context.svcNumber(rod.toY.toInt()),
              StyleText.fontSize10Weight400
                  .copyWith(color: AppColors.blackButton),
            );
          },
        ),
      );

  AxisTitles _monthTitles(BuildContext context) => AxisTitles(
        sideTitles: SideTitles(
          reservedSize: _kBottomTitlesSize,
          showTitles: true,
          getTitlesWidget: (value, _) {
            final month = _monthAt(context, value.toInt());
            if (month < 1 || month > 12) return const SizedBox.shrink();
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsetsDirectional.only(top: 3.sp),
                child: Text(
                  context.svcMonthShort(month),
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: _plotLabelColor,
                  ),
                ),
              ),
            );
          },
        ),
      );

  AxisTitles _valueTitles(BuildContext context, double interval, bool show) =>
      AxisTitles(
        sideTitles: SideTitles(
          showTitles: show,
          reservedSize: 28,
          interval: interval,
          getTitlesWidget: (value, _) {
            if (value % interval != 0) return const SizedBox.shrink();
            return Text(
              context.svcNumber(value.toInt()),
              style: StyleText.fontSize11Weight400.copyWith(
                color: _plotLabelColor,
              ),
            );
          },
        ),
      );

  BarChartData _data(
    BuildContext context, {
    required double maxY,
    required double interval,
    required bool showValueAxis,
    required double groupsSpace,
  }) {
    final isArabic = context.svcIsArabic;
    final hidden = AxisTitles(sideTitles: SideTitles(showTitles: false));
    return BarChartData(
      maxY: maxY,
      minY: 0,
      alignment: BarChartAlignment.spaceEvenly,
      groupsSpace: groupsSpace,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: _gridColor, strokeWidth: 1),
      ),
      // fl_chart draws no grid line at maxY; add it under the top number.
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(y: maxY, color: _gridColor, strokeWidth: 1),
        ],
      ),
      barTouchData: _touchData(context),
      titlesData: FlTitlesData(
        leftTitles:
            showValueAxis ? _valueTitles(context, interval, !isArabic) : hidden,
        rightTitles:
            showValueAxis ? _valueTitles(context, interval, isArabic) : hidden,
        topTitles: hidden,
        bottomTitles: _monthTitles(context),
      ),
      barGroups: _groups(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxY = _maxY();
    final interval = _interval(maxY);

    if (!context.isPhone) {
      return BarChart(
        _data(
          context,
          maxY: maxY,
          interval: interval,
          showValueAxis: true,
          groupsSpace: 8.sp,
        ),
      );
    }

    final isArabic = context.svcIsArabic;
    final axis = SizedBox(
      width: _kMobileAxisWidth,
      child: _ValueAxis(
        maxY: maxY,
        interval: interval,
        bottomInset: _kBottomTitlesSize,
        color: _plotLabelColor,
      ),
    );
    // Row follows the reading direction, so the axis lands on the reading
    // start in both languages.
    return Row(
      children: [
        axis,
        Expanded(
          // A third of the PLOT width (what is left after the axis strip).
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _kMobileVisibleBars;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: isArabic,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: 12 * itemWidth,
                  child: BarChart(
                    _data(
                      context,
                      maxY: maxY,
                      interval: interval,
                      showValueAxis: false,
                      groupsSpace: 12.sp,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// The fixed value axis beside the scrolling phone plot. Each number is
/// centred on the height of the grid line it labels.
class _ValueAxis extends StatelessWidget {
  final double maxY;
  final double interval;
  final double bottomInset;
  final Color color;

  const _ValueAxis({
    required this.maxY,
    required this.interval,
    required this.bottomInset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final values = <double>[];
    for (var v = maxY; v >= -0.0001; v -= interval) {
      values.add(v < 0 ? 0 : v);
    }
    final style = StyleText.fontSize10Weight400.copyWith(
      height: 1.0,
      color: color,
    );
    final lineHeight = 10.sp * 1.2;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: bottomInset),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final v in values)
                Positioned(
                  top: (maxY <= 0 ? h : h * (1 - v / maxY)) - lineHeight / 2,
                  height: lineHeight,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      context.svcNumber(v.round()),
                      maxLines: 1,
                      softWrap: false,
                      style: style,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
