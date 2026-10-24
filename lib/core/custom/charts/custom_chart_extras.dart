/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_chart_extras.dart
/// Purpose: Shared helpers for the Adding Widget "Chart & Graph" cards —
///          `ChartViewDetails`, `ChartRangeTabs`, `ChartCountBadge`,
///          `StackedChartData` and the axis number formatter.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026 - Added with the Figma "Chart & Graph" tab pass
///          (Settings > Home Layout > Adding Widget, iPad Horizontal View).
library;

// These pieces repeat across the Figma chart cards but are not chart-type
// specific, so they live here instead of being duplicated in 92..97.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// One bar made of stacked segments, one value per series.
///
/// Used by `StackedBarChartCard` (92) and `HorizontalStackedBarChartCard`
/// (93). The series definitions (label + color) are passed separately so
/// several bars share one legend, exactly like `GroupedBarData` (29) does for
/// grouped bars.
class StackedChartData {
  final String label;
  final List<double> values;

  const StackedChartData({required this.label, required this.values});

  double get total => values.fold<double>(0, (double sum, double v) => sum + v);
}

/// The ONE type scale of every chart card (Moataz 23/10/2026: "the numbers,
/// the font size, they are not equal").
///
/// Before: the cards asked `CardStyles.label(9)` / `title(10)`, and
/// `CardStyles` has no 9 (or 10 medium) — it silently fell back to 14 / 16, so
/// the x-axis names were the biggest text on the card while the bar values were
/// 10. Now: axis names, axis numbers and legends are all 11 regular grey; every
/// figure is 11 medium dark. Titles stay 14 medium ([ChartCard]).
abstract final class ChartText {
  /// Axis names and numbers, legends, links.
  static TextStyle get axis =>
      StyleText.fontSize11Weight400.copyWith(color: AppColors.secondaryText);

  /// A figure — the number on a bar, a table value.
  static TextStyle get value => StyleText.fontSize11Weight400
      .copyWith(color: AppColors.text, fontWeight: FontWeight.w500);
}

/// Rounds [v] UP to a clean axis top (1, 1.5, 2, 2.5, 3, 4, 5, 6, 8 × 10ⁿ), so
/// the half-way tick is also clean: a top of 40K gives 0 · 20K · 40K, not
/// 0 · 7.8K · 15.6K (Moataz 23/10/2026).
double niceChartTop(double v) {
  if (v <= 0) return 100;
  double e = 1;
  while (v / e >= 10) {
    e *= 10;
  }
  while (v / e < 1) {
    e /= 10;
  }
  for (final double f in <double>[1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10]) {
    if (f * e >= v - 1e-9) return f * e;
  }
  return 10 * e;
}

/// Gives [child] the card's leftover height when [fill] (a pinned-height Home
/// chart), else leaves it as is — so a plot fills its card exactly and the
/// bottom gap equals the side gap (Moataz 24/10/2026).
Widget fillIf(bool fill, Widget child) => fill ? Expanded(child: child) : child;

/// Function Name: [formatAxisValue]
///
/// Purpose: Format an axis tick the way the Figma charts show it — `0`,
///          `15K`, `30K` rather than `0`, `15000`, `30000`. Never wraps.
///
/// Parameters:
/// - [value]: The raw axis value.
///
/// Returns: [String] the label to draw on the axis.
String formatAxisValue(double value) {
  if (value == 0) return '0';
  if (value.abs() >= 1000000) {
    final double m = value / 1000000;
    return '${m == m.roundToDouble() ? m.toInt() : m.toStringAsFixed(1)}M';
  }
  if (value.abs() >= 1000) {
    final double k = value / 1000;
    return '${k == k.roundToDouble() ? k.toInt() : k.toStringAsFixed(1)}K';
  }
  return value.toInt().toString();
}

/// The "View details" link shown at the bottom of most Figma chart cards.
class ChartViewDetails extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final AlignmentGeometry alignment;

  const ChartViewDetails({
    super.key,
    required this.text,
    this.onTap,
    this.alignment = AlignmentDirectional.centerStart,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: InkWell(
        onTapDown: hapticDown(onTap, HapticLevel.low),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Text(
            text,
            style: ChartText.axis.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

/// The `1 Days Ago | 7 days | 30 days` range row from the Figma chart headers.
///
/// Purely presentational: the caller owns [selectedIndex] and reacts to
/// [onSelected], so the card stays stateless.
class ChartRangeTabs extends StatelessWidget {
  final List<String> ranges;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const ChartRangeTabs({
    super.key,
    required this.ranges,
    this.selectedIndex = 0,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 23/10/2026 (Moataz): one small pill switch. The old row printed the
    // active range as 16 pt yellow text beside two small grey ones, so it read
    // as a second title; now the active range is a yellow chip with dark text
    // and the others are the axis grey, all 11.
    return Container(
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < ranges.length; i++)
            InkWell(
              onTapDown:
                  onSelected != null ? (_) => HapticController.low() : null,
              onTap: onSelected == null ? null : () => onSelected!(i),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: i == selectedIndex
                      ? AppColors.primary
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  ranges[i],
                  maxLines: 1,
                  style: i == selectedIndex
                      ? ChartText.value.copyWith(color: AppColors.textButton)
                      : ChartText.axis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The small dark count badge in the "Base Line Chart" header (Figma: `200`).
class ChartCountBadge extends StatelessWidget {
  final String text;
  final Color? color;

  const ChartCountBadge({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color ?? AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(text, style: ChartText.value),
    );
  }
}

/// Function Name: [chartPalette]
///
/// Purpose: The ten series colours of every chart that has no status meaning
///          (departments, months, modules): brand shades (golds / yellows)
///          alternating with greys. Built so a user can tell ANY two apart
///          (Moataz 24/10/2026):
///
///   * five brand shades at lightness .88 / [primary] / .50 / .37 / .25 and
///     five greys at .80 / .62 / .44 / .30 / .16 — each family is spaced
///     about .13–.2 apart, so two bars of the same family never blur;
///   * a brand shade and a grey of similar lightness still differ in colour
///     (the brand keeps its saturation, the grey has none);
///   * the ORDER alternates light and dark, brand and grey, so two bars that
///     sit side by side always contrast — in colour AND in grey-scale.
///
/// The brand shades come from [AppColors.primary] at call time, so a branding
/// change follows; the greys are neutral. Series 1 IS the primary.
List<Color> chartPalette() {
  final HSLColor b = HSLColor.fromColor(AppColors.primary);
  Color gold(double l) => b
      .withLightness(l)
      .withSaturation(
          (l > .8 ? b.saturation * .9 : b.saturation).clamp(0.0, 1.0))
      .toColor();
  Color grey(double l) => HSLColor.fromAHSL(1, 0, 0, l).toColor();
  return <Color>[
    AppColors.primary, // 1 brand
    grey(.16), //          2 charcoal
    gold(.88), //          3 pale gold
    grey(.44), //          4 mid grey
    gold(.25), //          5 bronze
    grey(.80), //          6 light grey
    gold(.37), //          7 deep gold
    grey(.62), //          8 silver
    gold(.50), //          9 gold
    grey(.30), //         10 dark grey
  ];
}

/// Function Name: [defaultChartSeriesColors]
///
/// Purpose: The colours a chart cycles through when its series carry none: the
///          ten-step [chartPalette].
List<Color> defaultChartSeriesColors() => chartPalette();

/// Function Name: [resolveSeriesColor]
///
/// Purpose: Pick the color for series [index], preferring an explicit
///          [ChartData.color] and falling back to [defaultChartSeriesColors].
///
/// Parameters:
/// - [series]: The chart's series definitions.
/// - [index]: Which series to resolve.
///
/// Returns: [Color] the color to paint that series with.
Color resolveSeriesColor(List<ChartData> series, int index) {
  if (index < series.length && series[index].color != null) {
    return series[index].color!;
  }
  final List<Color> palette = defaultChartSeriesColors();
  return palette[index % palette.length];
}
