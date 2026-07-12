/// Module: Policy Management
/// Description: Firebase (Cloud Firestore) implementation of the Policy
///              data source. Handles all Firestore read/write operations for
///              Policy documents, including their nested Controls.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: cloud_firestore, PolicyDataSource, PolicyModel
/// Revision History: 2026-07-5 - Initial creation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/features/grc/data/models/policy_model.dart';

import 'policy_data_source.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_firebase_data_source.dart
/// Purpose: Contains the PolicyFirebaseDataSource class, the concrete
///          Cloud Firestore implementation of [PolicyDataSource].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyFirebaseDataSource]
///
/// purpose: implement [PolicyDataSource] using Cloud Firestore as the
///          storage backend. Every document is stored using the keys
///          produced by [PolicyModel.toJson] / [PolicyModel.fromJson],
///          including the nested Controls list-of-lists structure.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
class PolicyFirebaseDataSource implements PolicyDataSource {
  PolicyFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath =>
      '${getBaseUrl('Modules')}/grc/GRC Modules';
  static const String _policiesSubcollectionPath = 'Policies';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_policiesSubcollectionPath);

  @override
  Future<PolicyModel> create(PolicyModel model, {required String moduleId}) async {
    try {
      await _collection(moduleId).doc(model.id).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Policy: $e');
    }
  }

  @override
  Future<PolicyModel?> get(String id, {required String moduleId}) async {
    try {
      final doc = await _collection(moduleId).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return PolicyModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Policy: $e');
    }
  }

  @override
  Future<List<PolicyModel>> getAll({
    required String moduleId,
    bool includeDeleted = false,
  }) async {
    try {
      final snapshot = await _collection(moduleId).get();
      final models =
          snapshot.docs.map((doc) => PolicyModel.fromJson(doc.data()));
      if (includeDeleted) return models.toList();
      return models.where((m) => !m.isDeleted.last).toList();
    } catch (e) {
      throw Exception('Failed to fetch the Policies: $e');
    }
  }

  @override
  Future<PolicyModel> update(PolicyModel updatedModel, {required String moduleId}) async {
    try {
      final docRef = _collection(moduleId).doc(updatedModel.id);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        throw Exception(
          'Cannot update a Policy that does not exist (id: ${updatedModel.id})',
        );
      }
      await docRef.set(updatedModel.toJson());
      return updatedModel;
    } catch (e) {
      throw Exception('Failed to update the Policy: $e');
    }
  }

  @override
  Future<PolicyModel> delete(
    String id, {
    required String moduleId,
    required String editorId,
  }) async {
    try {
      final current = await get(id, moduleId: moduleId);
      if (current == null) {
        throw Exception(
          'Cannot delete a Policy that does not exist (id: $id)',
        );
      }
      final deletedModel = current.copyWithUpdate(
        isDeleted: true,
        editorId: editorId,
      );
      await _collection(moduleId).doc(id).set(deletedModel.toJson());
      return deletedModel;
    } catch (e) {
      throw Exception('Failed to delete the Policy: $e');
    }
  }

  @override
  Future<PolicyModel> restore(
    String id, {
    required String moduleId,
    required String editorId,
  }) async {
    try {
      final current = await get(id, moduleId: moduleId);
      if (current == null) {
        throw Exception(
          'Cannot restore a Policy that does not exist (id: $id)',
        );
      }
      final restoredModel = current.copyWithUpdate(
        isDeleted: false,
        editorId: editorId,
      );
      await _collection(moduleId).doc(id).set(restoredModel.toJson());
      return restoredModel;
    } catch (e) {
      throw Exception('Failed to restore the Policy: $e');
    }
  }
}