/// ***************************** FILE INFO ***************************** ///
/// File Name: create_vision_usecase.dart
/// Purpose: Implements the use case for creating a new vision record.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: Defines the `CreateVisionUsecase` class for creating a new vision record
///              by interacting with the `VisionRepo` repository, returning success or failure.
/// ********************************************************************* ///
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/base_repository/vision_repo.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';

class CreateVisionUsecase {
  final VisionRepo repository;

  CreateVisionUsecase(this.repository);

  Future<Either<Failure, void>> execute(List<List> params) async {
    return await repository.createVision(params);
  }
}
