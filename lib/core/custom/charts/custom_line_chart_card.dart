/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_line_chart_card.dart
/// Purpose: Declares `LineChartCard` — a trend line over time with a soft
///          area under it, a 3-label value axis and one dot per point.
/// Author: Knowticed Plus team
/// Created: 24/10/2026
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_extras.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class LineChartCard extends StatelessWidget {
  final String title;

  /// One point per entry, left to right (right to left in Arabic).
  final List<ChartData> points;
  final Widget? trailing;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool expandChild;
  final double chartHeight;
  final Color? lineColor;

  const LineChartCard({
    super.key,
    required this.title,
    required this.points,
    this.trailing,
    this.width,
    this.height,
    this.padding,
    this.expandChild = false,
    this.chartHeight = 100,
    this.lineColor,
  });

  double get _top {
    double m = 0;
    for (final ChartData p in points) {
      if (p.value > m) m = p.value;
    }
    return niceChartTop(m * 1.05);
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final List<ChartData> pts = isRtl ? points.reversed.toList() : points;
    final Color color = lineColor ?? AppColors.primary;
    final double top = _top;

    final AxisTitles yAxis = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 34.w,
        interval: top / 2,
        getTitlesWidget: (double v, TitleMeta meta) {
          if (v > meta.max + 0.0001) return const SizedBox.shrink();
          return Text(formatAxisValue(v),
              maxLines: 1, softWrap: false, style: ChartText.axis);
        },
      ),
    );
    const AxisTitles hidden =
        AxisTitles(sideTitles: SideTitles(showTitles: false));

    return ChartCard(
      title: title,
      trailing: trailing,
      width: width,
      height: height,
      padding: padding,
      expandChild: expandChild,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: expandChild ? MainAxisSize.max : MainAxisSize.min,
        children: <Widget>[
          fillIf(
            expandChild,
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                // 24/10/2026 (Moataz: "the whole year ... scroll inside the
                // chart"): each month keeps a readable width; when they do not
                // all fit the plot scrolls sideways inside the card.
                final double needed = pts.length * 46.w + 34.w;
                final bool scrolls = needed > c.maxWidth;
                final Widget plot = SizedBox(
                  height: expandChild && c.hasBoundedHeight
                      ? c.maxHeight
                      : chartHeight.h,
                  width: scrolls ? needed : null,
                  child: LineChart(
                    LineChartData(
                      // Half a step of room at each end, so the first and last month
                      // labels are not cut by the card edge (Moataz 24/10/2026).
                      minX: -0.45,
                      maxX: pts.length - 1 + 0.45,
                      minY: 0,
                      maxY: top,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: top / 2,
                        getDrawingHorizontalLine: (double v) => FlLine(
                          color: AppColors.border.withValues(alpha: .4),
                          strokeWidth: 1,
                          dashArray: <int>[4, 4],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: hidden,
                        leftTitles: isRtl ? hidden : yAxis,
                        rightTitles: isRtl ? yAxis : hidden,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 18.h,
                            interval: 1,
                            getTitlesWidget: (double v, TitleMeta meta) {
                              final int i = v.round();
                              if (i < 0 ||
                                  i >= pts.length ||
                                  (v - i).abs() > .01) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Text(pts[i].label,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: ChartText.axis),
                              );
                            },
                          ),
                        ),
                      ),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: <LineChartBarData>[
                        LineChartBarData(
                          spots: <FlSpot>[
                            for (int i = 0; i < pts.length; i++)
                              FlSpot(i.toDouble(), pts[i].value),
                          ],
                          isCurved: true,
                          curveSmoothness: .25,
                          color: color,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (FlSpot s, double p,
                                    LineChartBarData b, int i) =>
                                FlDotCirclePainter(
                              radius: 3.5,
                              color: AppColors.card,
                              strokeColor: color,
                              strokeWidth: 2,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withValues(alpha: .14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                return scrolls
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: isRtl,
                        child: plot,
                      )
                    : plot;
              },
            ),
          ),
        ],
      ),
    );
  }
}
