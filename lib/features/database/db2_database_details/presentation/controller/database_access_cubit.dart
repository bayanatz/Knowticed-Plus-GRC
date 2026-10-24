/// Module: database / db2_database_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_cubit.dart
/// Description: Declares `DatabaseAccessCubit`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// The Access screen — Figma 7398:10662 (iPad V) / 7398:10875 (iPad H).
///
/// WHAT IT DOES THAT THE SCREEN CANNOT
/// -----------------------------------
/// The screen shows a flat table of PEOPLE. Firestore holds a subcollection of
/// GRANTS — a department with twelve members is one document. Two joins have
/// to happen before a row can be drawn, and both need data that lives outside
/// the grant:
///
///   * the Department column is a NAME; the member snapshot only carries the id
///   * the Access Grantor column is a NAME; the grant carries an employee id,
///     and older grants carry nothing at all and fall back to the database's
///     `created_by`
///
/// So the directory is loaded alongside the grants and the flattening happens
/// here, once, into `DatabaseAccessRow`. Doing it in the table widget would
/// re-resolve a department name per cell per rebuild and would leave the
/// Export button re-deriving the same list a second time — the classic way for
/// a CSV to disagree with the screen it was exported from.
library;

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/helper/share_helper.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_directory_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_directory.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_row.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/enums/database_access_status.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/use_cases/database_access_rule.dart';
import 'package:knowticed_plus/generated/l10n.dart';

part './database_access_state.dart';

class DatabaseAccessCubit extends Cubit<DatabaseAccessState> {
  DatabaseAccessCubit({
    required DatabaseEntity database,
    DatabaseTableEntity? table,
    required DatabaseDetailsBaseRepository repository,
    required CreateTableBaseRepository tableRepository,
    CSVHelper? csvHelper,
    required DatabaseSessionBaseRepository session,
    required DatabaseDirectoryBaseRepository directory,
    DatabaseAccessRule rule = const DatabaseAccessRule(),
  })  : _repository = repository,
        _directory = directory,
        _tableRepository = tableRepository,
        _csv = csvHelper ?? CSVHelper(),
        _session = session,
        _rule = rule,
        super(DatabaseAccessState(database: database, table: table));

  final DatabaseSessionBaseRepository _session;
  final DatabaseAccessRule _rule;

  /// The org directory for the people and department lists (rule 1: no
  /// reaching into the roles feature from a cubit).
  final DatabaseDirectoryBaseRepository _directory;

  /// Function Name: [access]
  ///
  /// Purpose: What the signed-in employee may do with this database today
  /// (DB-DETAILS-01, same rule as DB-CREATE-01). Re-read on every call, so a
  /// grant that ends today stops working today.
  ///
  /// Returns: [DatabaseAccess].
  DatabaseAccess get access => _rule.resolve(
        state.database,
        viewerId: _session.signedInEmployeeId,
        today: DateTime.now(),
      );

  final DatabaseDetailsBaseRepository _repository;

  /// Only reached when the screen is showing a TABLE's access. Constructed
  /// either way because a cubit that builds half its dependencies lazily is a
  /// cubit whose failure mode depends on which screen opened it.
  final CreateTableBaseRepository _tableRepository;

  final CSVHelper _csv;

  @override
  void emit(DatabaseAccessState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  /// Function Name: [load]
  ///
  /// Purpose: Read the grants and the directory, then build the rows.
  ///
  /// The two reads run CONCURRENTLY. They are independent — grants come from
  /// this database's subcollection, the directory from controllers the app
  /// already registers — and awaiting them in sequence made the table appear
  /// a directory-read later than it needed to, on a screen whose whole content
  /// is that table.
  ///
  /// A directory failure is NOT fatal: the rows still render, just with blank
  /// Department and Access Grantor cells. Refusing to show anyone's access
  /// because the org chart could not be read would hide the security-relevant
  /// half of the screen over the cosmetic half.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    // A TABLE's grants live one subcollection deeper than a database's, and
    // both reads return the same `DatabaseAccessGrantRecord` — the two
    // subcollections are deliberately the same document shape (see
    // `CreateTableBaseRepository.fetchTableGrants`). That is what lets one
    // screen render either, instead of a near-copy per level.
    final DatabaseTableEntity? table = state.table;

    // The version BEFORE the grants (DB-DETAILS-04): if someone saves in
    // between, the grants are newer than the version and the editor's save is
    // refused — the safe direction to be wrong in.
    //
    // A FAILED version read is reported, not turned into 0: a 0 would let the
    // editor's save be checked against the wrong version.
    int accessVersion = 0;
    if (table == null) {
      final Either<Failure, int> version = await _repository.fetchAccessVersion(
        state.database.id,
      );
      if (isClosed) return;
      final Failure? versionFailure = version.fold(
        (Failure f) => f,
        (_) => null,
      );
      if (versionFailure != null) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: versionFailure.errMessage,
          ),
        );
        return;
      }
      accessVersion = version.getOrElse(() => 0);
    }

    final Future<Either<Failure, List<DatabaseAccessGrantRecord>>>
        grantsFuture = table == null
            ? _repository.fetchGrants(state.database.id)
            : _tableRepository.fetchTableGrants(
                databaseId: table.databaseId,
                tableId: table.id,
              );
    final Future<_Directory?> directoryFuture = _loadDirectory();

    final Either<Failure, List<DatabaseAccessGrantRecord>> grants =
        await grantsFuture;
    final _Directory? directory = await directoryFuture;

    emit(
      grants.fold(
        (Failure failure) =>
            state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        (List<DatabaseAccessGrantRecord> records) => state.copyWith(
          isLoading: false,
          records: records,
          accessVersion: accessVersion,
          departments: directory?.departments ?? const <DatabaseDepartment>[],
          employees: directory?.employees ?? const <DatabaseMember>[],
          directoryFailed: directory == null,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  /// Function Name: [retryDirectory]
  ///
  /// Purpose: Read the employee and department lists again after they failed
  /// (DB-DETAILS-05). The grants already on screen are kept.
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
  /// (DB-DETAILS-05). Blank name and department cells used to look like data.
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

  /// Function Name: [filterChanged]
  ///
  /// Purpose: Apply the access-list filter whose name matches [key].
  void filterChanged(String key) {
    for (final DatabaseAccessFilter f in DatabaseAccessFilter.values) {
      if (f.name == key) {
        emit(state.copyWith(filter: f));
        return;
      }
    }
  }

  /// Function Name: [searchChanged]
  ///
  /// Purpose: Store the search text; the visible list is filtered from it.
  void searchChanged(String query) => emit(state.copyWith(searchQuery: query));

  /// Applies the Filter dialog's department narrowing. Null clears it.
  void departmentFilterChanged(String? departmentId) => emit(
        departmentId == null
            ? state.copyWith(clearDepartmentFilter: true)
            : state.copyWith(departmentFilter: departmentId),
      );

  /// Function Name: [clearMessages]
  ///
  /// Purpose: Clear the error and success messages once the screen has shown them, so a rebuild does not show them twice.
  void clearMessages() =>
      emit(state.copyWith(clearErrorMessage: true, clearExportedFile: true));

  /// Called after the edit-access flow saves, so the table reflects the new
  /// grants without the screen being rebuilt from scratch.
  void databaseChanged(DatabaseEntity database) {
    emit(state.copyWith(database: database));
    load();
  }

  // ── Export ───────────────────────────────────────────────────────────────

  /// Function Name: [exportVisibleRows]
  ///
  /// Purpose: Write what is ON SCREEN to a CSV and hand it to the share sheet.
  ///
  /// VISIBLE rows, not every row. The chips and the search box are the user's
  /// statement of what they are looking at; an export that silently widened
  /// that back out to everyone would be a data leak dressed as a convenience —
  /// someone filtering to "Removed" before exporting is asking for the removed
  /// list, not the whole access list.
  ///
  /// `CSVHelper` writes a UTF-8 BOM, which is what makes the Arabic name column
  /// open correctly in Excel; that is the reason this goes through the shared
  /// helper rather than joining commas here.
  Future<void> exportVisibleRows({
    required List<String> headers,
    required String Function(DatabaseAccessRow row) statusLabel,
    required String Function(DatabasePermissionLevel? level) permissionLabel,
    required String Function(DateTime? date) dateLabel,
    required bool isArabic,
  }) async {
    // The file lists names, departments, dates and levels: Full Access only.
    if (!access.canManage) return;

    final List<DatabaseAccessRow> rows = visibleRows(isArabic: isArabic);
    if (rows.isEmpty) {
      emit(state.copyWith(exportStatus: DatabaseExportStatus.empty));
      return;
    }

    emit(
      state.copyWith(
        exportStatus: DatabaseExportStatus.running,
        clearExportedFile: true,
      ),
    );

    try {
      // Every cell is already a display string, so the rows are typed as such.
      final List<List<String>> table = <List<String>>[
        headers,
        for (final DatabaseAccessRow row in rows)
          <String>[
            // Title-cased like the table on screen. The export is the same data
            // the user was just looking at, and a CSV that spells names
            // differently from the screen it came from reads as a different
            // report. The file NAME below is left alone — that is a path, not
            // text.
            FormatHelper.capitalize(
              row.member.localizedName(isArabic: isArabic),
            ),
            row.departmentName,
            row.grantorName,
            dateLabel(row.startDate),
            dateLabel(row.endDate),
            permissionLabel(row.permission),
            statusLabel(row),
          ],
      ];

      // The file name carries the database title so two exports sitting in the
      // same Downloads folder can be told apart. Anything that is not a letter
      // or a digit becomes an underscore — a title with a slash in it would
      // otherwise be read as a directory that does not exist.
      final String safeTitle = state.database
          .localizedTitle(isArabic: isArabic)
          .replaceAll(RegExp(r'[^\w؀-ۿ]+'), '_');
      final String fileName =
          'access_${safeTitle.isEmpty ? 'database' : safeTitle}';

      final File file = await _csv.exportToCSV(table, fileName);

      emit(
        state.copyWith(
          exportStatus: DatabaseExportStatus.success,
          exportedFile: file,
        ),
      );

      // Sharing is best-effort and deliberately AFTER the success emit: the
      // file is already written, so a share sheet the platform refuses to open
      // must not be reported as a failed export.
      await ShareHelper.shareFile(file);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('🔴 [DatabaseAccessCubit] export failed: $error');
      }
      emit(
        state.copyWith(
          exportStatus: DatabaseExportStatus.failure,
          errorMessage: S.current.dbDetailsExportFailed,
        ),
      );
    }
  }

  /// Function Name: [exportHandled]
  ///
  /// Purpose: Mark the export result as shown so it is not reported again.
  void exportHandled() => emit(
        state.copyWith(
          exportStatus: DatabaseExportStatus.idle,
          clearExportedFile: true,
        ),
      );

  // ── Rows ─────────────────────────────────────────────────────────────────

  /// Every person on this database, live and removed, one row each.
  ///
  /// Built on demand rather than stored in state because it depends on the UI
  /// locale — the Department and Grantor columns are names — and a cubit that
  /// cached a localized string would hand the wrong language to a user who
  /// switched it without leaving the screen.
  List<DatabaseAccessRow> allRows({required bool isArabic}) {
    final List<DatabaseAccessRow> rows = <DatabaseAccessRow>[];

    for (final DatabaseAccessGrantRecord record in state.records) {
      final DatabaseAccessGrant grant = record.grant;
      final String grantor = _grantorName(record, isArabic: isArabic);
      final DatabaseAccessStatus status = DatabaseAccessStatus.resolve(grant);

      for (final DatabaseMember member in grant.members) {
        rows.add(
          DatabaseAccessRow(
            member: member,
            status: status,
            // The grant's department wins over the member's own when the grant
            // is department-scoped: that is the department the access was given
            // THROUGH, which is what the column is reporting. Someone who has
            // since transferred still holds this access via their old team.
            departmentName: grant.isDepartmentScoped
                ? _departmentName(
                    grant.departmentId,
                    isArabic: isArabic,
                    fallbackEn: grant.departmentNameEn,
                    fallbackAr: grant.departmentNameAr,
                  )
                : _departmentName(member.departmentId, isArabic: isArabic),
            grantorName: grantor,
            permission: grant.permission,
            startDate: grant.startDate,
            endDate: grant.endDate,
          ),
        );
      }

      for (final RemovedAccessMember removed in record.removedMembers) {
        rows.add(
          DatabaseAccessRow(
            member: removed.member,
            status: DatabaseAccessStatus.removed,
            departmentName: _departmentName(
              removed.departmentId ?? removed.member.departmentId,
              isArabic: isArabic,
              fallbackEn: removed.departmentNameEn,
              fallbackAr: removed.departmentNameAr,
            ),
            grantorName: grantor,
            permission: removed.permission,
            startDate: removed.startDate,
            endDate: removed.endDate,
            removedAt: removed.removedAt,
          ),
        );
      }
    }

    return rows;
  }

  /// What the table draws: [allRows] narrowed by the chip, the search box and
  /// the Filter dialog's department.
  List<DatabaseAccessRow> visibleRows({required bool isArabic}) {
    final DatabaseAccessStatus? wanted = state.filter.status;
    final String? department = state.departmentFilter;

    return allRows(isArabic: isArabic).where((DatabaseAccessRow row) {
      if (wanted != null && row.status != wanted) return false;
      if (department != null &&
          department.isNotEmpty &&
          row.member.departmentId != department) {
        return false;
      }
      return row.matches(state.searchQuery);
    }).toList(growable: false);
  }

  /// The number on one chip. Counted from [allRows] rather than from the
  /// visible list, so narrowing to "Active" does not zero every other chip and
  /// make the row look like the data disappeared.
  int countFor(DatabaseAccessFilter filter, {required bool isArabic}) {
    final List<DatabaseAccessRow> rows = allRows(isArabic: isArabic);
    final DatabaseAccessStatus? wanted = filter.status;
    if (wanted == null) return rows.length;
    return rows.where((DatabaseAccessRow r) => r.status == wanted).length;
  }

  // ── Name joins ───────────────────────────────────────────────────────────

  /// "Access Grantor" — the person who granted THIS access (DB-DETAILS-06):
  /// the record's `granted_by`, looked up in the directory.
  ///
  /// A grant that an access save left unchanged keeps its original grantor
  /// (see `EditDatabaseAccessCubit`), so the column does not turn into "whoever
  /// pressed Save last". The database's creator stands in only for grants
  /// saved before `granted_by` existed.
  String _grantorName(
    DatabaseAccessGrantRecord record, {
    required bool isArabic,
  }) {
    // Who granted THIS access (DB-DETAILS-06), not the database's creator.
    // The creator stands in only for grants saved before `granted_by` was.
    final String? stored =
        isArabic ? record.grantedByNameAr : record.grantedByNameEn;
    final String? id = (record.grantedBy?.isNotEmpty ?? false)
        ? record.grantedBy
        : state.database.createdBy;
    if (id == null || id.isEmpty) {
      return (stored?.isNotEmpty ?? false)
          ? FormatHelper.capitalize(stored!)
          : '';
    }

    for (final DatabaseMember m in state.employees) {
      if (m.employeeId == id) {
        return FormatHelper.capitalize(m.localizedName(isArabic: isArabic));
      }
    }

    // The grantor is no longer in the directory — they left the company, or the
    // directory could not be reached. A stored name if there is one, otherwise
    // an empty cell ("—"); the raw employee id would read as corruption.
    return (stored?.isNotEmpty ?? false)
        ? FormatHelper.capitalize(stored!)
        : '';
  }

  /// Resolves a department id to a NAME, preferring the live directory and
  /// falling back to the snapshot stored on the grant.
  ///
  /// Live first because a renamed department should show its new name; the
  /// snapshot second because a department that has since been deleted still
  /// has to render as the thing the access was granted through, not as blank.
  /// A raw id is never returned — see `MemberGrid._departmentLabel` for why a
  /// bare Firestore key in a person's row reads as corruption.
  String _departmentName(
    String? departmentId, {
    required bool isArabic,
    String? fallbackEn,
    String? fallbackAr,
  }) {
    if (departmentId != null && departmentId.isNotEmpty) {
      for (final DatabaseDepartment d in state.departments) {
        if (d.id == departmentId) return d.localizedName(isArabic: isArabic);
      }
    }

    final String? preferred = isArabic ? fallbackAr : fallbackEn;
    final String? other = isArabic ? fallbackEn : fallbackAr;
    if (preferred != null && preferred.isNotEmpty) return preferred;
    return other ?? '';
  }
}

/// The two directory lists, returned together so [DatabaseAccessCubit.load]
/// can await one future instead of two.
@immutable
class _Directory {
  const _Directory({required this.employees, required this.departments});

  final List<DatabaseMember> employees;
  final List<DatabaseDepartment> departments;
}
