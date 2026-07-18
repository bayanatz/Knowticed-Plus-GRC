// lib/features/grc/control_owner/data/repository/owner_repository_impl.dart
/// Module: Control Owner Management
/// Description: Data-layer implementation of [OwnerRepository]. Maps
///              between Models (persistence) and Entities (domain), and
///              wraps every result in Either<Failure, T>.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: dartz, OwnerRepository, OwnerFirebaseDataSource, OwnerModel

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/control/data/models/assigning_control_model.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control_owner/data/data_source/owner_firebase_data_source.dart';
import 'package:demo_app/features/grc/control_owner/data/models/owner_model.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_status.dart';
import 'package:demo_app/features/grc/control_owner/domain/repository/owner_repository.dart';

class OwnerRepositoryImpl implements OwnerRepository {
  OwnerRepositoryImpl({required OwnerFirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  final OwnerFirebaseDataSource _firebaseDataSource;

  List<AssigningControlModel> _toModels(List<AssigningControlEntity> entities) {
    return entities
        .map((a) => AssigningControlModel(policyId: a.policyId, controlId: a.controlId))
        .toList();
  }

  @override
  Future<Either<Failure, OwnerEntity>> createOwner({
    required String moduleId,
    required String ownerEmail,
    required List<AssigningControlEntity> assigningControls,
    required String editorId,
  }) async {
    try {
      final model = OwnerModel.create(
        ownerEmail: ownerEmail,
        initialAssigningControls: _toModels(assigningControls),
        modifierEmail: editorId,
      );
      final created = await _firebaseDataSource.create(model, moduleId: moduleId);
      return Right(created.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OwnerEntity>> getOwner(
    String ownerEmail, {
    required String moduleId,
  }) async {
    try {
      final model = await _firebaseDataSource.get(ownerEmail, moduleId: moduleId);
      if (model == null) {
        return Left(ValidationError('Control Owner not found (email: $ownerEmail)'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OwnerEntity>>> getAllOwners({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    try {
      final models = await _firebaseDataSource.getAll(
        moduleId: moduleId,
        includeRemoved: includeRemoved,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OwnerEntity>> updateOwner({
    required String ownerEmail,
    required String moduleId,
    required String editorId,
    List<AssigningControlEntity>? assigningControls,
    List<List<String>>? controlOwnerPermissions,
    OwnerStatus? status,
  }) async {
    try {
      final current = await _firebaseDataSource.get(ownerEmail, moduleId: moduleId);
      if (current == null) {
        return Left(ValidationError('Control Owner not found (email: $ownerEmail)'));
      }
      final updated = current.copyWithUpdate(
        assigningControls:
            assigningControls != null ? _toModels(assigningControls) : null,
        controlOwnerPermissions: controlOwnerPermissions,
        status: status?.value,
        modifierEmail: editorId,
      );
      final saved = await _firebaseDataSource.update(updated, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
