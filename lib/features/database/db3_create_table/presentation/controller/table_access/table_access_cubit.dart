/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_access_cubit.dart
/// Description: Declares `TableAccessCubit`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// "Editing Table Access" — the Viewable Fields half of the Figma section
/// "INSIDE DATABASE PAGE: Creating Table + Viewable Fields".
///
///   picker  7398:13651 (iPad H 1024x1097) / 7398:13925 (iPad V 768x1097)
///   review  7398:14553 (iPad V 768x1086) — Summary tiles, rule, fields
///   granted 7398:14122 / 7398:14296 — the picked people and their fields
///
/// ONE GRANT, NOT A LIST. See `TableAccessState.grant` for why the table screens
/// differ from db1's department-tabbed review here.
///
/// The directory comes from the injected `DatabaseDirectoryBaseRepository`,
/// which reads `MainCoreEmployeeController` / `MainCoreDepartmentCubit` — the app's single source for the org chart —
/// rather than a second set of Firestore queries, the same arrangement db1 and
/// db2 use.
library;

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_directory_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_directory.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_dispatcher.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_department.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';

import 'package:knowticed_plus/features/database/db3_create_table/domain/usecases/table_access_grants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_access/table_access_state.dart';

export 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_access/table_access_state.dart';

class TableAccessCubit extends Cubit<TableAccessState> {
  TableAccessCubit({
    required DatabaseTableEntity table,
    this.databaseNameEn = '',
    this.databaseNameAr = '',
    required DatabaseSessionBaseRepository session,
    required DatabaseDirectoryBaseRepository directory,
    required CreateTableBaseRepository repository,
  })  : _repository = repository,
        _session = session,
        _directory = directory,
        super(TableAccessState(table: table));

  final CreateTableBaseRepository _repository;

  /// The org directory for the people and department lists (rule 1: no
  /// reaching into the roles feature from a cubit).
  final DatabaseDirectoryBaseRepository _directory;

  /// Who is signed in — the "Access Grantor" stamped on every grant [save]
  /// writes (DB-CREATE-02).
  final DatabaseSessionBaseRepository _session;

  /// The parent database's bilingual title, for the notifications [save] raises
  /// — the §1.7 access bodies read "access to {{databaseName}} / {{tableName}}",
  /// so a table grant has to name both. ADDED 17/8/2026.
  ///
  /// Same reasoning as `CreateTableCubit.databaseNameEn`: two strings rather
  /// than a `DatabaseEntity`, defaulted so a caller that does not pass them
  /// still compiles.
  final String databaseNameEn;
  final String databaseNameAr;

  @override
  void emit(TableAccessState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  /// Function Name: [load]
  ///
  /// Purpose: Read this table's grants and the org directory, then seed the
  /// single rule the screens edit.
  ///
  /// The two reads run CONCURRENTLY. They are independent — grants come from
  /// the table's subcollection, the directory from controllers the app already
  /// registers — and awaiting them in sequence made db2's equivalent screen
  /// appear in two stages.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    final Future<Either<Failure, List<DatabaseAccessGrantRecord>>>
        grantsFuture = _repository.fetchTableGrants(
      databaseId: state.table.databaseId,
      tableId: state.table.id,
    );
    final Future<_Directory?> directoryFuture = _loadDirectory();

    final Either<Failure, List<DatabaseAccessGrantRecord>> grants =
        await grantsFuture;
    final _Directory? directory = await directoryFuture;

    emit(
      grants.fold(
        (Failure failure) => state.copyWith(
          isLoading: false,
          errorMessage: failure.errMessage,
          employees: directory?.employees ?? const <DatabaseMember>[],
          departments: directory?.departments ?? const <DatabaseDepartment>[],
          directoryFailed: directory == null,
          // Save stays refused until a reload succeeds (DB-TABLE-14).
          grantsFailed: true,
        ),
        (List<DatabaseAccessGrantRecord> records) {
          final DatabaseAccessGrantRecord? first =
              records.isEmpty ? null : records.first;

          // MERGED, not "the first one wins". A table's grants are only ever
          // written by this screen, which writes exactly one — so more than one
          // row means something else wrote them, and dropping the extras on load
          // would silently revoke people the moment this screen saved. The union
          // is the conservative direction to be wrong in, and the save replaces
          // the whole subcollection with the merged result.
          final DatabaseAccessGrant merged = TableAccessGrants.merge(records);
          final Map<String, List<String>> memberFields =
              TableAccessGrants.fieldsByMember(records);
          final List<RemovedAccessMember> removed =
              first?.removedMembers ?? const <RemovedAccessMember>[];

          return state.copyWith(
            isLoading: false,
            grantsFailed: false,
            memberFields: memberFields,
            originalMemberFields: memberFields,
            grant: merged,
            original: merged,
            recordId: first?.id ?? '',
            removedMembers: removed,
            originalRemovedMembers: removed,
            memberRules: TableAccessGrants.rulesByMember(records),
            employees: directory?.employees ?? const <DatabaseMember>[],
            departments: directory?.departments ?? const <DatabaseDepartment>[],
            directoryFailed: directory == null,
            clearErrorMessage: true,
          );
        },
      ),
    );
  }

  /// Function Name: [retryDirectory]
  ///
  /// Purpose: Read the employee and department lists again after they failed
  /// (DB-TABLE-11). The grant on screen is left as it is.
  ///
  /// Returns: [Future<void>]; the lists arrive as a new state.
  Future<void> retryDirectory() async {
    final _Directory? directory = await _loadDirectory();
    if (isClosed) return;
    emit(
      state.copyWith(
        employees: directory?.employees,
        departments: directory?.departments,
        directoryFailed: directory == null,
      ),
    );
  }

  /// The employee and department lists, or null when they could not be read
  /// (DB-TABLE-11) — never an empty list pretending to be the company. The
  /// people already on the grant are still shown.
  Future<_Directory?> _loadDirectory() async {
    final Either<Failure, DatabaseDirectory> result =
        await _directory.loadDirectory();
    return result.fold(
      (Failure _) => null,
      (DatabaseDirectory d) =>
          _Directory(employees: d.members, departments: d.departments),
    );
  }

  // ── Filtering ────────────────────────────────────────────────────────────

  /// Function Name: [searchChanged]
  ///
  /// Purpose: Store the search text; the visible list is filtered from it.
  void searchChanged(String query) => emit(state.copyWith(searchQuery: query));

  /// Function Name: [departmentFilterChanged]
  ///
  /// Purpose: Show only the employees of one department, or everyone when null.
  void departmentFilterChanged(String? departmentId) => emit(
        departmentId == null || departmentId.isEmpty
            ? state.copyWith(clearDepartmentFilter: true)
            : state.copyWith(departmentFilter: departmentId),
      );

  // ── Members ──────────────────────────────────────────────────────────────

  /// Function Name: [toggleMember]
  ///
  /// Purpose: Add the employee to the picked list, or remove them if already picked.
  void toggleMember(DatabaseMember member) {
    final List<DatabaseMember> members = <DatabaseMember>[
      ...state.grant.members,
    ];
    members.contains(member) ? members.remove(member) : members.add(member);
    _setMembers(members);
  }

  /// "Select All" / "Deselect All" — scoped to what the search and the
  /// department filter currently show. See `TableAccessState.allVisibleSelected`.
  void toggleSelectAllVisible() {
    final List<DatabaseMember> visible = state.visibleEmployees;
    if (visible.isEmpty) return;

    final List<DatabaseMember> members = <DatabaseMember>[
      ...state.grant.members,
    ];

    if (state.allVisibleSelected) {
      members.removeWhere(visible.contains);
    } else {
      for (final DatabaseMember m in visible) {
        if (!members.contains(m)) members.add(m);
      }
    }
    _setMembers(members);
  }

  /// Function Name: [removeMember]
  ///
  /// Purpose: Take one person off the grant, keeping the record of what they
  /// held.
  ///
  /// The removal is filed under `removedMembers` rather than simply dropped:
  /// the Access table's red "Removed" row is about someone with no grant left,
  /// and it cannot be drawn from a person who has been erased. Re-adding them
  /// afterwards cancels the entry, so a mis-tap does not leave a phantom
  /// removal behind.
  void removeMember(DatabaseMember member) {
    final List<DatabaseMember> members = <DatabaseMember>[
      ...state.grant.members,
    ]..remove(member);

    final List<RemovedAccessMember> removed = <RemovedAccessMember>[
      ...state.removedMembers,
    ];
    final RemovedAccessMember entry = RemovedAccessMember.from(
      member,
      state.grant,
    );
    if (!removed.contains(entry)) removed.add(entry);

    emit(
      state.copyWith(
        grant: state.grant.copyWith(members: members),
        removedMembers: List<RemovedAccessMember>.unmodifiable(removed),
      ),
    );
  }

  /// "Remove All Access" (Figma 7398:14280) — empties the grant in one action.
  ///
  /// Every person is filed as removed, exactly as if they had been taken off
  /// one at a time, so the Access table can still account for them.
  void removeAllAccess() {
    final List<RemovedAccessMember> removed = <RemovedAccessMember>[
      ...state.removedMembers,
    ];
    for (final DatabaseMember member in state.grant.members) {
      final RemovedAccessMember entry = RemovedAccessMember.from(
        member,
        state.grant,
      );
      if (!removed.contains(entry)) removed.add(entry);
    }

    emit(
      state.copyWith(
        grant: state.grant.copyWith(members: const <DatabaseMember>[]),
        removedMembers: List<RemovedAccessMember>.unmodifiable(removed),
      ),
    );
  }

  /// Adding someone back cancels their removal entry — see [removeMember].
  void _setMembers(List<DatabaseMember> members) {
    final List<RemovedAccessMember> removed = state.removedMembers
        .where((RemovedAccessMember r) => !members.contains(r.member))
        .toList(growable: false);

    emit(
      state.copyWith(
        grant: state.grant.copyWith(
          members: List<DatabaseMember>.unmodifiable(members),
        ),
        removedMembers: removed,
      ),
    );
  }

  // ── The rule ─────────────────────────────────────────────────────────────

  /// Function Name: [permissionChanged]
  ///
  /// Purpose: Store the permission level for the grant.
  void permissionChanged(DatabasePermissionLevel level) =>
      emit(state.copyWith(grant: state.grant.copyWith(permission: level)));

  /// Function Name: [startDateChanged]
  ///
  /// Purpose: Store the first day the grant is valid.
  void startDateChanged(DateTime date) =>
      emit(state.copyWith(grant: state.grant.copyWith(startDate: date)));

  /// Function Name: [endDateChanged]
  ///
  /// Purpose: Store the last day the grant is valid.
  void endDateChanged(DateTime date) =>
      emit(state.copyWith(grant: state.grant.copyWith(endDate: date)));

  /// Function Name: [memberFieldsChanged]
  ///
  /// Purpose: Set the columns ONE person may see (Figma 7398:14122 / 14296).
  ///
  /// Writes an explicit entry even when the list matches the grant's own set,
  /// so a person who has been deliberately given the default is not silently
  /// re-widened the next time the shared set changes.
  void memberFieldsChanged(String memberId, List<String> fields) {
    final Map<String, List<String>> next = Map<String, List<String>>.of(
      state.memberFields,
    );
    next[memberId] = List<String>.unmodifiable(fields);
    emit(state.copyWith(memberFields: next));
  }

  /// Function Name: [viewableFieldsChanged]
  ///
  /// Purpose: Store which columns the grant's holders may see — the default
  /// for anyone without their own entry in `memberFields`. An empty list is a
  /// real value meaning "all fields"; see `DatabaseAccessGrant.viewableFields`.
  void viewableFieldsChanged(List<String> fields) => emit(
        state.copyWith(
          grant: state.grant.copyWith(
            viewableFields: List<String>.unmodifiable(fields),
          ),
        ),
      );

  // ── Discard / Save ───────────────────────────────────────────────────────

  /// Function Name: [clearMessages]
  ///
  /// Purpose: Clear the error and success messages once the screen has shown them, so a rebuild does not show them twice.
  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  /// "Discard Changes" — back to the rule as loaded: the people, everyone's
  /// own Viewable Fields, and the removal history already on the record
  /// (DB-TABLE-19), which used to be emptied here.
  void discard() {
    final DatabaseAccessGrant? loaded = state.original;
    if (loaded == null) return;

    emit(
      state.copyWith(
        grant: loaded,
        memberFields: state.originalMemberFields,
        removedMembers: state.originalRemovedMembers,
        status: TableAccessStatus.initial,
        clearErrorMessage: true,
      ),
    );
  }

  /// Function Name: [save]
  ///
  /// Purpose: Write the rule as the table's whole `Access_Grants` subcollection.
  ///
  /// The guard is the page's, not this method's: `canSave` names which field is
  /// missing better than a boolean returned from here could, and the page has
  /// the localized copy to say it with.
  ///
  /// One record per distinct rule — the same Viewable Fields, level and dates
  /// — not one per person. The first record keeps the id it was loaded under
  /// so that document is rewritten rather than duplicated. The repository
  /// REPLACES the collection, so any rows not written again disappear in the
  /// same batch.
  Future<void> save() async {
    // The current grants were never read, and this write replaces them all
    // (DB-TABLE-14). The page says why and offers Retry.
    if (state.grantsFailed) return;
    final String? grantedBy = _session.signedInEmployeeId;
    emit(
      state.copyWith(
        status: TableAccessStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    final List<DatabaseAccessGrantRecord> toWrite =
        TableAccessGrants.recordsToWrite(
      grant: state.grant,
      loaded: state.original,
      memberRules: state.memberRules,
      fieldsFor: state.fieldsFor,
      recordId: state.recordId,
      removedMembers: state.removedMembers,
      grantedBy: grantedBy,
    );

    final Either<Failure, void> result = await _repository.replaceTableGrants(
      databaseId: state.table.databaseId,
      tableId: state.table.id,
      records: toWrite,
      grantedBy: grantedBy,
    );

    // Captured BEFORE the emit, because the emit replaces `original` with the
    // rule that was just saved — after it there is nothing left to diff against.
    final DatabaseAccessGrant? loaded = state.original;
    final DatabaseAccessGrant written = state.grant;

    emit(
      result.fold(
        (Failure failure) => state.copyWith(
          status: TableAccessStatus.failure,
          errorMessage: failure.errMessage,
        ),
        (_) => state.copyWith(
          status: TableAccessStatus.success,
          // The saved rule becomes the new baseline, so the next Discard returns
          // here rather than to the state before this save.
          original: state.grant,
          originalMemberFields: state.memberFields,
          originalRemovedMembers: state.removedMembers,
          table: state.table.copyWith(memberCount: state.grant.members.length),
          clearErrorMessage: true,
        ),
      ),
    );

    if (state.status != TableAccessStatus.success) return;

    // ── Notifications (spec §1.7) ───────────────────────────────────────────
    //
    // After the emit, not awaited — see `DatabaseNotificationDispatcher`.
    //
    // `viewableFieldsChanged` is passed EXPLICITLY rather than left to the
    // dispatcher's rule diff. That diff decides whether a person's own access
    // moved, which is a per-person question; the field list is one value on one
    // grant that everybody on it shares, and it has its own event
    // ("Data Visibility Permissions Updated"). Comparing as a SET, because
    // reordering the columns somebody may see is not a change to what they see.
    DatabaseNotificationDispatcher.accessSaved(
      databaseId: state.table.databaseId,
      tableId: state.table.id,
      databaseNameEn: databaseNameEn,
      databaseNameAr: databaseNameAr,
      tableNameEn: state.table.nameEn,
      tableNameAr: state.table.nameAr,
      before: loaded == null
          ? const <DatabaseAccessGrant>[]
          : <DatabaseAccessGrant>[loaded],
      after: <DatabaseAccessGrant>[written],
      viewableFieldsChanged: loaded != null &&
          !TableAccessGrants.sameFields(
            loaded.viewableFields,
            written.viewableFields,
          ),
    );
  }
}

/// The org directory, fetched once per screen. A private pair so [load] can
/// await ONE future instead of two.
class _Directory {
  const _Directory({required this.employees, required this.departments});

  final List<DatabaseMember> employees;
  final List<DatabaseDepartment> departments;
}
