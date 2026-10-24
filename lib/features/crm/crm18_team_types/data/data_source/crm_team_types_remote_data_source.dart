// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_types_remote_data_source.dart
// Purpose: Firestore data source for CRM team types
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/data/models/crm_team_type_model.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

/// Performs Firestore operations for the Team Types control.
class CrmTeamTypesRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmTeamTypesRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Streams all records that are not soft-deleted.
  Stream<List<CrmTeamType>> watchTeamTypes() async* {
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
        .collection(CrmFirestorePaths.teamTypes)
        .where('Is_Deleted', isEqualTo: false)
        .snapshots();
    await for (final QuerySnapshot<Map<String, dynamic>> snapshot
        in snapshots) {
      yield snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> document) =>
              CrmTeamTypeModel.fromMap(document.data()).teamType)
          .where((CrmTeamType item) => !item.isDeleted)
          .toList();
    }
  }

  /// Creates a Firestore document for [teamType].
  Future<void> createTeamType(CrmTeamType teamType) async {
    final DocumentReference<Map<String, dynamic>> reference =
        _firestore.collection(CrmFirestorePaths.teamTypes).doc();
    await reference.set(
      CrmTeamTypeModel(teamType.copyWith(id: reference.id)).toMap(),
    );
  }

  /// Persists the current fields for [teamType].
  Future<void> updateTeamType(CrmTeamType teamType) => _firestore
      .collection(CrmFirestorePaths.teamTypes)
      .doc(teamType.id)
      .update(CrmTeamTypeModel(teamType).toMap());

  /// Marks [teamType] as deleted while keeping its audit record.
  Future<void> deleteTeamType(CrmTeamType teamType) => _firestore
      .collection(CrmFirestorePaths.teamTypes)
      .doc(teamType.id)
      .update(CrmTeamTypeModel(teamType.copyWith(isDeleted: true)).toMap());
}
