// Figma: horizontal bar charts — "Inventory Valuation",
// "Products Discrepancy". Label + value sit ABOVE a full-width bar,
// with dashed vertical gridlines and an x-axis scale at the bottom.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/24-custom_chart_card.dart';

/// Horizontal bar chart card.
///
/// ```dart
/// HorizontalBarChartCard(
///   title: 'Products Discrepancy',
///   trailing: ChartTabPill(text: 'Consumables'),
///   bars: [
///     ChartData(label: 'Missing', value: 35),
///     ChartData(label: 'Damaged', value: 110, color: AppColors.red),
///     ChartData(label: 'Expired', value: 53),
///   ],
/// )
/// ```
class HorizontalBarChartCard extends StatelessWidget {
  final String title;
  final List<ChartData> bars;
  final Widget? trailing;

  /// Max X value; defaults to highest bar.
  final double? maxX;
  final double barHeight;
  final Color? barColor;

  /// Show the value above the end of each bar.
  final bool showValues;
  final double? width;

  /// Number of x-axis intervals (gridlines = divisions + 1).
  final int divisions;

  /// Color of the header dot.
  final Color? dotColor;

  /// Optional SVG asset placed inside the header dot.
  final String? dotIcon;

  const HorizontalBarChartCard({
    super.key,
    required this.title,
    required this.bars,
    this.trailing,
    this.maxX,
    this.barHeight = 14,
    this.barColor,
    this.showValues = true,
    this.width,
    this.divisions = 6,
    this.dotColor,
    this.dotIcon,
  });

  double get _maxX {
    if (maxX != null) return maxX!;
    double m = 0;
    for (final b in bars) {
      if (b.value > m) m = b.value;
    }
    return m == 0 ? 100 : m;
  }

  /// Evenly spaced, rounded axis ticks from 0 to [_maxX].
  List<double> get _ticks {
    final max = _maxX;
    final step = _niceStep(max, divisions);
    final ticks = <double>[];
    for (double v = 0; v <= max + step * 0.001; v += step) {
      ticks.add(v);
    }
    return ticks;
  }

  /// Rounds a raw step up to a "nice" 1/2/5 × 10ⁿ value.
  double _niceStep(double range, int maxTicks) {
    if (range <= 0) return 1;
    final raw = range / maxTicks;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final norm = raw / mag;
    double step;
    if (norm <= 1) {
      step = 1;
    } else if (norm <= 2) {
      step = 2;
    } else if (norm <= 5) {
      step = 5;
    } else {
      step = 10;
    }
    return step * mag;
  }

  @override
  Widget build(BuildContext context) {
    final defaultColor = barColor ?? AppColors.primary;
    final ticks = _ticks;
    return ChartCard(
      title: title,
      trailing: trailing,
      width: width,
      dotColor: dotColor,
      dotIcon: dotIcon,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final fractions = [for (final t in ticks) (t / _maxX).clamp(0.0, 1.0)];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final b in bars)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label (left) + value (right) above the bar.
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              b.label,
                              style: CardStyles.value(12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (showValues) ...[
                            SizedBox(width: 8.w),
                            Text(
                              b.value.toInt().toString(),
                              style: CardStyles.value(12),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // Full-width track + colored fill.
                      Stack(
                        children: [
                          Container(
                            height: barHeight.h,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor:
                                (b.value / _maxX).clamp(0.0, 1.0).toDouble(),
                            child: Container(
                              height: barHeight.h,
                              decoration: BoxDecoration(
                                color: b.color ?? defaultColor,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 6.h),
              // X-axis scale labels, aligned under the gridlines.
              SizedBox(
                height: 14.h,
                child: Stack(
                  children: [
                    for (int i = 0; i < ticks.length; i++)
                      Positioned(
                        left: fractions[i] * w,
                        child: FractionalTranslation(
                          translation: Offset(
                            i == 0
                                ? 0
                                : i == ticks.length - 1
                                    ? -1
                                    : -0.5,
                            0,
                          ),
                          child: Text(
                            ticks[i].toInt().toString(),
                            style: CardStyles.label(9),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
