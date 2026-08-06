// Figma: donut charts — "Demands", "Order Fulfillment Status".
// fl_chart PieChart with center total + legend with amounts.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/16-custom_card_styles.dart';
import 'package:grc_module/core/custom/24-custom_chart_card.dart';

/// Donut chart card: ring chart, center total, legend rows with amounts.
///
/// ```dart
/// DonutChartCard(
///   title: 'Demands',
///   centerValue: '9K',
///   centerLabel: 'Total Product',
///   sections: [
///     ChartData(label: 'Assets', value: 513, color: AppColors.primary),
///     ChartData(label: 'Consumables', value: 513, color: AppColors.text),
///   ],
/// )
/// ```
class DonutChartCard extends StatelessWidget {
  final String title;
  final List<ChartData> sections;
  final String? centerValue;
  final String? centerLabel;
  final Widget? trailing;
  final double chartSize;
  final double ringWidth;
  final double? width;

  /// Show the legend (name + amount) next to the chart.
  final bool showLegend;

  /// Color of the header dot.
  final Color? dotColor;

  /// Optional SVG asset placed inside the header dot.
  final String? dotIcon;

  /// Show the percentage label on each ring segment (Figma: "40%", "25%").
  final bool showPercentages;

  const DonutChartCard({
    super.key,
    required this.title,
    required this.sections,
    this.centerValue,
    this.centerLabel,
    this.trailing,
    this.chartSize = 130,
    this.ringWidth = 22,
    this.width,
    this.showLegend = true,
    this.dotColor,
    this.dotIcon,
    this.showPercentages = true,
  });

  @override
  Widget build(BuildContext context) {
    final double total =
        sections.fold<double>(0, (sum, s) => sum + s.value);

    final chart = SizedBox(
      width: chartSize.r,
      height: chartSize.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: (chartSize.r / 2) - ringWidth.r,
              sections: [
                for (final s in sections)
                  PieChartSectionData(
                    value: s.value,
                    color: s.color,
                    radius: ringWidth.r,
                    // Figma: white percentage label on each segment.
                    showTitle: showPercentages && total > 0,
                    title: total > 0
                        ? '${(s.value / total * 100).round()}%'
                        : '',
                    titleStyle: CardStyles.title(10)
                        .copyWith(color: AppColors.white),
                    titlePositionPercentageOffset: 0.5,
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (centerValue != null)
                Text(centerValue!, style: CardStyles.title(18)),
              if (centerLabel != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    centerLabel!,
                    style: CardStyles.label(9),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return ChartCard(
      title: title,
      trailing: trailing,
      width: width,
      dotColor: dotColor,
      dotIcon: dotIcon,
      child: showLegend
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final s in sections)
                        ChartLegendRow(
                          name: s.label,
                          amount: s.value.toInt().toString(),
                          color: s.color ?? AppColors.grey,
                        ),
                    ],
                  ),
                ),
                // 30.w gap between the legend text and the donut, plus
                // matching space on the far side so it isn't flush to the edge.
                SizedBox(width: 30.w),
                chart,
                SizedBox(width: 30.w),
              ],
            )
          : Center(child: chart),
    );
  }
}
