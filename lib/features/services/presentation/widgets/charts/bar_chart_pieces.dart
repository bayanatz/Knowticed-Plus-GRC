/// Module: services / presentation / widgets / charts
///
///*************************** FILE INFO ****************************///
/// File Name: bar_chart_pieces.dart
/// Purpose: The building blocks of the dashboard bar charts — the axis
///          scale, the grid, the value axis, one bar slot and one category
///          label — shared by CustomVerticalBarChartWidget.
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';

/// The colour of text that annotates a plot (axis numbers, category labels,
/// legend keys). Tooltips are values and keep the body text colour.
Color get dashboardPlotLabelColor => AppColors.colorGrey;

/// The grid / track colour of a dashboard chart.
Color dashboardGridColor(bool lightMode) =>
    lightMode ? AppColors.background : AppColors.darkGrey;

/// Text style of the value-axis numbers.
TextStyle dashboardAxisLabelStyle(bool isMobile) =>
    (isMobile ? StyleText.fontSize10Weight400 : StyleText.fontSize11Weight400)
        .copyWith(height: 1.0, color: dashboardPlotLabelColor);

/// Axis maths: a "nice" top value and the step between grid lines.
class BarChartScale {
  const BarChartScale._();

  /// A round ceiling at or above [dataMax] (10 when there is no data).
  static double niceMax(double dataMax) {
    if (dataMax <= 0) return 10.0;
    final top = dataMax.ceil();
    final int ceiling;
    if (top <= 5) {
      ceiling = 5;
    } else if (top <= 10) {
      ceiling = 10;
    } else if (top <= 20) {
      ceiling = 20;
    } else if (top <= 50) {
      ceiling = (top / 10).ceil() * 10;
    } else if (top <= 100) {
      ceiling = (top / 20).ceil() * 20;
    } else if (top <= 500) {
      ceiling = (top / 50).ceil() * 50;
    } else {
      ceiling = (top / 100).ceil() * 100;
    }
    return ceiling.toDouble();
  }

  /// The step between grid lines for an axis that ends at [maxY].
  static double interval(double maxY) {
    if (maxY <= 5) return 1.0;
    if (maxY <= 10) return 2.0;
    if (maxY <= 20) return 5.0;
    if (maxY <= 50) return 10.0;
    if (maxY <= 100) return 20.0;
    if (maxY <= 200) return 50.0;
    if (maxY <= 500) return 100.0;
    return (maxY / 5).ceilToDouble();
  }

  /// [maxY] rounded up to a whole number of [step]s, so the top number and
  /// the top grid line coincide.
  static double alignToStep(double maxY, double step) =>
      (maxY / step).ceilToDouble() * step;
}

/// Horizontal grid lines across the whole plot, one per interval from the
/// first step up to and including maxY (fl_chart skips the one at maxY).
class PlotGrid extends StatelessWidget {
  final double maxY;
  final double interval;
  final bool lightMode;

  const PlotGrid({
    super.key,
    required this.maxY,
    required this.interval,
    required this.lightMode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PlotGridPainter(
        maxY: maxY,
        interval: interval,
        color: dashboardGridColor(lightMode),
      ),
    );
  }
}

class _PlotGridPainter extends CustomPainter {
  _PlotGridPainter({
    required this.maxY,
    required this.interval,
    required this.color,
  });

  final double maxY;
  final double interval;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (maxY <= 0 || interval <= 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var v = interval; v <= maxY + 0.0001; v += interval) {
      final y = size.height * (1 - v / maxY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_PlotGridPainter old) =>
      old.maxY != maxY || old.interval != interval || old.color != color;
}

/// The value axis: each number centred on the height of its grid line,
/// y = h × (1 − v / maxY), hugging the edge that faces the plot.
class ValueAxisLabels extends StatelessWidget {
  final double maxY;
  final double interval;
  final bool isMobile;

  const ValueAxisLabels({
    super.key,
    required this.maxY,
    required this.interval,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final values = <double>[];
    for (var v = maxY; v >= -0.0001; v -= interval) {
      values.add(v < 0 ? 0 : v);
    }
    final style = dashboardAxisLabelStyle(isMobile);
    final lineHeight = (style.fontSize ?? 11) * 1.2;

    return LayoutBuilder(
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
    );
  }
}

/// One slot of the plot: a bar (or two side by side) centred in its width,
/// with its value always shown above it.
class BarSlot extends StatelessWidget {
  final double value;
  final double maxY;
  final Color barColor;
  final double barWidth;

  /// When non-null a second rod is drawn beside the first.
  final double? secondValue;
  final Color? secondBarColor;

  const BarSlot({
    super.key,
    required this.value,
    required this.maxY,
    required this.barColor,
    required this.barWidth,
    this.secondValue,
    this.secondBarColor,
  });

  @override
  Widget build(BuildContext context) {
    final second = secondValue;
    // Two rods share the slot, so both are narrowed to the same width.
    final width = second != null ? barWidth * 0.55 : barWidth;
    final hidden = AxisTitles(sideTitles: SideTitles(showTitles: false));
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.center,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 6.sp,
            getTooltipColor: (_) => AppColors.transparent,
            tooltipBorder: BorderSide.none,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (rod.toY <= 0) return null;
              return BarTooltipItem(
                context.svcNumber(rod.toY.toInt()),
                StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: hidden,
          rightTitles: hidden,
          topTitles: hidden,
          bottomTitles: hidden,
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barsSpace: second != null ? 4.sp : 0,
            barRods: [
              BarChartRodData(
                toY: value,
                width: width,
                borderRadius: BorderRadius.circular(4.r),
                color: barColor,
              ),
              if (second != null)
                BarChartRodData(
                  toY: second,
                  width: width,
                  borderRadius: BorderRadius.circular(4.r),
                  color: secondBarColor ?? AppColors.red,
                ),
            ],
            showingTooltipIndicators: [
              if (value > 0) 0,
              if (second != null && second > 0) 1,
            ],
          ),
        ],
      ),
    );
  }
}

/// One category label under the plot: same size and weight for every
/// label; a long one wraps to two lines and is then ellipsised.
class CategoryLabel extends StatelessWidget {
  final String label;
  final bool isMobile;

  const CategoryLabel({super.key, required this.label, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: (isMobile
                  ? StyleText.fontSize10Weight400
                  : StyleText.fontSize12Weight400)
              .copyWith(height: 1.15, color: dashboardPlotLabelColor),
        ),
      ),
    );
  }
}
