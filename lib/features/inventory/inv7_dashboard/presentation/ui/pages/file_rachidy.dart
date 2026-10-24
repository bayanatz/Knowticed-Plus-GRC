import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildVerticalCustomBarChart({
  required BuildContext context,
  required bool lightMode,
  required String title,
  required List<String> labels,
  required List<double> values,
  Widget? needWidget,
  double maxY = 400,
  double height = 250,
  Color? barColor,
  BarChartAlignment barAlignment = BarChartAlignment.spaceAround, // ✅ New
  double groupsSpace = 30, // ✅ NEW PARAM
}) {
  return Container(
    margin: EdgeInsets.only(top: 20.sp),
    padding: EdgeInsets.all(16.sp),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ),
                SizedBox(width: 8.sp),
                Text(
                  title,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: lightMode ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [if (needWidget != null) needWidget],
        ),

        SizedBox(height: 40.sp),

        // Chart
        SizedBox(
          height: height.sp,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: barAlignment,
              groupsSpace: groupsSpace.sp,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 100,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: lightMode
                        ? const Color(0xffEFF3F9)
                        : Colors.grey.shade800,
                    strokeWidth: 1,
                  );
                },
              ),
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 0.sp,
                  getTooltipColor: (_) => Colors.transparent,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toInt().toString(),
                      StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 100,
                    reservedSize: 35.sp,
                    getTitlesWidget: (value, _) => Text(
                      value.toInt().toString(),
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  axisNameSize: 24.sp,
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index < labels.length) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 0.sp),
                          child: SizedBox(
                            width: 150.sp,
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              labels[index],
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              barGroups: List.generate(values.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barsSpace: 200.sp,
                  barRods: [
                    BarChartRodData(
                      toY: values[index],
                      width: 30.sp,
                      borderRadius: BorderRadius.circular(6.r),
                      color: barColor ?? AppColors.primary,
                    ),
                  ],
                  showingTooltipIndicators: [0],
                );
              }),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildHorizontalInventoryChart({
  required BuildContext context,
  required bool lightMode,
  required String title,
  required List<String> labels,
  required List<double> values,
  required double maxValue,
  Widget? needWidget,
  Color? barColor,
  Color? backgroundColor,
  List<String>? axisLabels,
  List<Color>? barColors,
}) {
  final Color defaultBackgroundColor = AppColors.card;
  final Color defaultBarColor = barColor ?? AppColors.primary;

  return Container(
    margin: EdgeInsets.only(top: 20.sp),
    padding: EdgeInsets.all(16.sp),
    decoration: BoxDecoration(
      color: backgroundColor ?? defaultBackgroundColor,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 Title Row
        Row(
          children: [
            Container(
              width: 26.sp,
              height: 26.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8.sp),
            Text(
              title,
              style: StyleText.fontSize14Weight500.copyWith(
                color: lightMode ? Colors.black : Colors.white,
              ),
            ),
            Spacer(),
            if (needWidget != null) needWidget,
          ],
        ),

        SizedBox(height: 20.sp),

        /// 🔹 Horizontal Bars
        Column(
          children: List.generate(labels.length, (index) {
            final label = labels[index];
            final value = values[index];
            final percent = (value / maxValue).clamp(0, 1.0);
            final Color currentBarColor =
                (barColors != null && index < barColors.length)
                    ? barColors[index]
                    : defaultBarColor;

            return Padding(
              padding: EdgeInsets.only(bottom: 20.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔸 Label & Value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      Text(
                        value.toInt().toString(),
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.sp),

                  /// 🔸 Bar
                  Stack(
                    children: [
                      Container(
                        height: 20.sp,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5FF),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percent.toDouble(),
                        child: Container(
                          height: 20.sp,
                          decoration: BoxDecoration(
                            color: currentBarColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),

        /// 🔹 Bottom Axis
        Padding(
          padding: EdgeInsets.only(top: 10.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                (axisLabels ?? const ["0", "50K", "100K", "200K", "300K"]).map((
              label,
            ) {
              return Text(
                label,
                style: StyleText.fontSize10Weight400.copyWith(
                  color: AppColors.blackButton,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}

BarChartGroupData buildBarGroup(int index, int value) {
  Color color;
  if (index == 0 || index == 3) {
    color = Color(0xFFFF914D); // Orange
  } else if (index == 1 || index == 2) {
    color = Color(0xFF45C43C); // Green
  } else {
    color = Color(0xFFD61F1F); // Red
  }

  return BarChartGroupData(
    x: index,
    barRods: [
      BarChartRodData(
        toY: value.toDouble(),
        color: color,
        // Bar Width
        width: 40.sp,
        borderRadius: BorderRadius.circular(6),
      ),
    ],
    showingTooltipIndicators: [0],
  );
}
