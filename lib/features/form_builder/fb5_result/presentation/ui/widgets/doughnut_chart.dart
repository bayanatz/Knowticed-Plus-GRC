/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: doughnut_chart.dart
/// Description: `DoughnutChart` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/form_chart_data.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/utils/color_generator.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/analytics/custom_chart_data.dart';

import 'package:knowticed_plus/core/helper/extensions.dart'
    hide ContextExtension;
import 'package:knowticed_plus/generated/l10n.dart';

/// A doughnut chart of the answer counts of one field.
// doughnut chart
class DoughnutChart extends StatefulWidget {
  const DoughnutChart({required this.data, required this.total, super.key});
  final int total;
  final List<FormChartData> data;

  @override
  State<DoughnutChart> createState() => _DoughnutChartState();
}

class _DoughnutChartState extends State<DoughnutChart> {
  late List<Color> chartColors;

  // Safe color accessor method
  Color _getColor(int index) {
    if (index >= 0 && index < chartColors.length) {
      return chartColors[index];
    }
    return AppColors.grey;
  }

  @override
  Widget build(BuildContext context) {
    chartColors = ColorGenerator.generateColors(widget.data.length);

    // Ensure we have enough colors
    if (chartColors.length < widget.data.length) {
      // Fill with default colors if needed
      while (chartColors.length < widget.data.length) {
        chartColors.add(AppColors.grey);
      }
    }

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    bool isTablet = !kpIsPhoneLayout(context);
    return Row(
      children: [
        SizedBox(
          height: 200.h,
          child: SingleChildScrollView(
            child: Column(
              spacing: 10.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < widget.data.length; i++)
                  CustomChartDataRow(
                    isPerformanceScreen: (isPortrait ? false : true),
                    isSmallContainer: isTablet ? true : false,
                    dataColor: _getColor(i), // Safe access
                    textData: widget.data[i].text,
                    valueData: widget.data[i].values,
                    isHorizontal: false,
                  ),
              ],
            ),
          ),
        ),
        Spacer(),
        SizedBox(
          height: 200.h,
          width: 160.w,
          child: _buildChart(context, isPortrait),
        ),
        horizontalSpace(
          isTablet
              ? isPortrait
                    ? 20
                    : 10
              : 0,
        ),
      ],
    );
  }

  /// The doughnut with the total in the middle.
  Widget _buildChart(BuildContext context, bool isPortrait) {
    return SfCircularChart(
      margin: EdgeInsets.zero,
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.total.formatNumber(),
                  style: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    S.of(context).total,
                    style: StyleText.fontSize12Weight400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      series: <CircularSeries>[
        DoughnutSeries<FormChartData, String>(
          dataSource: widget.data,
          xValueMapper: (FormChartData info, _) => info.text,
          yValueMapper: (FormChartData info, _) => info.values,
          pointColorMapper: (FormChartData info, int index) {
            // Safe access here too
            return _getColor(index);
          },
          dataLabelSettings: DataLabelSettings(
            connectorLineSettings: ConnectorLineSettings(
              length: '10%', // Shorter connector lines
              width: 1,
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
            // Reduce margin around labels
            margin: EdgeInsets.zero,
            // Use opacity to avoid obscuring chart

            labelAlignment: ChartDataLabelAlignment.middle,
            isVisible: true,
            builder: (data, point, series, pointIndex, seriesIndex) {
              FormChartData dataChart = data as FormChartData;
              return Text(
                '${(dataChart.values / widget.total * 100).round()}%',
                style: StyleText.fontSize12Weight600
                    .copyWith(color: AppColors.lightGrey)
                    .copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              );
            },
            labelPosition: ChartDataLabelPosition.inside,
          ),
          radius: isPortrait ? '70%' : '90%',
          innerRadius: isPortrait ? '60%' : '50%',
          explodeOffset: '7%',
          explode: true,
          explodeAll: true,
        ),
      ],
    );
  }
}
