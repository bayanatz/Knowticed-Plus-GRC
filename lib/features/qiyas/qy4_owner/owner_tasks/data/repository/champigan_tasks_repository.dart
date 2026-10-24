import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';

import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_tasks/data/data_source/champigan_tasks_remote_data_source.dart';

class OwnerTasksRepository {
  OwnerTasksRemoteDataSource ownerTasksRemoteDataSource =
      OwnerTasksRemoteDataSource();

  Future<Either<Failure, dynamic>> getTasksStatus({
    required List<String> criteriaNumbers,
    required List<String> evidenceNumber,
  }) async {
    List<EvidenceSubmissionModel?> evidenceSubmissions = [];
    Either<Failure, dynamic> response;
    for (int i = 0; i < criteriaNumbers.length; i++) {
      debugPrint("criteriaNumber: ${criteriaNumbers[i]}");
      debugPrint("evidenceNumber: ${evidenceNumber[i]}");
      response = await ownerTasksRemoteDataSource.getTasksStatus(
        criteriaNumber: criteriaNumbers[i].trim(),
        evidenceNumber: evidenceNumber[i].trim(),
      );
      if (response.isLeft()) return response;
      List<Map<String, dynamic>>? data = response.fold((_) => null, (r) => r);
      if (data == null || data.isEmpty) {
        evidenceSubmissions.add(null);
      } else {
        evidenceSubmissions.add(EvidenceSubmissionModel.fromMap(data.first));
      }
      debugPrint("has evidence: ${evidenceSubmissions[i] != null}");
    }
    return response = Right(evidenceSubmissions);
  }

  Future<Either<Failure, dynamic>> uploadEvidence(
      {required String criteriaNumber,
      required String evidenceNumber,
      required File file,
      required String notes,
      required String championId}) async {
    var response = await ownerTasksRemoteDataSource.uploadEvidenceDocument(
        file.path,
        /* 'Qiyas_Evidence_Submissions/$criteriaNumber/$evidenceNumber'*/ 'Qiyas_Evidence_Submissions');
    /*  if (response.isLeft()) return response;*/
    String fileUrl = response.fold((_) => file.path, (r) => r);

    String fileSize = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
    EvidenceSubmissionModel model = EvidenceSubmissionModel(
      submissionDate: Timestamp.now(),
      submissionStatus: EvidenceSubmissionStatus.submitted,
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
    return await ownerTasksRemoteDataSource.uploadEvidenceSubmission(model);
  }

  Future<Either<Failure, dynamic>> getTaskSubmissions(
      {required String criteriaNumber,
      required String evidenceNumber,
      required String champiganId}) async {
    var response = await ownerTasksRemoteDataSource.getTaskSubmssions(
      criteriaNumber: criteriaNumber,
      evidenceNumber: evidenceNumber,
      champiganId: champiganId.toLowerCase().trim(),
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

  Future<Either<FirebaseFailure, void>> updateTaskStatus(
      {required String submissionId,
      required EvidenceSubmissionStatus status,
      required String ownerId,
      String? rejectNotes}) async {
    return await ownerTasksRemoteDataSource.updateTaskStatus(
      submissionId: submissionId,
      status: status,
      rejectNotes: rejectNotes,
      ownerId: ownerId,
    );
  }
}
