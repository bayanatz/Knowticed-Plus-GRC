// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rules_remote_data_source.dart
// Purpose: Firestore data source for delivery fee rules
// Author: Mohand Adel
// Created At: 08/10/2026

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/data/models/crm_delivery_rule_model.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

class CrmDeliveryRulesRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 15);
  final FirebaseFirestore _firestore;

  CrmDeliveryRulesRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<CrmDeliveryRule>> watchRules() async* {
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
        .collection(CrmFirestorePaths.deliveryRules)
        .where('Is_Deleted', isEqualTo: false)
        .snapshots();
    await for (final QuerySnapshot<Map<String, dynamic>> snapshot
        in snapshots) {
      yield snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> document) =>
              CrmDeliveryRuleModel.fromMap(document.data()).rule)
          .where((CrmDeliveryRule item) => !item.isDeleted)
          .toList();
    }
  }

  Future<void> createRule(CrmDeliveryRule rule) async {
    final DocumentReference<Map<String, dynamic>> reference =
        _firestore.collection(CrmFirestorePaths.deliveryRules).doc();
    await reference
        .set(CrmDeliveryRuleModel(rule.copyWith(id: reference.id)).toMap())
        .timeout(_requestTimeout, onTimeout: _saveTimeout);
  }

  Future<void> updateRule(CrmDeliveryRule rule) => _firestore
      .collection(CrmFirestorePaths.deliveryRules)
      .doc(rule.id)
      .update(CrmDeliveryRuleModel(rule).toMap())
      .timeout(_requestTimeout, onTimeout: _saveTimeout);

  Future<void> deleteRule(CrmDeliveryRule rule) => _firestore
      .collection(CrmFirestorePaths.deliveryRules)
      .doc(rule.id)
      .update(CrmDeliveryRuleModel(rule.copyWith(isDeleted: true)).toMap())
      .timeout(_requestTimeout, onTimeout: _saveTimeout);

  static Future<void> _saveTimeout() => Future<void>.error(
        TimeoutException(
          'The delivery rule could not be saved. Check your connection and try again.',
          _requestTimeout,
        ),
      );
}
