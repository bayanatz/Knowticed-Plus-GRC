// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reasons_remote_data_source.dart
// Purpose: Firestore data source for CRM client-status reason sets
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/data/models/crm_reason_set_model.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/domain/entities/crm_reason.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

class CrmReasonsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmReasonsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<CrmReason>> watchReasons(String reasonSetId) => _firestore
          .collection(CrmFirestorePaths.reasonSets)
          .doc(reasonSetId)
          .snapshots()
          .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return <CrmReason>[];
        return CrmReasonSetModel.fromMap(snapshot.data()!).reasons;
      });

  Future<void> saveReasons({
    required String reasonSetId,
    required List<CrmReason> reasons,
    required String updatedBy,
  }) =>
      _firestore
          .collection(CrmFirestorePaths.reasonSets)
          .doc(reasonSetId)
          .set(CrmReasonSetModel(reasons: reasons).toMap(updatedBy));
}
