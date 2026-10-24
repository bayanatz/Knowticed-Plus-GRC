/// ***************************** FILE INFO ***************************** ///
/// File Name: vision_repo_impl.dart
/// Purpose: Implements the repository interface for managing vision data operations.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file defines the implementation of the `VisionRepo` interface, which interacts with the
///              data sources to perform CRUD operations on vision data. It handles the creation, editing,
///              deletion, and reading of vision data, returning the results as `Either` types, encapsulating
///              either a `Failure` or a successful result.
/// ********************************************************************* ///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/base_repository/vision_repo.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/utils/headers_enum.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/data_source/vision_data_source.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';

class VisionRepoImpl extends VisionRepo {
  final VisionDataSource visionDataSource;

  VisionRepoImpl(this.visionDataSource);

  @override
  Future<Either<Failure, void>> createVision(List<List<dynamic>> rows) async {
    List<VisionModel> visions = [];
    for (List<dynamic> row in rows) {
      visions.add(fromList(row));
    }
    visionDataSource.startTransaction();
    for (var vision in visions) {
      visionDataSource.createVision(vision);
    }
    try {
      // The commit's own Either was wrapped in this Right and never read.
      await visionDataSource.commitTransaction();
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVision(VisionModel vision) {
    // TODO: implement deleteModule
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> editVision(VisionModel vision) async {
    try {
      return Right(await visionDataSource.editVision(vision));
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<VisionModel>>> readALLVisions() async {
    try {
      return Right(await visionDataSource.readALLVisions());
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  VisionModel fromList(List list) {
    return VisionModel(
      description: [list[HeadersEnum.description.index].toString()],
      id: '${list[HeadersEnum.criterionNumber.index].toString()}_${DateTime.now().year}',
      timeStamp: [Timestamp.now()],
      visionName: [list[HeadersEnum.visionName.index].toString()],
      topicNumber: [list[HeadersEnum.topicNumber.index].toString()],
      topicName: [list[HeadersEnum.topicName.index].toString()],
      criterionNumber: [list[HeadersEnum.criterionNumber.index].toString()],
      criterionName: [list[HeadersEnum.criterionName.index].toString()],
      goals: [list[HeadersEnum.goals.index].toString()],
      appRequirements: [list[HeadersEnum.appRequirements.index].toString()],
      evidenceDocuments: [list[HeadersEnum.evidence.index].toString()],
      ordersDecisionsAndCirculars: [list[HeadersEnum.orders.index].toString()],
      scope: [list[HeadersEnum.scope.index].toString()],
    );
  }
}
