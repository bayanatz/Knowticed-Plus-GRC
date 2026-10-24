/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_champion_data_sources.dart
/// Purpose: Defines the data source interface and implementation for interacting with Qiyas Champion data in Firestore.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `QiyasChampionDataSources` abstract class and its implementation, `QiyasChampionDataSourcesImpl`,
///              for interacting with Qiyas Champion data in Firestore. The data sources define methods for adding and reading Qiyas Champion
///              officers. The implementation uses a `FireBaseHelper` to interact with Firestore. It provides methods to add and fetch
///              Qiyas Champion records from the database. In case of errors, it throws a `ServerFailure`, which is rethrown for further
///              handling in higher layers. The methods are designed to handle Firestore data operations for Qiyas Champion entities.
/// ********************************************************************* ///
library;

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/app_services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/core/network/failure_model.dart'
    as firebase_repo_failure;

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/firebase_helper.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';

class QiyasChampionDataSources {
  FireBaseHelper<QiyasChampionModel> helper;
  WriteBatch _batch = FirebaseFirestore.instance.batch();
  QiyasChampionDataSources({required this.helper});
  Future<Either<firebase_repo_failure.Failure, dynamic>>
      addQiyasChampionOfficer(QiyasChampionModel model) async {
    Either<firebase_repo_failure.Failure, dynamic> result;
    debugPrint("api called ${DateTime.now().microsecondsSinceEpoch}");
    try {
      await helper.addItem(model.toMap());
      result = const Right(null);
    } catch (e) {
      result = Left(firebase_repo_failure.FirebaseFailure(e.toString()));
    }
    return result;
  }

  Future<List<QiyasChampionModel>> readAllQiyasControlChampion() async {
    Either<firebase_repo_failure.FirebaseFailure, dynamic> result =
        await FirebaseRepository.getDocumentsWithOneFilter(
      collectionPath: getBaseUrl(kQiyasChampionNameCollection),
      filterKey: QiyasChampionModel.statusKey,
      filterValue: 'active',
    );
    if (result.isLeft()) return List<QiyasChampionModel>.from([]);
    List<QiyasChampionModel> champions = [];
    for (var item in result.getOrElse(() => [])) {
      champions.add(QiyasChampionModel.fromMap(item));
    }
    return champions;
  }

  Future<Either<firebase_repo_failure.Failure, dynamic>> getEvidenceSubmissions(
      {required String criteriaNumber,
      required String evidenceNumber,
      required String championId}) async {
    debugPrint("getEvidenceSubmissions called with: "
        "criteriaNumber: $criteriaNumber, "
        "evidenceNumber: $evidenceNumber, "
        "championId: $championId");
    return await FirebaseRepository
        .getDocumentsWithThreeConditionsSortedByOneField(
      collectionName:
          getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
      fieldName1: EvidenceSubmissionModel.evidenceNumberKey,
      fieldValue1: evidenceNumber.trim(),
      fieldName2: EvidenceSubmissionModel.criteriaNumberKey,
      fieldValue2: criteriaNumber.trim(),
      fieldName3: EvidenceSubmissionModel.submittedByKey,
      fieldValue3: championId.trim(),
      sortFieldName: EvidenceSubmissionModel.submissionDateKey,
    );
  }

  Future<Either<firebase_repo_failure.FirebaseFailure, dynamic>>
      getEvidenceStatus(
          {required String criteriaNumber,
          required String evidenceNumber,
          required String championId}) async {
    return await FirebaseRepository
        .getDocumentsWithThreeConditionsSortedByOneFieldWithLimitOne(
      collectionName:
          getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection),
      fieldName1: EvidenceSubmissionModel.evidenceNumberKey,
      fieldValue1: evidenceNumber.trim(),
      fieldName2: EvidenceSubmissionModel.criteriaNumberKey,
      fieldValue2: criteriaNumber.trim(),
      fieldName3: EvidenceSubmissionModel.submittedByKey,
      fieldValue3: championId.trim(),
      sortFieldName: EvidenceSubmissionModel.submissionDateKey,
    );
  }

  Future<Either<firebase_repo_failure.Failure, dynamic>> getEvidenceOwner(
      {required String criteriaNumber, required String evidenceNumber}) async {
    return await FirebaseRepository
        .getDocumentsWithTwoConditionsSortedByOneFieldWithLimitOne(
            collectionName: getBaseUrl(kQiyasOwnerNameCollection),
            fieldName1: QiyasChampionModel.criteriaKey,
            fieldValue1: criteriaNumber,
            fieldName2: QiyasChampionModel
                .documentKey, // was Deadline (a date list): never matched an evidence number (QY-4)
            fieldValue2: evidenceNumber,
            sortFieldName: QiyasChampionModel.timeStampKey);
  }

  void startTransaction() {
    _batch = FirebaseFirestore.instance.batch();
  }

  Future<Either<firebase_repo_failure.Failure, dynamic>>
      commitTransaction() async {
    Either<firebase_repo_failure.Failure, dynamic> result;
    try {
      await _batch.commit();
      result = const Right(null);
    } catch (e) {
      debugPrint("Error during transaction commit: $e");
      result = Left(firebase_repo_failure.FirebaseFailure(e.toString()));
    }
    return result;
  }

  Future<void> deleteQiyasChampion(QiyasChampionEntity champion) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(getBaseUrl(kQiyasChampionNameCollection))
        .where(QiyasChampionModel.idKey, isEqualTo: champion.id)
        .limit(1)
        .get();

    DocumentReference championRef;
    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      championRef = FirebaseFirestore.instance
          .collection(getBaseUrl(kQiyasChampionNameCollection))
          .doc(docId);

      debugPrint("champion id ${champion.id}");
      _batch.update(championRef, {
        QiyasChampionModel.statusKey: 'inactive',
        QiyasChampionModel.timeStampKey:
            FieldValue.arrayUnion([Timestamp.now()])
      });
    }
  }
}
