/// Module: database / db1_create_database / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_repository.dart
/// Description: Declares `CreateDatabaseRepository`.
/// Author: Amr Mesbah
/// Created at: 15/8/2026
///
/// Turns the data source's throws into `Either<Failure, T>`. This is the only
/// layer that catches — the cubit folds, the UI renders, neither catches.
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/data_source/remote_data_source/create_database_remote_data_source.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_page.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/data_source/remote_data_source/database_title_index.dart';

class CreateDatabaseRepository implements CreateDatabaseBaseRepository {
  CreateDatabaseRepository({CreateDatabaseRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? CreateDatabaseRemoteDataSource();

  final CreateDatabaseRemoteDataSource _remoteDataSource;

  /// An uploaded cover whose save failed points at nothing (DB-CREATE-10).
  /// Only called while the write has not landed: once it has, the record
  /// uses the cover and `uploaded` is cleared (DB-CREATE-14).
  Future<void> _discardUpload(String? url) async {
    if (url != null) await _remoteDataSource.deleteCoverImage(url);
  }

  /// Reads the record just written. The write has already succeeded, so a
  /// failed read returns [fallback] — the record as it was written — instead
  /// of reporting an error for a save that worked (DB-CREATE-14).
  Future<DatabaseEntity> _readBack(
    String id, {
    required DatabaseEntity fallback,
  }) async {
    try {
      return await _remoteDataSource.readDatabase(id);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<Either<Failure, DatabaseEntity>> createDatabase(
    DatabaseEntity database, {
    String? coverImagePath,
    List<DatabaseAccessGrant> grants = const <DatabaseAccessGrant>[],
  }) async {
    String? uploaded;
    try {
      String? coverUrl = database.coverImageUrl;

      // Upload first. If this throws, nothing has been written yet — better
      // than a saved record pointing at an image that never landed.
      if (coverImagePath != null) {
        uploaded = await _remoteDataSource.uploadCoverImage(
          File(coverImagePath),
        );
        coverUrl = uploaded;
      }

      final String id = await _remoteDataSource.createDatabase(
        DatabaseModel.fromEntity(database.copyWith(coverImageUrl: coverUrl)),
        grants: grants,
      );

      // The record is written and points at the new cover, so from here on
      // the cover must survive, and a failed read-back is still a successful
      // save (DB-CREATE-14).
      uploaded = null;
      return Right(
        await _readBack(
          id,
          fallback: database.copyWith(
            id: id,
            coverImageUrl: coverUrl,
            createdAt: database.createdAt ?? DateTime.now(),
          ),
        ),
      );
    } on DuplicateTitleException {
      await _discardUpload(uploaded);
      return const Left(ConflictFailure('title_taken'));
    } on FirebaseException catch (error) {
      await _discardUpload(uploaded);
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      await _discardUpload(uploaded);
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, DatabaseEntity>> updateDatabase(
    DatabaseEntity database, {
    String? coverImagePath,
    List<DatabaseAccessGrant> grants = const <DatabaseAccessGrant>[],
  }) async {
    if (database.id.isEmpty) {
      return Left(FeatureFailure(S.current.dbNoIdCannotUpdate));
    }

    String? uploaded;
    try {
      String? coverUrl = database.coverImageUrl;

      // Upload first, exactly as `createDatabase` does: a failed upload leaves
      // the record untouched rather than pointing it at an image that never
      // landed.
      if (coverImagePath != null) {
        uploaded = await _remoteDataSource.uploadCoverImage(
          File(coverImagePath),
        );
        coverUrl = uploaded;
      }

      await _remoteDataSource.updateDatabase(
        database.id,
        DatabaseModel.fromEntity(database.copyWith(coverImageUrl: coverUrl)),
        grants: grants,
      );

      // The record is written and points at the new cover, so from here on
      // the cover must survive even if a later step fails (DB-CREATE-14).
      final String? landed = uploaded;
      uploaded = null;

      // The picture this one replaced is no longer pointed at (DB-CREATE-10).
      final String? previous = database.coverImageUrl;
      if (landed != null && previous != null && previous != landed) {
        await _remoteDataSource.deleteCoverImage(previous);
      }
      return Right(
        await _readBack(
          database.id,
          fallback: database.copyWith(
            coverImageUrl: coverUrl,
            updatedAt: DateTime.now(),
          ),
        ),
      );
    } on DuplicateTitleException {
      await _discardUpload(uploaded);
      return const Left(ConflictFailure('title_taken'));
    } on FirebaseException catch (error) {
      await _discardUpload(uploaded);
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      await _discardUpload(uploaded);
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DatabaseAccessGrant>>> fetchGrants(
    String databaseId,
  ) async {
    if (databaseId.isEmpty) {
      return const Right<Failure, List<DatabaseAccessGrant>>(
        <DatabaseAccessGrant>[],
      );
    }

    try {
      final List<DatabaseAccessGrant> grants =
          await _remoteDataSource.fetchGrants(databaseId);
      return Right(grants);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, DatabasePage>> listDatabasesPage({
    required String viewerId,
    required DatabaseListQuery query,
    DatabasePageCursor? after,
    int limit = 30,
  }) async {
    try {
      return Right<Failure, DatabasePage>(
        await _remoteDataSource.listDatabasesPage(
          viewerId: viewerId,
          query: query,
          after: after,
          limit: limit,
        ),
      );
    } on FirebaseException catch (error) {
      return Left<Failure, DatabasePage>(
        FirebaseFailure(error.message ?? error.code),
      );
    } catch (error) {
      return Left<Failure, DatabasePage>(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> countDatabases({
    required String viewerId,
    required DatabaseListQuery query,
  }) async {
    try {
      return Right<Failure, int>(
        await _remoteDataSource.countDatabases(
          viewerId: viewerId,
          query: query,
        ),
      );
    } on FirebaseException catch (error) {
      return Left<Failure, int>(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left<Failure, int>(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DatabaseEntity>>> listGrantedDatabases({
    required String viewerId,
    required List<DatabaseStatus> statuses,
  }) async {
    try {
      return Right<Failure, List<DatabaseEntity>>(
        await _remoteDataSource.listGrantedDatabases(
          viewerId: viewerId,
          statuses: statuses,
        ),
      );
    } on FirebaseException catch (error) {
      return Left<Failure, List<DatabaseEntity>>(
        FirebaseFailure(error.message ?? error.code),
      );
    } catch (error) {
      return Left<Failure, List<DatabaseEntity>>(
        FeatureFailure(error.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> titleExists({
    required String titleEn,
    required String titleAr,
    String? excludeId,
  }) async {
    try {
      final bool exists = await _remoteDataSource.titleExists(
        titleEn: titleEn,
        titleAr: titleAr,
        excludeId: excludeId,
      );
      return Right(exists);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDatabase(
    String id, {
    required DatabaseStatus previousStatus,
  }) async {
    // An empty id means the caller is holding a record that was never
    // written. Passing it through would call `_collection.doc('')`, which
    // throws a bare assertion from the Firestore SDK rather than anything the
    // UI can show — so it is rejected here as the Failure it actually is.
    if (id.isEmpty) {
      return Left(FeatureFailure(S.current.dbNoIdCannotDelete));
    }

    try {
      await _remoteDataSource.softDeleteDatabase(
        id,
        previousStatus: previousStatus,
      );
      return const Right<Failure, void>(null);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreDatabase(
    String id, {
    required DatabaseStatus status,
  }) async {
    if (id.isEmpty) {
      return Left(FeatureFailure(S.current.dbNoIdCannotRestore));
    }

    try {
      await _remoteDataSource.restoreDatabase(id, status: status);
      return const Right<Failure, void>(null);
    } on FirebaseException catch (error) {
      return Left(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left(FeatureFailure(error.toString()));
    }
  }
}
