/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: packed_wrap.dart
/// Purpose: Declares `PackedWrap` — a [Wrap] that re-orders its children so
///          every row is filled and no gap is left beside a card that would
///          have fitted.
/// Author: Knowticed Plus team
/// Created: 23/10/2026
///
/// WHY THIS EXISTS
/// ---------------
/// The widget picker on tablet shows every card at its OWN width (the cards
/// differ: 2 cells, 3 cells, 4 cells wide). A plain [Wrap] closes a row as soon
/// as the NEXT card does not fit, even when a narrower card further down
/// would — so rows end in blank strips (Moataz 23/10/2026: "rearrange these
/// widgets so I don't have these spaces, in all and even when filtered by a
/// module").
///
/// HOW IT PACKS
/// ------------
/// Children are measured at their natural width, then placed row by row:
/// a row starts with the first card not yet placed (so the original order
/// still leads), and is then topped up with the WIDEST remaining card that
/// still fits, until none does. Gaps are the fixed [spacing] / [runSpacing] —
/// never stretched. Only the last row can end short, and only when no
/// remaining card fits it.
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class PackedWrap extends MultiChildRenderObjectWidget {
  const PackedWrap({
    super.key,
    this.spacing = 0,
    this.runSpacing = 0,
    super.children,
  });

  /// Gap between two cards in a row.
  final double spacing;

  /// Gap between two rows.
  final double runSpacing;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderPackedWrap(
        spacing: spacing,
        runSpacing: runSpacing,
        textDirection: Directionality.of(context),
      );

  @override
  void updateRenderObject(BuildContext context, RenderPackedWrap renderObject) {
    renderObject
      ..spacing = spacing
      ..runSpacing = runSpacing
      ..textDirection = Directionality.of(context);
  }
}

class _PackedParentData extends ContainerBoxParentData<RenderBox> {}

class RenderPackedWrap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PackedParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PackedParentData> {
  RenderPackedWrap({
    required double spacing,
    required double runSpacing,
    required TextDirection textDirection,
  })  : _spacing = spacing,
        _runSpacing = runSpacing,
        _textDirection = textDirection;

  double _spacing;
  set spacing(double v) {
    if (v == _spacing) return;
    _spacing = v;
    markNeedsLayout();
  }

  double _runSpacing;
  set runSpacing(double v) {
    if (v == _runSpacing) return;
    _runSpacing = v;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PackedParentData) {
      child.parentData = _PackedParentData();
    }
  }

  /// Groups child indices into rows (see the file header for the rule).
  /// Pure: depends only on the measured [widths], so a test can call it.
  @visibleForTesting
  static List<List<int>> packRows(
    List<double> widths,
    double maxWidth,
    double spacing,
  ) {
    final List<int> remaining = List<int>.generate(widths.length, (i) => i);
    final List<List<int>> rows = <List<int>>[];
    while (remaining.isNotEmpty) {
      final int first = remaining.removeAt(0);
      final List<int> row = <int>[first];
      double used = widths[first];
      while (true) {
        int best = -1;
        for (final int i in remaining) {
          if (used + spacing + widths[i] > maxWidth + 0.01) continue;
          if (best == -1 || widths[i] > widths[best]) best = i;
        }
        if (best == -1) break;
        remaining.remove(best);
        row.add(best);
        used += spacing + widths[best];
      }
      rows.add(row);
    }
    return rows;
  }

  Size _layout(
    BoxConstraints constraints,
    Size Function(RenderBox child, BoxConstraints c) measure,
    void Function(int index, Offset offset)? place,
  ) {
    final List<RenderBox> kids = <RenderBox>[];
    for (RenderBox? c = firstChild; c != null; c = childAfter(c)) {
      kids.add(c);
    }
    if (kids.isEmpty) return constraints.smallest;

    final double maxW = constraints.maxWidth;
    final BoxConstraints loose = BoxConstraints(maxWidth: maxW);
    final List<Size> sizes = <Size>[
      for (final RenderBox k in kids) measure(k, loose),
    ];
    final List<List<int>> rows = packRows(
      <double>[for (final Size s in sizes) s.width],
      maxW,
      _spacing,
    );

    final bool rtl = _textDirection == TextDirection.rtl;
    double y = 0;
    double widest = 0;
    for (int r = 0; r < rows.length; r++) {
      double x = 0;
      double rowH = 0;
      for (final int i in rows[r]) {
        if (place != null) {
          final double left =
              rtl && maxW.isFinite ? maxW - x - sizes[i].width : x;
          place(i, Offset(left, y));
        }
        x += sizes[i].width + _spacing;
        if (sizes[i].height > rowH) rowH = sizes[i].height;
      }
      final double rowW = x - _spacing;
      if (rowW > widest) widest = rowW;
      y += rowH + (r == rows.length - 1 ? 0 : _runSpacing);
    }
    return constraints.constrain(Size(maxW.isFinite ? maxW : widest, y));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layout(
        constraints,
        (RenderBox c, BoxConstraints k) => c.getDryLayout(k),
        null,
      );

  @override
  void performLayout() {
    final List<RenderBox> kids = <RenderBox>[];
    for (RenderBox? c = firstChild; c != null; c = childAfter(c)) {
      kids.add(c);
    }
    size = _layout(
      constraints,
      (RenderBox c, BoxConstraints k) {
        c.layout(k, parentUsesSize: true);
        return c.size;
      },
      (int i, Offset o) =>
          (kids[i].parentData! as _PackedParentData).offset = o,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
