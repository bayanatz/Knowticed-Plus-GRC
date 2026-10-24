/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_champion_repo.dart
/// Purpose: Defines the repository interface for interacting with Qiyas Champion data.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `QiyasChampionRepo` abstract class, which defines the contract for the repository layer
///              responsible for handling Qiyas Champion data. It includes methods for adding Qiyas Champion officers and reading all
///              Qiyas Control Champions from the data sources. The repository uses functional programming constructs like `Either<Failure, T>`
///              to handle success and failure scenarios, ensuring that errors are properly managed in a functional style. This interface
///              is implemented by the repository class to interact with the data sources.
/// ********************************************************************* ///
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/late_unit_enum.dart';

abstract class QiyasChampionRepo {
  Future<Either<Failure, void>> addQiyasChampionOfficers({
    required List<String> criteriaIds,
    required List<String> document,
    required List<DateTime> documentSubmissionDate,
    required List<String> additionalNote,
    required List<int> lateUnitMultiplier,
    required List<LateUnitEnum> lateUnit,
    required String email,
  });
  Future<Either<Failure, List<QiyasChampionModel>>>
      readAllQiyasControlChampions();

  Future<Either<Failure, dynamic>> getEvidenceSubmissions(
      {required String criteriaNumber,
      required String evidenceNumber,
      required String championId});

  Future<Either<Failure, dynamic>> getEvidenceStatus(
      {required String criteriaNumber,
      required String evidenceNumber,
      required String championId});

  Future<Either<Failure, dynamic>> getEvidenceOwner(
      {required String criteriaNumber, required String evidenceNumber});

  Future<Either<Failure, dynamic>> deleteQiyasChampion(
      List<QiyasChampionEntity> permission);
}
