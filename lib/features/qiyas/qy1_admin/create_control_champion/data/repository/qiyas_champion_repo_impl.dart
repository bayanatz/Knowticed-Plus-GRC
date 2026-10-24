/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_champion_repo_impl.dart
/// Purpose: Implements the repository for interacting with Qiyas Champion data.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `QiyasChampionRepoImpl` class, which is the concrete implementation of the `QiyasChampionRepo`
///              repository interface. The repository class handles the business logic for interacting with the data sources related to
///              Qiyas Champion data. It utilizes the `QiyasChampionDataSources` to add and fetch Qiyas Champion officers from Firestore.
///              The methods are designed to handle errors using functional programming constructs like `Either<Failure, T>`, where `T`
///              represents the result type. The class is responsible for managing the flow of data and handling any failures that may occur
///              during the data operations.
/// ********************************************************************* ///
library;

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/failure_model.dart'
    as firebase_repo_failure;
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/late_unit_enum.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/base_repository/qiyas_champion_repo.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/data_source/qiyas_champion_data_sources.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';

class QiyasChampionRepoImpl extends QiyasChampionRepo {
  final QiyasChampionDataSources qiyasChampionDataSources;

  QiyasChampionRepoImpl(this.qiyasChampionDataSources);

  @override
  Future<Either<firebase_repo_failure.Failure, void>> addQiyasChampionOfficers({
    required List<String> criteriaIds,
    required List<String> document,
    required List<DateTime> documentSubmissionDate,
    required List<String> additionalNote,
    required List<int> lateUnitMultiplier,
    required List<LateUnitEnum> lateUnit,
    required String email,
  }) async {
    List<QiyasChampionModel> qiyasChampionModels = [];
    for (int i = 0; i < criteriaIds.length; i++) {
      debugPrint("micro seconds are ${DateTime.now().microsecondsSinceEpoch}");
      var model = QiyasChampionModel(
        id: email + (DateTime.now().microsecondsSinceEpoch).toString(),
        timeStamp: [Timestamp.now()],
        lateUnitMultiplier: lateUnitMultiplier[i],
        lateUnit: lateUnit[i],
        controlChampion: email,
        criteriaId: criteriaIds[i],
        document: document[i],
        documentSubmissionDate: [Timestamp.fromDate(documentSubmissionDate[i])],
        additionalNote: [additionalNote[i]],
        status: "active",
      );
      qiyasChampionModels.add(model);
    }
    debugPrint("length is ${qiyasChampionModels.length}");
    Either<firebase_repo_failure.Failure, void> result;
    for (var model in qiyasChampionModels) {
      result = await qiyasChampionDataSources.addQiyasChampionOfficer(model);
      if (result.isLeft()) {
        return result;
      }
    }

    return result = Right(null);
  }

  @override
  Future<Either<firebase_repo_failure.Failure, List<QiyasChampionModel>>>
      readAllQiyasControlChampions() async {
    try {
      return Right(
          await qiyasChampionDataSources.readAllQiyasControlChampion());
    } on ServerFailure catch (e) {
      return Left(firebase_repo_failure.FirebaseFailure(e.toString()));
    }
  }

  /// function name: [getEvidenceSubmissions]
  ///
  /// description: This function retrieves evidence submissions based on the provided criteria number, evidence number, and champion number.
  ///
  /// parameters:
  ///             - [criteriaNumber]: The criteria number to filter the evidence submissions.
  ///             - [evidenceNumber]: The evidence number to filter the evidence submissions.
  ///             - [championId]: The champion number to filter the evidence submissions.
  @override
  Future<Either<firebase_repo_failure.Failure, dynamic>> getEvidenceSubmissions(
      {required String criteriaNumber,
      required String evidenceNumber,
      required String championId}) async {
    Either<firebase_repo_failure.Failure, dynamic> result =
        await qiyasChampionDataSources.getEvidenceSubmissions(
            criteriaNumber: criteriaNumber,
            evidenceNumber: evidenceNumber,
            championId: championId);
    if (result.isLeft()) return result;
    List<Map<String, dynamic>> data = result.fold((_) => [], (r) => r);
    List<EvidenceSubmissionModel> evidenceSubmissions =
        data.map((e) => EvidenceSubmissionModel.fromMap(e)).toList();
    return result = Right(evidenceSubmissions);
  }

  /// function name: [getEvidenceStatus]
  ///
  /// description: This function retrieves the status of evidence submissions based on the provided criteria number, evidence number, and champion number.
  ///
  /// parameters:
  ///           - [criteriaNumber]: The criteria number to filter the evidence status.
  ///           - [evidenceNumber]: The evidence number to filter the evidence status.
  ///           - [championId]: The champion number to filter the evidence status.
  @override
  getEvidenceStatus(
      {required String criteriaNumber,
      required String evidenceNumber,
      required String championId}) async {
    Either<firebase_repo_failure.Failure, dynamic> result =
        await qiyasChampionDataSources.getEvidenceStatus(
            criteriaNumber: criteriaNumber,
            evidenceNumber: evidenceNumber,
            championId: championId);
    if (result.isLeft()) return result;
    List<Map<String, dynamic>> data = result.fold((_) => [], (r) => r);
    if (data.isEmpty) return result = Right(null);
    EvidenceSubmissionModel evidenceSubmissions =
        EvidenceSubmissionModel.fromMap(data.first);
    return result = Right(evidenceSubmissions);
  }

  @override
  getEvidenceOwner(
      {required String criteriaNumber, required String evidenceNumber}) async {
    Either<firebase_repo_failure.Failure, dynamic> result =
        await qiyasChampionDataSources.getEvidenceOwner(
            criteriaNumber: criteriaNumber, evidenceNumber: evidenceNumber);
    if (result.isLeft()) return result;
    List<Map<String, dynamic>> data = result.fold((_) => [], (r) => r);
    if (data.isEmpty) return result = Right(null);
    QiyasChampionEntity evidenceOwner =
        QiyasChampionEntity.qiyasChampionFireBasetoEntity(
            QiyasChampionModel.fromMap(data.first));
    return result = Right(evidenceOwner);
  }

  @override
  deleteQiyasChampion(List<QiyasChampionEntity> permission) async {
    qiyasChampionDataSources.startTransaction();
    for (var champion in permission) {
      await qiyasChampionDataSources.deleteQiyasChampion(champion);
    }
    return await qiyasChampionDataSources.commitTransaction();
  }
}
