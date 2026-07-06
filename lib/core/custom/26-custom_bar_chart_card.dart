// Figma: vertical bar charts — "Stocks Overview", "Product Consumption",
// "Products Allocated". Built with fl_chart.
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/24-custom_chart_card.dart';

/// Vertical bar chart card with value labels above the bars.
///
/// ```dart
/// BarChartCard(
///   title: 'Products Allocated',
///   trailing: ChartTabPill(text: 'Consumables'),
///   bars: const [
///     ChartData(label: 'Marketing', value: 320),
///     ChartData(label: 'HR', value: 410),
///   ],
/// )
/// ```
class BarChartCard extends StatelessWidget {
  final String title;
  final List<ChartData> bars;
  final Widget? trailing;

  /// Max Y axis value; defaults to highest bar rounded up.
  final double? maxY;
  final double chartHeight;
  final double barWidth;

  /// Default bar color when a [ChartData.color] is null.
  final Color? barColor;
  final double? width;

  /// Color of the header dot.
  final Color? dotColor;

  /// Optional SVG asset placed inside the header dot.
  final String? dotIcon;

  const BarChartCard({
    super.key,
    required this.title,
    required this.bars,
    this.trailing,
    this.maxY,
    this.chartHeight = 200,
    this.barWidth = 14,
    this.barColor,
    this.width,
    this.dotColor,
    this.dotIcon,
  });

  double get _maxY {
    if (maxY != null) return maxY!;
    double m = 0;
    for (final b in bars) {
      if (b.value > m) m = b.value;
    }
    return m == 0 ? 100 : m * 1.25;
  }

  /// Widest bar label measured at the label text style.
  double get _maxLabelWidth {
    double maxW = 0;
    final style = CardStyles.label(9);
    for (final b in bars) {
      final tp = TextPainter(
        text: TextSpan(text: b.label, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > maxW) maxW = tp.width;
    }
    return maxW;
  }

  @override
  Widget build(BuildContext context) {
    final defaultColor = barColor ?? AppColors.primary;
    return ChartCard(
      title: title,
      trailing: trailing,
      width: width,
      dotColor: dotColor,
      dotIcon: dotIcon,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth;
          // Each bar needs room for its label plus a 10.w gap; if that
          // doesn't fit, the chart scrolls horizontally instead of
          // overlapping the labels.
          final slot = math.max(barWidth.w, _maxLabelWidth) + 10.w;
          final needed = slot * bars.length;
          final scrollable = needed > available;
          final chart = SizedBox(
            width: scrollable ? needed : available,
            height: chartHeight.h,
            child: BarChart(
          BarChartData(
            maxY: _maxY,
            alignment: BarChartAlignment.spaceAround,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => FlLine(
                color: AppColors.border.withOpacity(.4),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 34.w,
                  getTitlesWidget: (v, meta) {
                    if (v >= meta.max) return const SizedBox.shrink();
                    return Text(meta.formattedValue,
                        style: CardStyles.label(9));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26.h,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= bars.length) return const SizedBox();
                    return Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        bars[i].label,
                        style: CardStyles.label(9),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppColors.transparent,
                tooltipMargin: 2,
                tooltipPadding: EdgeInsets.zero,
                getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                  rod.toY.toInt().toString(),
                  CardStyles.value(10),
                ),
              ),
            ),
            barGroups: [
              for (int i = 0; i < bars.length; i++)
                BarChartGroupData(
                  x: i,
                  showingTooltipIndicators: const [0],
                  barRods: [
                    BarChartRodData(
                      toY: bars[i].value,
                      color: bars[i].color ?? defaultColor,
                      width: barWidth.w,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ],
                ),
            ],
          ),
            ),
          );
          if (!scrollable) return chart;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: chart,
          );
        },
      ),
    );
  }
}
