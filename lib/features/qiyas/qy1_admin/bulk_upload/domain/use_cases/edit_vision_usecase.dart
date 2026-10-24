/// ***************************** FILE INFO ***************************** ///
/// File Name: edit_vision_usecase.dart
/// Purpose: Implements the use case for editing an existing vision record.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: Defines the `EditVisionUsecase` class that handles editing an existing vision record
///              by interacting with the `VisionRepo` repository and returns success or failure.
/// ********************************************************************* ///
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/base_repository/vision_repo.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';

class EditVisionUsecase {
  final VisionRepo repository;

  EditVisionUsecase(this.repository);

  Future<Either<Failure, void>> execute(VisionModel params) async {
    return await repository.editVision(params);
  }
}
