// [module-file:database] — deleted when the database module is split out
/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_database.dart
/// Purpose: Showcase Database Builder data: 27 databases (6 open, 6
///          restricted, 5 personal, 5 drafts, 5 deleted) with their tables,
///          typed columns, rows, access grants and table comments.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Documents use the module's own constants and models
/// (`DatabaseModel`, `DatabaseTableModel`, `TableDataRowModel`,
/// `TableCommentModel`, `DatabaseAccessGrantModel`,
/// `DatabaseAccessIndexModel`) under `CreateDatabaseCollections.databases`,
/// with fixed `showcase_` ids and explicit timestamps (the module itself
/// writes server timestamps, which could not be spread over the year).
///
/// The signed-in user is `created_by` of every database that is "by me";
/// every other database names the signed-in user in its access list, because
/// the list only returns databases the viewer created or is named in.
///
/// Note: the module has no quality score of its own; the quality figures
/// live in the cells of the "Data Quality Scorecards" tables. The database
/// title index (`Database_Titles`) is not written, so a showcase title can
/// still be reused by a new database.
///
/// Indexes: the list queries need the composite indexes in
/// `firestore.indexes.json` (not deployed). Until they are, the list falls
/// back to reading on the device and the tab counters may stay empty.
library;

import 'package:knowticed_plus/features/database/db1_create_database/data/models/create_database_collections.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/models/database_grant_fields.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/create_table_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_access_grant_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_access_index_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/database_table_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/table_comment_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/table_data_row_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_comments_access.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_database_data.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

/// Collects every write in batches of at most 400 operations.
class _Writer {
  _Writer(this._fs);

  final FirebaseFirestore _fs;
  final List<WriteBatch> _batches = <WriteBatch>[];
  int _inLast = 0;
  int count = 0;

  void set(
      DocumentReference<Map<String, dynamic>> ref, Map<String, dynamic> data) {
    if (_batches.isEmpty || _inLast + 1 > 400) {
      _batches.add(_fs.batch());
      _inLast = 0;
    }
    _inLast++;
    count++;
    _batches.last.set(ref, data);
  }

  Future<int> commit() async {
    for (final WriteBatch b in _batches) {
      await b.commit();
    }
    return count;
  }
}

abstract final class ShowcaseDatabase {
  /// Writes the Database showcase and returns the number of documents.
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    final _Writer w = _Writer(firestore);
    final String viewer = me.id.isNotEmpty ? me.id : me.email;
    String idOf(ShowcasePerson p) => p.id.isNotEmpty ? p.id : p.email;
    final List<ShowcasePerson> others = <ShowcasePerson>[
      for (final ShowcasePerson p in ShowcaseCommon.people)
        if (p.email.toLowerCase() != me.email.toLowerCase()) p,
    ];
    if (others.isEmpty) others.add(ShowcaseCommon.person(1));
    final DbCtx ctx =
        DbCtx(ar: isArabic, now: now, people: ShowcaseCommon.people);

    List<DepartmentModelPro> departments = <DepartmentModelPro>[];
    try {
      if (Get.isRegistered<MainCoreDepartmentCubit>()) {
        departments = Get.find<MainCoreDepartmentCubit>()
            .departmentModels
            .where((DepartmentModelPro d) => (d.departmentID ?? '').isNotEmpty)
            .toList();
      }
    } catch (_) {
      departments = <DepartmentModelPro>[];
    }

    Timestamp ts(DateTime d) => Timestamp.fromDate(d);
    DateTime cap(DateTime d) {
      final DateTime limit = now.subtract(const Duration(hours: 3));
      return d.isAfter(limit) ? limit : d;
    }

    DatabaseMember member(ShowcasePerson p) => DatabaseMember(
          employeeId: idOf(p),
          nameEn: p.nameEn,
          nameAr: p.nameAr,
          email: p.email,
          jobTitleEn: p.titleEn.isEmpty ? null : p.titleEn,
          jobTitleAr: p.titleAr.isEmpty ? null : p.titleAr,
        );

    DatabaseAccessGrant grant(
      int seed,
      List<ShowcasePerson> people,
      DatabasePermissionLevel level,
      DateTime start, {
      List<String> fields = const <String>[],
    }) {
      final DepartmentModelPro? dept =
          departments.isEmpty ? null : departments[seed % departments.length];
      return DatabaseAccessGrant(
        members: <DatabaseMember>[
          for (final ShowcasePerson p in people) member(p)
        ],
        departmentId: dept?.departmentID,
        departmentNameEn: dept?.departmentName,
        departmentNameAr: dept?.departmentNameInArabic,
        permission: level,
        startDate: DateTime(start.year, start.month, start.day),
        endDate: DateTime(now.year + 1, 12, 31),
        viewableFields: fields,
      );
    }

    int distinctMembers(List<DatabaseAccessGrant> grants) => <String>{
          for (final DatabaseAccessGrant g in grants)
            for (final DatabaseMember m in g.members) m.employeeId,
        }.length;

    final String dbPath = getBaseUrl(CreateDatabaseCollections.databases);
    final List<DbSpec> specs = DatabaseShowcaseData.specs;

    for (int n = 1; n <= specs.length; n++) {
      final DbSpec s = specs[n - 1];
      final String nn = n.toString().padLeft(2, '0');
      final String dbId = ShowcaseCommon.id('database', n);
      final DocumentReference<Map<String, dynamic>> dbRef =
          firestore.collection(dbPath).doc(dbId);

      final ShowcasePerson creatorPerson =
          s.byMe ? me : others[(n * 3) % others.length];
      final String creatorId = s.byMe ? viewer : idOf(creatorPerson);

      final DateTime created = s.state == DbState.draft
          ? now.subtract(Duration(days: 3 + (n * 5) % 26))
          : ShowcaseCommon.spread((n * 11) % specs.length, specs.length, now,
              endGap: const Duration(days: 12));
      final DateTime updated =
          cap(created.add(Duration(days: 6 + (n * 7) % 40, hours: 3)));
      final DateTime deletedAt =
          cap(created.add(Duration(days: 30 + (n * 7) % 60)));

      // ── Database-level access ──────────────────────────────────────
      final List<DatabaseAccessGrant> grants = <DatabaseAccessGrant>[];
      if (s.access != DbAccess.personal && s.state != DbState.draft) {
        final ShowcasePerson a = others[(n + 0) % others.length];
        final ShowcasePerson b = others[(n + 1) % others.length];
        final ShowcasePerson c = others[(n + 2) % others.length];
        final ShowcasePerson d = others[(n + 3) % others.length];
        final ShowcasePerson e = others[(n + 4) % others.length];
        if (s.byMe) {
          grants.add(grant(n, <ShowcasePerson>[a, b],
              DatabasePermissionLevel.edit, created));
          grants.add(grant(n + 1, <ShowcasePerson>[c, d, e],
              DatabasePermissionLevel.view, created));
          if (n % 3 == 0) {
            grants.add(grant(n + 2, <ShowcasePerson>[e],
                DatabasePermissionLevel.fullAccess, created));
          }
          if (n % 2 == 0) {
            grants.add(grant(n + 3, <ShowcasePerson>[d],
                DatabasePermissionLevel.export, created));
          }
        } else {
          // The creator is a colleague; the signed-in user is named so the
          // database shows up in the list.
          final bool edits = n % 2 == 1;
          grants.add(grant(
              n,
              <ShowcasePerson>[me, a],
              edits
                  ? DatabasePermissionLevel.edit
                  : DatabasePermissionLevel.view,
              created));
          grants.add(grant(n + 1, <ShowcasePerson>[b, c, d],
              DatabasePermissionLevel.view, created));
          grants.add(grant(n + 2, <ShowcasePerson>[e],
              DatabasePermissionLevel.export, created));
        }
      }

      // ── Tables ─────────────────────────────────────────────────────
      for (int k = 1; k <= s.tables.length; k++) {
        final DbTableRef t = s.tables[k - 1];
        final String kk = k.toString().padLeft(2, '0');
        final String tid = ShowcaseCommon.id('db${nn}_table', k);
        final DbTemplate tpl = DatabaseShowcaseData.templates[t.template]!;
        final DateTime tCreated =
            cap(created.add(Duration(days: k * 2, hours: k)));
        final DateTime tUpdated =
            cap(tCreated.add(Duration(days: 5 + (n + k) % 30)));
        final DocumentReference<Map<String, dynamic>> tRef =
            dbRef.collection(CreateTableCollections.tables).doc(tid);

        final List<TableColumn> columns = <TableColumn>[
          for (int c = 0; c < tpl.columns.length; c++)
            TableColumn(
              id: 'c${c + 1}',
              order: c,
              name: tpl.columns[c].name.of(isArabic),
              type: tpl.columns[c].type,
            ),
        ];
        final List<Map<String, dynamic>> columnMaps = DatabaseTableModel(
          id: tid,
          databaseId: dbId,
          nameEn: t.name.en,
          nameAr: t.name.ar,
          columns: columns,
        ).columnsToMap();

        // Table-level access for the restricted tables.
        final List<DatabaseAccessGrant> tableGrants = <DatabaseAccessGrant>[];
        if (t.restricted) {
          final ShowcasePerson a = others[(n + k) % others.length];
          final ShowcasePerson b = others[(n + k + 1) % others.length];
          final ShowcasePerson c = others[(n + k + 2) % others.length];
          if (s.byMe) {
            tableGrants.add(grant(n + k, <ShowcasePerson>[a, b],
                DatabasePermissionLevel.view, tCreated,
                fields: const <String>['c1', 'c2', 'c3', 'c4']));
            tableGrants.add(grant(n + k + 1, <ShowcasePerson>[c],
                DatabasePermissionLevel.edit, tCreated));
          } else {
            tableGrants.add(grant(n + k, <ShowcasePerson>[me, a],
                DatabasePermissionLevel.edit, tCreated));
            tableGrants.add(grant(n + k + 1, <ShowcasePerson>[b],
                DatabasePermissionLevel.view, tCreated,
                fields: const <String>['c1', 'c2', 'c3']));
          }
        }

        w.set(tRef, <String, dynamic>{
          DatabaseTableModel.fNameEn: t.name.en,
          DatabaseTableModel.fNameAr: t.name.ar,
          DatabaseTableModel.fNameEnLower: t.name.en.toLowerCase(),
          DatabaseTableModel.fNameArLower: t.name.ar.toLowerCase(),
          DatabaseTableModel.fDescriptionEn: t.description.en,
          DatabaseTableModel.fDescriptionAr: t.description.ar,
          DatabaseTableModel.fRowCount: t.rows,
          DatabaseTableModel.fRowsVersion: 1,
          DatabaseTableModel.fColumns: columnMaps,
          DatabaseTableModel.fCommentsAccess: t.shared
              ? TableCommentsAccess.shared.storageKey
              : TableCommentsAccess.private.storageKey,
          DatabaseTableModel.fMemberCount: distinctMembers(tableGrants),
          DatabaseTableModel.fCreatedBy: creatorId,
          DatabaseTableModel.fCreatedAt: ts(tCreated),
          DatabaseTableModel.fUpdatedAt: ts(tUpdated),
          DatabaseTableModel.fAccessRestricted: t.restricted,
          if (t.restricted) ...DatabaseAccessIndexModel.fieldsFor(tableGrants),
        });

        for (int g = 0; g < tableGrants.length; g++) {
          w.set(
            tRef
                .collection(CreateDatabaseCollections.accessGrants)
                .doc(ShowcaseCommon.id('db${nn}_t${kk}_grant', g + 1)),
            <String, dynamic>{
              ...DatabaseAccessGrantModel.toMap(tableGrants[g]),
              DatabaseGrantFields.removedMembers: <Object>[],
              DatabaseGrantFields.grantedBy: creatorId,
              DatabaseGrantFields.grantedByNameEn: creatorPerson.nameEn,
              DatabaseGrantFields.grantedByNameAr: creatorPerson.nameAr,
              DatabaseGrantFields.updatedAt: ts(tCreated),
            },
          );
        }

        // Rows.
        for (int r = 0; r < t.rows; r++) {
          final List<String> values = tpl.row(ctx, r + n * 3 + k);
          final DateTime rCreated =
              cap(tCreated.add(Duration(days: r % 25, hours: 2 + r % 6)));
          w.set(
            tRef
                .collection(CreateTableCollections.rows)
                .doc(ShowcaseCommon.id('db${nn}_t${kk}_row', r + 1)),
            <String, dynamic>{
              TableDataRowModel.fOrder: r,
              TableDataRowModel.fValues: <String, String>{
                for (int c = 0; c < values.length; c++) 'c${c + 1}': values[c],
              },
              TableDataRowModel.fCreatedAt: ts(rCreated),
              TableDataRowModel.fUpdatedAt:
                  ts(cap(rCreated.add(Duration(days: r % 9)))),
            },
          );
        }

        // Comments.
        if (t.shared) {
          final int count = 4 + (n + k) % 2;
          final int offset =
              (n * 3 + k * 5) % DatabaseShowcaseData.comments.length;
          for (int c = 0; c < count; c++) {
            final ShowcasePerson author =
                c.isEven ? me : others[(n + c) % others.length];
            final String id = idOf(author);
            w.set(
              tRef
                  .collection(CreateTableCollections.comments)
                  .doc(ShowcaseCommon.id('db${nn}_t${kk}_cmt', c + 1)),
              <String, dynamic>{
                TableCommentModel.fAuthorId: id,
                TableCommentModel.fAuthorNameEn: author.nameEn,
                TableCommentModel.fAuthorNameAr: author.nameAr,
                TableCommentModel.fAuthorJobTitleEn: author.titleEn,
                TableCommentModel.fAuthorJobTitleAr: author.titleAr,
                TableCommentModel.fAuthorPhotoUrl: null,
                TableCommentModel.fText: DatabaseShowcaseData.comments[
                        (offset + c) % DatabaseShowcaseData.comments.length]
                    .of(isArabic),
                TableCommentModel.fCreatedAt: ts(
                    cap(tCreated.add(Duration(days: 2 + c * 3, hours: 4 + c)))),
                TableCommentModel.fLikedBy: c % 3 == 0
                    ? <String>[idOf(others[0]), idOf(others[1 % others.length])]
                    : c % 3 == 1
                        ? <String>[viewer]
                        : <String>[],
                TableCommentModel.fDislikedBy: <String>[],
              },
            );
          }
        }
      }

      // ── The database itself ─────────────────────────────────────────
      final DatabaseAccessType accessType = switch (s.access) {
        DbAccess.open => DatabaseAccessType.open,
        DbAccess.restricted => DatabaseAccessType.restricted,
        DbAccess.personal => DatabaseAccessType.personal,
      };
      final DatabaseStatus status = switch (s.state) {
        DbState.active => DatabaseStatus.active,
        DbState.draft => DatabaseStatus.draft,
        DbState.deleted => DatabaseStatus.deleted,
      };
      w.set(dbRef, <String, dynamic>{
        DatabaseModel.fTitleEn: s.title.en,
        DatabaseModel.fTitleAr: s.title.ar,
        DatabaseModel.fTitleEnLower: s.title.en.toLowerCase(),
        DatabaseModel.fTitleArLower: s.title.ar.toLowerCase(),
        DatabaseModel.fDescriptionEn: s.description.en,
        DatabaseModel.fDescriptionAr: s.description.ar,
        DatabaseModel.fAccessType: accessType.storageKey,
        DatabaseModel.fCoverImageUrl: null,
        DatabaseModel.fCreatedBy: creatorId,
        DatabaseModel.fCreatedAt: ts(created),
        DatabaseModel.fUpdatedAt:
            ts(s.state == DbState.deleted ? deletedAt : updated),
        DatabaseModel.fTablesCount: s.tables.length,
        DatabaseModel.fMemberCount: distinctMembers(grants),
        DatabaseModel.fStatus: status.storageKey,
        if (s.state == DbState.deleted) ...<String, dynamic>{
          DatabaseModel.fPreviousStatus: DatabaseStatus.active.storageKey,
          DatabaseModel.fDeletedAt: ts(deletedAt),
        },
        ...DatabaseAccessIndexModel.fieldsFor(grants),
        DatabaseModel.fAccessVersion: 1,
      });
      for (int g = 0; g < grants.length; g++) {
        w.set(
          dbRef
              .collection(CreateDatabaseCollections.accessGrants)
              .doc(ShowcaseCommon.id('db${nn}_grant', g + 1)),
          DatabaseAccessGrantModel.toMap(grants[g]),
        );
      }
    }
    return w.commit();
  }
}
