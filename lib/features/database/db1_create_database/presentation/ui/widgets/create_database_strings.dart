/// Module: database / db1_create_database / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_strings.dart
/// Description: Declares `CreateDatabaseStrings`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// The module's on-screen text. Moved out of `domain/constants/` (rule 1: no
/// Flutter in the domain layer), and every string now lives in the .arb files
/// (rule 14) — the getters keep the names the screens already call.
library;

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/create_database_limits.dart';

/// The screen's copy, in the two locales the app ships.
class CreateDatabaseStrings {
  const CreateDatabaseStrings._(this._s);

  /// Every string comes from the .arb files (rule 14); this class only
  /// keeps the names the screens already use.
  final S _s;

  /// The strings for the current locale.
  factory CreateDatabaseStrings.of(BuildContext context) =>
      CreateDatabaseStrings._(S.of(context));

  // ── Breadcrumb ───────────────────────────────────────────────────────────
  String get database => _s.dbCreateDatabase;
  String get createNewDatabase => _s.dbCreateCreateNewDatabase;

  // ── Field labels ─────────────────────────────────────────────────────────
  /// English-side title label. The Arabic-side label is [databaseTitleAr] and
  /// is always Arabic regardless of the UI locale — the card captures BOTH
  /// languages at once, so the two labels are not translations of each other.
  String get databaseTitleEn => _s.dbEnglishDatabaseTitleLabel;
  String get databaseTitleAr => _s.dbArabicDatabaseTitleLabel;

  String get descriptionEn => _s.dbEnglishDescriptionLabel;
  String get descriptionAr => _s.dbArabicDescriptionLabel;

  String get accessManagement => _s.dbCreateAccessManagement;

  /// Hint inside the access dropdown while nothing is chosen. Deliberately an
  /// instruction ("Select Access") and not one of the three values, so an
  /// untouched field cannot be mistaken for a made choice.
  String get selectAccess => _s.dbCreateSelectAccess;

  /// Shown under the dropdown when the user presses the primary button
  /// without choosing.
  String get accessRequired => _s.dbCreateAccessRequired;

  // ── Hints ────────────────────────────────────────────────────────────────
  String get hintEn => _s.dbEnglishHint;
  String get hintAr => _s.dbArabicHint;

  // ── Actions ──────────────────────────────────────────────────────────────
  String get discard => _s.dbCreateDiscard;
  String get create => _s.dbCreateCreate;
  String get next => _s.dbCreateNext;
  String get review => _s.dbCreateReview;
  String get saveForLater => _s.dbCreateSaveForLater;
  String get grantAccess => _s.dbCreateGrantAccess;

  // ── Access Management (7398:7396 / 18600) ────────────────────────────────
  String get accessManagementCrumb => _s.dbCreateAccessManagementCrumb;
  String get addMembers => _s.dbCreateAddMembers;
  String get search => _s.dbCreateSearch;
  String get department => _s.dbCreateDepartment;

  /// Sits under the Department multi-select on Open Access while nothing is
  /// picked, in place of the permission fields and the employee list. It
  /// explains an empty screen rather than leaving one.
  String get pickDepartmentFirst => _s.dbCreatePickDepartmentFirst;

  String get selectAll => _s.dbCreateSelectAll;
  String get deselectAll => _s.dbCreateDeselectAll;
  String get employeeInformation => _s.dbCreateEmployeeInformation;
  String get noEmployeesFound => _s.dbCreateNoEmployeesFound;
  String get noMembersSelected => _s.dbCreateNoMembersSelected;

  // ── Access rule fields ───────────────────────────────────────────────────
  String get permissions => _s.dbCreatePermissions;
  String get choosePermissions => _s.dbCreateChoosePermissions;
  String get startDateOfAccess => _s.dbCreateStartDateOfAccess;
  String get endDateOfAccess => _s.dbCreateEndDateOfAccess;
  String get date => _s.dbCreateDate;
  String get endBeforeStart => _s.dbCreateEndBeforeStart;

  // The Viewable Fields strings are in db3's `CreateTableStrings`: a database
  // being created has no tables, so only a table's access screen needs them.

  // ── Review (7398:17988 / 18213) ──────────────────────────────────────────
  String get summary => _s.dbCreateSummary;
  String get totalEmployees => _s.dbCreateTotalEmployees;
  String get totalDepartments => _s.dbCreateTotalDepartments;
  String get incompleteGrants => _s.dbCreateIncompleteGrants;

  /// The same rule, but NAMING the tabs that still need filling.
  ///
  /// The generic sentence above is true and useless on the tabbed review: only
  /// one department's fields are on screen at a time, so "every group" tells a
  /// user staring at three filled boxes nothing about which of the other two
  /// tabs is empty. [departments] is the comma-joined list of the ones that
  /// are.
  String incompleteGrantsFor(String departments) =>
      _s.dbCreateIncompleteGrantsFor(departments);

  /// Shown under the actions row while "Grant Access" is greyed out, so the
  /// button is never disabled without saying why.
  String get finishTheseFirst => _s.dbCreateFinishTheseFirst;
  String get pickSomeoneFirst => _s.dbCreatePickSomeoneFirst;

  // ── Database Builder list (7398:2492) ────────────────────────────────────
  String get databaseBuilder => _s.dbCreateDatabaseBuilder;
  String get createDatabase => _s.dbCreateCreateDatabase;
  String get filter => _s.dbCreateFilter;
  String get sort => _s.dbCreateSort;
  String get all => _s.dbCreateAll;
  String get open => _s.dbCreateOpen;
  String get restricted => _s.dbCreateRestricted;
  String get personal => _s.dbCreatePersonal;
  String get drafts => _s.dbCreateDrafts;
  String get deleted => _s.dbCreateDeleted;
  String get noOfTables => _s.dbCreateNoOfTables;
  String get creation => _s.dbCreateCreation;
  String get access => _s.dbCreateAccess;
  String get noDatabasesYet => _s.dbCreateNoDatabasesYet;

  /// On the list's error state — a failed read is retried, not mistaken for
  /// an empty collection.
  String get retry => _s.dbCreateRetry;

  /// Shown when `titleExists` rejects the write.
  ///
  /// This used to be passed `confirmCreateTitle`, so the failure snackbar read
  /// "New Database" — the dialog's heading, which says nothing about what went
  /// wrong. The message has to name the rule that was broken AND what to do
  /// about it, because the record the user is looking at is complete and
  /// nothing on screen hints that the title is the problem.
  String get duplicateTitle => _s.dbCreateDuplicateTitle;
  String get creationDate => _s.dbCreateCreationDate;
  String get lastUpdate => _s.dbCreateLastUpdate;

  // ── Filter dialog (Figma "Filter" card on the list screen) ───────────────
  String get reset => _s.dbCreateReset;
  String get apply => _s.dbCreateApply;

  // ── Card "..." menu (Figma "3 Dots") ─────────────────────────────────────
  String get edit => _s.dbCreateEdit;
  String get delete => _s.dbCreateDelete;

  String get deleteConfirmTitle => _s.dbCreateDeleteConfirmTitle;

  /// Names the record rather than saying "this database": the menu opens from
  /// one card among many and the dialog then covers the grid, so by the time
  /// it is on screen the user can no longer see which card they tapped.
  ///
  /// With the soft delete. It used to promise that the
  /// grants were removed and that the action could not be undone; both are now
  /// false, and a warning that overstates what is about to happen makes people
  /// hesitate over something reversible.
  String deleteConfirmSubtitle(String title) =>
      _s.dbCreateDeleteConfirmSubtitle(title);

  String get deleteFailedTitle => _s.dbCreateDeleteFailedTitle;

  /// Body of the failure dialog when the repository returned no message of
  /// its own — rare, but "" on a dialog tells the user nothing at all.
  String get deleteFailed => _s.dbCreateDeleteFailed;

  // ── Restore (Deleted chip, "..." menu) ──────────────────

  String get restore => _s.dbCreateRestore;

  String get restoreConfirmTitle => _s.dbCreateRestoreConfirmTitle;

  /// Names the record for the same reason the delete dialog does, and says
  /// WHERE it is going back to — a draft returns to Drafts, not to the
  /// finished list, and a dialog that only said "restore?" would leave the
  /// user hunting for the card afterwards.
  String restoreConfirmSubtitle(String title, {required bool asDraft}) =>
      asDraft
          ? _s.dbCreateRestoreConfirmSubtitleDraft(title)
          : _s.dbCreateRestoreConfirmSubtitleLive(title);

  String get restoreFailedTitle => _s.dbCreateRestoreFailedTitle;

  String get restoreFailed => _s.dbCreateRestoreFailed;

  /// Empty state of the Deleted chip. Distinct from `noDatabasesYet`, which
  /// would read as "you have no databases" while the user is standing in a
  /// tab that is empty for a much better reason.
  String get noDeletedDatabases => _s.dbCreateNoDeletedDatabases;

  /// Shown from the Edit row until the edit flow exists. Worded as "not yet"
  /// rather than as a failure, because nothing broke.
  String get editNotAvailableTitle => _s.dbCreateEditNotAvailableTitle;
  String get editNotAvailable => _s.dbCreateEditNotAvailable;

  /// Shown when the details step validates but no next screen is wired yet.
  String get nextStepPending => _s.dbCreateNextStepPending;

  // ── Dialogs ──────────────────────────────────────────────────────────────
  String get confirmCreateTitle => _s.dbCreateConfirmCreateTitle;
  String get confirmCreateSubtitle => _s.dbCreateConfirmCreateSubtitle;
  String get yes => _s.dbCreateYes;
  String get no => _s.dbCreateNo;

  // ── Save For Later ───────────────────────────────────────────────────────
  String get saveDraftTitle => _s.dbCreateSaveDraftTitle;
  String get saveDraftSubtitle => _s.dbCreateSaveDraftSubtitle;

  /// Body of the failure dialog when the draft write returned no message of
  /// its own.
  String get couldNotSave => _s.dbCreateCouldNotSave;

  String get draftSavedTitle => _s.dbCreateDraftSavedTitle;
  String get draftSavedSubtitle => _s.dbCreateDraftSavedSubtitle;

  String get successTitle => _s.dbCreateSuccessTitle;
  String get successSubtitle => _s.dbCreateSuccessSubtitle;
  String get close => _s.dbCreateClose;

  /// Heading on the failure dialog that replaced the red error snackbar.
  /// The body is the cubit's `errorMessage`, which already names the rule
  /// that was broken, so the heading only has to say "this did not work".
  String get errorTitle => _s.dbCreateErrorTitle;

  /// Heading on the "you cannot continue yet" guards (no members picked, a
  /// grant missing its dates). Not an error — the form is merely incomplete —
  /// so it is worded as a prompt rather than a failure.
  String get incompleteTitle => _s.dbCreateIncompleteTitle;

  /// Heading for [nextStepPending], which reports a *successful* validation
  /// that simply has nowhere to go yet.
  String get nextStepPendingTitle => _s.dbCreateNextStepPendingTitle;

  String get discardConfirmTitle => _s.dbCreateDiscardConfirmTitle;
  String get discardConfirmSubtitle => _s.dbCreateDiscardConfirmSubtitle;

  // ── Validation ───────────────────────────────────────────────────────────
  String get titleEnRequired => _s.dbCreateTitleEnRequired;
  String get titleArRequired => _s.dbCreateTitleArRequired;
  String get titleTooShort =>
      _s.dbCreateTitleTooShort(CreateDatabaseLimits.titleMinLength);
}
