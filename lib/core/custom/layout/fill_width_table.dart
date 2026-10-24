/// Module: core / custom / layout
///
///*************************** FILE INFO ****************************///
/// File Name: fill_width_table.dart
/// Description: Declares `fillColumnWidth` and `FillWidthHorizontalScroll` —
///              the two pieces that make a wide `Table` / `DataTable` take the
///              FULL width of its container on a large screen and still scroll
///              sideways on a narrow one.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Owner 21/10/2026: tables take the full width and share it equally between their columns (reference: Time Tracker Attendance table).
///
/// HOW IT WORKS
/// ------------
/// A table inside a horizontal `SingleChildScrollView` gets UNBOUNDED width,
/// so it sizes to its content and sits packed to the left. Two changes fix it:
///
///   1. [FillWidthHorizontalScroll] measures the real width OUTSIDE the scroll
///      view and gives the table that width as a MINIMUM (never a fixed width,
///      so a table wider than the screen keeps its own width and scrolls).
///   2. [fillColumnWidth] turns a column's measured width into
///      `max(measured, equal share)`. `RenderTable` grows flex columns to the
///      minimum width when the max width is unbounded, so every data column
///      gets the same share of the free space — and a column whose content is
///      wider than that share keeps its own width instead of being squeezed.
///
/// Keep a narrow leading "No" column as a plain `FixedColumnWidth` so it stays
/// narrow (like the Attendance table's "No").
///
/// NOT FOR CALLERS INSIDE `IntrinsicWidth` / `IntrinsicHeight`: the
/// `LayoutBuilder` here cannot report intrinsic sizes.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A data column that is at least [width] wide — and never narrower than its
/// full header title (Owner 21/10/2026: a column title is never cut with "…")
/// — and otherwise takes an equal share of the table's free width.
TableColumnWidth fillColumnWidth(double width) => MaxColumnWidth(
      MaxColumnWidth(FixedColumnWidth(width), const HeaderTitleColumnWidth()),
      const FlexColumnWidth(),
    );

/// Owner 21/10/2026: a column as wide as its HEADER cell (the table's first row)
/// wants to be — its full title plus padding — ignoring the body values. Only
/// meaningful where the table width is not capped (inside
/// [FillWidthHorizontalScroll]), so the table scrolls instead of cutting a title.
class HeaderTitleColumnWidth extends TableColumnWidth {
  const HeaderTitleColumnWidth();

  double _header(Iterable<RenderBox> cells) =>
      cells.isEmpty ? 0 : cells.first.getMaxIntrinsicWidth(double.infinity);

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      _header(cells);

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      _header(cells);
}

/// Owner 21/10/2026: the width a header [title] needs on ONE line at [style]
/// (+ [padding] on both sides) — the minimum of its column, so the title is
/// never cut with "…".
double measureTitleWidth(
  BuildContext context,
  String title,
  TextStyle style, {
  double padding = 0,
}) {
  final TextPainter painter = TextPainter(
    // Merged onto the inherited style: StyleText leaves the font family to
    // the theme (Cairo), and a bare TextPainter would measure the narrower
    // system font — the title then came out cut with "…" (Owner 21/10/2026).
    text: TextSpan(
        text: title, style: DefaultTextStyle.of(context).style.merge(style)),
    maxLines: 1,
    textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
    textScaler: MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling,
  )..layout();
  // +2: a sub-pixel rounding difference must not trip the ellipsis.
  return painter.width.ceilToDouble() + padding * 2 + 2;
}

/// A data column sized to its content (like `DataTable`'s default) that also
/// takes an equal share of the free width.
const TableColumnWidth fillIntrinsicColumnWidth = IntrinsicColumnWidth(flex: 1);

/// A horizontal scroll view whose child is at least as wide as the space the
/// parent offers. Put the `Table` / `DataTable` straight inside it.
class FillWidthHorizontalScroll extends StatelessWidget {
  const FillWidthHorizontalScroll({
    super.key,
    required this.child,
    this.controller,
    this.physics,
    this.reverse = false,
  });

  final Widget child;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: controller,
          physics: physics,
          reverse: reverse,
          child: ConstrainedBox(
            // Guard: inside another horizontal scroll the width is infinite.
            constraints: BoxConstraints(
              minWidth: box.hasBoundedWidth ? box.maxWidth : 0,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Owner 21/10/2026: column widths that fill [available]. When the [natural]
/// widths already fill (or overflow) it they come back unchanged, so the table
/// scrolls. Otherwise the first [fixedLeading] columns (a "No" column) keep
/// their width and every other column grows to one EQUAL share; a column whose
/// content is wider than that share keeps its own width and the rest share
/// what is left.
List<double> fillTableWidths(
  List<double> natural,
  double available, {
  int fixedLeading = 0,
}) {
  final double total = natural.fold<double>(0, (double s, double w) => s + w);
  if (!available.isFinite || total >= available || natural.isEmpty) {
    return natural;
  }
  final int lead = fixedLeading.clamp(0, natural.length);
  if (lead == natural.length) return natural;
  double room = available;
  for (int i = 0; i < lead; i++) {
    room -= natural[i];
  }
  // Water-fill: the columns wider than the equal share keep their width and
  // leave the share to the others; repeat until the share settles.
  final List<double> rest = natural.sublist(lead);
  final Set<int> wide = <int>{};
  double share = 0;
  while (true) {
    final int count = rest.length - wide.length;
    double free = room;
    for (final int i in wide) {
      free -= rest[i];
    }
    share = count == 0 ? 0 : free / count;
    bool changed = false;
    for (int i = 0; i < rest.length; i++) {
      if (!wide.contains(i) && rest[i] > share) {
        wide.add(i);
        changed = true;
      }
    }
    if (!changed) break;
  }
  return <double>[
    ...natural.sublist(0, lead),
    for (int i = 0; i < rest.length; i++) wide.contains(i) ? rest[i] : share,
  ];
}

/// Owner 21/10/2026: a horizontal scroll that hands [builder] column widths
/// filling the parent's width (see [fillTableWidths]). [reserved] is the width
/// that is not a column — row padding and the gaps between columns.
class FillWidthTableLayout extends StatelessWidget {
  const FillWidthTableLayout({
    super.key,
    required this.naturalWidths,
    required this.builder,
    this.fixedLeading = 0,
    this.reserved = 0,
    this.controller,
    this.physics,
    this.scroll = true,
    this.titles,
    this.titleStyle,
    this.titlePadding = 0,
  });

  /// Owner 21/10/2026: the header titles (null = no title). Each column is at
  /// least as wide as its full title at [titleStyle] + [titlePadding] per side.
  final List<String?>? titles;
  final TextStyle? titleStyle;
  final double titlePadding;

  final List<double> naturalWidths;
  final Widget Function(BuildContext context, List<double> widths) builder;
  final int fixedLeading;
  final double reserved;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  /// False when the caller already wraps the table in its own horizontal
  /// scroll view (the widths are still measured OUTSIDE it).
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final List<double> natural = <double>[
          for (int i = 0; i < naturalWidths.length; i++)
            titles != null &&
                    titleStyle != null &&
                    i < titles!.length &&
                    titles![i] != null
                ? math.max(
                    naturalWidths[i],
                    measureTitleWidth(context, titles![i]!, titleStyle!,
                        padding: titlePadding),
                  )
                : naturalWidths[i],
        ];
        final List<double> widths = box.hasBoundedWidth
            ? fillTableWidths(
                natural,
                box.maxWidth - reserved,
                fixedLeading: fixedLeading,
              )
            : natural;
        final Widget table = builder(context, widths);
        if (!scroll) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: controller,
          physics: physics,
          child: table,
        );
      },
    );
  }
}

/// Owner 21/10/2026: turns a table's `FixedColumnWidth`s into [fillColumnWidth]s
/// (the first [fixedLeading] columns — a "No" column — stay fixed). Use with
/// [FillWidthHorizontalScroll].
Map<int, TableColumnWidth> fillColumnWidths(
  Map<int, TableColumnWidth> widths, {
  int fixedLeading = 1,
}) {
  return <int, TableColumnWidth>{
    for (final MapEntry<int, TableColumnWidth> e in widths.entries)
      e.key: e.key >= fixedLeading && e.value is FixedColumnWidth
          ? fillColumnWidth((e.value as FixedColumnWidth).value)
          : e.value,
  };
}
