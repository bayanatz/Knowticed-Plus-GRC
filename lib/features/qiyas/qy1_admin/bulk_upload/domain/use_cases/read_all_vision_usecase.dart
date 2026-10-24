/// ***************************** FILE INFO ***************************** ///
/// File Name: read_all_visions_usecase.dart
/// Purpose: Implements the use case for retrieving all vision records.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: Defines the `ReadAllVisionUsecase` class that retrieves all vision records
///              by interacting with the `VisionRepo` repository and returns a list of visions or a failure.
/// ********************************************************************* ///
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/base_repository/vision_repo.dart';

class ReadAllVisionUsecase {
  final VisionRepo repository;

  ReadAllVisionUsecase(this.repository);

  Future<Either<Failure, List<VisionModel>>> execute() async {
    return await repository.readALLVisions();
  }
}
