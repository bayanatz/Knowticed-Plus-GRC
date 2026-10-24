/// ***************************** FILE INFO ***************************** ///
/// File Name: vision_repo.dart
/// Purpose: Defines the repository interface for managing vision data operations.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file declares the `VisionRepo` abstract class, which defines the contract for managing
///              vision data operations. It includes methods for creating, editing, deleting, and reading
///              vision data, which will be implemented by a concrete repository class. The methods return
///              results as `Either` types, encapsulating either a `Failure` or a successful result.
/// ********************************************************************* ///
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';

abstract class VisionRepo {
  Future<Either<Failure, void>> createVision(List<List<dynamic>> moduleVision);
  Future<Either<Failure, void>> editVision(VisionModel moduleVision);
  Future<Either<Failure, void>> deleteVision(VisionModel moduleVision);
  Future<Either<Failure, List<VisionModel>>> readALLVisions();
}
