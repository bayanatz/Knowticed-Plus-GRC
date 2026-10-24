/// Module: services / presentation / widgets / charts
///
///*************************** FILE INFO ****************************///
/// File Name: horizontal_bar_chart_widget.dart
/// Purpose: The dashboard's horizontal bar chart card — one labelled
///          progress bar per category over a five-step value axis.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/charts/bar_chart_pieces.dart';

class CustomHorizontalBarChartWidget extends StatelessWidget {
  final String title;
  final String? iconAsset;
  final List<String> labels;
  final List<double> values;
  final double? maxValue;
  final double? height;
  final double? width;
  final double? barHeight;
  final Widget? headerWidget;
  final Color? barColor;
  final List<Color>? barColors;
  final Color? backgroundColor;
  final bool lightMode;

  const CustomHorizontalBarChartWidget({
    super.key,
    required this.title,
    required this.labels,
    required this.values,
    this.maxValue,
    this.height,
    this.width,
    this.barHeight,
    this.iconAsset,
    this.headerWidget,
    this.barColor,
    this.barColors,
    this.backgroundColor,
    required this.lightMode,
  });

  Map<String, double> _calculateAxisParams() {
    if (values.isEmpty) {
      return {'maxValue': 100, 'interval': 25};
    }

    final dataMax = values.reduce((a, b) => a > b ? a : b);
    final calculatedMaxValue = maxValue ?? dataMax;

    double roundedMaxValue;
    if (calculatedMaxValue <= 10) {
      roundedMaxValue = (calculatedMaxValue / 2).ceil() * 2.0;
    } else if (calculatedMaxValue <= 20) {
      roundedMaxValue = (calculatedMaxValue / 4).ceil() * 4.0;
    } else if (calculatedMaxValue <= 40) {
      roundedMaxValue = (calculatedMaxValue / 8).ceil() * 8.0;
    } else if (calculatedMaxValue <= 100) {
      roundedMaxValue = (calculatedMaxValue / 20).ceil() * 20.0;
    } else if (calculatedMaxValue <= 200) {
      roundedMaxValue = (calculatedMaxValue / 40).ceil() * 40.0;
    } else if (calculatedMaxValue <= 400) {
      roundedMaxValue = (calculatedMaxValue / 80).ceil() * 80.0;
    } else if (calculatedMaxValue <= 500) {
      roundedMaxValue = (calculatedMaxValue / 100).ceil() * 100.0;
    } else if (calculatedMaxValue <= 1000) {
      roundedMaxValue = (calculatedMaxValue / 200).ceil() * 200.0;
    } else {
      roundedMaxValue = (calculatedMaxValue / 400).ceil() * 400.0;
    }

    double interval = roundedMaxValue / 4;

    // ✅ FIX (bug report p32): _generateAxisLabels renders each tick with
    // toInt(), which truncates. A fractional interval therefore produced
    // duplicate labels — a max of 1 rounded to 2, gave an interval of 0.5 and
    // an axis reading "0 0 1 1 2".
    //
    // Force a whole-number step and stretch the axis to 4 x that step so all
    // five ticks are distinct integers.
    if (interval < 1 || interval != interval.roundToDouble()) {
      interval = interval < 1 ? 1 : interval.ceilToDouble();
      roundedMaxValue = interval * 4;
    }

    return {'maxValue': roundedMaxValue, 'interval': interval};
  }

  List<String> _generateAxisLabels(
    BuildContext context,
    double maxValue,
    double interval,
  ) {
    return [
      for (var i = 0; i < 4; i++) context.svcNumber((interval * i).toInt()),
      context.svcNumber(maxValue.toInt()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final defaultBarColor = barColor ?? AppColors.primary;
    final defaultBgColor = backgroundColor ?? AppColors.card;

    final axisParams = _calculateAxisParams();
    final calculatedMaxValue = axisParams['maxValue']!;
    final interval = axisParams['interval']!;
    final axisLabels = _generateAxisLabels(
      context,
      calculatedMaxValue,
      interval,
    );
    final calculatedBarHeight = barHeight ?? 20;

    // Only show header if title or icon is provided
    final showHeader = title.isNotEmpty || iconAsset != null;

    return Stack(
      children: [
        Container(
          width: width?.w,
          height: 300.h,
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: defaultBgColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              // Header - only show if needed
              if (showHeader)
                Row(
                  children: [
                    const Spacer(),
                    if (headerWidget != null) headerWidget!,
                  ],
                ),

              if (showHeader) SizedBox(height: 25.sp),

              // Horizontal Bars - Fixed overflow issue
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate if content needs scrolling
                    final itemHeight =
                        calculatedBarHeight.sp + 6.sp + 18.sp + 12.sp;
                    final totalContentHeight = labels.length * itemHeight;
                    final availableHeight = constraints.maxHeight;

                    if (totalContentHeight > availableHeight) {
                      // Content is too tall, make it scrollable
                      return SingleChildScrollView(
                        child: Column(
                          children: _buildBarList(
                            context,
                            labels,
                            values,
                            calculatedMaxValue,
                            calculatedBarHeight,
                            defaultBarColor,
                          ),
                        ),
                      );
                    } else {
                      // Content fits, no scroll needed
                      return Column(
                        children: _buildBarList(
                          context,
                          labels,
                          values,
                          calculatedMaxValue,
                          calculatedBarHeight,
                          defaultBarColor,
                        ),
                      );
                    }
                  },
                ),
              ),

              SizedBox(height: 8.sp),

              // Bottom Axis - Always 5 labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: axisLabels.map((label) {
                  return Text(
                    label,
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Title row drawn over the card's top edge.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Row(
            children: [
              if (iconAsset != null)
                Container(
                  width: 26.sp,
                  height: 26.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: defaultBarColor,
                  ),
                  child: Center(
                    child: CustomSvgImage.natural(
                      assetPath: iconAsset!,
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              if (iconAsset != null) SizedBox(width: 8.sp),
              if (title.isNotEmpty)
                Text(
                  title,
                  style: StyleText.fontSize14Weight600.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBarList(
    BuildContext context,
    List<String> labels,
    List<double> values,
    double calculatedMaxValue,
    double calculatedBarHeight,
    Color defaultBarColor,
  ) {
    return List.generate(labels.length, (index) {
      final label = labels[index];
      final value = values[index];
      final percent = (value / calculatedMaxValue).clamp(0.0, 1.0);
      final Color currentBarColor =
          (barColors != null && index < barColors!.length)
              ? barColors![index]
              : defaultBarColor;

      return Padding(
        padding: EdgeInsets.only(bottom: 12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label & Value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                if (value > 0)
                  Text(
                    context.svcNumber(value.toInt()),
                    style: StyleText.fontSize12Weight500.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
              ],
            ),

            SizedBox(height: 13.sp),

            // Progress Bar
            Stack(
              children: [
                Container(
                  height: calculatedBarHeight.sp,
                  decoration: BoxDecoration(
                    color: dashboardGridColor(lightMode),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    height: calculatedBarHeight.sp,
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
    });
  }
}
