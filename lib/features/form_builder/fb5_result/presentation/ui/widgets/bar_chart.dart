/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: bar_chart.dart
/// Description: `BarChart` widget, state and UI of the `BarChart` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/form_chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// A bar chart of the answer counts of one field.
class BarChart extends StatefulWidget {
  const BarChart({required this.data, super.key});
  final List<FormChartData> data;

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        backgroundColor: AppColors.transparent,
        primaryYAxis: NumericAxis(
          axisLine: AxisLine(width: 0),
          majorTickLines: MajorTickLines(size: 0, width: 0),
          tickPosition: TickPosition.outside,
        ),
        primaryXAxis: CategoryAxis(
          isVisible: false,
          labelStyle: StyleText.fontSize14Weight400,
          majorTickLines: MajorTickLines(size: 0, width: 0),
          axisLine: AxisLine(width: 0),
          labelPosition: ChartDataLabelPosition.inside,
        ),
        series: <CartesianSeries<FormChartData, String>>[
          BarSeries<FormChartData, String>(
              dataLabelMapper: (FormChartData data, _) {
                return data.text;
              },
              borderRadius: BorderRadius.circular(10.r),
              width: 0.3, // Width of the bars
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.top,
                textStyle: StyleText.fontSize14Weight500,
              ),
              isTrackVisible: true,
              trackColor: AppColors.lightGrey,
              trackBorderColor: AppColors.transparent,
              trackPadding: 0,
              trackBorderWidth: 0,
              dataSource: widget.data,
              xValueMapper: (FormChartData data, _) => data.text,
              yValueMapper: (FormChartData data, _) => data.values,
              name: S.current.fbAnswersCount,
              color: AppColors.primary)
        ]);
  }
}
