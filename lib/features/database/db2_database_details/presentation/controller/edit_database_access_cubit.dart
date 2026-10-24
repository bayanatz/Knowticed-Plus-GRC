/// Module: database / db2_database_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: edit_database_access_cubit.dart
/// Description: Declares `EditDatabaseAccessCubit`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// "Editing Database Access" — Figma 7398:9476 (Open, iPad V) / 7398:9790
/// (Open, iPad H), 7398:10176 + 10331 (Restricted, card and list views),
/// 7398:10612 (Personal), and the review screen 7398:18356 / 10002.
///
/// WHY THIS EXTENDS THE CREATE CUBIT INSTEAD OF COPYING IT
/// ------------------------------------------------------
/// Put the create screens and the edit screens side by side and the difference
/// is the header, the footer labels, and what the last button does. The middle
/// — a department multi-select that drives chips, a permission-and-dates block
/// scoped to the focused chip, a searchable employee grid, dedupe across
/// grants, "who is selected" — is the same behaviour on the same state, and it
/// is roughly six hundred lines of it.
///
/// Reimplementing that here would mean two definitions of "a person can be in
/// exactly one department grant", and the first bug fixed in one would live on
/// in the other. So `CreateDatabaseState` and every selection method are
/// INHERITED, and this class adds only the three things editing needs:
///
///   1. [seed]        — start from what is stored, not from an empty draft
///   2. per-person rules for the Restricted screen (see below)
///   3. [saveAccess]  — rewrite the subcollection instead of creating a record
///
/// PER-PERSON RULES ON THE RESTRICTED SCREEN
/// -----------------------------------------
/// The create wizard gives everyone picked individually ONE window and ONE
/// permission level: a single grant with a null departmentId. The editing
/// screen does not — Figma 7398:10176 draws "Access Begins", "Access Ends" and
/// "Permissions" INSIDE each person's card, so Mona can be a viewer until
/// March while Salma edits until December.
///
/// That is expressed by giving each individually-picked person their own
/// single-member grant, which is why the methods below exist instead of the
/// inherited `toggleMember` — that one funnels everybody into the first
/// null-department grant it finds and would collapse the per-person windows
/// back into one the moment a second person was ticked.
///
/// The `Access_Grants` shape does not change: a grant has always been "a
/// permission, a window, and the people it applies to". One person is a legal
/// value of "the people".
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_dispatcher.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/use_cases/database_access_rule.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/usecases/database_grant_editor.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EditDatabaseAccessCubit extends CreateDatabaseCubit {
  EditDatabaseAccessCubit({
    required DatabaseEntity database,
    required List<DatabaseAccessGrantRecord> records,
    required int expectedAccessVersion,
    required super.session,
    required super.directory,
    required DatabaseDetailsBaseRepository repository,
    required CreateDatabaseBaseRepository createRepository,
    required super.useCase,
  })  : _database = database,
        _originalRecords = records,
        _expectedAccessVersion = expectedAccessVersion,
        _repository = repository,
        _editor = session,
        super(repository: createRepository);

  DatabaseEntity _database;
  final List<DatabaseAccessGrantRecord> _originalRecords;

  /// The access version [_originalRecords] were read at (DB-DETAILS-04).
  final int _expectedAccessVersion;
  final DatabaseDetailsBaseRepository _repository;

  /// Who is doing the editing — stamped onto every grant this save writes, so
  /// the Access table's "Access Grantor" column names the person who actually
  /// granted it rather than whoever first created the database.
  final DatabaseSessionBaseRepository _editor;

  DatabaseEntity get database => _database;

  /// The record as it stands after a successful save, for the caller to swap
  /// into the screen behind this one.
  DatabaseEntity? get savedDatabase => state.createdDatabase;

  // ── Seeding ──────────────────────────────────────────────────────────────

  /// Function Name: [seed]
  ///
  /// Purpose: Load the directory and open on the stored grants.
  ///
  /// The directory load is awaited FIRST because the seeded state depends on
  /// it: `loadDirectory` emits a state built from whatever it was handed when
  /// it started, so seeding before it returns would have the directory's emit
  /// overwrite the grants a moment later — the screen would flash the right
  /// selection and then lose it.
  Future<void> seed() async {
    await loadDirectory();

    final List<DatabaseAccessGrant> grants = _originalRecords
        .map((DatabaseAccessGrantRecord r) => r.grant)
        .where((DatabaseAccessGrant g) => g.members.isNotEmpty)
        .toList(growable: false);

    // Department ids in the order they were written, deduped. This is what
    // draws the chip row, and a department that lost every member still counts
    // as picked — dropping it here would make the chip vanish from a screen
    // the user has not touched yet.
    final List<String> departmentIds = <String>[];
    for (final DatabaseAccessGrant g in grants) {
      final String? id = g.departmentId;
      if (id != null && id.isNotEmpty && !departmentIds.contains(id)) {
        departmentIds.add(id);
      }
    }

    final DatabaseAccessType type = _database.accessType;

    emit(
      state.copyWith(
        accessType: type,
        grants: grants,
        selectedDepartmentIds: departmentIds,
        selectedDepartmentId:
            departmentIds.isEmpty ? null : departmentIds.first,
        clearSelectedDepartment: departmentIds.isEmpty,
        step: _stepFor(type),
      ),
    );
  }

  CreateDatabaseStep _stepFor(DatabaseAccessType type) {
    switch (type) {
      case DatabaseAccessType.open:
        return CreateDatabaseStep.byDepartment;
      case DatabaseAccessType.restricted:
        return CreateDatabaseStep.addMembers;
      case DatabaseAccessType.personal:
        return CreateDatabaseStep.details;
    }
  }

  /// Switching the access type in the dropdown at the top of the screen.
  ///
  /// The three types are three different ways of choosing people, not three
  /// labels on one selection: Open grants to whole departments, Restricted to
  /// named individuals with their own windows, Personal to nobody. There is no
  /// honest automatic translation between them — flattening a department into
  /// individuals invents a per-person window nobody set, and grouping
  /// individuals into departments silently merges windows that disagree.
  ///
  /// So the picks are CLEARED on a real change, and the screen asks first
  /// (see `EditDatabaseAccessPage._onAccessTypeChanged`). Re-selecting the
  /// type that is already set is not a change and clears nothing.
  @override
  void accessTypeChanged(DatabaseAccessType value) {
    if (state.accessType == value) return;

    emit(
      state.copyWith(
        accessType: value,
        grants: const <DatabaseAccessGrant>[],
        selectedDepartmentIds: const <String>[],
        clearSelectedDepartment: true,
        clearAccessTypeError: true,
        step: _stepFor(value),
      ),
    );
  }

  // ── Restricted: one grant per person ─────────────────────────────────────

  /// The employee list the Restricted screen draws.
  ///
  /// `state.visibleEmployees` only applies the department narrowing on the
  /// by-department step, because that is the only create screen that has one.
  /// The editing screen has a Department dropdown next to the search box on
  /// the Restricted variant too (Figma 7398:10176), so the filter is applied
  /// here rather than by widening the inherited getter — that one is shared
  /// with the create wizard, where a department filter on Add Members would
  /// change which people the user can pick.
  ///
  /// THE LIST IS THE ACCESS LIST UNTIL YOU SEARCH (16/8/2026)
  /// -------------------------------------------------------
  /// With no query this returns ONLY the people who already hold a grant, not
  /// the whole directory. This screen is "Editing Database Access": what it is
  /// for is reading and changing the access that exists, and each row here is
  /// a person's whole rule — their window and their permission level. Drawing
  /// all 400 employees put four rows of live date pickers and permission
  /// dropdowns between the user and the two people they came to edit, and the
  /// picked faces above were the only way to tell which was which.
  ///
  /// Adding someone new is what the SEARCH box is for: type, and the whole
  /// directory is matched again so anyone can be found and ticked. Once ticked
  /// they hold a grant, so they stay in the list when the box is cleared.
  ///
  /// The department dropdown stays a FILTER either way — it narrows whatever
  /// is being shown (the access list, or the search results) rather than
  /// revealing unpicked people on its own. Browsing a department to find
  /// someone is the search box's job, and one control that sometimes adds
  /// people to the list and sometimes removes them is the confusing part.
  List<DatabaseMember> get filteredEmployees {
    final String query = state.memberSearchQuery.trim().toLowerCase();
    final String? department = state.selectedDepartmentId;
    final bool isSearching = query.isNotEmpty;

    return state.availableEmployees.where((DatabaseMember m) {
      if (department != null &&
          department.isNotEmpty &&
          m.departmentId != department) {
        return false;
      }
      if (!isSearching) return grantForMember(m) != null;
      return m.nameEn.toLowerCase().contains(query) ||
          m.nameAr.contains(state.memberSearchQuery.trim()) ||
          (m.email?.toLowerCase().contains(query) ?? false);
    }).toList(growable: false);
  }

  /// Function Name: [grantForMember]
  ///
  /// Purpose: The grant carrying exactly [member].
  ///
  /// Parameters: [member] the person.
  ///
  /// Returns: [DatabaseAccessGrant?] null while they are not picked.
  DatabaseAccessGrant? grantForMember(DatabaseMember member) =>
      DatabaseGrantEditor.grantForMember(state.grants, member);

  /// Function Name: [toggleIndividualMember]
  ///
  /// Purpose: Tick or untick one person on the Restricted screen — a
  /// one-person grant, not the inherited `toggleMember`, because each person
  /// keeps their own window here.
  ///
  /// Parameters: [member] the person tapped.
  ///
  /// Returns: void; the change arrives as a new state.
  void toggleIndividualMember(DatabaseMember member) => emit(
        state.copyWith(
          grants: DatabaseGrantEditor.toggleIndividual(state.grants, member),
        ),
      );

  /// Function Name: [memberRuleChanged]
  ///
  /// Purpose: Apply one person's own permission or window; nothing changes
  /// while they are not picked.
  ///
  /// Parameters: [member]; [permission], [startDate], [endDate] the fields to
  /// change, null to keep.
  ///
  /// Returns: void; the change arrives as a new state.
  void memberRuleChanged(
    DatabaseMember member, {
    DatabasePermissionLevel? permission,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      emit(
        state.copyWith(
          grants: DatabaseGrantEditor.setMemberRule(
            state.grants,
            member,
            permission: permission,
            startDate: startDate,
            endDate: endDate,
          ),
        ),
      );

  /// True once every picked person has a level and both dates — what gates
  /// "Grant Access" on the Restricted screen. `state.canGrantAccess` says the
  /// same thing; this reads it under the name the screen uses.
  bool get individualRulesComplete => state.canGrantAccess;

  // ── Save ─────────────────────────────────────────────────────────────────

  /// Function Name: [saveAccess]
  ///
  /// Purpose: Rewrite the `Access_Grants` subcollection and bring the parent
  /// record back in step.
  ///
  /// This does NOT go through the inherited `submit`. That one creates a new
  /// document from the whole draft — title, description, cover, lifecycle —
  /// and this screen has none of those; running it here would write a second
  /// database rather than edit the one on screen.
  Future<void> saveAccess() async {
    // Only the creator or Full Access may change who has access, and never on
    // a deleted database (DB-DETAILS-01, DB-DETAILS-02).
    final bool allowed = !_database.isDeleted &&
        const DatabaseAccessRule()
            .resolve(
              _database,
              viewerId: _editor.signedInEmployeeId,
              today: DateTime.now(),
            )
            .canManage;
    if (!allowed) return;

    emit(
      state.copyWith(
        status: CreateDatabaseStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    final Either<Failure, void> written = await _repository.replaceGrants(
      databaseId: _database.id,
      accessType: state.accessType ?? _database.accessType,
      records: _recordsToWrite(),
      expectedAccessVersion: _expectedAccessVersion,
      grantedBy: _editor.signedInEmployeeId,
    );

    final Failure? failure = written.fold((Failure f) => f, (_) => null);

    if (failure != null) {
      emit(
        state.copyWith(
          status: CreateDatabaseStatus.failure,
          // Someone else saved first: nothing was written, say so plainly
          // (DB-DETAILS-04).
          errorMessage: failure is ConflictFailure
              ? S.current.accessChangedElsewhere
              : failure.errMessage,
        ),
      );
      return;
    }

    // ── Notifications (spec §1.7) ───────────────────────────────────────────
    //
    // Raised HERE, between the write and the read-back, and NOT awaited. The
    // write is what earned them; the read-back that follows only refreshes a
    // count, and a notification failure must not delay the success state (see
    // the dispatcher's header).
    //
    // The diff is against `_originalRecords` — the grants this screen was SEEDED
    // with — so a person whose rule was not touched gets nothing even though the
    // save rewrote their document. `_originalRecords` is final and this flow pops
    // on success, so it is still the right baseline; a screen that stayed open
    // for a second save would have to re-seed it.
    DatabaseNotificationDispatcher.accessSaved(
      databaseId: _database.id,
      databaseNameEn: _database.titleEn,
      databaseNameAr: _database.titleAr,
      before: _originalRecords
          .map((DatabaseAccessGrantRecord r) => r.grant)
          .toList(growable: false),
      after: state.grants,
    );

    // Re-read rather than patching the local copy: the batch also wrote
    // `member_count` and `updated_at`, and the screen behind this one shows
    // both. Patching would leave the details card claiming the old count until
    // the module was reopened.
    final Either<Failure, DatabaseEntity> refreshed =
        await _repository.fetchDatabase(_database.id);

    emit(
      refreshed.fold(
        // The write SUCCEEDED — only the read-back did not. Reporting a failure
        // here would tell the user their change was lost when it is safely in
        // Firestore, so the save is confirmed with the record as last known.
        (Failure _) => state.copyWith(
          status: CreateDatabaseStatus.success,
          createdDatabase: _database,
        ),
        (DatabaseEntity saved) {
          _database = saved;
          return state.copyWith(
            status: CreateDatabaseStatus.success,
            createdDatabase: saved,
          );
        },
      ),
    );
  }

  /// The loaded record whose grant [grant] repeats unchanged — same scope,
  /// people, level, dates and Viewable Fields — or null when the grant is new
  /// or was edited. Records whose id is already in [usedIds] are skipped.
  DatabaseAccessGrantRecord? _unchangedOriginal(
    DatabaseAccessGrant grant,
    Set<String> usedIds,
  ) {
    for (final DatabaseAccessGrantRecord r in _originalRecords) {
      if (r.id.isNotEmpty && usedIds.contains(r.id)) continue;
      final DatabaseAccessGrant was = r.grant;
      if (was.departmentId == grant.departmentId &&
          was.permission == grant.permission &&
          was.startDate == grant.startDate &&
          was.endDate == grant.endDate &&
          was.members.toSet().containsAll(grant.members) &&
          grant.members.toSet().containsAll(was.members) &&
          was.viewableFields.toSet().containsAll(grant.viewableFields) &&
          grant.viewableFields.toSet().containsAll(was.viewableFields)) {
        return r;
      }
    }
    return null;
  }

  /// Function Name: [_recordsToWrite]
  ///
  /// Purpose: Turn the draft grants back into documents, carrying the removed
  /// people with them.
  ///
  /// THE REMOVAL BOOKKEEPING IS THE WHOLE POINT OF THIS METHOD. The Access
  /// table has a "Removed" chip; if a save simply wrote the current grants,
  /// everyone taken off would vanish and that chip would count zero for ever —
  /// the screen would have no way to answer "who used to have access to this?"
  /// which is the question an access log exists to answer.
  ///
  /// So: anybody in the stored grants who is not in the draft is moved into
  /// `removedMembers`, keeping the window and level they HELD (not the grant's
  /// current ones — the grant may have been re-dated in the same edit).
  /// Anybody previously removed who has been granted access again is dropped
  /// from that list, so a person cannot be both current and removed.
  List<DatabaseAccessGrantRecord> _recordsToWrite() {
    final Set<DatabaseMember> keeping =
        state.grants.expand((DatabaseAccessGrant g) => g.members).toSet();

    final DateTime now = DateTime.now();
    final List<RemovedAccessMember> removed = <RemovedAccessMember>[];

    for (final DatabaseAccessGrantRecord original in _originalRecords) {
      // People who were on this grant and are not in the draft any more.
      for (final DatabaseMember member in original.grant.members) {
        if (keeping.contains(member)) continue;
        removed.add(
          RemovedAccessMember.from(member, original.grant, removedAt: now),
        );
      }

      // Previously-removed people stay removed, unless they are back.
      for (final RemovedAccessMember was in original.removedMembers) {
        if (keeping.contains(was.member)) continue;
        if (removed.contains(was)) continue;
        removed.add(was);
      }
    }

    // Reuse the stored document id for a grant that still covers the same
    // department, so the subcollection stays stable across edits instead of
    // every save looking like a brand-new set of grants to anything watching
    // it. Individually-scoped grants are one per person now and have no such
    // key, so they are written fresh.
    String? idForDepartment(String? departmentId) {
      if (departmentId == null || departmentId.isEmpty) return null;
      for (final DatabaseAccessGrantRecord r in _originalRecords) {
        if (r.grant.departmentId == departmentId) return r.id;
      }
      return null;
    }

    // A grant this save did not change keeps the person who granted it
    // (DB-DETAILS-06). Only a new or changed grant is stamped with the editor
    // — by `replaceGrants`, from its own `grantedBy`. Grants saved before
    // `granted_by` existed were granted by the database's creator.
    final Set<String> usedIds = <String>{};
    final List<DatabaseAccessGrantRecord> records =
        <DatabaseAccessGrantRecord>[];
    for (final DatabaseAccessGrant grant in state.grants) {
      final DatabaseAccessGrantRecord? kept = _unchangedOriginal(
        grant,
        usedIds,
      );
      String id = kept?.id ?? idForDepartment(grant.departmentId) ?? '';
      if (id.isNotEmpty && !usedIds.add(id)) id = '';
      records.add(
        kept == null
            ? DatabaseAccessGrantRecord(id: id, grant: grant)
            : DatabaseAccessGrantRecord(
                id: id,
                grant: grant,
                grantedBy: (kept.grantedBy?.isNotEmpty ?? false)
                    ? kept.grantedBy
                    : _database.createdBy,
                grantedByNameEn: kept.grantedByNameEn,
                grantedByNameAr: kept.grantedByNameAr,
              ),
      );
    }

    if (removed.isEmpty) return records;

    // Removed people are filed against the grant they lost, when it still
    // exists. When it does not — a whole department was dropped, or the
    // database was switched to Personal and has no grants left — they go on a
    // member-less holder document, because a removal that has nowhere to live
    // is a removal that disappears from the table.
    final List<DatabaseAccessGrantRecord> withRemovals =
        <DatabaseAccessGrantRecord>[...records];
    final List<RemovedAccessMember> orphaned = <RemovedAccessMember>[];

    for (final RemovedAccessMember entry in removed) {
      final int index = withRemovals.indexWhere(
        (DatabaseAccessGrantRecord r) =>
            entry.departmentId != null &&
            r.grant.departmentId == entry.departmentId,
      );

      if (index == -1) {
        orphaned.add(entry);
        continue;
      }

      withRemovals[index] = withRemovals[index].copyWith(
        removedMembers: <RemovedAccessMember>[
          ...withRemovals[index].removedMembers,
          entry,
        ],
      );
    }

    if (orphaned.isEmpty) return withRemovals;

    if (withRemovals.isEmpty) {
      return <DatabaseAccessGrantRecord>[
        DatabaseAccessGrantRecord(
          grant: const DatabaseAccessGrant(members: <DatabaseMember>[]),
          removedMembers: orphaned,
        ),
      ];
    }

    withRemovals[0] = withRemovals[0].copyWith(
      removedMembers: <RemovedAccessMember>[
        ...withRemovals[0].removedMembers,
        ...orphaned,
      ],
    );
    return withRemovals;
  }
}
