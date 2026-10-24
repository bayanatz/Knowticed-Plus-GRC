/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: column_chart.dart
/// Description: `ColumnChart` widget, state and UI of the `ColumnChart` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/form_chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// A column chart of the answer counts of one field.
class ColumnChart extends StatefulWidget {
  const ColumnChart({required this.data, super.key});
  final List<FormChartData> data;

  @override
  State<ColumnChart> createState() => _ColumnChartState();
}

class _ColumnChartState extends State<ColumnChart> {
  @override
  Widget build(BuildContext context) {
    // Bug report p.41: response counts are whole numbers, so the axis steps
    // by 1 (no 0.2 / 0.6 / 1.2 ticks) while the counts are small, and the
    // axis leaves one step of headroom so the value label above the tallest
    // column is not clipped.
    double maxValue = 0;
    for (final FormChartData item in widget.data) {
      if (item.values > maxValue) maxValue = item.values;
    }
    final double? axisInterval = maxValue <= 10 ? 1 : null;

    return SizedBox(
      height: 300.h,
      child: SfCartesianChart(
          backgroundColor: AppColors.transparent,
          primaryXAxis: CategoryAxis(
            labelStyle: StyleText.fontSize10Weight400,
            axisLine: AxisLine(width: 0),
          ),
          primaryYAxis: NumericAxis(
            decimalPlaces: 0,
            interval: axisInterval,
            minimum: 0,
            maximum: axisInterval == null ? null : maxValue + 1,
            majorGridLines: MajorGridLines(
              width: 1, // Line thickness
              color: AppColors.grey.withValues(alpha: 0.5), // Line color
              dashArray: <double>[5, 5], // Dash pattern (5px dash, 5px gap)
            ),
            majorTickLines: MajorTickLines(size: 0, width: 0),
            axisLine: AxisLine(width: 0),
          ),
          series: <CartesianSeries<FormChartData, String>>[
            ColumnSeries<FormChartData, String>(
                borderRadius: BorderRadius.circular(10.r),
                width: ContextExtension(context).isPhone ? 0.2 : 0.05,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  // Bug report p.41: the count sits ABOVE the column
                  // (`outer`), not inside its top (`top`).
                  labelAlignment: ChartDataLabelAlignment.outer,
                  textStyle: StyleText.fontSize12Weight400,
                  labelIntersectAction: LabelIntersectAction.shift,
                ),
                dataSource: widget.data,
                xValueMapper: (FormChartData data, _) => data.text,
                yValueMapper: (FormChartData data, _) => data.values,
                name: S.current.fbAnswersCount,
                color: AppColors.primary)
          ]),
    );
  }
}
