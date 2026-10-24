/// Module: database / db1_create_database / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_cubit.dart
/// Description: Declares `CreateDatabaseCubit`.
/// Author: Amr Mesbah
/// Created at: 15/8/2026
/// Updated: 15/8/2026 - Now owns the whole wizard, not just the form.
///
/// ONE CUBIT FOR THE WHOLE FLOW
/// ----------------------------
/// The Figma section "MAIN PAGE : Creating A DataBase" is four screens that
/// build one record together:
///
///   details (7398:6137) -> add members (7398:7396) or by department
///   (7398:18600) -> review (7398:17988 / 18213) -> Grant Access
///
/// Nothing is written until the last step. If each screen owned its own cubit
/// the draft would have to be threaded through Navigator arguments, and going
/// back a step — which the breadcrumb invites — would drop whatever the later
/// screen had collected. "Save For Later" would also have to re-assemble the
/// draft from pieces held in different places.
///
/// So one cubit owns `CreateDatabaseState` for the whole flow, provided above
/// the wizard's Navigator. Each screen is a view on it.
///
/// The directory (employees, departments) is loaded ONCE per flow into the
/// state rather than per screen: steps 2, 3 and 4 all render the same people,
/// and re-querying on every push made the member list flicker.
library;

import 'package:intl/intl.dart';

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_dispatcher.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
// Also for the `part` file: `CreateDatabaseState.hasValidTitles` reads
// `CreateDatabaseLimits.titleMinLength`, so the button and the validator agree
// on how short is too short.
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/use_cases/create_database_use_case.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/usecases/database_grant_editor.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_directory_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_directory.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_state.dart';
export 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_state.dart';

// Every screen that reads the cubit's state reads departments too.
export 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_department.dart';

class CreateDatabaseCubit extends Cubit<CreateDatabaseState> {
  CreateDatabaseCubit({
    required DatabaseSessionBaseRepository session,
    required DatabaseDirectoryBaseRepository directory,
    required CreateDatabaseBaseRepository repository,
    required CreateDatabaseUseCase useCase,
  }) : this._(
          repository,
          useCase,
          session,
          directory,
          const CreateDatabaseState(),
        );

  /// Function Name: [CreateDatabaseCubit.resumingDraft]
  ///
  /// Purpose: Reopen the wizard on a PARKED DRAFT — what tapping a draft card
  /// in the Database Builder list does.
  ///
  /// The form fills in synchronously from the row the list already had, so the
  /// first screen is never blank behind a spinner. The people picked before
  /// the draft was parked live in a subcollection and arrive through
  /// [loadDraftGrants], which the flow calls on the way in.
  CreateDatabaseCubit.resumingDraft({
    required DatabaseEntity draft,
    required DatabaseSessionBaseRepository session,
    required DatabaseDirectoryBaseRepository directory,
    required CreateDatabaseBaseRepository repository,
    required CreateDatabaseUseCase useCase,
  }) : this._(
          repository,
          useCase,
          session,
          directory,
          CreateDatabaseState.fromDraft(draft),
        );

  /// The one constructor both public ones forward to, so they cannot drift.
  CreateDatabaseCubit._(
    this._repository,
    this._useCase,
    this._session,
    this._directory,
    CreateDatabaseState initial,
  ) : super(initial);

  /// Held alongside the use case because the resume path reads the draft's
  /// grants directly — a plain fetch with no rule attached, so wrapping it in
  /// a use case would only add a layer that forwards.
  final CreateDatabaseBaseRepository _repository;

  final CreateDatabaseUseCase _useCase;

  /// Who is signed in. Read when the record is written, so `created_by` is
  /// never empty for a signed-in user (DB-CREATE-02).
  final DatabaseSessionBaseRepository _session;

  /// The org directory, for the people and department pickers (rule 1: no
  /// reaching into the roles feature from here).
  final DatabaseDirectoryBaseRepository _directory;

  /// Function Name: [loadDraftGrants]
  ///
  /// Purpose: Put a resumed draft's access rules back into the wizard.
  ///
  /// A no-op unless this wizard was opened on a draft, so the flow can call it
  /// unconditionally next to [loadDirectory].
  ///
  /// A failure degrades to "no grants yet" rather than blocking the screen —
  /// the same shape [loadDirectory] uses — but it is NOT silent: the message
  /// goes to the banner, because a draft that quietly reopens with an empty
  /// member list looks like the picks were thrown away, and finishing it from
  /// there would write that emptiness back over them.
  ///
  /// `selectedDepartmentIds` is rebuilt from the grants rather than stored on
  /// the record: the department chips on step 2 are what the user picked, and
  /// for a resumed draft the department-scoped grants ARE that list.
  Future<void> loadDraftGrants() async {
    final String? id = state.resumedDraftId;
    if (id == null || id.isEmpty) return;

    emit(state.copyWith(isLoadingDraft: true, clearErrorMessage: true));

    final Either<Failure, List<DatabaseAccessGrant>> result =
        await _repository.fetchGrants(id);

    emit(
      result.fold(
        (Failure failure) => state.copyWith(
          isLoadingDraft: false,
          errorMessage: failure.errMessage,
        ),
        (List<DatabaseAccessGrant> grants) => state.copyWith(
          isLoadingDraft: false,
          grants: grants,
          selectedDepartmentIds: <String>[
            for (final DatabaseAccessGrant g in grants)
              if (g.departmentId != null) g.departmentId!,
          ],
        ),
      ),
    );
  }

  @override
  void emit(CreateDatabaseState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── Step 1: details ──────────────────────────────────────────────────────

  /// Function Name: [titleEnChanged]
  ///
  /// Purpose: Store the English title as typed and clear its error.
  void titleEnChanged(String value) =>
      emit(state.copyWith(titleEn: value, clearTitleEnError: true));

  /// Function Name: [titleArChanged]
  ///
  /// Purpose: Store the Arabic title as typed and clear its error.
  void titleArChanged(String value) =>
      emit(state.copyWith(titleAr: value, clearTitleArError: true));

  /// Function Name: [descriptionEnChanged]
  ///
  /// Purpose: Store the English description as typed.
  void descriptionEnChanged(String value) =>
      emit(state.copyWith(descriptionEn: value));

  /// Function Name: [descriptionArChanged]
  ///
  /// Purpose: Store the Arabic description as typed.
  void descriptionArChanged(String value) =>
      emit(state.copyWith(descriptionAr: value));

  /// Function Name: [accessTypeChanged]
  ///
  /// Purpose: Set the access type. A REAL change clears the people and
  /// departments picked for the old type (DB-CREATE-03): Personal has nobody,
  /// and Open and Restricted pick people in different ways, so nothing carries
  /// across honestly. The form asks first when there is something to lose.
  ///
  /// Parameters: [value] the type chosen in the dropdown.
  void accessTypeChanged(DatabaseAccessType value) {
    if (state.accessType == value) return;
    emit(
      state.copyWith(
        accessType: value,
        grants: const <DatabaseAccessGrant>[],
        selectedDepartmentIds: const <String>[],
        clearSelectedDepartment: true,
        clearAccessTypeError: true,
      ),
    );
  }

  /// Function Name: [coverImagePicked]
  ///
  /// Purpose: Store the cover image the user picked.
  void coverImagePicked(File file) => emit(state.copyWith(coverImage: file));

  /// Function Name: [coverImageCleared]
  ///
  /// Purpose: Remove the picked cover image.
  void coverImageCleared() => emit(state.copyWith(clearCoverImage: true));

  // ── Navigation between steps ─────────────────────────────────────────────

  /// Function Name: [goToStep]
  ///
  /// Purpose: Move the wizard to [step].
  void goToStep(CreateDatabaseStep step) => emit(state.copyWith(step: step));

  /// True when the chosen access type needs no people-picking step, so the
  /// details screen creates the record directly.
  ///
  /// PERSONAL means the database belongs to its creator alone, so there is
  /// nobody to select. OPEN is opened to departments, so it is the one that
  /// needs the picking step.
  bool get skipsAccessStep => state.accessType == DatabaseAccessType.personal;

  CreateDatabaseStep _nextStepForAccessType() {
    switch (state.accessType) {
      case DatabaseAccessType.personal:
        // Nothing to pick — the details screen submits from here.
        return CreateDatabaseStep.details;
      case DatabaseAccessType.restricted:
        return CreateDatabaseStep.addMembers;
      case DatabaseAccessType.open:
        return CreateDatabaseStep.byDepartment;
      case null:
        // Unreachable: the caller above returns false while it is null. Stays
        // on the details card rather than throwing, so a future caller that
        // forgets the guard strands nobody mid-wizard.
        return CreateDatabaseStep.details;
    }
  }

  // ── Steps 2-3: choosing people ───────────────────────────────────────────

  /// Function Name: [memberSearchChanged]
  ///
  /// Purpose: Store the people-search text; the visible list is filtered from it.
  void memberSearchChanged(String query) =>
      emit(state.copyWith(memberSearchQuery: query));

  /// Focuses one chip — the yellow one on 7398:18600. Does NOT change which
  /// departments are in play; see [departmentsChanged] for that.
  void departmentSelected(String? departmentId) => emit(
        departmentId == null
            ? state.copyWith(clearSelectedDepartment: true)
            : state.copyWith(selectedDepartmentId: departmentId),
      );

  /// Function Name: [departmentsChanged]
  ///
  /// Purpose: Applies the Department MULTI-SELECT's new full selection.
  ///
  /// Two things follow from a change here, and both have to happen in one
  /// emit or the screen renders a half-updated draft:
  ///
  ///   * DESELECTING a department drops its grant. Leaving it behind would
  ///     write access for a department the user removed from the field, and
  ///     it would still show up as a tab on the Review screen.
  ///   * The FOCUS has to stay on a chip that still exists. When the focused
  ///     department is deselected, focus moves to the most recent pick —
  ///     which is also the one the user just added, so ticking a department
  ///     immediately scopes the fields and the employee list to it.
  void departmentsChanged(List<String> departmentIds) {
    final List<String> ids = List<String>.from(departmentIds);

    String? focus = state.selectedDepartmentId;
    if (focus == null || !ids.contains(focus)) {
      focus = ids.isEmpty ? null : ids.last;
    }

    final List<DatabaseAccessGrant> grants = state.grants
        .where(
          (DatabaseAccessGrant g) =>
              !g.isDepartmentScoped || ids.contains(g.departmentId),
        )
        .toList(growable: false);

    emit(
      state.copyWith(
        selectedDepartmentIds: ids,
        grants: grants,
        selectedDepartmentId: focus,
        clearSelectedDepartment: focus == null,
      ),
    );
  }

  /// Function Name: [toggleMember]
  ///
  /// Purpose: Add or remove one person, creating the grant on first pick. On
  /// Add Members they go into the individual grant; on By Department into the
  /// grant of the department in focus, which gives Review its per-department
  /// tabs.
  ///
  /// Parameters: [member] the person tapped.
  ///
  /// Returns: void; the change arrives as a new state.
  void toggleMember(DatabaseMember member) => emit(
        state.copyWith(
          grants: DatabaseGrantEditor.toggleMember(
            state.grants,
            scope: _memberScope,
            member: member,
            departments: state.departments,
          ),
        ),
      );

  /// The grant a pick goes into: the department in focus on By Department,
  /// the individual grant everywhere else.
  String? get _memberScope => state.step == CreateDatabaseStep.byDepartment
      ? state.selectedDepartmentId
      : null;

  /// Function Name: [toggleAllVisible]
  ///
  /// Purpose: Pick every visible person into the same grant [toggleMember]
  /// uses — the select-all control on 7398:18600 — or unpick them all when
  /// they are already in.
  ///
  /// Returns: void; the change arrives as a new state.
  void toggleAllVisible() => emit(
        state.copyWith(
          grants: DatabaseGrantEditor.toggleAll(
            state.grants,
            scope: _memberScope,
            visible: state.visibleEmployees,
            departments: state.departments,
          ),
        ),
      );

  /// Function Name: [removeMemberEverywhere]
  ///
  /// Purpose: Remove one person wherever they appear — the red minus on the
  /// Review screens (7398:17988, 7398:18213).
  ///
  /// Parameters: [member] the person.
  ///
  /// Returns: void; the change arrives as a new state.
  void removeMemberEverywhere(DatabaseMember member) => emit(
        state.copyWith(
          grants: DatabaseGrantEditor.removeEverywhere(state.grants, member),
        ),
      );

  // ── Step 4: review ───────────────────────────────────────────────────────

  /// Applies [change] to the grant(s) [departmentId] names; see
  /// `DatabaseGrantEditor.mutate`.
  void _mutateGrant(
    String? departmentId,
    DatabaseAccessGrant Function(DatabaseAccessGrant grant) change,
  ) =>
      emit(
        state.copyWith(
          grants: DatabaseGrantEditor.mutate(
            state.grants,
            departmentId: departmentId,
            change: change,
            departments: state.departments,
          ),
        ),
      );

  /// Function Name: [permissionChanged]
  ///
  /// Purpose: Apply a permission level — to every grant when [departmentId]
  /// is null (the single dropdown on 7398:17988), or to that department only
  /// (the per-tab dropdown on 7398:18213).
  ///
  /// Parameters: [permission] the level; [departmentId] the tab, or null.
  ///
  /// Returns: void; the change arrives as a new state.
  void permissionChanged(
    DatabasePermissionLevel permission, {
    String? departmentId,
  }) =>
      _mutateGrant(
        departmentId,
        (DatabaseAccessGrant g) => g.copyWith(permission: permission),
      );

  /// Function Name: [startDateChanged]
  ///
  /// Purpose: Set the start date, scoped like [permissionChanged].
  ///
  /// Parameters: [date] the first day; [departmentId] the tab, or null.
  ///
  /// Returns: void; the change arrives as a new state.
  void startDateChanged(DateTime date, {String? departmentId}) => _mutateGrant(
        departmentId,
        (DatabaseAccessGrant g) => g.copyWith(startDate: date),
      );

  /// Function Name: [endDateChanged]
  ///
  /// Purpose: Set the end date, scoped like [permissionChanged].
  ///
  /// Parameters: [date] the last day; [departmentId] the tab, or null.
  ///
  /// Returns: void; the change arrives as a new state.
  void endDateChanged(DateTime date, {String? departmentId}) => _mutateGrant(
        departmentId,
        (DatabaseAccessGrant g) => g.copyWith(endDate: date),
      );

  // Grants written by the wizard carry an empty Viewable Fields list, which
  // means "all fields": the database has no tables yet. db3's
  // `TableAccessCubit` sets the list once a table exists.

  // ── Submit ───────────────────────────────────────────────────────────────

  /// Function Name: [clearMessages]
  ///
  /// Purpose: Clear the error and success messages once the screen has shown them, so a rebuild does not show them twice.
  void clearMessages() => emit(state.consumed());

  /// Clears the draft back to an empty form, keeping the directory so the next
  /// pass does not re-query it.
  ///
  /// `resumedDraftId` and `resumedCoverImageUrl` are carried through: a wizard
  /// opened on a parked draft is still editing THAT record after a reset, and
  /// dropping the id here would turn the next write into a create and leave a
  /// duplicate beside the draft.
  void reset() => emit(
        CreateDatabaseState(
          availableEmployees: state.availableEmployees,
          departments: state.departments,
          resumedDraftId: state.resumedDraftId,
          resumedCoverImageUrl: state.resumedCoverImageUrl,
        ),
      );

  /// Function Name: [submit]
  ///
  /// Purpose: The finished write — "Grant Access" on the Review screen, or
  /// "Create" straight from the details card on Personal Access.
  ///
  /// The localized copy is passed in because the cubit has no BuildContext,
  /// and the domain layer must not acquire one.
  Future<void> submit({
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String duplicateMessage,
    required String accessRequiredMessage,
  }) =>
      _write(
        lifecycle: DatabaseStatus.active,
        requiredEnMessage: requiredEnMessage,
        requiredArMessage: requiredArMessage,
        tooShortMessage: tooShortMessage,
        duplicateMessage: duplicateMessage,
        accessRequiredMessage: accessRequiredMessage,
      );

  /// Function Name: [saveAsDraft]
  ///
  /// Purpose: "Save For Later" — park the wizard's work as a DRAFT.
  ///
  /// This used to be wired to the flow's exit callback, so pressing it threw
  /// the draft away: nothing was written, and the Drafts chip on the list
  /// counted zero for ever. It is a real write now, at the same moment and
  /// through the same use case as Grant Access — only the lifecycle differs,
  /// which is what puts the record under Drafts instead of under its access
  /// type.
  ///
  /// The grants ARE written with it. A draft that dropped the people already
  /// picked would make "Save For Later" mean "start again later", which is
  /// the opposite of what the button says.
  Future<void> saveAsDraft({
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String duplicateMessage,
    required String accessRequiredMessage,
  }) =>
      _write(
        lifecycle: DatabaseStatus.draft,
        requiredEnMessage: requiredEnMessage,
        requiredArMessage: requiredArMessage,
        tooShortMessage: tooShortMessage,
        duplicateMessage: duplicateMessage,
        accessRequiredMessage: accessRequiredMessage,
      );

  // ── Internals ────────────────────────────────────────────────────────────

  /// The entity the wizard is about to write.
  ///
  /// [id] stays empty even when resuming a draft: `existingId` on the use case
  /// is what decides create vs update, and two places holding the same id is
  /// how they end up disagreeing.
  ///
  /// `coverImageUrl` carries the resumed draft's existing cover. The update
  /// writes that field, so without it, finishing a draft whose cover picker
  /// was never touched would blank the image it was saved with.
  DatabaseEntity _draft({String? createdBy}) => DatabaseEntity(
        id: '',
        coverImageUrl: state.resumedCoverImageUrl,
        titleEn: state.titleEn,
        titleAr: state.titleAr,
        descriptionEn: state.descriptionEn,
        descriptionAr: state.descriptionAr,
        // `DatabaseEntity.accessType` is non-nullable — a SAVED record always
        // has one. The fallback only ever feeds the title-only validation
        // pass, which does not read it; every path that writes checks
        // `state.accessType != null` first.
        accessType: state.accessType ?? DatabaseAccessType.restricted,
        createdBy: createdBy,
      );

  // ── Directory ────────────────────────────────────────────────────────────

  /// Function Name: [loadDirectory]
  ///
  /// Purpose: Read the employees and departments for the pickers, through
  /// the injected [DatabaseDirectoryBaseRepository].
  ///
  /// A failure degrades to an empty directory instead of throwing — the
  /// screen shows its empty state — and the banner reports it.
  ///
  /// Returns: [Future<void>]; the lists arrive as a new state.
  Future<void> loadDirectory() async {
    if (state.isLoadingDirectory) return;
    emit(state.copyWith(isLoadingDirectory: true));

    final Either<Failure, DatabaseDirectory> result =
        await _directory.loadDirectory();

    emit(
      result.fold(
        (Failure failure) => state.copyWith(
          isLoadingDirectory: false,
          errorMessage: failure.errMessage,
        ),
        (DatabaseDirectory directory) => state.copyWith(
          isLoadingDirectory: false,
          availableEmployees: directory.members,
          departments: directory.departments,
        ),
      ),
    );
  }

  /// Validates the details screen and, if it passes, advances.
  /// Returns whether it advanced so the page can decide to push.
  bool validateDetailsAndAdvance({
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String accessRequiredMessage,
  }) {
    final CreateDatabaseValidation validation = _useCase.validate(
      _draft(),
      requiredEnMessage: requiredEnMessage,
      requiredArMessage: requiredArMessage,
      tooShortMessage: tooShortMessage,
    );

    // The access type is checked HERE and not in the use case: the use case
    // validates a `DatabaseEntity`, whose accessType is non-nullable by
    // design (a saved record always has one). "The user has not chosen yet"
    // is a state of this form, not of the record.
    final bool accessMissing = state.accessType == null;

    if (!validation.isValid || accessMissing) {
      emit(_withErrors(validation, accessMissing, accessRequiredMessage));
      return false;
    }

    // The access type decides the next screen: PERSONAL submits from the
    // card, RESTRICTED goes to Add Members, OPEN to By Department.
    emit(
      state.copyWith(
        submitted: true,
        step: _nextStepForAccessType(),
        clearTitleEnError: true,
        clearTitleArError: true,
        clearAccessTypeError: true,
      ),
    );
    return true;
  }

  /// The one write both buttons go through.
  ///
  /// Validation is identical for a draft: a record with no title is one the
  /// user cannot recognise in the list, so "Save For Later" is not an escape
  /// hatch from naming it. What a draft is NOT asked for is a complete set of
  /// grants — `canGrantAccess` gates the Review screen's primary button, not
  /// this path.
  Future<void> _write({
    required DatabaseStatus lifecycle,
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String duplicateMessage,
    required String accessRequiredMessage,
  }) async {
    final DatabaseEntity draft = _draft(createdBy: _session.signedInEmployeeId)
        .copyWith(status: lifecycle);

    final CreateDatabaseValidation validation = _useCase.validate(
      draft,
      requiredEnMessage: requiredEnMessage,
      requiredArMessage: requiredArMessage,
      tooShortMessage: tooShortMessage,
    );

    // Same guard as the advance path, repeated because this is the write:
    // `_draft()` fills a fallback access type to satisfy the entity, so
    // without this a submit reached with an empty dropdown would silently
    // store that fallback.
    final bool accessMissing = state.accessType == null;

    if (!validation.isValid || accessMissing) {
      emit(
        _withErrors(validation, accessMissing, accessRequiredMessage).copyWith(
          step: CreateDatabaseStep.details,
          status: CreateDatabaseStatus.initial,
        ),
      );
      return;
    }

    // ADDED 18/10/2026 (DB-2): a database saved while the signed-in
    // employee was not loaded got `created_by: null`, and the list query
    // (created_by == me OR member) then never shows it to anyone.
    if (_session.signedInEmployeeId == null) {
      emit(
        state.copyWith(
          status: CreateDatabaseStatus.failure,
          errorMessage: Intl.getCurrentLocale().startsWith('ar')
              ? 'تعذّر تحميل بيانات حسابك. أعد المحاولة بعد لحظات.'
              : 'Your account details are still loading. Please try again in a moment.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitted: true,
        status: CreateDatabaseStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    // Personal Access is the creator's alone: no grants are written and nobody
    // is notified, whatever is still in state (DB-CREATE-03).
    final List<DatabaseAccessGrant> grants =
        state.accessType == DatabaseAccessType.personal
            ? const <DatabaseAccessGrant>[]
            : state.grants;

    final Either<Failure, DatabaseEntity> result = await _useCase(
      draft,
      coverImagePath: state.coverImage?.path,
      grants: grants,
      // Null for a new database, the draft's id when the wizard was reopened
      // on one — which turns this write into an UPDATE of that record and
      // stops the duplicate check refusing the draft for clashing with its own
      // title. See `CreateDatabaseUseCase.call`.
      existingId: state.resumedDraftId,
      duplicateMessage: duplicateMessage,
    );

    final CreateDatabaseState next = result.fold(
      (Failure failure) => state.copyWith(
        status: CreateDatabaseStatus.failure,
        errorMessage: failure.errMessage,
      ),
      (DatabaseEntity created) => state.copyWith(
        status: CreateDatabaseStatus.success,
        createdDatabase: created,
        // Which success dialog the screen shows. Without this the draft path
        // would announce "You Successfully Created New Database", which is
        // exactly what it did not do.
        savedAsDraft: lifecycle.isDraft,
      ),
    );

    emit(next);

    // ── Notifications (spec §1.7) ───────────────────────────────────────────
    //
    // After the emit and not awaited: one push per recipient would hold the
    // success dialog back, and a failure cannot change what was written.
    // Drafts send nothing — nobody has been granted anything yet, and
    // finishing the draft later would notify them again.
    final DatabaseEntity? created = next.createdDatabase;
    if (next.status == CreateDatabaseStatus.success &&
        !lifecycle.isDraft &&
        created != null) {
      DatabaseNotificationDispatcher.databaseCreated(
        databaseId: created.id,
        databaseNameEn: created.titleEn,
        databaseNameAr: created.titleAr,
        grants: grants,
      );
    }
  }

  /// The state after a failed validation: the title and access-type errors
  /// shown, and the ones that passed cleared.
  CreateDatabaseState _withErrors(
    CreateDatabaseValidation validation,
    bool accessMissing,
    String accessRequiredMessage,
  ) =>
      state.copyWith(
        submitted: true,
        titleEnError: validation.titleEnError,
        titleArError: validation.titleArError,
        accessTypeError: accessMissing ? accessRequiredMessage : null,
        clearTitleEnError: validation.titleEnError == null,
        clearTitleArError: validation.titleArError == null,
        clearAccessTypeError: !accessMissing,
      );
}
