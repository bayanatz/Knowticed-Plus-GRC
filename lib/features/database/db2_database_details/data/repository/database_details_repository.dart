/// Module: database / db2_database_details / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_repository.dart
/// Description: Declares `DatabaseDetailsRepository`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// Turns the data source's throws into `Either<Failure, T>`. This is the only
/// layer that catches — the cubits fold, the UI renders, neither catches.
library;

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/data_source/remote_data_source/database_details_remote_data_source.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/base_repository/database_details_base_repository.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/data_source/remote_data_source/database_title_index.dart';

class DatabaseDetailsRepository implements DatabaseDetailsBaseRepository {
  DatabaseDetailsRepository({DatabaseDetailsRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? DatabaseDetailsRemoteDataSource();

  final DatabaseDetailsRemoteDataSource _remoteDataSource;

  /// Every method funnels through this, so the two failure shapes — a
  /// Firebase error with a code and everything else — are mapped once instead
  /// of in six near-identical try/catch blocks that can drift apart.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right<Failure, T>(await run());
    } on FirebaseException catch (error) {
      return Left<Failure, T>(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left<Failure, T>(FeatureFailure(error.toString()));
    }
  }

  /// An empty id means the caller is holding a record that was never written.
  /// Passing it through calls `doc('')`, which throws a bare assertion from
  /// the Firestore SDK rather than anything the UI can show.
  Either<Failure, void>? _rejectEmptyId(String id) {
    if (id.isNotEmpty) return null;
    return Left<Failure, void>(
      FeatureFailure(S.current.dbNoIdCannotReadOrSave),
    );
  }

  @override
  Future<Either<Failure, DatabaseEntity>> fetchDatabase(String id) async {
    if (id.isEmpty) {
      return Left<Failure, DatabaseEntity>(
        FeatureFailure(S.current.dbNoIdCannotRead),
      );
    }
    return _guard<DatabaseEntity>(() => _remoteDataSource.fetchDatabase(id));
  }

  @override
  Future<Either<Failure, List<DatabaseAccessGrantRecord>>> fetchGrants(
    String databaseId,
  ) async {
    // A record with no id has no subcollection either. Reporting an empty list
    // rather than a failure is right here: the Access screen's honest state
    // for an unsaved database is "nobody has access yet", not an error banner.
    if (databaseId.isEmpty) {
      return const Right<Failure, List<DatabaseAccessGrantRecord>>(
        <DatabaseAccessGrantRecord>[],
      );
    }
    return _guard<List<DatabaseAccessGrantRecord>>(
      () => _remoteDataSource.fetchGrants(databaseId),
    );
  }

  @override
  Future<Either<Failure, DatabaseEntity>> updateDatabase(
    DatabaseEntity database, {
    String? coverImagePath,
  }) async {
    if (database.id.isEmpty) {
      return Left<Failure, DatabaseEntity>(
        FeatureFailure(S.current.dbNoIdCannotSave),
      );
    }

    // Upload FIRST. If this throws, the document is untouched — better than a
    // saved record pointing at an image that never landed.
    String? uploadedUrl;
    try {
      if (coverImagePath != null) {
        uploadedUrl = await _remoteDataSource.uploadCoverImage(
          File(coverImagePath),
        );
      }
      await _remoteDataSource.updateDatabase(
        DatabaseModel.fromEntity(database),
        coverImageUrl: uploadedUrl,
      );
    } catch (error) {
      // Only the WRITE failed here, so the uploaded cover points at nothing
      // and can go (DB-CREATE-14).
      if (uploadedUrl != null) {
        await _remoteDataSource.deleteCoverImage(uploadedUrl);
      }
      if (error is DuplicateTitleException) {
        return const Left<Failure, DatabaseEntity>(
          ConflictFailure('title_taken'),
        );
      }
      if (error is FirebaseException) {
        return Left<Failure, DatabaseEntity>(
          FirebaseFailure(error.message ?? error.code),
        );
      }
      return Left<Failure, DatabaseEntity>(FeatureFailure(error.toString()));
    }

    // The record is written and points at the new cover: from here on the
    // save has worked, whatever happens next (DB-CREATE-14).
    //
    // The picture this one replaced is no longer pointed at (DB-CREATE-10).
    // deleteCoverImage never throws.
    final String? previous = database.coverImageUrl;
    if (uploadedUrl != null && previous != null && previous != uploadedUrl) {
      await _remoteDataSource.deleteCoverImage(previous);
    }

    // A failed read-back keeps the cover and still reports success, with the
    // record as it was written.
    final Either<Failure, DatabaseEntity> saved = await _guard<DatabaseEntity>(
      () => _remoteDataSource.fetchDatabase(database.id),
    );
    return saved.fold(
      (Failure _) => Right<Failure, DatabaseEntity>(
        database.copyWith(
          coverImageUrl: uploadedUrl ?? database.coverImageUrl,
          updatedAt: DateTime.now(),
        ),
      ),
      (DatabaseEntity entity) => Right<Failure, DatabaseEntity>(entity),
    );
  }

  @override
  Future<Either<Failure, bool>> titleExists({
    required String titleEn,
    required String titleAr,
    required String excludeId,
  }) =>
      _guard<bool>(
        () => _remoteDataSource.titleExists(
          titleEn: titleEn,
          titleAr: titleAr,
          excludeId: excludeId,
        ),
      );

  @override
  Future<Either<Failure, void>> replaceGrants({
    required String databaseId,
    required DatabaseAccessType accessType,
    required List<DatabaseAccessGrantRecord> records,
    required int expectedAccessVersion,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) async {
    final Either<Failure, void>? rejected = _rejectEmptyId(databaseId);
    if (rejected != null) return rejected;

    try {
      await _remoteDataSource.replaceGrants(
        databaseId: databaseId,
        accessType: accessType,
        records: records,
        expectedAccessVersion: expectedAccessVersion,
        grantedBy: grantedBy,
        grantedByNameEn: grantedByNameEn,
        grantedByNameAr: grantedByNameAr,
      );
      return const Right<Failure, void>(null);
    } on StaleAccessException {
      return const Left<Failure, void>(
        ConflictFailure('access_version changed since the grants were read'),
      );
    } on DeletedDatabaseException {
      return Left<Failure, void>(
        FeatureFailure(S.current.dbDetailsDeletedNoAccessChange),
      );
    } on FirebaseException catch (error) {
      return Left<Failure, void>(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left<Failure, void>(FeatureFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> fetchAccessVersion(String databaseId) async {
    if (databaseId.isEmpty) return const Right<Failure, int>(0);
    return _guard<int>(() => _remoteDataSource.fetchAccessVersion(databaseId));
  }
}
