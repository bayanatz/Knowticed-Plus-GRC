/// Module: roles / r4_active_directory / presentation / ui / widgets / table
///
///*************************** FILE INFO ****************************///
/// File Name: default_data_table.dart
/// Description: Declares `DefaultDataTable`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 31/8/2026 - Added the opt-in [fillWidth]. See its doc comment.
/// Updated: 9/10/2026 - The LayoutBuilder is now used only when [fillWidth] is
///          set. Unconditional, it broke every caller wrapped in an
///          IntrinsicWidth — Active Directory showed an empty table.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/layout/overflow_fade.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/layout/fill_width_table.dart';

import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

//Youssef Ashraf , mohammed Ashraf
///Default Table Style for active_directory
class DefaultDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? columnSpacing;

  /// Stretch the table to the full width available instead of letting it size
  /// to its content.
  ///
  /// ADDED 31/8/2026. The horizontal `SingleChildScrollView` below hands the
  /// `DataTable` UNBOUNDED width, so the table measures its columns from their
  /// own content and stops there. When that total is narrower than the screen
  /// — a table with few columns, or short values — the result is a table
  /// floating in unused space, which is what the Services dashboard showed.
  ///
  /// Opt-in rather than the default: this widget is shared by System Logs,
  /// Active Directory and User Management, whose tables have enough columns to
  /// already fill their space. Flipping the default would relayout all of them
  /// for the sake of one caller.
  ///
  /// The constraint is a MINIMUM, not a fixed width — see [build]. A wide table
  /// keeps its content width and still scrolls; only a narrow one is stretched.
  final bool fillWidth;

  /// Owner 21/10/2026: the Time Tracker Attendance table look (dark header, Medium 14 white titles, #F1F1F1/white zebra, 12 values, 12 gap), full width, columns share the free width equally.
  ///
  /// Implies [fillWidth], so NOT for callers inside an `IntrinsicWidth`.
  final bool attendanceStyle;

  /// Owner 21/10/2026: [attendanceStyle] only — an extra floor under the title-width minimum
  /// of every column (null = the title width alone).
  final double? minColumnWidth;

  const DefaultDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnSpacing,
    this.fillWidth = false,
    this.attendanceStyle = false,
    this.minColumnWidth,
  });

  @override
  Widget build(BuildContext context) {
    var isLandScape = ContextExtension(context).isLandscape;
    bool isDarkMode = themeController.currentTheme.value == AppColors.darkTheme;

    // FIXED 9/10/2026 — EMPTY ACTIVE DIRECTORY. The LayoutBuilder below was
    // added on 31/8/2026 for EVERY caller, but only [fillWidth] reads its
    // constraints. Active Directory wraps this table in an `IntrinsicWidth`
    // (csv_table_builders2.dart `_buildTableArea`), and a LayoutBuilder cannot
    // report intrinsic sizes: "LayoutBuilder does not support returning
    // intrinsic dimensions" was thrown on every layout, the table was never
    // laid out, and the Users Data / Invalid Data tabs drew nothing as soon as
    // they had one row. Callers that do not ask for [fillWidth] now get the
    // same tree they had before 31/8/2026 (no LayoutBuilder), so intrinsic
    // measurement works again; [fillWidth] callers are unchanged.
    if (attendanceStyle) {
      return LayoutBuilder(
        builder: (context, constraints) =>
            _attendanceTable(context, constraints),
      );
    }
    if (!fillWidth) {
      return _scrollingTable(_buildTable(isLandScape, isDarkMode), null);
    }

    // The LayoutBuilder sits OUTSIDE both scroll views on purpose: inside the
    // horizontal one `constraints.maxWidth` is infinite, which is the whole
    // reason the table cannot size itself to the screen. Out here it is the
    // real width the parent is offering. The vertical scroll view below only
    // unbounds the HEIGHT, so it passes this width straight through.
    return LayoutBuilder(
      builder: (context, constraints) =>
          _scrollingTable(_buildTable(isLandScape, isDarkMode), constraints),
    );
  }

  /// The styled [DataTable]. Split out 9/10/2026 so the [fillWidth] and
  /// non-[fillWidth] paths in [build] share one definition.
  Widget _buildTable(bool isLandScape, bool isDarkMode) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8.r),
        topRight: Radius.circular(8.r),
      ),
      child: AnimatedSizeWrap(
          child: DataTable(
        border: TableBorder(
          horizontalInside: BorderSide(
            width: 0,
            color: isDarkMode ? AppColors.totalBlack : AppColors.white,
          ),
        ),
        // columnSpacing: 45.w, //columnSpacing,
        // AppColors.header is already 0xff2D2D2D in the light palette and
        // 0xFF171717 in the dark one, so it replaces the manual ternary.
        headingRowColor: WidgetStatePropertyAll(AppColors.header),
        dataRowMinHeight: 46.h,
        dataRowMaxHeight: 46.h,
        headingRowHeight: 46.h,
        horizontalMargin: isLandScape ? 29.w : 16.w,
        dividerThickness: 0,
        showCheckboxColumn: false,
        columns: fillWidth ? _fillColumns() : columns,
        rows: rows,
      )),
    );
  }

  /// Owner 21/10/2026: every column takes an equal share of the free width (fill_width_table.dart) — used by [fillWidth] and [attendanceStyle].
  List<DataColumn> _fillColumns() => <DataColumn>[
        for (final DataColumn c in columns)
          DataColumn(
            label: c.label,
            tooltip: c.tooltip,
            numeric: c.numeric,
            onSort: c.onSort,
            mouseCursor: c.mouseCursor,
            headingRowAlignment: c.headingRowAlignment,
            columnWidth: c.columnWidth ?? fillIntrinsicColumnWidth,
          ),
      ];

  /// Owner 21/10/2026: the [attendanceStyle] table, built the SAME way as the Time Tracker
  /// Attendance table (`AttendanceTableView`): no `DataTable` (its rows are 46 tall, draw hairline
  /// dividers and ignore the zebra in dark mode) — a header band + one coloured Row per line, 10 side
  /// padding, 11 top/bottom, 12 gap, #F1F1F1/white zebra (dark: #28282B/#1E1F24), Medium 14 white
  /// titles, 12 regular values. Every column gets an EQUAL width; when they cannot fit at
  /// [minColumnWidth] the table scrolls sideways at that width and fades its hidden edge
  /// (`OverflowFade`) instead of cutting a title in half.
  Widget _attendanceTable(BuildContext context, BoxConstraints box) {
    final double gap = 12.w;
    final double side = 10.w;
    final int n = columns.length;
    // +1: a sub-pixel rounding must never turn a fitting table into a scrolling one.
    final double reserved = side * 2 + gap * math.max(0, n - 1) + 1;
    // Owner 21/10/2026: a title is never cut — each column is at least its full title wide
    // (and at least [minColumnWidth]); the rest of the width is shared equally.
    final TextStyle headStyle =
        StyleText.fontSize14Weight500.copyWith(color: AppColors.white);
    final List<double> natural = <double>[
      for (final DataColumn c in columns)
        math.max(_labelWidth(context, c.label, headStyle), minColumnWidth ?? 0),
    ];
    final List<double> w = box.hasBoundedWidth
        ? fillTableWidths(natural, box.maxWidth - reserved)
        : natural;

    Widget line({
      Key? key,
      required Color color,
      required List<Widget> cells,
      required TextStyle style,
    }) {
      return Container(
        key: key,
        color: color,
        padding:
            EdgeInsetsDirectional.symmetric(horizontal: side, vertical: 11.sp),
        child: DefaultTextStyle.merge(
          style: style,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: gap,
            children: <Widget>[
              for (int j = 0; j < n; j++)
                SizedBox(
                  width: w[j],
                  child: j < cells.length ? cells[j] : const SizedBox(),
                ),
            ],
          ),
        ),
      );
    }

    final TextStyle value =
        StyleText.fontSize12Weight400.copyWith(color: AppColors.text);
    final Widget table = ClipRRect(
      borderRadius: CardStyles.radius(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          line(
            color: AppTheme.isDark ? AppColors.blackShadow : AppColors.black,
            style: headStyle,
            cells: <Widget>[for (final DataColumn c in columns) c.label],
          ),
          for (int i = 0; i < rows.length; i++) _attendanceRow(i, line, value),
        ],
      ),
    );

    return SingleChildScrollView(
      child: OverflowFade(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        ),
      ),
    );
  }

  /// The width a header label needs on one line: a `Text` is measured at its own style over
  /// [base]; a fixed-width box keeps its width; anything else has no minimum.
  static double _labelWidth(
      BuildContext context, Widget label, TextStyle base) {
    if (label is Text && label.data != null) {
      return measureTitleWidth(context, label.data!, base.merge(label.style));
    }
    if (label is SizedBox && label.width != null) return label.width!;
    return 0;
  }

  Widget _attendanceRow(
    int i,
    Widget Function({
      Key? key,
      required Color color,
      required List<Widget> cells,
      required TextStyle style,
    }) line,
    TextStyle value,
  ) {
    final DataRow row = rows[i];
    final Widget built = line(
      key: row.key,
      // Zebra: #F1F1F1 first, then white (dark: the house pair) — TtTableColors.row.
      color: i.isEven
          ? (AppTheme.isDark ? AppColors.tableRowDark : AppColors.evenRowColor)
          : (AppTheme.isDark
              ? AppColors.tableDarkBackground
              : AppColors.oddRowColor),
      style: value,
      cells: <Widget>[
        for (final DataCell c in row.cells)
          c.onTap == null
              ? c.child
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: c.onTap,
                  child: c.child,
                ),
      ],
    );
    final ValueChanged<bool?>? select = row.onSelectChanged;
    if (select == null) return built;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticController.low();
        select(true);
      },
      child: built,
    );
  }

  /// Both scroll views around [table]. [constraints] is the LayoutBuilder's,
  /// and is `null` on the non-[fillWidth] path (9/10/2026), where nothing
  /// reads it.
  Widget _scrollingTable(Widget table, BoxConstraints? constraints) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // `minWidth`, deliberately, and never a fixed width or a tight
        // `SizedBox`: DataTable hands surplus space to its columns, so a
        // narrow table is stretched to fill the row, while a table wider
        // than the screen is left at its own width and still scrolls
        // horizontally. A fixed width would have squeezed the wide case
        // into an overflow.
        //
        // `hasBoundedWidth` guards the case where this widget is itself
        // placed inside another horizontal scroll view or an unbounded Row:
        // maxWidth would be infinity there, and an infinite minWidth is a
        // layout crash rather than a wide table.
        child: (fillWidth || attendanceStyle) &&
                constraints != null &&
                constraints.hasBoundedWidth
            ? ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: table,
              )
            : table,
      ),
    );
  }
}
