/// ***************************** FILE INFO ***************************** ///
/// File Name: add_qiyas_champion_officer.dart
/// Purpose: Defines the use case for adding Qiyas Champion officers.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `AddQiyasChampionOfficersUsecase` class, which encapsulates the business logic for adding
///              Qiyas Champion officers. It interacts with the `QiyasChampionRepo` repository to perform the operation of adding a new
///              Qiyas Champion officer. The use case is part of the application layer and acts as an intermediary between the ui and
///              the repository layer, providing a higher-level abstraction for performing the operation. It returns an `Either<Failure, T>`
///              to handle potential errors gracefully.
/// ********************************************************************* ///
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/late_unit_enum.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/base_repository/qiyas_champion_repo.dart';

class AddQiyasChampionOfficersUsecase {
  final QiyasChampionRepo repository;

  AddQiyasChampionOfficersUsecase(this.repository);

  Future<Either<Failure, void>> execute({
    required List<String> criteriaIds,
    required List<String> document,
    required List<DateTime> documentSubmissionDate,
    required List<String> additionalNote,
    required List<int> lateUnitMultiplier,
    required List<LateUnitEnum> lateUnit,
    required String email,
  }) async {
    return await repository.addQiyasChampionOfficers(
        criteriaIds: criteriaIds,
        document: document,
        documentSubmissionDate: documentSubmissionDate,
        additionalNote: additionalNote,
        lateUnitMultiplier: lateUnitMultiplier,
        lateUnit: lateUnit,
        email: email);
  }
}
