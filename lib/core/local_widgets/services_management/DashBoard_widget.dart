import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graphic/graphic.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';


// ============================================
// 1. VERTICAL BAR CHART WIDGET
// ============================================

// ✅ Change from StatelessWidget to StatefulWidget
class CustomVerticalBarChartWidget extends StatefulWidget {
  final String title;
  final String? iconAsset;
  final List<String> labels;
  final List<double> values;
  final Widget? headerWidget;
  final double? maxY;
  final double? height;
  final double? width;
  final double? barWidth;
  final Color? barColor;
  final Color? iconBackgroundColor;
  final Color? backgroundColor;
  final BarChartAlignment barAlignment;
  final double groupsSpace;
  final bool showGrid;
  final bool lightMode;
  final bool showAllMonths;

  const CustomVerticalBarChartWidget({
    Key? key,
    required this.title,
    required this.labels,
    required this.values,
    this.iconAsset,
    this.headerWidget,
    this.maxY,
    this.height,
    this.width,
    this.barWidth,
    this.barColor,
    this.iconBackgroundColor,
    this.backgroundColor,
    this.barAlignment = BarChartAlignment.spaceAround,
    this.groupsSpace = 30,
    this.showGrid = true,
    this.showAllMonths = false,
    required this.lightMode,
  }) : super(key: key);

  @override
  State<CustomVerticalBarChartWidget> createState() =>
      _CustomVerticalBarChartWidgetState();
}

class _CustomVerticalBarChartWidgetState
    extends State<CustomVerticalBarChartWidget> {
  ScrollController? _scrollController;
  bool _didInitScroll = false;

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  double _getMaxY() {
    if (widget.values.isEmpty) return 10.0;
    if (widget.maxY != null) return widget.maxY!;
    double dataMax = 0.0;
    for (var value in widget.values) {
      if (value > dataMax) dataMax = value;
    }
    if (dataMax == 0) return 10.0;
    int intMax = dataMax.ceil();
    int niceCeiling;
    if (intMax <= 5) {
      niceCeiling = 5;
    } else if (intMax <= 10) {
      niceCeiling = 10;
    } else if (intMax <= 20) {
      niceCeiling = 20;
    } else if (intMax <= 50) {
      niceCeiling = ((intMax / 10).ceil() * 10);
    } else if (intMax <= 100) {
      niceCeiling = ((intMax / 20).ceil() * 20);
    } else if (intMax <= 500) {
      niceCeiling = ((intMax / 50).ceil() * 50);
    } else {
      niceCeiling = ((intMax / 100).ceil() * 100);
    }
    return niceCeiling.toDouble();
  }

  double _getInterval(double maxY) {
    if (maxY <= 5) return 1.0;
    if (maxY <= 10) return 2.0;
    if (maxY <= 20) return 5.0;
    if (maxY <= 50) return 10.0;
    if (maxY <= 100) return 20.0;
    if (maxY <= 200) return 50.0;
    if (maxY <= 500) return 100.0;
    return (maxY / 5).ceilToDouble();
  }

  String _formatNumber(num number, bool isArabic) {
    int intNumber = number.toInt();
    if (isArabic) {
      final westernDigits = [
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
      ];
      final arabicDigits = [
        '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'
      ];
      String numStr = intNumber.toString();
      for (int i = 0; i < westernDigits.length; i++) {
        numStr = numStr.replaceAll(westernDigits[i], arabicDigits[i]);
      }
      return numStr;
    }
    return intNumber.toString();
  }

  String _getMonthName(int month, bool isArabic) {
    final englishMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    if (month >= 1 && month <= 12) {
      return isArabic ? arabicMonths[month - 1] : englishMonths[month - 1];
    }
    return '';
  }

  String _convertLabelToArabic(String label, bool isArabic) {
    if (!isArabic) return label;
    final englishMonths = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    final arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    String lowerLabel = label.toLowerCase().trim();
    for (int i = 0; i < englishMonths.length; i++) {
      if (lowerLabel == englishMonths[i] ||
          lowerLabel.startsWith(englishMonths[i])) {
        return arabicMonths[i];
      }
    }
    return label;
  }

  Map<String, dynamic> _prepareMonthlyData(bool isArabic) {
    if (!widget.showAllMonths) {
      List<String> processedLabels = widget.labels
          .map((l) => _convertLabelToArabic(l, isArabic))
          .toList();
      return {
        'labels': processedLabels,
        'values': List<double>.from(widget.values),
      };
    }

    Map<String, double> dataMap = {};
    for (int i = 0; i < widget.labels.length; i++) {
      dataMap[widget.labels[i].toLowerCase()] = widget.values[i];
    }

    List<String> allLabels = [];
    List<double> allValues = [];

    for (int month = 1; month <= 12; month++) {
      allLabels.add(_getMonthName(month, isArabic));
      final monthKey = _getMonthName(month, false).toLowerCase();
      allValues.add(dataMap[monthKey] ?? 0);
    }

    return {
      'labels': allLabels,
      'values': allValues,
    };
  }

  @override
  @override
  Widget build(BuildContext context) {
    final defaultBarColor = widget.barColor ?? AppColors.primary;
    final defaultIconBgColor = widget.iconBackgroundColor ?? AppColors.primary;
    final defaultBgColor = widget.backgroundColor ?? AppColors.card;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final preparedData = _prepareMonthlyData(isArabic);
    final displayLabels = preparedData['labels'] as List<String>;
    final displayValues = preparedData['values'] as List<double>;

    final calculatedMaxY = _getMaxY();
    final calculatedBarWidth = widget.barWidth ?? 30;
    final interval = _getInterval(calculatedMaxY);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final itemCount = displayLabels.length;

    final double availableWidth = screenWidth - 30.sp;
    final double minWidthPerItem = 70.0;
    final shouldScroll = (itemCount * minWidthPerItem) > availableWidth;

    final double axisReservedSize = isMobile ? 28.0 : 13.w;
    final double itemWidth = 80.0;
    final double scrollContentWidth = itemCount * itemWidth;

    if (shouldScroll) {
      _scrollController ??= ScrollController();
      if (isArabic && !_didInitScroll) {
        _didInitScroll = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController!.hasClients) {
            _scrollController!.jumpTo(
              _scrollController!.position.maxScrollExtent,
            );
          }
        });
      }
    }

    return Container(
      width: widget.width?.w,
      height: widget.height?.h,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: defaultBgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row: Icon + Title (+ toggle on tablet) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.iconAsset != null)
                Container(
                  width: 26.sp,
                  height: 26.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: defaultIconBgColor,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      widget.iconAsset!,
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              if (widget.iconAsset != null) SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.font14BlackSemiBoldCairo
                      .copyWith(color: AppColors.text),
                ),
              ),
              // ✅ Show toggle inline on tablet/desktop only
              if (!isMobile && widget.headerWidget != null)
                widget.headerWidget!,
            ],
          ),

          // ✅ Show toggle on separate row for mobile only
          if (isMobile && widget.headerWidget != null) ...[
            SizedBox(height: 12.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.headerWidget!,
              ],
            ),
          ],

          SizedBox(height: 20.sp),

          // ── Chart + Labels ─────────────────────────────
          Expanded(
            child: shouldScroll
                ? _buildScrollableContent(
              context,
              displayLabels,
              displayValues,
              calculatedMaxY,
              calculatedBarWidth,
              interval,
              isArabic,
              defaultBarColor,
              isMobile: isMobile,
              axisReservedSize: axisReservedSize,
              itemWidth: itemWidth,
              scrollContentWidth: scrollContentWidth,
            )
                : _buildStaticContent(
              context,
              displayLabels,
              displayValues,
              calculatedMaxY,
              calculatedBarWidth,
              interval,
              isArabic,
              defaultBarColor,
              isMobile: isMobile,
              axisReservedSize: axisReservedSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(
      BuildContext context,
      List<String> displayLabels,
      List<double> displayValues,
      double calculatedMaxY,
      double calculatedBarWidth,
      double interval,
      bool isArabic,
      Color defaultBarColor, {
        required bool isMobile,
        required double axisReservedSize,
        required double itemWidth,
        required double scrollContentWidth,
      }) {
    // ✅ Find first non-zero bar index to auto-scroll to it
    int firstNonZeroIndex = displayValues.indexWhere((v) => v > 0);

    if (firstNonZeroIndex > 0 && _scrollController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController!.hasClients) {
          // Center the first non-zero bar on screen
          final screenWidth = MediaQuery.of(context).size.width;
          double targetOffset =
              (firstNonZeroIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
          targetOffset = targetOffset.clamp(
            0.0,
            _scrollController!.position.maxScrollExtent,
          );
          _scrollController!.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Row(
      children: [
        if (!isArabic)
          SizedBox(
            width: axisReservedSize,
            child: _buildLeftAxisLabels(
                calculatedMaxY, interval, isMobile, isArabic),
          ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            reverse: false,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: scrollContentWidth,
              child: Column(
                children: [
                  // ✅ Chart area — each bar centered in its itemWidth slot
                  Expanded(
                    child: Row(
                      children: List.generate(displayValues.length, (index) {
                        return SizedBox(
                          width: itemWidth,
                          child: _buildSingleBarChart(
                            value: displayValues[index],
                            maxY: calculatedMaxY,
                            interval: interval,
                            isArabic: isArabic,
                            barColor: defaultBarColor,
                            barWidth: isMobile ? 20.0 : 24.0,
                            showGrid: index == 0, // grid only on first to avoid overlap
                          ),
                        );
                      }),
                    ),
                  ),
                  // ✅ Labels — each centered in same itemWidth slot
                  SizedBox(
                    height: 28.sp,
                    child: Row(
                      children: displayLabels.map((label) {
                        return SizedBox(
                          width: itemWidth,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isArabic)
          SizedBox(
            width: axisReservedSize,
            child: _buildLeftAxisLabels(
                calculatedMaxY, interval, isMobile, isArabic),
          ),
      ],
    );
  }

  /// ✅ NEW: Single bar chart per slot — ensures bar is perfectly centered under label
  Widget _buildSingleBarChart({
    required double value,
    required double maxY,
    required double interval,
    required bool isArabic,
    required Color barColor,
    required double barWidth,
    required bool showGrid,
  }) {
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.center,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (v) => FlLine(
            color: widget.lightMode
                ? const Color(0xffEFF3F9)
                : Colors.grey.shade800,
            strokeWidth: 1,
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 6.sp,
            getTooltipColor: (_) => Colors.transparent,
            tooltipBorder: BorderSide.none,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (rod.toY > 0) {
                return BarTooltipItem(
                  _formatNumber(rod.toY.toInt(), isArabic),
                  AppTextStyles.font12BlackMediumCairo.copyWith(color: AppColors.text),
                );
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: value,
                width: barWidth,
                borderRadius: BorderRadius.circular(4.r),
                color: barColor,
              ),
            ],
            showingTooltipIndicators: value > 0 ? [0] : [],
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Static content now uses the SAME Row layout as scrollable
  // Y-axis labels are OUTSIDE the chart — no internal reservedSize padding
  Widget _buildStaticContent(
      BuildContext context,
      List<String> displayLabels,
      List<double> displayValues,
      double calculatedMaxY,
      double calculatedBarWidth,
      double interval,
      bool isArabic,
      Color defaultBarColor, {
        required bool isMobile,
        required double axisReservedSize,
      }) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // ✅ Y-axis labels
              if (!isArabic)
                SizedBox(
                  width: axisReservedSize,
                  child: _buildLeftAxisLabels(
                      calculatedMaxY, interval, isMobile, isArabic),
                ),

              // ✅ Chart area with grid as background layer
              // In _buildStaticContent, change the Stack to:
              Expanded(
                child: Stack(
                  children: [
                    // Layer 1: Full-width grid lines — ONLY if showGrid is true
                    if (widget.showGrid)
                      Positioned.fill(
                        child: _buildGridOnly(
                          maxY: calculatedMaxY,
                          interval: interval,
                        ),
                      ),
                    // Layer 2: Bars
                    Row(
                      children: List.generate(displayValues.length, (index) {
                        return Expanded(
                          child: _buildSingleBarChart(
                            value: displayValues[index],
                            maxY: calculatedMaxY,
                            interval: interval,
                            isArabic: isArabic,
                            barColor: defaultBarColor,
                            barWidth: isMobile ? 20.0 : calculatedBarWidth,
                            showGrid: false,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              if (isArabic)
                SizedBox(
                  width: axisReservedSize,
                  child: _buildLeftAxisLabels(
                      calculatedMaxY, interval, isMobile, isArabic),
                ),
            ],
          ),
        ),
        // Labels row
        Padding(
          padding: EdgeInsets.only(
            left: isArabic ? 0 : axisReservedSize,
            right: isArabic ? axisReservedSize : 0,
          ),
          child: SizedBox(
            height: 28.sp,
            child: Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: displayLabels.map((label) {
                return Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: isMobile ? 10.sp : 12.sp,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ NEW: Grid-only chart — no bars, just horizontal lines spanning full width
  Widget _buildGridOnly({
    required double maxY,
    required double interval,
  }) {
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        borderData: FlBorderData(show: false),
        barGroups: [], // No bars
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: widget.lightMode
                ? const Color(0xffEFF3F9)
                : Colors.grey.shade800,
            strokeWidth: 1,
          ),
        ),
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }

  Widget _buildLeftAxisLabels(
      double maxY, double interval, bool isMobile, bool isArabic) {
    final List<double> values = [];
    double value = maxY;
    while (value >= 0) {
      values.add(value);
      value -= interval;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment:
      isArabic ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: values.map((v) {
        return Text(
          _formatNumber(v.toInt(), isArabic),
          style: TextStyle(
            fontSize: isMobile ? 9 : 11.sp,
            color: Colors.grey,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarChartOnly(
      BuildContext context,
      List<double> displayValues,
      double calculatedMaxY,
      double calculatedBarWidth,
      double interval,
      bool isArabic,
      Color defaultBarColor, {
        required bool isMobile,
        required bool shouldScroll,
      }) {
    final double effectiveBarWidth =
    shouldScroll ? 24 : (isMobile ? 20 : calculatedBarWidth.sp);
    final double effectiveGroupsSpace =
    shouldScroll ? 5 : (isMobile ? 8 : widget.groupsSpace.sp);

    return BarChart(
      BarChartData(
        maxY: calculatedMaxY,
        minY: 0,
        alignment: BarChartAlignment.spaceEvenly,
        groupsSpace: effectiveGroupsSpace,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: widget.lightMode
                ? const Color(0xffEFF3F9)
                : Colors.grey.shade800,
            strokeWidth: 1,
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 6.sp,
            getTooltipColor: (_) => Colors.transparent,
            tooltipBorder: BorderSide.none,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (rod.toY > 0) {
                return BarTooltipItem(
                  _formatNumber(rod.toY.toInt(), isArabic),
                  AppTextStyles.font12BlackMediumCairo
                      .copyWith(color: AppColors.text),
                );
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(displayValues.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: displayValues[index],
                width: effectiveBarWidth,
                borderRadius: BorderRadius.circular(4.r),
                color: defaultBarColor,
              ),
            ],
            showingTooltipIndicators:
            displayValues[index] > 0 ? [0] : [],
          );
        }),
      ),
    );
  }
}





// ============================================
// 2. HORIZONTAL BAR CHART WIDGET
// ============================================
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
    Key? key,
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
  }) : super(key: key);

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
    return {'maxValue': roundedMaxValue, 'interval': interval};
  }

  List<String> _generateAxisLabels(double maxValue, double interval) {
    return [
      '0',
      interval.toInt().toString(),
      (interval * 2).toInt().toString(),
      (interval * 3).toInt().toString(),
      maxValue.toInt().toString(),
    ];
  }

  double _calculateRequiredHeight() {
    final calculatedBarHeight = barHeight ?? 20;

    // ✅ Check if there's no data
    final hasNoData = labels.isEmpty || values.isEmpty || values.every((v) => v == 0);

    if (hasNoData) {
      // Return a taller height for "No data" message display
      // Header + "No data" message area + padding
      final showHeader = title.isNotEmpty || iconAsset != null;
      final headerHeight = showHeader ? (26.sp + 12.sp) : 0.0;
      final noDataMessageHeight = 150.h; // Tall enough to center "No data" message nicely
      final padding = 32.sp;

      return (headerHeight + noDataMessageHeight + padding).clamp(200.h, 298.h);
    }

    // Normal calculation when data exists
    // Each item: bar height + spacing above bar + label height + bottom padding
    final itemHeight = calculatedBarHeight.sp + 6.sp + 18.sp + 12.sp;
    final contentHeight = labels.length * itemHeight;

    // Header: icon/title height + bottom spacing (only if title or icon exists)
    final showHeader = title.isNotEmpty || iconAsset != null;
    final headerHeight = showHeader ? (26.sp + 12.sp) : 0.0;

    // Bottom axis: text height + top spacing
    final axisHeight = 10.sp + 8.sp;

    // Container padding (top + bottom)
    final padding = 32.sp;

    final totalHeight = contentHeight + headerHeight + axisHeight + padding;

    // Return the smaller of calculated height or max height
    return totalHeight.clamp(0, 298.h);
  }

  @override
  Widget build(BuildContext context) {
    final defaultBarColor = barColor ?? AppColors.primary;
    final defaultBgColor = backgroundColor ??
        (lightMode ? AppColors.white : AppColors.chatBackground);

    final axisParams = _calculateAxisParams();
    final calculatedMaxValue = axisParams['maxValue']!;
    final interval = axisParams['interval']!;
    final axisLabels = _generateAxisLabels(calculatedMaxValue, interval);
    final calculatedBarHeight = barHeight ?? 20;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Only show header if title or icon is provided
    final showHeader = title.isNotEmpty || iconAsset != null;

    return Stack(
      children: [
        Container(
          width: width?.w,
          height: 300.h,
          padding: EdgeInsets.all(15.sp), // Added padding back
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
                      style: AppTextStyles.font14BlackSemiBoldCairo.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey));
                }).toList(),
              ),
            ],
          ),
        ),
        // ✅ FIX: Positioned must be direct child of Stack, then Padding inside
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
                    child: SvgPicture.asset(
                      iconAsset!,
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
                  style: AppTextStyles.font14BlackSemiBoldCairo.copyWith(
                      color: lightMode
                          ? AppColors.blackButton
                          : AppColors.white),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBarList(
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
                    child: Text(label,
                        style: AppTextStyles.font14BlackCairoRegular.copyWith(
                            color: lightMode
                                ? AppColors.secondaryText
                                : AppColors.grey))),
                SizedBox(width: 8.w),
                if (value > 0)
                  Text(value.toInt().toString(),
                      style: AppTextStyles.font12BlackMediumCairo.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey)),
              ],
            ),

            SizedBox(height: 13.sp),

            // Progress Bar
            Stack(
              children: [
                Container(
                  height: calculatedBarHeight.sp,
                  decoration: BoxDecoration(
                    color: lightMode
                        ? const Color(0xFFF5F5FF)
                        : Colors.grey.shade800,
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

// ============================================
// 3. PIE CHART WITH LABELS WIDGET
// ============================================
class CustomPieChartWithLabelsWidget extends StatelessWidget {
  final String title;
  final String? iconAsset;
  final String totalValue;
  final String totalLabel;
  final List<ChartDataItem> data;
  final List<String> valueLabels;
  final bool lightMode;
  final double? height;

  const CustomPieChartWithLabelsWidget({
    Key? key,
    required this.title,
    required this.totalValue,
    required this.totalLabel,
    required this.data,
    required this.valueLabels,
    this.iconAsset,
    required this.lightMode,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final defaultBgColor = lightMode ? AppColors.white : AppColors.chatBackground;

    final int itemCount = data.length;
    final double labelRowHeight = 26.sp;
    final double itemRowHeight = 19.sp;
    final double itemSpacing = 5.sp;
    final double topPadding = 10.sp;
    final double pieChartHeight = 120.sp;
    final double bottomPadding = 10.sp;

    final double minHeight =
        labelRowHeight + topPadding + 30.sp + bottomPadding + pieChartHeight;

    final double calculatedHeight = labelRowHeight +
        topPadding +
        bottomPadding +
        (itemCount * (itemRowHeight + itemSpacing));

    return Container(
      height: height ?? (isMobile ? min(max(calculatedHeight, minHeight), 220.sp) : 260.sp),
      // Remove width: double.infinity to work properly in Row
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: defaultBgColor,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                if (iconAsset != null)
                  Container(
                    width: 26.sp,
                    height: 26.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        iconAsset!,
                        width: 16.sp,
                        height: 16.sp,
                        color: AppColors.textButton
                      ),
                    ),
                  ),
                SizedBox(width: 7.sp),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: lightMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15.sp),

            // Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate responsive dimensions based on available height
                  final availableHeight = constraints.maxHeight;
                  final responsivePieHeight = availableHeight * 0.8; // 80% of available height
                  final responsiveRadius = (responsivePieHeight / 2) * 0.35; // 35% of pie diameter for ring thickness
                  final responsiveCenterRadius = (responsivePieHeight / 2) * 0.5; // 50% of pie diameter for center hole

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Labels
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: data
                              .map(
                                (item) => Padding(
                              padding: EdgeInsets.only(bottom: 5.sp),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14.sp,
                                    height: 14.sp,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: item.color,
                                    ),
                                  ),
                                  SizedBox(width: 6.sp),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: lightMode
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      ),



                      // Values
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: valueLabels
                              .map(
                                (value) => Padding(
                              padding: EdgeInsets.only(bottom: 5.sp),
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color:
                                  lightMode ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      ),

                      SizedBox(width: 30.sp),

                      // Pie Chart
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: responsivePieHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: responsiveCenterRadius,
                                  sections: data
                                      .map(
                                        (item) => PieChartSectionData(
                                      value: item.value,
                                      color: item.color,
                                      radius: responsiveRadius,
                                      title: "",
                                      showTitle: false,
                                    ),
                                  )
                                      .toList(),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    totalValue,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color:
                                      lightMode ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    totalLabel,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color:
                                      lightMode ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class CustomPieChartGraphicWithLabelsWidget extends StatelessWidget {
  final String title;
  final String? iconAsset;
  final String totalValue;
  final String totalLabel;
  final List<ChartDataItem> data;
  final List<String> valueLabels;
  final bool lightMode;
  final double? height;

  const CustomPieChartGraphicWithLabelsWidget({
    super.key,
    required this.title,
    required this.totalValue,
    required this.totalLabel,
    required this.data,
    required this.valueLabels,
    this.iconAsset,
    required this.lightMode,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final defaultBgColor = lightMode ? AppColors.white : AppColors.chatBackground;

    return Container(
      height: height ?? (isMobile ? 220.sp : 200.sp),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: defaultBgColor,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                if (iconAsset != null)
                  Container(
                    width: 26.sp,
                    height: 26.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD8A353),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        iconAsset!,
                        width: 16.sp,
                        height: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                SizedBox(width: 7.sp),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: lightMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),

           // SizedBox(height: 15.sp),

            // Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Labels
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data
                          .map(
                            (item) => Padding(
                          padding: EdgeInsets.only(bottom: 5.sp),
                          child: Row(
                            children: [
                              Container(
                                width: 14.sp,
                                height: 14.sp,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: item.color,
                                ),
                              ),
                              SizedBox(width: 6.sp),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: lightMode
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),

                  SizedBox(width: 60.sp),

                  // Values
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: valueLabels
                          .map(
                            (value) => Padding(
                          padding: EdgeInsets.only(bottom: 5.sp),
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color:
                              lightMode ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),

                  SizedBox(width: 30.sp),

                  // Graphic Pie Chart
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 155.sp,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Chart(
                            data: data.asMap().entries.map((entry) {
                              return {
                                'category': entry.value.label,
                                'value': entry.value.value,
                                'color': entry.value.color,
                              };
                            }).toList(),
                            variables: {
                              'category': Variable(
                                accessor: (Map map) => map['category'] as String,
                              ),
                              'value': Variable(
                                accessor: (Map map) => map['value'] as num,
                              ),
                            },
                            marks: [
                              IntervalMark(
                                color: ColorEncode(
                                  variable: 'category',
                                  values: data.map((e) => e.color).toList(),
                                ),
                              )
                            ],
                            coord: PolarCoord(
                              startRadius: 0.6,  // Inner radius
                              endRadius: 1.0,    // Outer radius
                              transposed: true,
                              dimFill: 0.02, // Additional spacing control
                            ),
                          ),

                          // Center Text
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                totalValue,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: lightMode ? Colors.black : Colors.white,
                                ),
                              ),
                              Text(
                                totalLabel,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: lightMode ? Colors.black : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// Helper class for Pie Chart Data
class ChartDataItem {
  final String label;
  final Color color;
  final double value;

  ChartDataItem({
    required this.label,
    required this.color,
    required this.value,
  });
}

// ============================================
// USAGE EXAMPLES
// ============================================

class ChartExamplesScreen extends StatelessWidget {
  const ChartExamplesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(title: const Text('Chart Examples')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            // Vertical Bar Chart with custom bar width
            CustomVerticalBarChartWidget(

              title: 'Product Consumption',
              labels: ['Water', 'Juice', 'Soda', 'Coffee'],
              values: [220, 300, 205, 320],
              barWidth: 40,  // Custom bar width (default is 30)
              lightMode: lightMode,
            ),

            // Horizontal Bar Chart with custom bar height
            CustomHorizontalBarChartWidget(
              title: 'Inventory Valuation',
              labels: ['Q1', 'Q2', 'Q3', 'Q4'],
              values: [355, 110, 53, 11],

              maxValue: 400,
              barHeight: 30,  // Custom bar height (default is 20)
              lightMode: lightMode,
            ),

            // Pie Chart
            CustomPieChartGraphicWithLabelsWidget(
              title: 'Demands',
              totalValue: '9K',
              totalLabel: 'Total',
              data: [
                ChartDataItem(
                  label: 'Assets',
                  color: Color(0xFFFFD452),
                  value: 40.0,
                ),
                ChartDataItem(
                  label: 'Consumables',
                  color: Color(0xFFACACAC),
                  value: 25.0,
                ),
              ],
              valueLabels: ['513', '513'],
              lightMode: lightMode,
            ),
          ],
        ),
      ),
    );
  }
}



const stockData = [
  {
    'time': '2015-11-19',
    'start': 8.18,
    'max': 8.33,
    'min': 7.98,
    'end': 8.32,
    'volume': 1810,
    'money': 14723.56
  },
  {
    'time': '2015-11-18',
    'start': 8.37,
    'max': 8.6,
    'min': 8.03,
    'end': 8.09,
    'volume': 2790.37,
    'money': 23309.19
  },
  {
    'time': '2015-11-17',
    'start': 8.7,
    'max': 8.78,
    'min': 8.32,
    'end': 8.37,
    'volume': 3729.04,
    'money': 31709.71
  },
  {
    'time': '2015-11-16',
    'start': 8.18,
    'max': 8.69,
    'min': 8.05,
    'end': 8.62,
    'volume': 3095.44,
    'money': 26100.69
  },
  {
    'time': '2015-11-13',
    'start': 8.01,
    'max': 8.75,
    'min': 7.97,
    'end': 8.41,
    'volume': 5815.58,
    'money': 48562.37
  },
  {
    'time': '2015-11-12',
    'start': 7.76,
    'max': 8.18,
    'min': 7.61,
    'end': 8.15,
    'volume': 4742.6,
    'money': 37565.36
  },
  {
    'time': '2015-11-11',
    'start': 7.55,
    'max': 7.81,
    'min': 7.49,
    'end': 7.8,
    'volume': 3133.82,
    'money': 24065.42
  },
  {
    'time': '2015-11-10',
    'start': 7.5,
    'max': 7.68,
    'min': 7.44,
    'end': 7.57,
    'volume': 2670.35,
    'money': 20210.58
  },
  {
    'time': '2015-11-09',
    'start': 7.65,
    'max': 7.66,
    'min': 7.3,
    'end': 7.58,
    'volume': 2841.79,
    'money': 21344.36
  },
  {
    'time': '2015-11-06',
    'start': 7.52,
    'max': 7.71,
    'min': 7.48,
    'end': 7.64,
    'volume': 2725.44,
    'money': 20721.51
  },
  {
    'time': '2015-11-05',
    'start': 7.48,
    'max': 7.57,
    'min': 7.29,
    'end': 7.48,
    'volume': 3520.85,
    'money': 26140.83
  },
  {
    'time': '2015-11-04',
    'start': 7.01,
    'max': 7.5,
    'min': 7.01,
    'end': 7.46,
    'volume': 3591.47,
    'money': 26285.52
  },
  {
    'time': '2015-11-03',
    'start': 7.1,
    'max': 7.17,
    'min': 6.82,
    'end': 7,
    'volume': 2029.21,
    'money': 14202.33
  },
  {
    'time': '2015-11-02',
    'start': 7.09,
    'max': 7.44,
    'min': 6.93,
    'end': 7.17,
    'volume': 3191.31,
    'money': 23205.11
  },
  {
    'time': '2015-10-30',
    'start': 6.98,
    'max': 7.27,
    'min': 6.84,
    'end': 7.18,
    'volume': 3522.61,
    'money': 25083.44
  },
  {
    'time': '2015-10-29',
    'start': 6.94,
    'max': 7.2,
    'min': 6.8,
    'end': 7.05,
    'volume': 2752.27,
    'money': 19328.44
  },
  {
    'time': '2015-10-28',
    'start': 7.01,
    'max': 7.14,
    'min': 6.8,
    'end': 6.85,
    'volume': 2311.11,
    'money': 16137.32
  },
  {
    'time': '2015-10-27',
    'start': 6.91,
    'max': 7.31,
    'min': 6.48,
    'end': 7.18,
    'volume': 3172.9,
    'money': 21827.3
  },
  {
    'time': '2015-10-26',
    'start': 6.9,
    'max': 7.08,
    'min': 6.87,
    'end': 6.95,
    'volume': 2769.31,
    'money': 19337.44
  },
  {
    'time': '2015-10-23',
    'start': 6.71,
    'max': 6.85,
    'min': 6.58,
    'end': 6.79,
    'volume': 2483.18,
    'money': 16714.31
  },
  {
    'time': '2015-10-22',
    'start': 6.38,
    'max': 6.67,
    'min': 6.34,
    'end': 6.65,
    'volume': 2225.88,
    'money': 14465.56
  },
];

const adjustData = [
  {"type": "Email", "index": 0, "value": 120},
  {"type": "Email", "index": 1, "value": 132},
  {"type": "Email", "index": 2, "value": 101},
  {"type": "Email", "index": 3, "value": 134},
  {"type": "Email", "index": 4, "value": 90},
  {"type": "Email", "index": 5, "value": 230},
  {"type": "Email", "index": 6, "value": 210},
  {"type": "Affiliate", "index": 0, "value": 220},
  {"type": "Affiliate", "index": 1, "value": 182},
  {"type": "Affiliate", "index": 2, "value": 191},
  {"type": "Affiliate", "index": 3, "value": 234},
  {"type": "Affiliate", "index": 4, "value": 290},
  {"type": "Affiliate", "index": 5, "value": 330},
  {"type": "Affiliate", "index": 6, "value": 310},
  {"type": "Video", "index": 0, "value": 150},
  {"type": "Video", "index": 1, "value": 232},
  {"type": "Video", "index": 2, "value": 201},
  {"type": "Video", "index": 3, "value": 154},
  {"type": "Video", "index": 4, "value": 190},
  {"type": "Video", "index": 5, "value": 330},
  {"type": "Video", "index": 6, "value": 410},
  {"type": "Direct", "index": 0, "value": 320},
  {"type": "Direct", "index": 1, "value": 332},
  {"type": "Direct", "index": 2, "value": 301},
  {"type": "Direct", "index": 3, "value": 334},
  {"type": "Direct", "index": 4, "value": 390},
  {"type": "Direct", "index": 5, "value": 330},
  {"type": "Direct", "index": 6, "value": 320},
  {"type": "Search", "index": 0, "value": 320},
  {"type": "Search", "index": 1, "value": 432},
  {"type": "Search", "index": 2, "value": 401},
  {"type": "Search", "index": 3, "value": 434},
  {"type": "Search", "index": 4, "value": 390},
  {"type": "Search", "index": 5, "value": 430},
  {"type": "Search", "index": 6, "value": 420},
];


const basicData = [
  {'genre': 'Sports', 'sold': 275},
  {'genre': 'Strategy', 'sold': 115},
  {'genre': 'Action', 'sold': 120},
  {'genre': 'Shooter', 'sold': 350},
  {'genre': 'Other', 'sold': 150},
];


const heatmapData = [
  [0, 0, 10],
  [0, 1, 19],
  [0, 2, 8],
  [0, 3, 24],
  [0, 4, 67],
  [1, 0, 92],
  [1, 1, 58],
  [1, 2, 78],
  [1, 3, 117],
  [1, 4, 48],
  [2, 0, 35],
  [2, 1, 15],
  [2, 2, 123],
  [2, 3, 64],
  [2, 4, 52],
  [3, 0, 72],
  [3, 1, 132],
  [3, 2, 114],
  [3, 3, 19],
  [3, 4, 16],
  [4, 0, 38],
  [4, 1, 5],
  [4, 2, 8],
  [4, 3, 117],
  [4, 4, 115],
  [5, 0, 88],
  [5, 1, 32],
  [5, 2, 12],
  [5, 3, 6],
  [5, 4, 120],
  [6, 0, 13],
  [6, 1, 44],
  [6, 2, 88],
  [6, 3, 98],
  [6, 4, 96],
  [7, 0, 31],
  [7, 1, 1],
  [7, 2, 82],
  [7, 3, 32],
  [7, 4, 30],
  [8, 0, 85],
  [8, 1, 97],
  [8, 2, 123],
  [8, 3, 64],
  [8, 4, 84],
  [9, 0, 47],
  [9, 1, 114],
  [9, 2, 31],
  [9, 3, 48],
  [9, 4, 91]
];



class TriangleShape extends IntervalShape {
  @override
  List<MarkElement> drawGroupPrimitives(
      List<Attributes> group,
      CoordConv coord,
      Offset origin,
      ) {
    assert(coord is RectCoordConv);
    assert(coord.transposed == false);

    final rst = <MarkElement>[];

    for (var item in group) {
      for (var point in item.position) {
        if (!point.dy.isFinite) {
          return [];
        }
      }

      final style = getPaintStyle(item, false, 0, null, null);

      final start = coord.convert(item.position[0]);
      final end = coord.convert(item.position[1]);
      final size = item.size ?? defaultSize;
      final startLeft = Offset(start.dx - size / 2, start.dy);
      final startRight = Offset(start.dx + size / 2, start.dy);

      rst.add(
          PolygonElement(points: [end, startLeft, startRight], style: style));
    }

    return rst;
  }

  @override
  List<MarkElement<ElementStyle>> drawGroupLabels(
      List<Attributes> group, CoordConv coord, Offset origin) {
    final rst = <MarkElement>[];

    for (var item in group) {
      bool nan = false;
      for (var point in item.position) {
        if (!point.dy.isFinite) {
          nan = true;
          break;
        }
      }
      if (!nan && item.label != null) {
        final end = coord.convert(item.position[1]);
        rst.add(LabelElement(
            text: item.label!.text!,
            anchor: end,
            defaultAlign: Alignment.topCenter,
            style: item.label!.style));
      }
    }

    return rst;
  }

  @override
  bool equalTo(Object other) => other is TriangleShape;
}

List<MarkElement> simpleTooltip(
    Size size,
    Offset anchor,
    Map<int, Tuple> selectedTuples,
    ) {
  List<MarkElement> elements;

  String textContent = '';
  final selectedTupleList = selectedTuples.values;
  final fields = selectedTupleList.first.keys.toList();
  if (selectedTuples.length == 1) {
    final original = selectedTupleList.single;
    var field = fields.first;
    textContent += '$field: ${original[field]}';
    for (var i = 1; i < fields.length; i++) {
      field = fields[i];
      textContent += '\n$field: ${original[field]}';
    }
  } else {
    for (var original in selectedTupleList) {
      final domainField = fields.first;
      final measureField = fields.last;
      textContent += '\n${original[domainField]}: ${original[measureField]}';
    }
  }

  const textStyle = TextStyle(fontSize: 12, color: Colors.white);
  const padding = EdgeInsets.all(5);
  const align = Alignment.topRight;
  const offset = Offset(5, -5);
  const elevation = 1.0;
  const backgroundColor = Colors.black;

  final painter = TextPainter(
    text: TextSpan(text: textContent, style: textStyle),
    textDirection: TextDirection.ltr,
  );
  painter.layout();

  final width = padding.left + painter.width + padding.right;
  final height = padding.top + painter.height + padding.bottom;

  final paintPoint = getBlockPaintPoint(
    anchor + offset,
    width,
    height,
    align,
  );

  final window = Rect.fromLTWH(
    paintPoint.dx,
    paintPoint.dy,
    width,
    height,
  );

  var textPaintPoint = paintPoint + padding.topLeft;

  elements = <MarkElement>[
    RectElement(
        rect: window,
        style: PaintStyle(fillColor: backgroundColor, elevation: elevation)),
    LabelElement(
        text: textContent,
        anchor: textPaintPoint,
        style: LabelStyle(textStyle: textStyle, align: Alignment.bottomRight)),
  ];

  return elements;
}

List<MarkElement> centralPieLabel(
    Size size,
    Offset anchor,
    Map<int, Tuple> selectedTuples,
    ) {
  final tuple = selectedTuples.values.last;

  final titleElement = LabelElement(
      text: '${tuple['genre']}\n',
      anchor: const Offset(175, 150),
      style: LabelStyle(
          textStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          align: Alignment.topCenter));

  final valueElement = LabelElement(
      text: tuple['sold'].toString(),
      anchor: const Offset(175, 150),
      style: LabelStyle(
          textStyle: const TextStyle(
            fontSize: 28,
            color: Colors.black87,
          ),
          align: Alignment.bottomCenter));

  return [titleElement, valueElement];
}

class PolygonCustomPage extends StatelessWidget {
  PolygonCustomPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Custom'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Heatmap',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(
                      accessor: (List datum) => datum[0].toString(),
                    ),
                    'day': Variable(
                      accessor: (List datum) => datum[1].toString(),
                    ),
                    'sales': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                  },
                  marks: [
                    PolygonMark(
                      color: ColorEncode(
                        variable: 'sales',
                        values: [
                          const Color(0xffbae7ff),
                          const Color(0xff1890ff),
                          const Color(0xff0050b3)
                        ],
                      ),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection()},
                  tooltip: TooltipGuide(),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Heatmap fade',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Tap to select one, and others will fade.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With corner radius.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(
                      accessor: (List datum) => datum[0].toString(),
                    ),
                    'day': Variable(
                      accessor: (List datum) => datum[1].toString(),
                    ),
                    'sales': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                  },
                  marks: [
                    PolygonMark(
                      shape: ShapeEncode(
                          value: HeatmapShape(
                              borderRadius: BorderRadius.circular(4))),
                      color: ColorEncode(
                        variable: 'sales',
                        values: [
                          const Color(0xffbae7ff),
                          const Color(0xff1890ff),
                          const Color(0xff0050b3)
                        ],
                        updaters: {
                          'tap': {false: (color) => color.withAlpha(70)}
                        },
                      ),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection()},
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Polar Heatmap of Polygon',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Tap to select one for tooltip, and others will fade.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(
                      accessor: (List datum) => datum[0].toString(),
                    ),
                    'day': Variable(
                      accessor: (List datum) => datum[1].toString(),
                    ),
                    'sales': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                  },
                  marks: [
                    PolygonMark(
                      color: ColorEncode(
                        variable: 'sales',
                        values: [
                          const Color(0xffbae7ff),
                          const Color(0xff1890ff),
                          const Color(0xff0050b3)
                        ],
                        updaters: {
                          'tap': {false: (color) => color.withAlpha(70)}
                        },
                      ),
                    )
                  ],
                  coord: PolarCoord(),
                  selections: {'tap': PointSelection()},
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Polar Heatmap of Sector',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Tap to select one for tooltip, and others will fade.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: heatmapData,
                  variables: {
                    'name': Variable(
                      accessor: (List datum) => datum[0].toString(),
                    ),
                    'day': Variable(
                      accessor: (List datum) => datum[1].toString(),
                    ),
                    'sales': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                  },
                  marks: [
                    PolygonMark(
                      shape: ShapeEncode(value: HeatmapShape(sector: true)),
                      color: ColorEncode(
                        variable: 'sales',
                        values: [
                          const Color(0xffbae7ff),
                          const Color(0xff1890ff),
                          const Color(0xff0050b3)
                        ],
                        updaters: {
                          'tap': {false: (color) => color.withAlpha(70)}
                        },
                      ),
                    )
                  ],
                  coord: PolarCoord(),
                  selections: {'tap': PointSelection()},
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Custom Shape and Tooltip',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- A custom shape attribution should corresponds to the geometry elemnet type.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                        accessor: (Map map) => map['sold'] as num,
                        scale: LinearScale(min: 0)),
                  },
                  marks: [
                    IntervalMark(
                      shape: ShapeEncode(value: TriangleShape()),
                      label: LabelEncode(
                          encoder: (tuple) => Label(tuple['sold'].toString())),
                      elevation: ElevationEncode(value: 0, updaters: {
                        'tap': {true: (_) => 5}
                      }),
                      color:
                      ColorEncode(value: Defaults.primaryColor, updaters: {
                        'tap': {false: (color) => color.withAlpha(100)}
                      }),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection(dim: Dim.x)},
                  tooltip: TooltipGuide(renderer: simpleTooltip),
                  crosshair: CrosshairGuide(),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Central Pie Label by Custom Tooltip',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                    ),
                  },
                  transforms: [
                    Proportion(
                      variable: 'sold',
                      as: 'percent',
                    )
                  ],
                  marks: [
                    IntervalMark(
                      position: Varset('percent') / Varset('genre'),
                      color: ColorEncode(
                          variable: 'genre', values: Defaults.colors10),
                      modifiers: [StackModifier()],
                    )
                  ],
                  coord: PolarCoord(
                    transposed: true,
                    dimCount: 1,
                    startRadius: 0.4,
                  ),
                  selections: {'tap': PointSelection()},
                  tooltip: TooltipGuide(renderer: centralPieLabel),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Custom Legend',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Custom legend by mark and tag annotations.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With dodge modifier.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  padding: (_) => const EdgeInsets.fromLTRB(40, 5, 10, 40),
                  data: adjustData,
                  variables: {
                    'index': Variable(
                      accessor: (Map map) => map['index'].toString(),
                    ),
                    'type': Variable(
                      accessor: (Map map) => map['type'] as String,
                    ),
                    'value': Variable(
                      accessor: (Map map) => map['value'] as num,
                    ),
                  },
                  marks: [
                    IntervalMark(
                      position:
                      Varset('index') * Varset('value') / Varset('type'),
                      color: ColorEncode(
                          variable: 'type', values: Defaults.colors10),
                      size: SizeEncode(value: 2),
                      modifiers: [DodgeModifier(ratio: 0.1)],
                    )
                  ],
                  coord: RectCoord(
                    horizontalRangeUpdater: Defaults.horizontalRangeEvent,
                  ),
                  axes: [
                    Defaults.horizontalAxis..tickLine = TickLine(),
                    Defaults.verticalAxis,
                  ],
                  selections: {
                    'tap': PointSelection(
                      variable: 'index',
                    )
                  },
                  tooltip: TooltipGuide(multiTuples: true),
                  crosshair: CrosshairGuide(),
                  annotations: [
                    CustomAnnotation(
                        renderer: (_, size) => [
                          CircleElement(
                              center: const Offset(25, 290),
                              radius: 5,
                              style: PaintStyle(
                                  fillColor: Defaults.colors10[0]))
                        ],
                        anchor: (p0) => const Offset(0, 0)),
                    TagAnnotation(
                      label: Label(
                        'Email',
                        LabelStyle(
                            textStyle: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => const Offset(34, 290),
                    ),
                    CustomAnnotation(
                        renderer: (_, size) => [
                          CircleElement(
                              center: Offset(25 + size.width / 5, 290),
                              radius: 5,
                              style: PaintStyle(
                                  fillColor: Defaults.colors10[1]))
                        ],
                        anchor: (p0) => const Offset(0, 0)),
                    TagAnnotation(
                      label: Label(
                        'Affiliate',
                        LabelStyle(
                            textStyle: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5, 290),
                    ),
                    CustomAnnotation(
                        renderer: (_, size) => [
                          CircleElement(
                              center: Offset(25 + size.width / 5 * 2, 290),
                              radius: 5,
                              style: PaintStyle(
                                  fillColor: Defaults.colors10[2]))
                        ],
                        anchor: (p0) => const Offset(0, 0)),
                    TagAnnotation(
                      label: Label(
                        'Video',
                        LabelStyle(
                            textStyle: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5 * 2, 290),
                    ),
                    CustomAnnotation(
                        renderer: (_, size) => [
                          CircleElement(
                              center: Offset(25 + size.width / 5 * 3, 290),
                              radius: 5,
                              style: PaintStyle(
                                  fillColor: Defaults.colors10[3]))
                        ],
                        anchor: (p0) => const Offset(0, 0)),
                    TagAnnotation(
                      label: Label(
                        'Direct',
                        LabelStyle(
                            textStyle: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5 * 3, 290),
                    ),
                    CustomAnnotation(
                        renderer: (_, size) => [
                          CircleElement(
                              center: Offset(25 + size.width / 5 * 4, 290),
                              radius: 5,
                              style: PaintStyle(
                                  fillColor: Defaults.colors10[4]))
                        ],
                        anchor: (p0) => const Offset(0, 0)),
                    TagAnnotation(
                      label: Label(
                        'Search',
                        LabelStyle(
                            textStyle: Defaults.textStyle,
                            align: Alignment.centerRight),
                      ),
                      anchor: (size) => Offset(34 + size.width / 5 * 4, 290),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Custom Modifier',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With dodge and size modifier that scales the interval mark width to fit within its band',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  padding: (_) => const EdgeInsets.fromLTRB(40, 5, 10, 40),
                  data: adjustData,
                  variables: {
                    'index': Variable(
                      accessor: (Map map) => map['index'].toString(),
                    ),
                    'type': Variable(
                      accessor: (Map map) => map['type'] as String,
                    ),
                    'value': Variable(
                      accessor: (Map map) => map['value'] as num,
                    ),
                  },
                  marks: [
                    IntervalMark(
                      position:
                      Varset('index') * Varset('value') / Varset('type'),
                      color: ColorEncode(
                          variable: 'type', values: Defaults.colors10),
                      size: SizeEncode(value: 2),
                      modifiers: [DodgeSizeModifier()],
                    )
                  ],
                  coord: RectCoord(
                    horizontalRangeUpdater: Defaults.horizontalRangeEvent,
                  ),
                  axes: [
                    Defaults.horizontalAxis..tickLine = TickLine(),
                    Defaults.verticalAxis,
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Candlestick Chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- A candlestick custom shape is provided.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Shape must be designated explicitly for a custom mark.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Make sure to specify a same scale for all variables in a same dimension.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'We insist that the price of a subject matter of investment is determined by its intrinsic value. Too much attention to the short-term fluctuations in prices is harmful. Thus a candlestick chart may misslead your investment decision.',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: stockData.reversed.toList(),
                  variables: {
                    'time': Variable(
                      accessor: (Map datumn) => datumn['time'].toString(),
                      scale: OrdinalScale(tickCount: 4),
                    ),
                    'start': Variable(
                      accessor: (Map datumn) => datumn['start'] as num,
                      scale: LinearScale(min: 6, max: 9),
                    ),
                    'max': Variable(
                      accessor: (Map datumn) => datumn['max'] as num,
                      scale: LinearScale(min: 6, max: 9),
                    ),
                    'min': Variable(
                      accessor: (Map datumn) => datumn['min'] as num,
                      scale: LinearScale(min: 6, max: 9),
                    ),
                    'end': Variable(
                      accessor: (Map datumn) => datumn['end'] as num,
                      scale: LinearScale(min: 6, max: 9),
                    ),
                  },
                  marks: [
                    CustomMark(
                      shape: ShapeEncode(value: CandlestickShape()),
                      position: Varset('time') *
                          (Varset('start') +
                              Varset('max') +
                              Varset('min') +
                              Varset('end')),
                      color: ColorEncode(
                          encoder: (tuple) => tuple['end'] >= tuple['start']
                              ? Colors.red
                              : Colors.green),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  coord: RectCoord(
                      horizontalRangeUpdater: Defaults.horizontalRangeEvent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _kBaseGroupPaddingHorizontal = 32.0;
const _kMinBarSize = 4.0;

/// Changes the position of marks while also updating their width to match
/// the number of marks in a single band. Useful for bar charts when the
/// width of the bars can be dynamic.
@immutable
class DodgeSizeModifier extends Modifier {
  @override
  AttributesGroups modify(
      AttributesGroups groups,
      Map<String, ScaleConv<dynamic, num>> scales,
      AlgForm form,
      CoordConv coord,
      Offset origin) {
    final xField = form.first[0];
    final band = (scales[xField]! as DiscreteScaleConv).band;

    final ratio = 1 / groups.length;
    final numGroups = groups.length;
    final groupHorizontalPadding = _kBaseGroupPaddingHorizontal / numGroups;
    final invertedGroupPaddingHorizontal =
    coord.invertDistance(groupHorizontalPadding, Dim.x);

    final effectiveBand = band - 2 * invertedGroupPaddingHorizontal;

    final maxWidth = coord.convert(const Offset(1, 0)).dx;
    final maxWidthInBand = effectiveBand * maxWidth;
    final maxWidthPerAttributes = maxWidthInBand / numGroups;
    final barHorizontalPadding = groupHorizontalPadding / 2;
    final size =
    max(maxWidthPerAttributes - barHorizontalPadding, _kMinBarSize);

    final bias = ratio * effectiveBand;

    // Negatively shift half of the total bias.
    var accumulated = -bias * (numGroups + 1) / 2;

    final AttributesGroups rst = [];
    for (final group in groups) {
      final groupRst = <Attributes>[];
      for (final attributes in group) {
        final oldPosition = attributes.position;

        groupRst.add(Attributes(
          index: attributes.index,
          tag: attributes.tag,
          position: oldPosition
              .map(
                (point) => Offset(point.dx + accumulated + bias, point.dy),
          )
              .toList(),
          shape: attributes.shape,
          color: attributes.color,
          gradient: attributes.gradient,
          elevation: attributes.elevation,
          label: attributes.label,
          size: size,
        ));
      }
      rst.add(groupRst);
      accumulated += bias;
    }

    return rst;
  }

  @override
  bool equalTo(Object other) {
    return other is DodgeSizeModifier;
  }
}