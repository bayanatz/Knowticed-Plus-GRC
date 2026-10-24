import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/data/data_source/champigan_tasks_remote_data_source.dart';

import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';

class ChampiganTasksRepository {
  ChampiganTasksRemoteDataSource champiganTasksRemoteDataSource =
      ChampiganTasksRemoteDataSource();

  Future<Either<Failure, dynamic>> getTasksStatus(
      {required List<String> criteriaNumbers,
      required List<String> evidenceNumber,
      required String champiganId}) async {
    List<EvidenceSubmissionModel?> evidenceSubmissions = [];
    Either<Failure, dynamic> response;
    for (int i = 0; i < criteriaNumbers.length; i++) {
      response = await champiganTasksRemoteDataSource.getTasksStatus(
        criteriaNumber: criteriaNumbers[i].trim(),
        evidenceNumber: evidenceNumber[i].trim(),
        champiganId: champiganId,
      );
      if (response.isLeft()) return response;
      List<Map<String, dynamic>>? data = response.fold((_) => null, (r) => r);
      if (data == null || data.isEmpty) {
        evidenceSubmissions.add(null);
      } else {
        evidenceSubmissions.add(EvidenceSubmissionModel.fromMap(data.first));
      }
    }
    return response = Right(evidenceSubmissions);
  }

  Future<Either<Failure, dynamic>> uploadEvidence(
      {required String criteriaNumber,
      required String evidenceNumber,
      required File file,
      required String notes,
      required String championId}) async {
    debugPrint('📂 [REPOSITORY] Starting upload...');
    debugPrint('   Champion: $championId');
    debugPrint('   File path: ${file.path}');
    debugPrint('   File exists: ${await file.exists()}');

    if (!await file.exists()) {
      debugPrint('❌ [REPOSITORY] File does not exist!');
    }

    var response = await champiganTasksRemoteDataSource.uploadEvidenceDocument(
        file.path,
        'Qiyas_Evidence_Submissions/$criteriaNumber/$evidenceNumber');
    if (response.isLeft()) return response;
    String fileUrl = response.fold((_) => file.path, (r) => r);
    debugPrint('File URL: $fileUrl');

    String fileSize = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
    EvidenceSubmissionModel model = EvidenceSubmissionModel(
      submissionDate: Timestamp.now(),
      submissionStatus: EvidenceSubmissionStatus.submitted,
      submissionNote: notes,
      submissionId:
          '$criteriaNumber _ $evidenceNumber _ ${Timestamp.now().microsecondsSinceEpoch}',
      evidenceNumber: evidenceNumber,
      criteriaNumber: criteriaNumber,
      submittedBy: championId,
      approvedBy: null,
      approvedDate: null,
      filePath: fileUrl,
      fileName: file.path.split('/').last,
      fileSize: '$fileSize MB',
    );
    return await champiganTasksRemoteDataSource.uploadEvidenceSubmission(model);
  }

  Future<Either<Failure, dynamic>> getTaskSubmissions(
      {required String criteriaNumber,
      required String evidenceNumber,
      required String champiganId}) async {
    var response = await champiganTasksRemoteDataSource.getTaskSubmssions(
      criteriaNumber: criteriaNumber,
      evidenceNumber: evidenceNumber,
      champiganId: champiganId,
    );
    if (response.isLeft()) return response;
    List<Map<String, dynamic>>? data = response.fold((_) => null, (r) => r);
    if (data == null || data.isEmpty) {
      return response = Right([]);
    } else {
      List<EvidenceSubmissionModel> submissions =
          data.map((e) => EvidenceSubmissionModel.fromMap(e)).toList();
      return response = Right(submissions);
    }
  }
}
