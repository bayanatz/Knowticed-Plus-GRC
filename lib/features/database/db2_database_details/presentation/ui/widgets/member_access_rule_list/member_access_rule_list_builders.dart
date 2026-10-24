/// Module: database/db2_database_details
///
///*************************** FILE INFO ****************************///
/// File Name: member_access_rule_list_builders.dart
/// Description: UI builder methods of `MemberAccessRuleList` — split out of `member_access_rule_list.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../member_access_rule_list.dart';

// Split from member_access_rule_list.dart to keep every file under 700 lines.

extension MemberAccessRuleListBuilders on MemberAccessRuleList {
  // ── Table (7398:19187) ───────────────────────────────────────────────────

  /// The list view — the Figma's full column set (7398:19187):
  ///
  ///   Name | Department | Job Title | Access Begin | Access End | Permissions
  ///
  /// THE RULE COLUMNS ARE BACK (17/8/2026)
  /// -------------------------------------
  /// Access Begin, Access End and Permissions were dropped on 16/8/2026, on the
  /// argument that fifteen live controls competing for one horizontal scroll
  /// made a table nobody could read across, and that the CARDS view is where a
  /// rule gets edited. Requested back: switching views to change one date is
  /// worse than a busy table, and this view is the only place the whole set of
  /// rules can be compared down a column — which is the thing a table is for.
  ///
  /// Three things keep it readable, and all three are why this is not simply a
  /// revert:
  ///
  ///   * The controls are UNLABELLED here. Each one's label is its column
  ///     heading, so a row is three boxes rather than three labelled blocks —
  ///     the cards view keeps its labels, because there the fields have no
  ///     heading above them.
  ///   * Every control is pinned to one row height (`_rowFieldHeight`) through
  ///     `CustomDropdown.height` and the calendar's own, so taking a value
  ///     cannot make a row grow and shove the rows under it down.
  ///   * The picture column stays gone. A face needs no heading, so it sits in
  ///     front of the name and the width it would have taken goes to the three
  ///     columns that came back.
  ///
  /// Still hand-built rather than `DataTable`: fixed widths inside a
  /// horizontal scroll keep the columns aligned between the header and the
  /// rows, which intrinsic sizing does not.
  Widget _table(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    // The old picture column's 90 folded into the name's 170 — the tick and
    // the avatar now sit in front of the name inside this one width, so the
    // three columns still start where they used to.
    const double nameWidth = 260;
    const double departmentWidth = 140;
    const double jobWidth = 150;

    // The three rule columns, back on 17/8/2026. The dates get more room than
    // the permission because "28 Nov 2025" plus a calendar glyph is the widest
    // thing either box has to hold; the permission's longest value is
    // "Full Access".
    const double dateWidth = 165;
    const double permissionWidth = 155;

    // Owner 21/10/2026: full width, equal column shares; scrolls when the columns cannot fit.
    return FillWidthTableLayout(
      naturalWidths: <double>[
        nameWidth.w,
        departmentWidth.w,
        jobWidth.w,
        dateWidth.w,
        dateWidth.w,
        permissionWidth.w,
      ],
      reserved: 24.w,
      // Owner 21/10/2026: a title is never cut — each column is at least its full title wide.
      titles: <String?>[
        strings.colName,
        strings.colDepartment,
        strings.colJobTitle,
        strings.accessBegins,
        strings.accessEnds,
        strings.permissions,
      ],
      titleStyle: StyleText.fontSize12Weight500,
      builder: (BuildContext context, List<double> w) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
            child: Container(
              height: 46.h,
              // ONE HEADING COLOUR FOR EVERY TABLE IN THIS MODULE (17/8/2026)
              // — see `AccessTable` and `TableRowsGrid`, which use the same
              // pair. Was `AppColors.header`.
              color: AppTheme.isDark ? AppColors.blackShadow : AppColors.black,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: <Widget>[
                  _head(strings.colName, w[0]),
                  _head(strings.colDepartment, w[1]),
                  _head(strings.colJobTitle, w[2]),
                  // These three headings ARE the labels for the controls
                  // underneath them — see this method's doc for why the fields
                  // in this view carry none of their own.
                  _head(strings.accessBegins, w[3]),
                  _head(strings.accessEnds, w[4]),
                  _head(strings.permissions, w[5]),
                ],
              ),
            ),
          ),
          for (int i = 0; i < rules.length; i++)
            Container(
              // Zebra striping, the same pairing the access table uses so the
              // two tables in this section read as one component.
              color: i.isEven
                  ? (AppTheme.isDark
                      ? AppColors.tableRowDark
                      : AppColors.evenRowColor)
                  : (AppTheme.isDark
                      ? AppColors.tableDarkBackground
                      : AppColors.oddRowColor),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              child: Row(
                // The row is as tall as the controls in it, and the text cells
                // centre against them — left at the default the department and
                // job title would sit on the row's top edge with the boxes
                // hanging below.
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Tick, face and name in ONE column. The Figma's row has no
                  // separate select column either, and the row itself is not
                  // tappable — the tick is the only thing that grants or
                  // revokes, so it has to be its own hit target.
                  SizedBox(
                    width: w[0],
                    child: Row(
                      children: <Widget>[
                        _tick(
                          rules[i].isSelected,
                          () => onToggle(rules[i].member),
                        ),
                        SizedBox(width: 6.w),
                        _avatar(rules[i].member, 14.r),
                        SizedBox(width: 8.w),
                        // Expanded, not a fixed width: the name takes whatever
                        // the tick and the avatar leave, so a long one
                        // ellipsises instead of overflowing the column.
                        Expanded(
                          child: Text(
                            FormatHelper.capitalize(rules[i]
                                .member
                                .localizedName(isArabic: isArabic)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: StyleText.fontSize12Weight400
                                .copyWith(color: AppColors.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _cell(departmentLabel(rules[i].member), w[1]),
                  _cell(
                    rules[i].member.localizedJobTitle(isArabic: isArabic),
                    w[2],
                  ),
                  SizedBox(
                    width: w[3],
                    child: _rowStartField(context, rules[i]),
                  ),
                  SizedBox(
                    width: w[4],
                    child: _rowEndField(context, rules[i]),
                  ),
                  SizedBox(
                    width: w[5],
                    child: _rowPermissionField(context, rules[i]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
