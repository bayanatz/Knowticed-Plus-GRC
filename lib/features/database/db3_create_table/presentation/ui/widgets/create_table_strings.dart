/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_strings.dart
/// Description: Declares `CreateTableStrings`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// The module's on-screen text. Moved out of `domain/constants/` (rule 1: no
/// Flutter in the domain layer), and every string now lives in the .arb files
/// (rule 14) — the getters keep the names the screens already call.
library;

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/create_table_limits.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/create_database_limits.dart';

/// The screen's copy, in the two locales the app ships.
class CreateTableStrings {
  const CreateTableStrings._(this._s, this._isArabic);

  /// Every string comes from the .arb files (rule 14); this class only
  /// keeps the names the screens already use.
  final S _s;

  /// Whether the current locale is Arabic — picks the ordinal form below.
  final bool _isArabic;

  /// The strings for the current locale.
  factory CreateTableStrings.of(BuildContext context) =>
      CreateTableStrings._(S.of(context), context.isArabic);

  // ── Breadcrumbs (Figma 7398:6535) ────────────────────────────────────────
  String get database => _s.dbTableDatabase;

  /// The middle crumb is the database's own name, so it is passed in.
  String get creatingTable => _s.dbTableCreatingTable;
  String get editingTableName => _s.dbTableEditingTableName;

  // ── Field labels ─────────────────────────────────────────────────────────
  /// Bilingual by nature: the card captures BOTH languages at once, so these
  /// two are not translations of each other and neither is translated. Same
  /// rule as `CreateDatabaseStrings.databaseTitleEn`.
  ///
  /// The landscape frame labels this "Table Name" and the portrait frame
  /// "Enter Table Name" (7398:6574 vs 7398:6773). One label, not two: an
  /// instruction that changes when the iPad is rotated reads as a bug.
  String get tableNameEn => 'Table Name';
  String get tableNameAr => _s.dbArabicTableNameLabel;

  String get descriptionEn => 'Description';
  String get descriptionAr => _s.dbArabicDescriptionLabel;

  String get commentsAccess => _s.dbTableCommentsAccess;
  String get selectCommentsAccess => _s.dbTableSelectCommentsAccess;

  String get enterRowNumber => _s.dbTableEnterRowNumber;
  String get enterColumnNumber => _s.dbTableEnterColumnNumber;

  // ── Hints ────────────────────────────────────────────────────────────────
  String get hintEn => 'Text here';
  String get hintAr => _s.dbArabicHint;

  // ── Column blocks (Figma 7398:6667 and siblings) ─────────────────────────
  String get dataType => _s.dbTableDataType;
  String get selectDataType => _s.dbTableSelectDataType;
  String get columnName => _s.dbTableColumnName;
  String get columnNameHint => _s.dbTableColumnNameHint;

  /// "1st Column" / "2nd Column" — [index] is ZERO-BASED, the ordinal is not.
  ///
  /// English ordinals are irregular for 1–3 and for anything ending in 11–13,
  /// so the suffix is computed rather than picked from a four-entry table that
  /// would render "21th Column". Arabic uses "العمود ١" past the first three
  /// because the ordinal forms stop being common well before column ten.
  String nthColumn(int index) {
    final int n = index + 1;
    switch (n) {
      case 1:
        return _s.dbTableColumnFirst;
      case 2:
        return _s.dbTableColumnSecond;
      case 3:
        return _s.dbTableColumnThird;
    }
    // English uses the ordinal ("21st"), Arabic the plain number. The .arb
    // key takes ONE placeholder, so the right form is chosen here.
    final bool teen = n % 100 >= 11 && n % 100 <= 13;
    final String suffix = teen
        ? 'th'
        : switch (n % 10) {
            1 => 'st',
            2 => 'nd',
            3 => 'rd',
            _ => 'th',
          };
    return _s.dbTableNthColumn(_isArabic ? '$n' : '$n$suffix');
  }

  String get duplicateColumn => _s.dbTableDuplicateColumn;
  String get removeColumn => _s.dbTableRemoveColumn;

  // ── Actions ──────────────────────────────────────────────────────────────
  String get discard => _s.dbTableDiscard;
  String get create => _s.dbTableCreate;
  String get save => _s.dbTableSave;

  // ── Form Builder: filling a table in (Figma 7398:3042 / 15076 / 15210) ────

  /// Third crumb on the editing screen (7398:15076). "Editing Table Name" in
  /// the Figma is the TEMPLATE — the real crumb carries the table's own name,
  /// the same way `tableDetailsCrumb` does.
  String editingTableDataCrumb(String name) =>
      _s.dbTableEditingTableDataCrumb(name);

  /// Third crumb on the preview screen (7398:15210).
  String get previewCrumb => _s.dbTablePreviewCrumb;

  String get preview => _s.dbTablePreview;
  String get undo => _s.dbTableUndo;
  String get redo => _s.dbTableRedo;
  String get removeSelection => _s.dbTableRemoveSelection;
  String get addRow => _s.dbTableAddRow;
  String get addColumn => _s.dbTableAddColumn;

  /// The Import Table dialog (7398:4041).
  String get importTable => _s.dbTableImportTable;
  String get import => _s.dbTableImport;
  String get typeOfImport => _s.dbTableTypeOfImport;
  String get uploadFile => _s.dbTableUploadFile;

  /// The file was read but nothing in it belonged to this table.
  String get importMatchedNothing => _s.dbTableImportMatchedNothing;

  /// Headings the file had that this table has no column for.
  String importUnmatchedHeadings(String headings) =>
      _s.dbTableImportUnmatchedHeadings(headings);

  /// Asked before the red circle on a heading takes the column away.
  ///
  /// It names the VALUES and not just the column: removing a heading on the
  /// create card costs nothing because there is no data yet, and removing one
  /// here empties a cell in every row.
  String removeColumnSubtitle(String name) =>
      _s.dbTableRemoveColumnSubtitle(name);

  /// Said when Save is pressed over a cell that does not fit its column's type.
  ///
  /// It names the COUNT rather than the cells: the wrong cells are already
  /// outlined in red where they are, and a dialog listing "row 4, Date" for
  /// eleven of them is a dialog nobody reads.
  String invalidCellsSubtitle(int count) => count == 1
      ? _s.dbTableInvalidCellsSubtitleOne
      : _s.dbTableInvalidCellsSubtitleOther(count);

  String get rowsSavedSubtitle => _s.dbTableRowsSavedSubtitle;

  String get discardRowsSubtitle => _s.dbTableDiscardRowsSubtitle;

  /// Shown when Preview is pressed on a table that has nothing in it yet.
  String get nothingToPreview => _s.dbTableNothingToPreview;

  // ── Table list on the details page ───────────────────────────────────────
  //
  // REMOVED 17/8/2026: the nine column headings this section used to hold
  // (`colNo`, `colTableName`, `colColumns`, `colRows`, `colComments`,
  // `colMembers`, `colCreated`, `colLastEdit`, `colAccess`), plus `noTablesYet`
  // and `noTablesMatch`. The list is the Figma's CARD GRID now — see
  // `TableListSection` for why — so there are no columns to head, and both
  // empty states have been the shared animation since 16/8/2026. What the
  // cards do say is under "Table cards" below.

  String get tablesLoadFailed => _s.dbTableTablesLoadFailed;
  String get retry => _s.dbTableRetry;

  /// The rows failed to load (DB-TABLE-01): shown instead of an empty grid.
  String get rowsLoadFailed => _s.dbTableRowsLoadFailed;

  // ── Editing Table Access (7398:13651 / 14122 / 14553) ────────────────────
  //
  // Several of these repeat keys db1 already has (search, department, Select
  // All …). That is the same duplication db2 carries, and it is deliberate:
  // each module ships ONE table so a screen never has to reach across features
  // for a word, and the migration into `intl_*.arb` is a per-module move rather
  // than an untangling.
  String get editingTableAccess => _s.dbTableEditingTableAccess;
  String get accessCrumb => _s.dbTableAccessCrumb;

  String get employeeInformation => _s.dbTableEmployeeInformation;
  String get search => _s.dbTableSearch;
  String get department => _s.dbTableDepartment;
  String get allDepartments => _s.dbTableAllDepartments;
  String get selectAll => _s.dbTableSelectAll;
  String get deselectAll => _s.dbTableDeselectAll;
  String get review => _s.dbTableReview;
  String get discardChanges => _s.dbTableDiscardChanges;

  String get noEmployeesFound => _s.dbTableNoEmployeesFound;
  String get noMembersSelected => _s.dbTableNoMembersSelected;
  String get pickSomeoneFirst => _s.dbTablePickSomeoneFirst;

  // ── Summary tiles (7398:14697-14708) ─────────────────────────────────────
  String get summary => _s.dbTableSummary;
  String get totalEmployees => _s.dbTableTotalEmployees;
  String get totalDepartments => _s.dbTableTotalDepartments;
  String get permissions => _s.dbTablePermissions;

  // ── Viewable Fields ──────────────────────────────────────────────────────
  String get viewableFields => _s.dbTableViewableFields;

  // ── Column headings on the review screen's table view (Figma 7398:14296) ──

  String get colPicture => _s.dbTableColPicture;
  String get colName => _s.dbTableColName;
  String get colJobTitle => _s.dbTableColJobTitle;

  /// The multi-select's empty trigger. Moved here from db1 on 16/8/2026 with
  /// `ViewableFieldsField` itself — the create wizard has no tables, so it had
  /// no columns to offer and the control went with them.
  String get selectViewableFields => _s.dbTableSelectViewableFields;

  /// The tile's value when nothing is restricted. "All fields", not "None":
  /// an unrestricted grant sees the whole table. See
  /// `DatabaseAccessGrant.viewableFields`.
  String get allFields => _s.dbTableAllFields;

  String fieldsSelected(int count) => count == 1
      ? _s.dbTableFieldsSelectedOne
      : _s.dbTableFieldsSelectedOther(count);

  /// Shown under the control when the table has columns but none of them has a
  /// name yet — a table saved through an older build, or one whose headings
  /// were cleared. Different sentence from db1's "no tables yet", because the
  /// fix is different.
  String get tableHasNoNamedColumns => _s.dbTableTableHasNoNamedColumns;

  // ── Access actions ───────────────────────────────────────────────────────
  String get removeAllAccess => _s.dbTableRemoveAllAccess;

  String removeAllAccessSubtitle(int count) => count == 1
      ? _s.dbTableRemoveAllAccessSubtitleOne
      : _s.dbTableRemoveAllAccessSubtitleOther(count);

  String get confirmAccessTitle => _s.dbTableConfirmAccessTitle;
  String get confirmAccessSubtitle => _s.dbTableConfirmAccessSubtitle;
  String get accessSavedSubtitle => _s.dbTableAccessSavedSubtitle;

  String get discardAccessSubtitle => _s.dbTableDiscardAccessSubtitle;

  /// The "you cannot save yet" guard. Names all three requirements, because the
  /// user cannot tell from the screen which one the button is objecting to.
  String get incompleteGrant => _s.dbTableIncompleteGrant;

  String get endBeforeStart => _s.dbTableEndBeforeStart;

  // ── Dialogs ──────────────────────────────────────────────────────────────
  String get confirmCreateTitle => _s.dbTableConfirmCreateTitle;
  String get confirmCreateSubtitle => _s.dbTableConfirmCreateSubtitle;

  String get successTitle => _s.dbTableSuccessTitle;
  String get createdSubtitle => _s.dbTableCreatedSubtitle;
  String get savedSubtitle => _s.dbTableSavedSubtitle;

  String get errorTitle => _s.dbTableErrorTitle;

  /// Heading on the "you cannot continue yet" guards. Not an error — the form
  /// is merely incomplete — so it is worded as a prompt rather than a failure.
  String get incompleteTitle => _s.dbTableIncompleteTitle;

  /// What a greyed-out Save says when it is tapped. ADDED 17/8/2026 with the
  /// rule that Save stays disabled until something is actually edited.
  ///
  /// Same wording as db2's `nothingChangedTitle` / `nothingChanged`, and
  /// deliberately duplicated rather than imported: each module ships ONE string
  /// table so a screen never reaches across features for a sentence — the same
  /// duplication this file's "Editing Table Access" block already carries.
  String get nothingChangedTitle => _s.dbTableNothingChangedTitle;
  String get nothingChanged => _s.dbTableNothingChanged;

  String get close => _s.dbTableClose;
  String get yes => _s.dbTableYes;
  String get no => _s.dbTableNo;

  String get discardConfirmTitle => _s.dbTableDiscardConfirmTitle;
  String get discardConfirmSubtitle => _s.dbTableDiscardConfirmSubtitle;

  /// Lowering "Enter Column Number" throws away the blocks at the end. Naming
  /// the count matters: the blocks being dropped are below the fold on a
  /// portrait iPad, so the user cannot see what they are about to lose.
  String get removeColumnsTitle => _s.dbTableRemoveColumnsTitle;
  String removeColumnsSubtitle(int count) => count == 1
      ? _s.dbTableRemoveColumnsSubtitleOne
      : _s.dbTableRemoveColumnsSubtitleOther(count);

  // ── Validation ───────────────────────────────────────────────────────────
  String get nameEnRequired => _s.dbTableNameEnRequired;
  String get nameArRequired => _s.dbTableNameArRequired;

  String get nameTooShort =>
      _s.dbTableNameTooShort(CreateDatabaseLimits.titleMinLength);

  /// Shown when `tableNameExists` rejects the write. Names the rule that was
  /// broken AND what to do about it: the form the user is looking at is
  /// complete and nothing on screen hints that the name is the problem.
  String get duplicateName => _s.dbTableDuplicateName;

  String get columnCountRange => _s.dbTableColumnCountRange(
        CreateTableLimits.minColumns,
        CreateTableLimits.maxColumns,
      );

  String get rowCountRange => _s.dbTableRowCountRange(
        CreateTableLimits.minRows,
        CreateTableLimits.maxRows,
      );

  // COLUMN-NAME MESSAGES REMOVED 17/8/2026, with the rules that raised them:
  // `columnNameRequired`, `duplicateColumnName`, `columnTypeMismatch` and
  // `columnTypeMismatchAt`. The Column Name box takes any text now — see
  // `TableColumnBlock._nameField` for why the Data Type was the wrong thing to
  // hold a heading to.

  String get couldNotSave => _s.dbTableCouldNotSave;

  // ── Table cards on the details page (Figma 7398:2183 / 1270) ─────────────

  /// "No. of Rows: 100" and "No. of Columns: 10" — the two counts on a card.
  /// The colon is part of the label, as it is on db1's database card.
  ///
  /// The card's two DATE lines are not here: they are [creationDateLabel] and
  /// [lastEditLabel], shared with the info card one screen down, because the
  /// same date under two spellings is exactly what one string table is for.
  String get cardRows => _s.dbTableCardRows;
  String get cardColumns => _s.dbTableCardColumns;

  // ── Table Name Details (Figma 7398:4102 open / 7398:4690 collapsed) ──────

  /// Third crumb. The Figma writes the table's name followed by the word
  /// "Details"; the name is substituted by the caller, the same shape db2's
  /// `detailsCrumb` uses one level up.
  String tableDetailsCrumb(String name) => _s.dbTableTableDetailsCrumb(name);

  /// The label on the COLLAPSED card (7398:4690), where the card's own name is
  /// hidden and something still has to say what "Expand" brings back.
  String get tableDetails => _s.dbTableTableDetails;

  String get hide => _s.dbTableHide;
  String get expand => _s.dbTableExpand;

  String get access => _s.dbTableAccess;
  String get edit => _s.dbTableEdit;
  String get delete => _s.dbTableDelete;
  String get export => _s.dbTableExport;
  String get filter => _s.dbTableFilter;

  String get descriptionLabel => _s.dbTableDescriptionLabel;
  String get creationDateLabel => _s.dbTableCreationDateLabel;
  String get lastEditLabel => _s.dbTableLastEditLabel;

  String get noDescription => _s.dbTableNoDescription;

  // ── The four tiles (Figma 7398:4102, `Frame 1597883023`-`1597883026`) ────
  String get noOfColumns => _s.dbTableNoOfColumns;
  String get noOfRows => _s.dbTableNoOfRows;
  String get accesses => _s.dbTableAccesses;

  // ── The rows grid ────────────────────────────────────────────────────────

  /// Heading over the row-number column of the data grid — the Figma's "NO"
  /// (7398:4138). Same word as [colNo], reused rather than a second key.
  String get rowNumber => _s.dbTableRowNumber;

  /// Shown in place of the grid on a table whose columns were all left unnamed.
  /// Different sentence from [tableHasNoNamedColumns], which explains the same
  /// fact to someone choosing viewable FIELDS — here the fix is to edit the
  /// table, so the sentence says so.
  String get noNamedColumns => _s.dbTableNoNamedColumns;

  String get deleteTableTitle => _s.dbTableDeleteTableTitle;
  String deleteTableSubtitle(String name) =>
      _s.dbTableDeleteTableSubtitle(name);
  String get deletedTitle => _s.dbTableDeletedTitle;
  String deletedSubtitle(String name) => _s.dbTableDeletedSubtitle(name);
  String get deleteFailedTitle => _s.dbTableDeleteFailedTitle;
  String get couldNotDelete => _s.dbTableCouldNotDelete;

  // ── Comments (Figma 7398:8232 / 8311 / 8587) ─────────────────────────────

  /// Fourth crumb, and the label on the button that opens the screen.
  String get comments => _s.dbTableComments;

  String get writeAComment => _s.dbTableWriteAComment;
  String get send => _s.dbTableSend;

  String get like => _s.dbTableLike;
  String get dislike => _s.dbTableDislike;

  /// "Date: 28 Nov 2024 At 8:23" — the Figma's timestamp line, word for word
  /// (7398:8232). The date itself comes from `DatabaseDateFormat.short`, so a
  /// comment and the card above it cannot disagree about how a month is
  /// written; only the "At" and the clock are added here.
  String commentDate(String date, String time) =>
      _s.dbTableCommentDate(date, time);

  String get commentsLoadFailed => _s.dbTableCommentsLoadFailed;

  String get commentFailed => _s.dbTableCommentFailed;

  /// Why the composer is missing. Shown, rather than the box simply being
  /// absent, because a Comments screen with no way to comment reads as broken —
  /// and the reason is a setting somebody can change on the Editing Table Name
  /// card, so naming it is actionable.
  String get commentsPrivate => _s.dbTableCommentsPrivate;

  /// Shown when nobody is signed in, which is the other reason the composer can
  /// be missing — and a completely different fix from [commentsPrivate].
  String get signInToComment => _s.dbTableSignInToComment;

  String get deleteCommentTitle => _s.dbTableDeleteCommentTitle;
  String get deleteCommentSubtitle => _s.dbTableDeleteCommentSubtitle;
}
