/// Module: database / db2_database_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_strings.dart
/// Description: Declares `DatabaseDetailsStrings`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// The module's on-screen text. Moved out of `domain/constants/` (rule 1: no
/// Flutter in the domain layer), and every string now lives in the .arb files
/// (rule 14) — the getters keep the names the screens already call.
library;

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';

/// The section's copy, in the two locales the app ships.
class DatabaseDetailsStrings {
  const DatabaseDetailsStrings._(this._s);

  /// Every string comes from the .arb files (rule 14); this class only
  /// keeps the names the screens already use.
  final S _s;

  factory DatabaseDetailsStrings.of(BuildContext context) =>
      DatabaseDetailsStrings._(S.of(context));

  // ── Breadcrumbs ──────────────────────────────────────────────────────────
  String get database => _s.dbDetailsDatabase;

  /// Third crumb on the details screen. The Figma writes the record's name
  /// followed by the word "Details"; the name is substituted by the caller.
  String detailsCrumb(String title) => _s.dbDetailsDetailsCrumb(title);

  String get accessCrumb => _s.dbDetailsAccessCrumb;

  String editingCrumb(String title) => _s.dbDetailsEditingCrumb(title);

  String get editingDatabaseAccess => _s.dbDetailsEditingDatabaseAccess;

  String get editingAccessManagement => _s.dbDetailsEditingAccessManagement;

  // ── Details page actions (Figma 7398:735 / 847) ──────────────────────────
  String get access => _s.dbDetailsAccess;
  String get edit => _s.dbDetailsEdit;
  String get delete => _s.dbDetailsDelete;
  String get hide => _s.dbDetailsHide;
  String get expand => _s.dbDetailsExpand;
  String get databaseDetails => _s.dbDetailsDatabaseDetails;

  String get accessManagementLabel => _s.dbDetailsAccessManagementLabel;
  String get descriptionLabel => _s.dbDetailsDescriptionLabel;
  String get creationLabel => _s.dbDetailsCreationLabel;
  String get lastEditLabel => _s.dbDetailsLastEditLabel;
  String get noDescription => _s.dbDetailsNoDescription;

  // ── Details toolbar ──────────────────────────────────────────────────────
  String get search => _s.dbDetailsSearch;
  String get filter => _s.dbDetailsFilter;
  String get sort => _s.dbDetailsSort;
  String get reset => _s.dbDetailsReset;
  String get apply => _s.dbDetailsApply;

  /// The label on the "+ Table" button. The button now opens db3's Creating
  /// Table card; the empty-state and column headings of the list underneath it
  /// belong to that module and live in `CreateTableStrings`.
  ///
  /// REMOVED 16/8/2026, with the section they were placeholders for:
  /// `noTablesYet`, `tableBuilderPendingTitle` and `tableBuilderPending`. The
  /// first is now `CreateTableStrings.noTablesYet` — one owner, next to the
  /// widget that draws it — and the other two said "not wired up yet" about a
  /// screen that exists.
  String get table => _s.dbDetailsTable;

  // ── Access screen (Figma 7398:10662 / 10875) ─────────────────────────────
  String get editAccess => _s.dbDetailsEditAccess;
  String get export => _s.dbDetailsExport;
  String get all => _s.dbDetailsAll;
  String get activeChip => _s.dbDetailsActiveChip;
  String get deactivatedChip => _s.dbDetailsDeactivatedChip;
  String get removedChip => _s.dbDetailsRemovedChip;
  String get scheduledChip => _s.dbDetailsScheduledChip;

  // Table headers — `Group 1597882843`.

  /// Heading of the picture column on the ACCESS table (`access_table.dart`),
  /// which still has one.
  ///
  // `colPicture` REMOVED 17/8/2026. Both tables in this section now put the
  // face in front of the NAME rather than in a column of its own — the member
  // list on 16/8/2026, the access table today — so the heading has no caller
  // left. It also brings the on-screen table and the exported CSV to the same
  // seven columns, which they were not before.
  String get colName => _s.dbDetailsColName;
  String get colDepartment => _s.dbDetailsColDepartment;
  String get colJobTitle => _s.dbDetailsColJobTitle;
  String get colGrantor => _s.dbDetailsColGrantor;
  String get colStart => _s.dbDetailsColStart;
  String get colEnd => _s.dbDetailsColEnd;
  String get colAccessType => _s.dbDetailsColAccessType;
  String get colAccessStatus => _s.dbDetailsColAccessStatus;

  String get noAccessYet => _s.dbDetailsNoAccessYet;
  String get noAccessMatches => _s.dbDetailsNoAccessMatches;

  // ── Export ───────────────────────────────────────────────────────────────
  String get exportEmptyTitle => _s.dbDetailsExportEmptyTitle;
  String get exportEmpty => _s.dbDetailsExportEmpty;
  String get exportDoneTitle => _s.dbDetailsExportDoneTitle;
  String exportDone(String fileName) => _s.dbDetailsExportDone(fileName);
  String get exportFailedTitle => _s.dbDetailsExportFailedTitle;
  String get exportFailed => _s.dbDetailsExportFailed;

  // ── Edit database (Figma 7398:6461 / 16968) ──────────────────────────────
  String get discardChanges => _s.dbDetailsDiscardChanges;
  String get save => _s.dbDetailsSave;
  String get databaseTitleEn => _s.dbEnglishDatabaseTitleLabel;
  String get databaseTitleAr => _s.dbArabicDatabaseTitleLabel;
  String get descriptionEn => _s.dbEnglishDescriptionLabel;
  String get descriptionAr => _s.dbArabicDescriptionLabel;
  String get hintEn => _s.dbEnglishHint;
  String get hintAr => _s.dbArabicHint;

  /// The Figma's confirm/success pair for every edit path
  /// (Frames 1597883137 / 1597883138 and their per-screen copies).
  String get editConfirmTitle => _s.dbDetailsEditConfirmTitle;
  String get editConfirmSubtitle => _s.dbDetailsEditConfirmSubtitle;
  String get editSuccessSubtitle => _s.dbDetailsEditSuccessSubtitle;

  String get discardConfirmTitle => _s.dbDetailsDiscardConfirmTitle;
  String get discardConfirmSubtitle => _s.dbDetailsDiscardConfirmSubtitle;
  String get nothingChangedTitle => _s.dbDetailsNothingChangedTitle;
  String get nothingChanged => _s.dbDetailsNothingChanged;

  // ── Edit access (Figma 7398:9476 / 10176 / 10612 / 18356) ────────────────
  String get accessManagement => _s.dbDetailsAccessManagement;
  String get department => _s.dbDetailsDepartment;
  String get permissions => _s.dbDetailsPermissions;
  String get choosePermissions => _s.dbDetailsChoosePermissions;
  String get selectPermission => _s.dbDetailsSelectPermission;
  String get employeeInformation => _s.dbDetailsEmployeeInformation;
  String get selectAll => _s.dbDetailsSelectAll;
  String get deselectAll => _s.dbDetailsDeselectAll;
  String get review => _s.dbDetailsReview;
  String get grantAccess => _s.dbDetailsGrantAccess;
  String get accessBegins => _s.dbDetailsAccessBegins;
  String get accessEnds => _s.dbDetailsAccessEnds;
  String get startDateOfAccess => _s.dbDetailsStartDateOfAccess;
  String get endDateOfAccess => _s.dbDetailsEndDateOfAccess;
  String get date => _s.dbDetailsDate;
  String get jobTitleLabel => _s.dbDetailsJobTitleLabel;
  String get departmentLabel => _s.dbDetailsDepartmentLabel;
  String get noEmployeesFound => _s.dbDetailsNoEmployeesFound;

  /// Shown on the Open variant before any department has been picked.
  ///
  /// Every pick on that screen belongs to the department in focus, so with no
  /// department there is nowhere for a selection to go — the grid is held back
  /// and says why.
  String get pickDepartmentFirst => _s.dbDetailsPickDepartmentFirst;
  String get summary => _s.dbDetailsSummary;
  String get totalEmployees => _s.dbDetailsTotalEmployees;
  String get totalDepartments => _s.dbDetailsTotalDepartments;

  /// The Personal Access screen (7398:10612) has nothing under the dropdown.
  /// An empty white card reads as a screen that failed to load, so it says
  /// what the empty state MEANS.
  String get personalAccessExplainer => _s.dbDetailsPersonalAccessExplainer;

  /// Shown when switching a database that already has grants to Personal.
  String get personalDropsGrantsTitle => _s.dbDetailsPersonalDropsGrantsTitle;
  String personalDropsGrants(int count) =>
      _s.dbDetailsPersonalDropsGrants(count);

  /// Shown when switching between Open and Restricted with people already
  /// picked. Worded around the SELECTION rather than around revoking, because
  /// nothing is written until Save — what is lost here is the picking work,
  /// and the people keep their access until the save happens.
  String get accessTypeChangeTitle => _s.dbDetailsAccessTypeChangeTitle;
  String accessTypeChangeSubtitle(int count) =>
      _s.dbDetailsAccessTypeChangeSubtitle(count);

  String get pickSomeoneFirst => _s.dbDetailsPickSomeoneFirst;
  String get incompleteGrants => _s.dbDetailsIncompleteGrants;
  String get incompleteRows => _s.dbDetailsIncompleteRows;

  String get accessSavedTitle => _s.dbDetailsAccessSavedTitle;
  String get accessSavedSubtitle => _s.dbDetailsAccessSavedSubtitle;

  // ── Delete (reuses db1's write path) ─────────────────────────────────────
  String get deleteConfirmTitle => _s.dbDetailsDeleteConfirmTitle;
  String deleteConfirmSubtitle(String title) =>
      _s.dbDetailsDeleteConfirmSubtitle(title);
  String get deleteFailedTitle => _s.dbDetailsDeleteFailedTitle;
  String get deletedTitle => _s.dbDetailsDeletedTitle;
  String deletedSubtitle(String title) => _s.dbDetailsDeletedSubtitle(title);

  // ── Shared ───────────────────────────────────────────────────────────────
  String get yes => _s.dbDetailsYes;
  String get no => _s.dbDetailsNo;
  String get close => _s.dbDetailsClose;
  String get retry => _s.dbDetailsRetry;
  String get errorTitle => _s.dbDetailsErrorTitle;
  String get incompleteTitle => _s.dbDetailsIncompleteTitle;
  String get couldNotSave => _s.dbDetailsCouldNotSave;
  String get couldNotLoad => _s.dbDetailsCouldNotLoad;

  // ── Validation ───────────────────────────────────────────────────────────
  String get titleEnRequired => _s.dbDetailsTitleEnRequired;
  String get titleArRequired => _s.dbDetailsTitleArRequired;
  String titleTooShort(int min) => _s.dbDetailsTitleTooShort(min);
  String get duplicateTitle => _s.dbDetailsDuplicateTitle;
}
