// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commissions_remote_data_source.dart
// Purpose: Firestore data source for flat-rate commission packages
// Author: Mohand Adel
// Created At: 08/10/2026

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/data/models/crm_commission_package_model.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

class CrmCommissionsRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 15);
  final FirebaseFirestore _firestore;

  CrmCommissionsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<CrmCommissionPackage>> watchPackages() async* {
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
        .collection(CrmFirestorePaths.commissionPackages)
        .where('Is_Deleted', isEqualTo: false)
        .snapshots();
    await for (final QuerySnapshot<Map<String, dynamic>> snapshot
        in snapshots) {
      yield snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> document) =>
              CrmCommissionPackageModel.fromMap(document.data()).package)
          .where((CrmCommissionPackage item) => !item.isDeleted)
          .toList();
    }
  }

  Future<void> createPackage(CrmCommissionPackage package) async {
    final DocumentReference<Map<String, dynamic>> reference =
        _firestore.collection(CrmFirestorePaths.commissionPackages).doc();
    await reference
        .set(
          CrmCommissionPackageModel(package.copyWith(id: reference.id)).toMap(),
        )
        .timeout(_requestTimeout, onTimeout: _saveTimeout);
  }

  Future<void> updatePackage(CrmCommissionPackage package) => _firestore
      .collection(CrmFirestorePaths.commissionPackages)
      .doc(package.id)
      .update(CrmCommissionPackageModel(package).toMap())
      .timeout(_requestTimeout, onTimeout: _saveTimeout);

  Future<void> deletePackage(CrmCommissionPackage package) => _firestore
      .collection(CrmFirestorePaths.commissionPackages)
      .doc(package.id)
      .update(
          CrmCommissionPackageModel(package.copyWith(isDeleted: true)).toMap())
      .timeout(_requestTimeout, onTimeout: _saveTimeout);

  static Future<void> _saveTimeout() => Future<void>.error(
        TimeoutException(
          'The commission package could not be saved. Check your connection and try again.',
          _requestTimeout,
        ),
      );
}
