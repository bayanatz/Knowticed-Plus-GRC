/// Module: GRC Request Management
/// Description: Use case for creating a new Reassign Control Champion request.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: dartz, Failure, GrcRequestEntity, GrcRequestRepository, AssigningControlEntity

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/repository/grc_request_repository.dart';

class CreateGrcRequestParams {
  final String moduleId;
  final String requestedBy;
  final String note;
  final String currentChampionEmail;
  final String newChampionEmail;
  final List<AssigningControlEntity> controls;
  final DateTime startDate;
  final DateTime? endDate;

  const CreateGrcRequestParams({
    required this.moduleId,
    required this.requestedBy,
    required this.note,
    required this.currentChampionEmail,
    required this.newChampionEmail,
    required this.controls,
    required this.startDate,
    this.endDate,
  });
}

class CreateGrcRequestUseCase {
  const CreateGrcRequestUseCase(this._repository);

  final GrcRequestRepository _repository;

  Future<Either<Failure, GrcRequestEntity>> call(CreateGrcRequestParams params) {
    return _repository.createReassignChampionRequest(
      moduleId: params.moduleId,
      requestedBy: params.requestedBy,
      note: params.note,
      currentChampionEmail: params.currentChampionEmail,
      newChampionEmail: params.newChampionEmail,
      controls: params.controls,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
