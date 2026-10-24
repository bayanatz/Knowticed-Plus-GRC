/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_card_metrics.dart
/// Purpose: Declares `HomeCardMetrics` — the one place the home component
///          cards get their HEIGHT and their width SAFETY CAP from.
/// Author: Knowticed Plus team
/// Created: 31/8/2026
/// Updated: 7/10/2026 - Owner decision: every home card keeps its OWN width
///          on the dashboard, the layout editor and the widget picker. The
///          shared 250.sp `width` and the unused `box` are gone; `fitBox` and
///          `heightBox` now constrain width only to `minWidth 0` and a
///          [maxWidthOf] cap (screen width minus the panel gutters), so a card
///          is as wide as it declares and nothing can receive an infinite
///          width inside the horizontally scrolling rows.
///
/// WHY THIS EXISTS
/// ---------------
/// A home component is rendered by `HomeComponent.widget(model)`. Three
/// separate call sites build those cards:
///
///   • adding_widget_page.dart   → AddComponentWrapper      (the widget picker)
///   • edit_home_page.dart       → RemoveComponentWrapper   (the layout editor)
///   • home_screen.dart          → the component directly   (the dashboard)
///
/// All three go through [fitBox] (dashboard) or [heightBox] (editor, picker)
/// below, so height behaviour and the width cap live in one place.
///
/// WIDTH CONTRACT (7/10/2026)
/// --------------------------
/// Every module widget returned by `HomeComponents.widget()` declares its own
/// width (a `SizedBox`/`Container` width, or `HomeWidgetCard.width`, whose
/// default is `kHomeWidgetWidth`). The dashboard and editor rows sit inside a
/// horizontal `SingleChildScrollView`, which hands its children UNBOUNDED
/// width — so a card without a width that contains a `Row` + `Expanded` (or a
/// bare `Container()`) would either throw or stretch. The [maxWidthOf] cap is
/// the safety net for that case and also keeps a card wider than a phone
/// (e.g. the 600 Roles cards) inside the screen instead of off its edge.
/// A NEW home card must still declare its own width.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeCardMetrics {
  const HomeCardMetrics._();

  /// Height of every home component card, on every screen (a MINIMUM on the
  /// dashboard, fixed in the editor and picker).
  // Owner 21/10/2026 (Figma 2289-37365, "the height are equal"): EVERY home
  // card is this one height on every row and every device; the content
  // sits under the title and a card's spare height is at its bottom.
  static double get height => 150.sp;

  /// Phone card height factor (22/10/2026): a tile card's content (16 + title
  /// + 8 + tiles + 16) comes to ~143 of the 150, and the spare 7 fell under the
  /// tiles, so the bottom gap was bigger than the sides (Moataz: equal padding
  /// all round). 0.97 takes it out on phone (0.95 overflowed the tile cards by 2px). A first try at 0.9 clipped the
  /// unscaled cards; the whole card is scaled now ([phoneScale]), which is
  /// why this is safe at 0.95. Now applied on tablet and desktop too (Moataz 22/10/2026: the padding was unequal there as well).
  static const double phoneHeightFactor = 0.97;

  /// A phone draws every card at this scale — title, padding, tiles and
  /// height together. It is what Inventory already looked like there: that
  /// card is wider than the screen, so it was scaled down whole to ~0.84
  /// while every other card stayed full size (Moataz 22/10/2026: "the same
  /// diagonal cut, the same box, the same height as Inventory").
  static const double phoneScale = 0.68;

  /// [height] for this device — the one every card should read.
  static double heightOf(BuildContext context) => height * phoneHeightFactor;

  /// The height a card is actually DRAWN at: [heightOf], times [phoneScale]
  /// on a phone (the whole card is scaled there). An empty "+" slot must match
  /// this, not [heightOf], or it stands taller than the cards beside it.
  static double drawnHeightOf(BuildContext context) =>
      heightOf(context) * (kpIsPhoneLayout(context) ? phoneScale : 1);

  /// Gap BETWEEN two cards in a row.
  ///
  /// Applied as a `Row.spacing`, which puts this gap between neighbours and
  /// nothing at the two outer ends — as opposed to giving every card its own
  /// horizontal padding, which would also inset the first and last card from
  /// the panel edges.
  // Owner item 195 (21/10/2026, Home iPad): ONE gap between widgets,
  // sideways and downwards, = the section gap 16 (D-243).
  // Owner 22/10/2026: halved to 8 — Home only (R-4's exception).
  static double get gap => 8.sp;

  /// 18/10/2026 (Moataz: "only three rows, four columns"): the home grid is
  /// ALWAYS 4 equal columns × 3 rows. Every card takes exactly one cell, so
  /// widths are a share of the panel and every card has the same height —
  /// on the home page, in the layout editor and in the widget picker alike.
  static const int columns = 4;

  /// Width of one cell for a row [rowWidth] wide: [perLine] cells and
  /// `perLine - 1` gaps. D-10 / D-217 (21/10/2026): 4 per line on iPad
  /// landscape and large screens, 2 on iPad portrait, 1 on the phone — the
  /// grid always fits inside its area, never a cut column.
  static double cellWidth(double rowWidth, [int perLine = columns]) =>
      ((rowWidth - (perLine - 1) * gap) / perLine).clamp(80.0, double.infinity);

  /// The home grid panel is the 5 / 8 share beside the calendar (HomeScreen
  /// split, with one [gap] between). The picker spans the whole page, so it
  /// derives the SAME cell width from the page width.
  static double cellWidthForPage(double pageWidth) =>
      cellWidth((pageWidth - gap) * 5 / 8);

  /// One grid cell: exactly [width] wide and [height] tall — the card inside
  /// is forced to the cell (tight constraints) and scrolls internally if its
  /// content is taller.
  static Widget cell({required double width, required Widget child}) {
    return SizedBox(width: width, child: heightBox(child: child));
  }

  /// Room each card leaves on its top and end for the red minus and the gear
  /// (D-242, owner 21/10/2026: the gear sits top-RIGHT, beside the minus).
  static double get badgeInset => 12.sp;

  /// The box the red minus and the gear each sit in; bigger on iPad and Mac,
  /// where 17 was too small to hit (Moataz 24/10/2026).
  static double badgeBoxOf(BuildContext context) =>
      kpIsPhoneLayout(context) ? 25.sp : 30.sp;

  /// Height of a Chart & Graph card (23/10/2026: the SAME as a counter card, so a row of widgets and charts lines up).
  static double get chartHeight => height * phoneHeightFactor;

  /// The cell height of [component]: null for a counter card (the standard
  /// height), [chartHeight] for a chart — the SAME for every chart (Moataz
  /// 23/10/2026: "build them the same height").
  static double? chartHeightFor(HomeComponents component) =>
      component.isChart ? chartHeight : null;

  /// Visible diameter of the red minus and of the settings gear — one size
  /// for both (Moataz 23/10/2026).
  static double get badgeDiameter => 17.sp;

  /// [badgeDiameter] for this device: 17 on a phone, 26 on iPad and Mac.
  static double badgeDiameterOf(BuildContext context) =>
      kpIsPhoneLayout(context) ? 17.sp : 22.sp;

  /// The gap to leave BETWEEN cards that each already carry [badgeInset] of
  /// badge room, so the visible gap reads as [gap]. Never below 0: the Home
  /// gap is 8 now, and `gap - badgeInset` (-4) crashed the Home Layout editor
  /// ('spacing >= 0.0', negative SizedBox width) on tablet and desktop
  /// (22/10/2026). With an 8 gap the badge room itself (12) is the visible gap.
  static double get gapBesideBadge =>
      (gap - badgeInset).clamp(0.0, double.infinity).toDouble();

  /// Horizontal gutter of the home panel on each side (the phone dashboard's
  /// `EdgeInsets.symmetric(horizontal: 10.w)`).
  static double get gutter => 10.w;

  /// Function Name: [maxWidthOf]
  ///
  /// Purpose: The widest a single home card may ever be — the screen width
  /// minus the panel gutters on both sides. A safety cap, not a target: cards
  /// keep the width they declare and only one wider than the screen is
  /// clamped to it.
  ///
  /// Parameters:
  ///   [BuildContext] context: read for the screen width.
  ///
  /// Return type: [double]
  static double maxWidthOf(BuildContext context) {
    final double cap = MediaQuery.sizeOf(context).width - 2 * gutter;
    return cap > 0 ? cap : 0;
  }

  /// Function Name: [heightBox]
  ///
  /// Purpose: Fixed [height], the card's OWN width (bounded by [maxWidthOf]).
  /// Used by the layout EDITOR and the widget PICKER, where cards are
  /// previews laid out on an even row height.
  ///
  /// Vertical behaviour: content taller than [height] scrolls inside the card
  /// rather than overflowing, and a short card is stretched up to the full
  /// height so its background paints the whole tile.
  ///
  /// Parameters:
  ///   [Widget] child: the module widget.
  ///
  /// Return type: [Widget]
  static Widget heightBox({
    required Widget child,
    bool capWidth = true,
    double? height,
  }) {
    return Builder(builder: (BuildContext context) {
      final BoxConstraints cap = BoxConstraints(maxWidth: maxWidthOf(context));
      if (capWidth) {
        return ConstrainedBox(
            constraints: cap,
            child: HomePhoneScale(child: _box(context, child, height)));
      }
      // [capWidth] false: the card keeps its natural width instead of being
      // squeezed (and overflowing inside). 22/10/2026 — Owner: a card never
      // spills past the screen — one wider than [maxWidthOf] (a 405 / 545
      // chart on a 375 phone) is scaled DOWN to it, whole; on the tablet
      // every card fits, so nothing is scaled there.
      return ConstrainedBox(
        constraints: cap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.topStart,
          child: HomePhoneScale(child: _box(context, child, height)),
        ),
      );
    });
  }

  /// The card at its natural width and the cell height — [heightBox] without
  /// any width limit. [HomeGridCell] uses it directly: it scales the card to
  /// its cell itself and stretches a narrower card to fill it.
  static Widget _box(BuildContext context, Widget child,
      [double? heightOverride]) {
    // [heightOverride]: a Chart & Graph card is 200 tall, not the 145 of a
    // counter card — at 145 every chart overflowed (Moataz 23/10/2026).
    final double height = heightOverride ?? heightOf(context);
    // 18/10/2026 (Moataz): fixed HEIGHT, WIDTH = what the card needs.
    // IntrinsicWidth measures the card's natural width, so tiles get
    // exactly their room (no stretched gaps). Fixed-width charts report
    // their own width and are unaffected.
    return _ContentWidth(
      // Owner item 196 (21/10/2026): the cell is the card height, or the
      // row height the grid hands down (tight) when the rows share the
      // panel height — the card fills the whole cell either way.
      child: _CellHeight(
        fallback: height,
        // D-146 (18/10/2026): a shorter card is laid out at EXACTLY the
        // cell height, so its title sits at the top and its last item at
        // the bottom inset (Spacer / spaceBetween inside the cards work);
        // a taller one keeps its own height and scrolls.
        child: SingleChildScrollView(
          child: _AtLeastHeight(minHeight: height, child: child),
        ),
      ),
    );
  }

  /// Function Name: [fitBox]
  ///
  /// Purpose: The card's OWN width (bounded by [maxWidthOf]) and AT LEAST
  /// [height] — a card that needs more room grows instead of scrolling inside
  /// itself. Used by the DASHBOARD (13/9/2026: pinning the height there hid
  /// the Forms card's third button behind an inner scroll).
  ///
  /// [height] stays the MINIMUM so a short card still paints a full tile.
  /// No `IntrinsicHeight` above the row to even the cards up: several module
  /// widgets contain a `ListView`, which throws when asked for an intrinsic
  /// height. Cards in a row can end on different baselines; that is the
  /// cheaper flaw.
  ///
  /// Parameters:
  ///   [Widget] child: the module widget.
  ///
  /// Return type: [Widget]
  static Widget fitBox({required Widget child}) {
    return Builder(
      builder: (BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidthOf(context),
          minHeight: heightOf(context),
        ),
        child: child,
      ),
    );
  }
}

/// Sizes [child] to its natural (max-intrinsic) width, like [IntrinsicWidth],
/// but never breaks the page: a card that cannot report a finite natural
/// width (an infinite-width descendant) falls back to the standard card
/// width and is logged by type so it can be fixed.
class _ContentWidth extends SingleChildRenderObjectWidget {
  const _ContentWidth({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderContentWidth();
}

class _RenderContentWidth extends RenderProxyBox {
  double _natural() {
    final RenderBox? c = child;
    if (c == null) return 0;
    try {
      final double w = c.getMaxIntrinsicWidth(double.infinity);
      if (w.isFinite) return w;
    } catch (e) {
      debugPrint('[HomeCard] natural width failed under '
          '${c.runtimeType}: $e');
    }
    return 320.sp;
  }

  @override
  void performLayout() {
    final RenderBox? c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    final double w = constraints.constrainWidth(_natural());
    c.layout(constraints.tighten(width: w), parentUsesSize: true);
    size = c.size;
  }

  @override
  double computeMinIntrinsicWidth(double height) => _natural();

  @override
  double computeMaxIntrinsicWidth(double height) => _natural();
}

/// Lays [child] out with a TIGHT height of max([minHeight], its natural
/// height), so a short card fills the card height exactly (bounded, so a
/// Spacer / spaceBetween can push its last item to the bottom inset).
class _AtLeastHeight extends SingleChildRenderObjectWidget {
  const _AtLeastHeight({required this.minHeight, super.child});
  final double minHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderAtLeastHeight(minHeight);

  @override
  void updateRenderObject(
          BuildContext context, _RenderAtLeastHeight renderObject) =>
      renderObject.minHeight = minHeight;
}

class _RenderAtLeastHeight extends RenderProxyBox {
  _RenderAtLeastHeight(this._minHeight);
  double _minHeight;
  set minHeight(double v) {
    if (v == _minHeight) return;
    _minHeight = v;
    markNeedsLayout();
  }

  /// The height of the cell this card sits in (set by [_RenderCellHeight]
  /// during the same layout pass), else the configured minimum.
  double get _floor {
    RenderObject? p = parent;
    while (p != null && p is! _RenderCellHeight) {
      p = p.parent;
    }
    if (p is _RenderCellHeight && p.chosen > _minHeight) return p.chosen;
    return _minHeight;
  }

  @override
  void performLayout() {
    final RenderBox? c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    // Owner 21/10/2026 12:16 (the To-Do card is the pattern): the card is
    // EXACTLY the cell height — never taller — so the title stays and only
    // the body scrolls inside the card; the cell itself never scrolls.
    final double h = _floor;
    c.layout(
        constraints.tighten(height: h).copyWith(minWidth: constraints.minWidth),
        parentUsesSize: true);
    size = constraints.constrain(c.size);
  }
}

/// One grid cell of the home layout (D-217 / D-226, owner 21/10/2026: "equal
/// widths and equal gaps, no ragged widths"): exactly [width] wide, the card
/// FILLS it — a narrower card is stretched to the cell, a wider one is scaled
/// down to it — so every card of a row has the same width and the gaps between
/// them are the grid's one gap.
///
/// [inset] is the horizontal room the caller adds around the card (the layout
/// editor's badge room at the end): the card gets `width - inset`, and the
/// caller's padding brings the whole thing back to [width].
class _CellHeight extends SingleChildRenderObjectWidget {
  const _CellHeight({required this.fallback, super.child});
  final double fallback;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCellHeight(fallback);

  @override
  void updateRenderObject(BuildContext context, _RenderCellHeight r) =>
      r.fallback = fallback;
}

/// Lays its child out at the cell height: the incoming TIGHT height when the
/// grid shares the panel height between the rows (owner item 196), else
/// [fallback] (the card height).
class _RenderCellHeight extends RenderProxyBox {
  _RenderCellHeight(this._fallback);
  double _fallback;
  set fallback(double v) {
    if (v == _fallback) return;
    _fallback = v;
    markNeedsLayout();
  }

  double chosen = 0;

  double _height(BoxConstraints c) =>
      c.hasTightHeight ? c.maxHeight : c.constrainHeight(_fallback);

  @override
  void performLayout() {
    final RenderBox? c = child;
    chosen = _height(constraints);
    if (c == null) {
      size = constraints.constrain(Size(0, chosen));
      return;
    }
    c.layout(constraints.tighten(height: chosen), parentUsesSize: true);
    size = c.size;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderBox? c = child;
    final double h = _height(constraints);
    if (c == null) return constraints.constrain(Size(0, h));
    return c.getDryLayout(constraints.tighten(height: h));
  }

  /// The height this cell NEEDS: the card height, or more when the content
  /// is taller — the grid gives every card the tallest need.
  double _needed(double width) {
    final RenderBox? c = child;
    if (c == null) return _fallback;
    try {
      final double h = c.getMaxIntrinsicHeight(width);
      if (h.isFinite && h > _fallback) return h;
    } catch (e) {
      debugPrint('[HomeCell] needed height failed: $e');
    }
    return _fallback;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _needed(width);
  @override
  double computeMaxIntrinsicHeight(double width) => _needed(width);
}

class HomeGridCell extends StatelessWidget {
  const HomeGridCell({
    super.key,
    required this.width,
    required this.child,
    this.inset = 0,
    this.height,
  });

  /// A taller cell for a chart card; null = the standard card height.
  final double? height;
  final double width;
  final double inset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double card = (width - inset).clamp(0.0, double.infinity);
    return SizedBox(
      width: card,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: card),
          child: HomeCardMetrics._box(context, child, height),
        ),
      ),
    );
  }
}

/// Owner 21/10/2026 12:19 (To-Do counters: "no diagonal cut from the
/// downside … add padding between high, medium, low consistently"): the
/// body of a home card is laid out at LEAST as tall as the room under the
/// title, so a column with `spaceBetween` spreads its rows down to the 16
/// bottom inset; a body taller than that keeps its height and scrolls.
/// [HomeCardBodyViewport] sits outside the scroll view and remembers the
/// room; [HomeCardBodyFill] sits inside it and takes that room as its floor.
class HomeCardBodyViewport extends SingleChildRenderObjectWidget {
  const HomeCardBodyViewport({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderHomeCardBodyViewport();
}

class RenderHomeCardBodyViewport extends RenderProxyBox {
  double room = 0;

  @override
  void performLayout() {
    room = constraints.hasBoundedHeight ? constraints.maxHeight : 0;
    super.performLayout();
  }
}

class HomeCardBodyFill extends SingleChildRenderObjectWidget {
  const HomeCardBodyFill({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHomeCardBodyFill();
}

class _RenderHomeCardBodyFill extends RenderProxyBox {
  double get _floor {
    RenderObject? p = parent;
    while (p != null && p is! RenderHomeCardBodyViewport) {
      p = p.parent;
    }
    return p is RenderHomeCardBodyViewport ? p.room : 0;
  }

  @override
  void performLayout() {
    final RenderBox? c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    // 12:30: the body is EXACTLY the room under the title when its content
    // fits (so rows, tiles and people stretch to the bottom inset), and its
    // own height when the content is taller (then it scrolls).
    final double room = _floor;
    double natural = 0;
    try {
      natural = c.getMaxIntrinsicHeight(constraints.maxWidth);
      if (!natural.isFinite) natural = 0;
    } catch (e) {
      debugPrint('[HomeCardBodyFill] natural height failed: $e');
    }
    final double h = (natural > room ? natural : room)
        .clamp(constraints.minHeight, constraints.maxHeight);
    c.layout(constraints.tighten(height: h), parentUsesSize: true);
    size = constraints.constrain(c.size);
  }
}

/// Draws a whole card at [HomeCardMetrics.phoneScale] on a phone and untouched elsewhere.
///
/// The child is laid out in the room it WOULD have at full size (the parent's
/// limits divided by the scale), the box reports the scaled size, and the
/// painting is scaled to match — so a card that hugs its content hugs the
/// smaller drawing, and intrinsic-width measuring agrees with it.
class HomePhoneScale extends StatelessWidget {
  final Widget child;

  const HomePhoneScale({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kpIsPhoneLayout(context)) return child;
    return _ScaledBox(scale: HomeCardMetrics.phoneScale, child: child);
  }
}

class _ScaledBox extends SingleChildRenderObjectWidget {
  const _ScaledBox({required this.scale, super.child});

  final double scale;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderScaledBox(scale);

  @override
  void updateRenderObject(BuildContext context, _RenderScaledBox r) =>
      r.scale = scale;
}

class _RenderScaledBox extends RenderProxyBox {
  _RenderScaledBox(this._scale);

  double _scale;
  set scale(double v) {
    if (v == _scale) return;
    _scale = v;
    markNeedsLayout();
  }

  BoxConstraints _inner(BoxConstraints c) => BoxConstraints(
        minWidth: 0,
        maxWidth: c.maxWidth.isFinite ? c.maxWidth / _scale : c.maxWidth,
        minHeight: 0,
        maxHeight: c.maxHeight.isFinite ? c.maxHeight / _scale : c.maxHeight,
      );

  @override
  void performLayout() {
    final RenderBox? c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    c.layout(_inner(constraints), parentUsesSize: true);
    size = constraints.constrain(c.size * _scale);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderBox? c = child;
    if (c == null) return constraints.smallest;
    return constraints.constrain(c.getDryLayout(_inner(constraints)) * _scale);
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      (child?.getMinIntrinsicWidth(height / _scale) ?? 0) * _scale;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      (child?.getMaxIntrinsicWidth(height / _scale) ?? 0) * _scale;

  @override
  double computeMinIntrinsicHeight(double width) =>
      (child?.getMinIntrinsicHeight(width / _scale) ?? 0) * _scale;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      (child?.getMaxIntrinsicHeight(width / _scale) ?? 0) * _scale;

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? c = child;
    if (c == null) return;
    context.pushTransform(
      needsCompositing,
      offset,
      Matrix4.diagonal3Values(_scale, _scale, 1),
      c.paint,
    );
  }

  @override
  void applyPaintTransform(RenderBox c, Matrix4 transform) =>
      transform.multiply(Matrix4.diagonal3Values(_scale, _scale, 1));

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      child?.hitTest(result, position: position / _scale) ?? false;
}
