/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_table_chart_card.dart
/// Description: Declares `TableChartCard`, `TableChartRowData` and
///          `TableChartCell`.
/// Author: Amr Mesbah
/// Created at: 23/8/2026 - Added with the Figma "Chart & Graph" tab pass.
library;

// Figma: "Table chart" — the one entry on the Chart & Graph tab that is a
// table rather than a plot: Service / Service Requester / Service Provider /
// Status, where the two people columns show an avatar with a name and role.
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_extras.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

/// One cell: a value, an optional second line, and an optional avatar.
class TableChartCell {
  final String text;

  /// Second line under [text] — the person's role in the Figma rows.
  final String? subtitle;

  /// Leading circular avatar. Null renders the cell as plain text.
  final ImageProvider<Object>? avatar;

  /// Overrides the value color — used to tint a status (e.g. red "Cancelled").
  final Color? textColor;

  /// A status as a small coloured dot before the text (23/10/2026: four
  /// coloured words read as four different styles; a dot keeps the text one
  /// style). Wins over [textColor] when both are given.
  final Color? dotColor;

  const TableChartCell({
    required this.text,
    this.subtitle,
    this.avatar,
    this.textColor,
    this.dotColor,
  });
}

/// One table row: exactly one cell per column.
class TableChartRowData {
  final List<TableChartCell> cells;

  const TableChartRowData({required this.cells});
}

/// Table chart card.
///
/// ```dart
/// TableChartCard(
///   title: 'Table chart',
///   columns: const ['Service', 'Service Requester', 'Status'],
///   rows: const [
///     TableChartRowData(cells: [
///       TableChartCell(text: 'Service Name'),
///       TableChartCell(text: 'Ahmed Abd el Rahman', subtitle: 'HR'),
///       TableChartCell(text: 'Pending'),
///     ]),
///   ],
/// )
/// ```
class TableChartCard extends StatelessWidget {
  final String title;
  final List<String> columns;
  final List<TableChartRowData> rows;

  final Widget? trailing;

  /// Anything placed above the table — usually a `ChartRangeTabs` row (91).
  final Widget? header;

  /// Anything placed under the table — usually a `ChartViewDetails` link (91).
  final Widget? footer;

  /// Relative column widths. Must be the same length as [columns] when given;
  /// otherwise every column gets equal width.
  final List<int>? columnFlex;

  final double avatarSize;

  /// Vertical padding above and below each table row. Figma's rows sit 25
  /// apart; the default 8 is the roomier spacing.
  final double rowSpacing;
  final double? width;

  /// Fixed card height. Null keeps the card hugging its content; the Adding
  /// Widget picker passes Figma's 200 so a row of charts lines up.
  final double? height;

  /// Card padding. Null uses [ChartCard]'s default of 16; the Figma chart
  /// frames use 10.
  final EdgeInsetsGeometry? padding;

  /// Forwarded to [ChartCard.expandChild]: with a fixed [height], let the
  /// plot absorb the leftover space rather than leaving a gap underneath.
  final bool expandChild;

  /// Color of the header dot.
  final Color? dotColor;

  /// Optional SVG asset placed inside the header dot.
  final String? dotIcon;

  const TableChartCard({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.trailing,
    this.header,
    this.footer,
    this.columnFlex,
    this.avatarSize = 22,
    this.rowSpacing = 8,
    this.width,
    this.height,
    this.padding,
    this.expandChild = false,
    this.dotColor,
    this.dotIcon,
  });

  /// Column weights, falling back to equal widths when [columnFlex] is absent
  /// or does not describe every column.
  List<int> get _flex {
    if (columnFlex != null && columnFlex!.length == columns.length) {
      return columnFlex!;
    }
    return List<int>.filled(columns.length, 1);
  }

  Widget _cell(TableChartCell cell) {
    final TextStyle valueStyle = cell.dotColor != null || cell.textColor == null
        ? ChartText.value
        : ChartText.value.copyWith(color: cell.textColor);
    Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // A name wraps onto a second line before it is ever cut with "…".
        Text(
          cell.text,
          style: valueStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (cell.subtitle != null)
          Text(
            cell.subtitle!,
            style: ChartText.axis.copyWith(fontSize: 9.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
    if (cell.dotColor != null) {
      text = Row(
        children: <Widget>[
          Container(
            width: 8.r,
            height: 8.r,
            decoration:
                BoxDecoration(color: cell.dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Expanded(child: text),
        ],
      );
    }

    if (cell.avatar == null) return text;

    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: avatarSize.r / 2,
          backgroundColor: AppColors.background,
          backgroundImage: cell.avatar,
        ),
        SizedBox(width: 6.w),
        Expanded(child: text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<int> flex = _flex;

    return AnimatedSizeWrap(
      // Tables animate their size (rows added / removed / filtered).
      child: ChartCard(
        title: title,
        trailing: trailing,
        width: width,
        height: height,
        padding: padding,
        expandChild: expandChild,
        // 24/10/2026 (Moataz): on a pinned-height card only the ROWS scroll;
        // the column headings stay (they scrolled away with the rows).
        scrollBody: false,
        dotColor: dotColor,
        dotIcon: dotIcon,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (header != null) ...<Widget>[header!, SizedBox(height: 10.h)],
            // Column headings.
            Row(
              children: <Widget>[
                for (int c = 0; c < columns.length; c++)
                  Expanded(
                    flex: flex[c],
                    child: Text(
                      columns[c],
                      style: ChartText.axis,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Divider(height: 1.h, color: AppColors.border.withValues(alpha: .5)),
            if (expandChild)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    for (final TableChartRowData row in rows) ...<Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: rowSpacing.h),
                        child: Row(
                          children: <Widget>[
                            for (int c = 0; c < columns.length; c++)
                              Expanded(
                                flex: flex[c],
                                // A row with fewer cells than columns renders the
                                // missing trailing cells as blanks rather than throwing.
                                child: c < row.cells.length
                                    ? _cell(row.cells[c])
                                    : const SizedBox.shrink(),
                              ),
                          ],
                        ),
                      ),
                      Divider(
                          height: 1.h,
                          color: AppColors.border.withValues(alpha: .5)),
                    ],
                  ]),
                ),
              )
            else ...<Widget>[
              for (final TableChartRowData row in rows) ...<Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: rowSpacing.h),
                  child: Row(
                    children: <Widget>[
                      for (int c = 0; c < columns.length; c++)
                        Expanded(
                          flex: flex[c],
                          // A row with fewer cells than columns renders the
                          // missing trailing cells as blanks rather than throwing.
                          child: c < row.cells.length
                              ? _cell(row.cells[c])
                              : const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
                Divider(
                    height: 1.h, color: AppColors.border.withValues(alpha: .5)),
              ],
            ],
            if (footer != null) ...<Widget>[SizedBox(height: 6.h), footer!],
          ],
        ),
      ),
    );
  }
}
