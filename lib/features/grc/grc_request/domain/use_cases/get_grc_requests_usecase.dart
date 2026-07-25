/// Module: GRC Request Management
/// Description: Use case for reading all GRC requests for a module.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestRepository

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class GetGrcRequestsUseCase {
  const GetGrcRequestsUseCase(this._repository);

  final GrcRequestRepository _repository;

  Future<Either<Failure, List<GrcRequestEntity>>> call(String moduleId) {
    return _repository.getRequestsForModule(moduleId);
  }
}
