// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_remote_data_source.dart
// Purpose: Firestore data source for CRM conversion stages
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/data/models/crm_convert_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/domain/entities/crm_convert_stage.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

class CrmConvertRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmConvertRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<CrmConvertStage>> watchStages() async* {
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
        .collection(CrmFirestorePaths.convertStages)
        .where('Is_Deleted', isEqualTo: false)
        .snapshots();
    await for (final QuerySnapshot<Map<String, dynamic>> snapshot
        in snapshots) {
      final List<CrmConvertStage> stages = snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              CrmConvertStageModel.fromMap(doc.data()).stage)
          .where((CrmConvertStage stage) => !stage.isDeleted)
          .toList()
        ..sort((CrmConvertStage first, CrmConvertStage second) =>
            first.order.compareTo(second.order));
      yield stages;
    }
  }

  Future<void> createStage(CrmConvertStage stage) async {
    final DocumentReference<Map<String, dynamic>> reference =
        _firestore.collection(CrmFirestorePaths.convertStages).doc();
    await reference
        .set(CrmConvertStageModel(stage.copyWith(id: reference.id)).toMap());
  }

  Future<void> updateStage(CrmConvertStage stage) async {
    await _firestore
        .collection(CrmFirestorePaths.convertStages)
        .doc(stage.id)
        .update(CrmConvertStageModel(stage).toMap());
  }

  Future<void> deleteStage(CrmConvertStage stage) async {
    await _firestore
        .collection(CrmFirestorePaths.convertStages)
        .doc(stage.id)
        .update(CrmConvertStageModel(stage.copyWith(isDeleted: true)).toMap());
  }
}
