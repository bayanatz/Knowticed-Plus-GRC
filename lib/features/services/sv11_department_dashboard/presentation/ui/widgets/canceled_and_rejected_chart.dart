/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: canceled_and_rejected_chart.dart
/// Purpose: The cancelled / rejected requests chart of the department
///          dashboard, with a toggle between the two.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Import your existing widgets
import 'package:knowticed_plus/features/services/presentation/widgets/charts/vertical_bar_chart_widget.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/charts/horizontal_bar_chart_widget.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Dynamic Rejected/Canceled Services Chart Widget
/// Supports both vertical and horizontal orientations
/// Toggles between "Rejected" and "Canceled"
class DynamicRejectedCanceledChart extends StatefulWidget {
  final Map<int, double> monthRejected;
  final Map<int, double> monthCanceled;
  final bool isLoading;
  final Function buildBarGroups;
  final VoidCallback onFetchRejectedCounts;
  final VoidCallback onFetchCanceledCounts;
  final String titleText;
  final String rejectedText;
  final String canceledText;
  final Widget loadingWidget;
  final Color primaryColor;
  final Color buttonTextColor;
  final bool lightMode;
  final ChartOrientation orientation;

  const DynamicRejectedCanceledChart({
    super.key,
    required this.monthRejected,
    required this.monthCanceled,
    required this.isLoading,
    required this.buildBarGroups,
    required this.onFetchRejectedCounts,
    required this.onFetchCanceledCounts,
    required this.titleText,
    required this.rejectedText,
    required this.canceledText,
    required this.loadingWidget,
    required this.primaryColor,
    required this.buttonTextColor,
    required this.lightMode,
    this.orientation = ChartOrientation.vertical,
  });

  @override
  State<DynamicRejectedCanceledChart> createState() =>
      _DynamicRejectedCanceledChartState();
}

class _DynamicRejectedCanceledChartState
    extends State<DynamicRejectedCanceledChart> {
  bool _isCanceled = false; // false = rejected, true = canceled

  final List<String> _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: widget.lightMode ? AppColors.white : AppColors.header,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Center(child: widget.loadingWidget),
      );
    }

    // Prepare data based on toggle state
    final data = _isCanceled ? widget.monthCanceled : widget.monthRejected;
    final values = List.generate(12, (i) => data[i] ?? 0.0);

    // Render based on orientation
    if (widget.orientation == ChartOrientation.horizontal) {
      return _buildHorizontalChart(values);
    } else {
      return _buildVerticalChart(values);
    }
  }

  /// Build Vertical Chart (Original Style)
  Widget _buildVerticalChart(List<double> values) {
    var isMobile = ContextExtension(context).isPhone;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Padding(
            padding: EdgeInsets.only(top: 15.sp, right: 10.sp, left: 10.sp),
            child: isMobile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26.sp,
                            height: 26.sp,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.primaryColor,
                            ),
                            child: Center(
                              child: CustomSvgImage.natural(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_module_support_headset.svg",
                                fit: BoxFit.scaleDown,
                                width: 16.sp,
                                height: 16.sp,
                                color: widget.buttonTextColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            widget.titleText,
                            style: StyleText.fontSize14Weight400.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [_buildToggleButton()],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26.sp,
                            height: 26.sp,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.primaryColor,
                            ),
                            child: Center(
                              child: CustomSvgImage.natural(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_module_support_headset.svg",
                                fit: BoxFit.scaleDown,
                                width: 16.sp,
                                height: 16.sp,
                                color: widget.buttonTextColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            widget.titleText,
                            style: StyleText.fontSize14Weight400.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      _buildToggleButton(),
                    ],
                  ),
          ),
          // Vertical Bar Chart
          CustomVerticalBarChartWidget(
            title: '',
            labels: _monthLabels,
            values: values,
            barWidth: 20,
            lightMode: widget.lightMode,
            height: 300,
          ),
        ],
      ),
    );
  }

  /// Build Horizontal Chart (New Style)
  Widget _buildHorizontalChart(List<double> values) {
    return CustomHorizontalBarChartWidget(
      title: widget.titleText,
      iconAsset:
          "assets/icons_assets/main_icons_assets/ic_module_support_headset.svg",
      labels: _monthLabels,
      values: values,
      barHeight: 15,
      lightMode: widget.lightMode,
      backgroundColor: AppColors.card,
      headerWidget: _buildToggleButton(),
    );
  }

  /// Toggle Button Widget
  Widget _buildToggleButton() {
    final isArabic = context.svcIsArabic;

    final indicatorAlignment = isArabic
        ? (_isCanceled ? Alignment.centerLeft : Alignment.centerRight)
        : (_isCanceled ? Alignment.centerRight : Alignment.centerLeft);

    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        setState(() {
          _isCanceled = !_isCanceled;
        });

        if (_isCanceled) {
          widget.onFetchCanceledCounts();
        } else {
          widget.onFetchRejectedCounts();
        }
      },
      child: Container(
        width: 240.sp,
        height: 30.sp,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: indicatorAlignment, // ✅ Fixed
              child: Container(
                width: 116.sp,
                height: 30.sp,
                margin: EdgeInsets.all(4.sp),
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Row(
              children: [
                // Rejected Text
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: !_isCanceled
                            ? AppColors.textButton
                            : AppColors.text,
                      ),
                      child: Text(widget.rejectedText),
                    ),
                  ),
                ),

                //       color: _isCanceled
                //                             ? AppColors.textButton
                //                             : AppColors.text,
                // Canceled Text
                Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color:
                            _isCanceled ? AppColors.textButton : AppColors.text,
                      ),
                      child: Text(widget.canceledText),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
