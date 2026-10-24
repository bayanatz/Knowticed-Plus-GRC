/// Module: services / presentation / widgets / charts
///
///*************************** FILE INFO ****************************///
/// File Name: vertical_bar_chart_widget.dart
/// Purpose: The dashboard's vertical bar chart card — title, optional
///          header control, optional second series with a legend, and a
///          plot that scrolls when the bars do not fit (three at a time on
///          a phone).
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_durations.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/charts/bar_chart_pieces.dart';

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

  /// Show all twelve months; [labels] are then English month names
  /// ("Jan", "February"…) and missing months are drawn as zero.
  final bool showAllMonths;

  /// Second data series, plotted beside [values] in each slot. Same length
  /// as [values]. Null or empty = single series (no legend).
  final List<double>? secondaryValues;

  /// Bar colour for [secondaryValues]. Defaults to AppColors.red.
  final Color? secondaryBarColor;

  /// Legend caption for [values]; shown only with a second series.
  final String? legendLabel;

  /// Legend caption for [secondaryValues].
  final String? secondaryLegendLabel;

  /// True when a usable second series was supplied.
  bool get hasSecondarySeries =>
      secondaryValues != null && secondaryValues!.isNotEmpty;

  const CustomVerticalBarChartWidget({
    super.key,
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
    this.secondaryValues,
    this.secondaryBarColor,
    this.legendLabel,
    this.secondaryLegendLabel,
  });

  @override
  State<CustomVerticalBarChartWidget> createState() =>
      _CustomVerticalBarChartWidgetState();
}

/// The bars and labels the chart draws, after month padding.
class _PlotData {
  final List<String> labels;
  final List<double> values;
  final List<double>? secondaryValues;

  const _PlotData(this.labels, this.values, this.secondaryValues);
}

class _CustomVerticalBarChartWidgetState
    extends State<CustomVerticalBarChartWidget> {
  /// How many bars a phone shows at once before the plot scrolls.
  static const int _kMobileVisibleBars = 3;

  /// Minimum width of the fixed value-axis strip on a phone.
  static const double _kMobileAxisWidth = 14.0;

  /// Width of one bar slot when a wide screen scrolls.
  static const double _kDesktopSlotWidth = 80.0;

  /// Height of the category-label row under the plot. The phone's axis
  /// strip is inset by it so the numbers span the plot, not plot + labels.
  static double get _kLabelRowHeight => 28.sp;

  ScrollController? _scrollController;
  bool _didInitScroll = false;

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  double _dataMaxY() {
    if (widget.values.isEmpty) return 10.0;
    if (widget.maxY != null) return widget.maxY!;
    var top = 0.0;
    for (final v in [...widget.values, ...?widget.secondaryValues]) {
      if (v > top) top = v;
    }
    return BarChartScale.niceMax(top);
  }

  /// Month (1-12) an English label names ("Jan", "january"), or null.
  /// Whole-word match only, so a category such as "Marketing" is never
  /// taken for March.
  static int? _monthOfLabel(String label) {
    final lower = label.toLowerCase().trim();
    final short = DateFormat.MMM('en');
    final long = DateFormat.MMMM('en');
    for (var month = 1; month <= 12; month++) {
      final date = DateTime(2000, month);
      if (lower == short.format(date).toLowerCase() ||
          lower == long.format(date).toLowerCase()) {
        return month;
      }
    }
    return null;
  }

  _PlotData _prepare(BuildContext context) {
    final second = widget.hasSecondarySeries ? widget.secondaryValues! : null;
    if (!widget.showAllMonths) {
      return _PlotData(
        [
          for (final label in widget.labels)
            switch (_monthOfLabel(label)) {
              final int month => context.svcMonthShort(month),
              _ => label,
            },
        ],
        List<double>.from(widget.values),
        second == null ? null : List<double>.from(second),
      );
    }

    final byMonth = <int, double>{};
    final secondByMonth = <int, double>{};
    for (var i = 0; i < widget.labels.length; i++) {
      final month = _monthOfLabel(widget.labels[i]);
      if (month == null) continue;
      byMonth[month] = widget.values[i];
      if (second != null && i < second.length) secondByMonth[month] = second[i];
    }
    return _PlotData(
      [for (var m = 1; m <= 12; m++) context.svcMonthShort(m)],
      [for (var m = 1; m <= 12; m++) byMonth[m] ?? 0],
      second == null
          ? null
          : [for (var m = 1; m <= 12; m++) secondByMonth[m] ?? 0],
    );
  }

  /// The axis strip is at least as wide as its widest number.
  double _axisWidth(BuildContext context, double maxY, bool isMobile) {
    final painter = TextPainter(
      text: TextSpan(
        text: context.svcNumber(maxY.toInt()),
        style: dashboardAxisLabelStyle(isMobile),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    final minimum = isMobile ? _kMobileAxisWidth : 13.w;
    final needed = painter.width + (isMobile ? 5 : 6.sp);
    return needed > minimum ? needed : minimum;
  }

  @override
  Widget build(BuildContext context) {
    final barColor = widget.barColor ?? AppColors.primary;
    final iconBackground = widget.iconBackgroundColor ?? AppColors.primary;
    final secondaryColor = widget.secondaryBarColor ?? AppColors.red;
    final isArabic = context.svcIsArabic;

    final data = _prepare(context);
    final rawMaxY = _dataMaxY();
    final interval = BarChartScale.interval(rawMaxY);
    final maxY = BarChartScale.alignToStep(rawMaxY, interval);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;
    // A phone shows at most three bars; wide screens scroll only when the
    // bars would get narrower than 70.
    final shouldScroll = isMobile
        ? data.values.length > _kMobileVisibleBars
        : data.values.length * 70.0 > screenWidth - 30.sp;
    final axisWidth = _axisWidth(context, maxY, isMobile);

    if (shouldScroll) {
      _scrollController ??= ScrollController();
      if (isArabic && !_didInitScroll) {
        _didInitScroll = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final controller = _scrollController;
          if (controller != null && controller.hasClients) {
            controller.jumpTo(controller.position.maxScrollExtent);
          }
        });
      }
    }

    final plot = _PlotLayout(
      data: data,
      maxY: maxY,
      interval: interval,
      isMobile: isMobile,
      axisWidth: axisWidth,
      barColor: barColor,
      secondaryColor: secondaryColor,
      barWidth: widget.barWidth ?? 30,
      showGrid: widget.showGrid,
      lightMode: widget.lightMode,
      labelRowHeight: _kLabelRowHeight,
    );

    return Container(
      width: widget.width?.w,
      height: widget.height?.h,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.iconAsset != null) ...[
                Container(
                  width: 26.sp,
                  height: 26.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBackground,
                  ),
                  child: Center(
                    child: CustomSvgImage.natural(
                      assetPath: widget.iconAsset!,
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
              ],
              Expanded(
                child: Text(
                  widget.title,
                  style: StyleText.fontSize14Weight600.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
              if (!isMobile && widget.headerWidget != null)
                widget.headerWidget!,
            ],
          ),
          // The legend is the chart's key, straight under the title.
          if (data.secondaryValues != null) ...[
            SizedBox(height: 12.sp),
            _Legend(
              primaryColor: barColor,
              secondaryColor: secondaryColor,
              primaryLabel: widget.legendLabel ?? '',
              secondaryLabel: widget.secondaryLegendLabel ?? '',
            ),
          ],
          if (isMobile && widget.headerWidget != null) ...[
            SizedBox(height: 12.sp),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: widget.headerWidget!,
            ),
          ],
          SizedBox(height: 20.sp),
          Expanded(
            child: shouldScroll
                ? plot.scrolling(context, _scrollController)
                : plot.fixed(context),
          ),
        ],
      ),
    );
  }
}

/// Lays out the axis strip, the bars and the label row, either fitted to
/// the card ([fixed]) or in a horizontal scroll view ([scrolling]).
class _PlotLayout {
  final _PlotData data;
  final double maxY;
  final double interval;
  final bool isMobile;
  final double axisWidth;
  final Color barColor;
  final Color secondaryColor;
  final double barWidth;
  final bool showGrid;
  final bool lightMode;
  final double labelRowHeight;

  const _PlotLayout({
    required this.data,
    required this.maxY,
    required this.interval,
    required this.isMobile,
    required this.axisWidth,
    required this.barColor,
    required this.secondaryColor,
    required this.barWidth,
    required this.showGrid,
    required this.lightMode,
    required this.labelRowHeight,
  });

  double? _secondAt(int index) {
    final second = data.secondaryValues;
    return (second != null && index < second.length) ? second[index] : null;
  }

  Widget _slot(int index, double width) => BarSlot(
        value: data.values[index],
        maxY: maxY,
        barColor: barColor,
        barWidth: width,
        secondValue: _secondAt(index),
        secondBarColor: secondaryColor,
      );

  Widget _bars(Widget Function(int index) slot) => Stack(
        children: [
          if (showGrid)
            Positioned.fill(
              child: PlotGrid(
                  maxY: maxY, interval: interval, lightMode: lightMode),
            ),
          Row(children: [for (var i = 0; i < data.values.length; i++) slot(i)]),
        ],
      );

  Widget _axis() =>
      ValueAxisLabels(maxY: maxY, interval: interval, isMobile: isMobile);

  /// Every bar fits: the axis sits at the reading start, labels below.
  Widget fixed(BuildContext context) {
    final width = isMobile ? 20.0 : barWidth;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(width: axisWidth, child: _axis()),
              Expanded(child: _bars((i) => Expanded(child: _slot(i, width)))),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: axisWidth),
          child: SizedBox(
            height: labelRowHeight,
            child: Row(
              children: [
                for (final label in data.labels)
                  Expanded(
                    child: CategoryLabel(label: label, isMobile: isMobile),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// More bars than fit: a fixed axis and a scrolling plot that opens on
  /// the first bar with a value.
  Widget scrolling(BuildContext context, ScrollController? controller) {
    return Row(
      children: [
        SizedBox(
          width: axisWidth,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: isMobile ? labelRowHeight : 0,
            ),
            child: _axis(),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = isMobile
                  ? constraints.maxWidth /
                      _CustomVerticalBarChartWidgetState._kMobileVisibleBars
                  : _CustomVerticalBarChartWidgetState._kDesktopSlotWidth;
              _scrollToFirstValue(context, controller, constraints, itemWidth);
              final width = isMobile ? 20.0 : 24.0;
              return SingleChildScrollView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: data.values.length * itemWidth,
                  child: Column(
                    children: [
                      Expanded(
                        child: _bars(
                          (i) => SizedBox(
                            width: itemWidth,
                            child: _slot(i, width),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: labelRowHeight,
                        child: Row(
                          children: [
                            for (final label in data.labels)
                              SizedBox(
                                width: itemWidth,
                                child: CategoryLabel(
                                  label: label,
                                  isMobile: isMobile,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _scrollToFirstValue(
    BuildContext context,
    ScrollController? controller,
    BoxConstraints constraints,
    double itemWidth,
  ) {
    final first = data.values.indexWhere((v) => v > 0);
    if (first <= 0 || controller == null) return;
    final centreOn =
        isMobile ? constraints.maxWidth : MediaQuery.sizeOf(context).width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      final target = (first * itemWidth - centreOn / 2 + itemWidth / 2).clamp(
        0.0,
        controller.position.maxScrollExtent,
      );
      controller.animateTo(
        target,
        duration: ServicesDurations.chartScroll,
        curve: Curves.easeOut,
      );
    });
  }
}

/// The two legend keys, shown only with a second series.
class _Legend extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final String primaryLabel;
  final String secondaryLabel;

  const _Legend({
    required this.primaryColor,
    required this.secondaryColor,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  Widget _entry(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.sp,
            height: 10.sp,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 6.sp),
          Text(
            label,
            style: StyleText.fontSize12Weight500.copyWith(
              color: dashboardPlotLabelColor,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (primaryLabel.isNotEmpty) _entry(primaryColor, primaryLabel),
        if (primaryLabel.isNotEmpty && secondaryLabel.isNotEmpty)
          SizedBox(width: 16.sp),
        if (secondaryLabel.isNotEmpty) _entry(secondaryColor, secondaryLabel),
      ],
    );
  }
}
