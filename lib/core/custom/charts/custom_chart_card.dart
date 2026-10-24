/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: chart_card.dart
/// Description: Declares `ChartSvg`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - (Time Tracker UI fix round 1) `ChartLegendRow.maxLines`
///          (default 1 = unchanged) so a legend label can wrap instead of "…".
library;

// Shared shell + helpers for the chart widgets (Figma CHARTS section).
// Same style language as the card widgets: AppColors theme + screenutil.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_extras.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// SVG icon assets used by the chart widgets.
/// All paths point to existing, pubspec-declared assets in assets/icons_assets.
abstract class ChartSvg {
  static const String products =
      'assets/icons_assets/main_icons_assets/ic_data_inventory_products.svg';
  static const String orders =
      'assets/icons_assets/main_icons_assets/ic_data_service_requests.svg';
  static const String warehouse =
      'assets/icons_assets/main_icons_assets/ic_module_inventory.svg';
  static const String lowStock =
      'assets/icons_assets/main_icons_assets/ic_data_inventory_damaged.svg';
  static const String supplier =
      'assets/icons_assets/main_icons_assets/ic_building_office.svg';
  static const String request =
      'assets/icons_assets/main_icons_assets/ic_module_requests.svg';
  static const String present =
      'assets/icons_assets/main_icons_assets/ic_status_success_small.svg';
  static const String absent =
      'assets/icons_assets/main_icons_assets/ic_reason_reject.svg';
  static const String late =
      'assets/icons_assets/main_icons_assets/ic_time_clock.svg';
  static const String vacation =
      'assets/icons_assets/main_icons_assets/ic_status_todo_scheduled.svg';
  static const String excused =
      'assets/icons_assets/main_icons_assets/ic_module_request_change.svg';
}

/// White rounded container with the standard chart header:
/// [yellow dot] Title ........................ [trailing controls]
class ChartCard extends StatelessWidget {
  final String title;
  final Color? dotColor;
  final Widget? trailing;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final String? dotIcon; // ← add this

  /// Let [child] absorb the leftover vertical space instead of hugging
  /// its content. Only valid together with an explicit [height] (or a
  /// parent that gives a tight height) — a flexed child in an unbounded
  /// column asserts.
  final bool expandChild;

  /// With [expandChild]: the body scrolls up and down inside the card instead
  /// of being cut or scaled, so a list of any length stays reachable
  /// (24/10/2026 — every status / department, not the first three).
  final bool scrollBody;

  /// Drawn right under the title row (a legend, say), outside the scrolling
  /// body, so it stays put.
  final Widget? belowTitle;

  const ChartCard({
    super.key,
    required this.title,
    required this.child,
    this.dotColor,
    this.trailing,
    this.width,
    this.height,
    this.padding,
    this.dotIcon, // ← add this
    this.expandChild = false,
    this.scrollBody = false,
    this.belowTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      // Figma: card padding 16.
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Header marker: a tinted SVG icon when [dotIcon] is given,
              // otherwise the standard small colored dot.
              if (dotIcon != null)
                // Same proportions as the bar-chart card header: a 26 circle
                // with a 16 glyph centered inside, so the icon reads as a
                // badge instead of filling the whole circle.
                Container(
                  width: 26.r,
                  height: 26.r,
                  decoration: BoxDecoration(
                    color: dotColor ?? AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomSvgImage(
                      assetPath: dotIcon!,
                      width: 16.r,
                      height: 16.r,
                      fit: BoxFit.contain,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              // No standard dot any more (Moataz 23/10/2026: "no need for the
              // yellow circle in each title"); only an icon badge, when given.
              // GRC bug report p32: 6 read as the badge touching the title.
              if (dotIcon != null) SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: CardStyles.title(14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          // CHANGED 12/9/2026 — 20.sp on a phone, was 12.
          //
          // A bar chart draws its value label ABOVE the bar, so on a narrow
          // card the topmost "4" ended up level with the title row and the two
          // read as one line of overlapping text (Knowledge Hub Resources).
          // 12 was tuned on the wide cards, where the plot has room to breathe.
          //
          // Tablet and desktop keep 12.h — several cards there are pinned to a
          // fixed height with no slack to give, and they were never crowded.
          // A card pinned to a fixed height (the Home charts) takes a tighter gap, so
          // it does not overflow on a short window (the Mac; Moataz 24/10/2026).
          SizedBox(
              height: ContextExtension(context).isPhone
                  ? 20.sp
                  : (height != null ? 2.h : 12.h)),
          // NOTE: keep this branch intrinsic-safe. This card is used inside
          // IntrinsicHeight layouts (e.g. the knowledge dashboard's Dept +
          // Document-Utilization row, mirroring the services dashboard), and
          // IntrinsicHeight measures its children's intrinsic height. A
          // LayoutBuilder or a scroll view (viewport) cannot report an intrinsic
          // height, so wrapping [child] in either produces a zero-size render
          // box and crashes hit-testing ("Cannot hit test a render box with no
          // size"). Callers that give this card a FIXED height must therefore
          // pass one large enough for the content (or use expandChild).
          if (belowTitle != null) ...<Widget>[
            belowTitle!,
            SizedBox(height: 6.h),
          ],
          if (expandChild && scrollBody)
            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(scrollbars: false),
                child: SingleChildScrollView(child: child),
              ),
            )
          else if (expandChild)
            Expanded(child: child)
          else if (height != null)
            // 24/10/2026 (Moataz: the overflow stripes on the horizontal bar,
            // table and radial charts): a card pinned to a height shows its
            // whole content, scaled down just enough to fit — never cut and
            // never striped, in English or Arabic. Safe here because a fixed
            // height means a fixed-size cell around it, so the card is never
            // asked for its intrinsic height.
            Flexible(child: _FitHeight(child: child))
          else
            child,
        ],
      ),
    );
  }
}

/// Whether a bar chart renders vertically ([BarChartCard], 26) or
/// horizontally ([HorizontalBarChartCard], 28).
///
/// Moved here from the removed
/// home/h1_home_page/presentation/ui/services_management_module/dashboard_view_data/, so the chart
/// cards and the enum that selects between them live together in core.
enum ChartOrientation {
  horizontal,
  vertical;

  /// Convert enum to string for Firestore storage
  String toFirestore() => name;

  /// Create enum from Firestore string
  static ChartOrientation fromFirestore(String value) {
    switch (value.toLowerCase()) {
      case 'horizontal':
        return ChartOrientation.horizontal;
      case 'vertical':
        return ChartOrientation.vertical;
      default:
        return ChartOrientation.vertical; // Default fallback
    }
  }
}

/// One data entry for charts: label + value + color.
class ChartData {
  final String label;
  final double value;
  final Color? color;

  const ChartData({required this.label, required this.value, this.color});
}

/// Legend row item: [colored dot] Name ..... Amount
class ChartLegendRow extends StatelessWidget {
  final String name;
  final String? amount;
  final Color color;
  final double fontSize;

  /// ADDED 9/10/2026: lines the name may use before it ends in "…".
  /// Defaults to 1 (the historical single line); null = wrap freely.
  final int? maxLines;

  const ChartLegendRow({
    super.key,
    required this.name,
    required this.color,
    this.amount,
    this.fontSize = 12,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          // ONE legend style (23/10/2026): 8 dot, 6 gap, 11 grey text — the
          // same in a row legend, an inline legend and the pie / donut / radial.
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              name,
              style: ChartText.axis,
              maxLines: maxLines,
              overflow:
                  maxLines == 1 ? TextOverflow.ellipsis : TextOverflow.visible,
            ),
          ),
          // 9/10/2026 (Time Tracker UI pass): a gap so a long name never
          // touches its amount ("Annual Vacation2").
          if (amount != null) ...[
            SizedBox(width: 8.w),
            Text(amount!, style: ChartText.value),
          ],
        ],
      ),
    );
  }
}

/// Compact horizontal legend (dot + name) used above grouped charts.
class ChartLegendInline extends StatelessWidget {
  final List<ChartData> items;
  final double fontSize;

  /// Keep every entry on ONE line: when they do not fit, the line shrinks a
  /// little instead of dropping the last entry onto a second line (Moataz
  /// 24/10/2026, "Canceled" on a phone).
  final bool singleLine;

  const ChartLegendInline({
    super.key,
    required this.items,
    this.fontSize = 11,
    this.singleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> entries = [
      for (final item in items)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: item.color ?? AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(item.label, style: ChartText.axis),
          ],
        ),
    ];
    if (singleLine) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < entries.length; i++) ...[
              if (i > 0) SizedBox(width: 12.w),
              entries[i],
            ],
          ],
        ),
      );
    }
    return Wrap(spacing: 12.w, runSpacing: 4.h, children: entries);
  }
}

/// Small yellow pill tab (e.g. "Consumables") used in chart headers.
class ChartTabPill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;

  const ChartTabPill({super.key, required this.text, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: withHaptic(onTap, HapticLevel.low),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: CardStyles.title(11).copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}

/// Lays [child] out at the full width the card gives it and, when it is taller
/// than the room it was given, draws it scaled down just enough to fit — at a
/// WIDER layout width (width ÷ scale), so the scaled content still spans the
/// whole card instead of leaving a blank strip beside it (a plain FittedBox
/// scaled the width down too, 24/10/2026).
class _FitHeight extends SingleChildRenderObjectWidget {
  const _FitHeight({required Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderFitHeight();
}

class _RenderFitHeight extends RenderProxyBox {
  double _scale = 1;

  @override
  void performLayout() {
    final RenderBox? c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    final double w = constraints.maxWidth;
    final double room = constraints.maxHeight;
    double s = 1;
    c.layout(BoxConstraints.tightFor(width: w), parentUsesSize: true);
    for (int i = 0;
        i < 3 && room.isFinite && c.size.height * s > room + 0.01;
        i++) {
      s = (room / c.size.height).clamp(0.3, 1.0);
      c.layout(BoxConstraints.tightFor(width: w / s), parentUsesSize: true);
    }
    if (room.isFinite && c.size.height * s > room + 0.01) {
      s = (room / c.size.height).clamp(0.3, 1.0);
    }
    _scale = s;
    size = constraints.constrain(Size(w, c.size.height * s));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? c = child;
    if (c == null) return;
    context.pushClipRect(needsCompositing, offset, Offset.zero & size,
        (PaintingContext ctx, Offset o) {
      ctx.pushTransform(
        needsCompositing,
        o,
        Matrix4.diagonal3Values(_scale, _scale, 1),
        c.paint,
      );
    });
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.scaleByDouble(_scale, _scale, 1, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final RenderBox? c = child;
    if (c == null) return false;
    return result.addWithPaintTransform(
      transform: Matrix4.diagonal3Values(_scale, _scale, 1),
      position: position,
      hitTest: (BoxHitTestResult r, Offset p) => c.hitTest(r, position: p),
    );
  }
}
