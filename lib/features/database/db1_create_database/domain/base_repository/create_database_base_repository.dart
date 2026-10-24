/// Module: database / db1_create_database / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_base_repository.dart
/// Description: Declares `CreateDatabaseBaseRepository`.
/// Author: Amr Mesbah
/// Created at: 15/8/2026
///
/// The contract the cubit depends on, so the presentation layer never names
/// the Firestore-backed implementation and tests can pass a fake.
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_page.dart';

abstract class CreateDatabaseBaseRepository {
  /// Writes [database] plus its access [grants] and returns the record with
  /// its generated id (and cover URL, when [coverImagePath] was supplied)
  /// filled in.
  ///
  /// The grants are written as a subcollection rather than an array field:
  /// a department grant embeds every member, and a few hundred of those would
  /// push the parent document towards Firestore's 1 MB ceiling.
  Future<Either<Failure, DatabaseEntity>> createDatabase(
    DatabaseEntity database, {
    String? coverImagePath,
    List<DatabaseAccessGrant> grants = const <DatabaseAccessGrant>[],
  });

  /// Rewrites the database [database.id] and REPLACES its access grants — the
  /// wizard reopened on an existing draft and finished it.
  ///
  /// Without this, resuming a draft would go through [createDatabase] and
  /// write a SECOND document, leaving the original sitting under Drafts. The
  /// fields the wizard does not own — `created_at`, `created_by`,
  /// `tables_count` — are left alone; see `DatabaseModel.toUpdateMap`.
  Future<Either<Failure, DatabaseEntity>> updateDatabase(
    DatabaseEntity database, {
    String? coverImagePath,
    List<DatabaseAccessGrant> grants = const <DatabaseAccessGrant>[],
  });

  /// The access rules under [databaseId], as the wizard's own entity, so a
  /// resumed draft reopens with the people it had picked
  /// instead of an empty member list.
  Future<Either<Failure, List<DatabaseAccessGrant>>> fetchGrants(
    String databaseId,
  );

  /// Function Name: [listDatabasesPage]
  ///
  /// Purpose: One page of one tab of the Database Builder list, newest first:
  /// the records [viewerId] created or is named in that match [query]
  /// (DB-CREATE-08). Dates and levels are checked afterwards by
  /// `DatabaseAccessRule`.
  ///
  /// Parameters: [viewerId]; [query] the tab; [after] null for the first page;
  /// [limit] records per page.
  ///
  /// Returns: [Either<Failure, DatabasePage>].
  Future<Either<Failure, DatabasePage>> listDatabasesPage({
    required String viewerId,
    required DatabaseListQuery query,
    DatabasePageCursor? after,
    int limit = 30,
  });

  /// Function Name: [countDatabases]
  ///
  /// Purpose: How many records one tab holds, counted on the server
  /// (DB-CREATE-08), with the same filters as [listDatabasesPage].
  ///
  /// Parameters: [viewerId]; [query] the tab.
  ///
  /// Returns: [Either<Failure, int>].
  Future<Either<Failure, int>> countDatabases({
    required String viewerId,
    required DatabaseListQuery query,
  });

  /// Function Name: [listGrantedDatabases]
  ///
  /// Purpose: Every record in [statuses] that names [viewerId] in a grant and
  /// was created by someone else (DB-CREATE-08). The tab counts use it to
  /// leave out grants whose dates have ended or not started yet.
  ///
  /// Parameters: [viewerId]; [statuses] the statuses to read.
  ///
  /// Returns: [Either<Failure, List<DatabaseEntity>>].
  Future<Either<Failure, List<DatabaseEntity>>> listGrantedDatabases({
    required String viewerId,
    required List<DatabaseStatus> statuses,
  });

  /// True when another database already uses [titleEn] or [titleAr]. The
  /// screen blocks duplicates before writing.
  ///
  /// [excludeId] is the one record allowed to keep its own name — the draft
  /// being resumed. Without it, reopening a draft and pressing the primary
  /// button matches the draft against ITSELF and is refused as a duplicate.
  Future<Either<Failure, bool>> titleExists({
    required String titleEn,
    required String titleAr,
    String? excludeId,
  });

  /// Moves the database [id] into the Deleted chip — the "Delete" row of the
  /// card's "..." menu (Figma 7398:2492, "3 Dots"). A soft delete.
  ///
  /// The document and its `Access_Grants` subcollection both survive; only the
  /// status changes. That is the whole point: [restoreDatabase] has to hand
  /// the record back with everyone's access intact, and a record whose grants
  /// had been swept would come back looking valid while granting nobody
  /// anything.
  ///
  /// [previousStatus] is where the record was standing — `active` or `draft` —
  /// so Restore can return it there. The caller has the entity on screen and
  /// already knows; re-reading it inside the implementation would only add a
  /// way for the two to disagree.
  Future<Either<Failure, void>> deleteDatabase(
    String id, {
    required DatabaseStatus previousStatus,
  });

  /// Puts a soft-deleted record back — "Restore" on the "..." menu.
  ///
  /// [status] is `DatabaseEntity.restoreTarget`, not a hardcoded `active`: a
  /// draft that was deleted belongs back under Drafts, where it grants nobody
  /// anything, rather than in the finished list.
  Future<Either<Failure, void>> restoreDatabase(
    String id, {
    required DatabaseStatus status,
  });
}
