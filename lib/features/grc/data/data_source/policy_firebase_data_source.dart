/// Module: Policy Management
/// Description: Firebase (Cloud Firestore) implementation of the Policy
///              data source. Handles all Firestore read/write operations for
///              Policy documents, including their nested Controls.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: cloud_firestore, PolicyDataSource, PolicyModel
/// Revision History: 2026-07-5 - Initial creation

import 'package:cloud_firestore/cloud_firestore.dart';
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

  static const String _collectionPath = 'Policies';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionPath);

  // ------------------------------------------------------------------
  // CREATE
  // ------------------------------------------------------------------

  /// function name: [create]
  ///
  /// purpose: write a brand new Policy document to Firestore, using the
  ///          model's id as the document id.
  ///
  /// parameters:
  ///            [PolicyModel] model: the policy model instance to be created
  ///
  /// return type: [Future<PolicyModel>] - the created model instance, or throws an Exception on failure
  @override
  Future<PolicyModel> create(PolicyModel model) async {
    try {
      await _collection.doc(model.id).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Policy: $e');
    }
  }

  // ------------------------------------------------------------------
  // GET (single)
  // ------------------------------------------------------------------

  /// function name: [get]
  ///
  /// purpose: fetch a single Policy document from Firestore by its id,
  ///          deserializing the full revision history including nested
  ///          Controls.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to fetch
  ///
  /// return type: [Future<PolicyModel?>] - the matching model, null if not found, or throws an Exception on failure
  @override
  Future<PolicyModel?> get(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return PolicyModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Policy: $e');
    }
  }

  // ------------------------------------------------------------------
  // GET ALL
  // ------------------------------------------------------------------

  /// function name: [getAll]
  ///
  /// purpose: fetch all Policy documents stored in the collection, with an
  ///          optional filter to exclude soft-deleted records.
  ///
  /// parameters:
  ///            [bool] includeDeleted: when false (default), soft-deleted
  ///            policies (latest revision has isDeleted = true) are excluded
  ///
  /// return type: [Future<List<PolicyModel>>] - the list of matching model instances, or throws an Exception on failure
  @override
  Future<List<PolicyModel>> getAll({bool includeDeleted = false}) async {
    try {
      final snapshot = await _collection.get();
      final models =
          snapshot.docs.map((doc) => PolicyModel.fromJson(doc.data()));
      if (includeDeleted) return models.toList();
      return models.where((m) => !m.isDeleted.last).toList();
    } catch (e) {
      throw Exception('Failed to fetch the Policies: $e');
    }
  }

  // ------------------------------------------------------------------
  // UPDATE
  // ------------------------------------------------------------------

  /// function name: [update]
  ///
  /// purpose: overwrite an existing Policy document with [updatedModel],
  ///          which is expected to already contain the newly appended
  ///          revision (produced via [PolicyModel.copyWithUpdate]).
  ///
  /// parameters:
  ///            [PolicyModel] updatedModel: the model instance with the new revision appended
  ///
  /// return type: [Future<PolicyModel>] - the persisted updated model, or throws an Exception if not found or write fails
  @override
  Future<PolicyModel> update(PolicyModel updatedModel) async {
    try {
      final docRef = _collection.doc(updatedModel.id);
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

  // ------------------------------------------------------------------
  // DELETE  (soft)
  // ------------------------------------------------------------------

  /// function name: [delete]
  ///
  /// purpose: soft-delete a Policy document by reading the current record,
  ///          appending a new revision via [PolicyModel.copyWithUpdate] with
  ///          isDeleted = true, then overwriting the document. The document
  ///          stays in Firestore so it can be restored later.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to soft-delete
  ///            [String] editorId: id of the user performing the delete
  ///
  /// return type: [Future<PolicyModel>] - the model after the delete revision, or throws an Exception on failure
  @override
  Future<PolicyModel> delete(String id, {required String editorId}) async {
    try {
      final current = await get(id);
      if (current == null) {
        throw Exception(
          'Cannot delete a Policy that does not exist (id: $id)',
        );
      }
      final deletedModel = current.copyWithUpdate(
        isDeleted: true,
        editorId: editorId,
      );
      await _collection.doc(id).set(deletedModel.toJson());
      return deletedModel;
    } catch (e) {
      throw Exception('Failed to delete the Policy: $e');
    }
  }

  // ------------------------------------------------------------------
  // RESTORE
  // ------------------------------------------------------------------

  /// function name: [restore]
  ///
  /// purpose: restore a previously soft-deleted Policy document by reading
  ///          the current record, appending a new revision with
  ///          isDeleted = false, then overwriting the document.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to restore
  ///            [String] editorId: id of the user performing the restore
  ///
  /// return type: [Future<PolicyModel>] - the model after the restore revision, or throws an Exception on failure
  @override
  Future<PolicyModel> restore(String id, {required String editorId}) async {
    try {
      final current = await get(id);
      if (current == null) {
        throw Exception(
          'Cannot restore a Policy that does not exist (id: $id)',
        );
      }
      final restoredModel = current.copyWithUpdate(
        isDeleted: false,
        editorId: editorId,
      );
      await _collection.doc(id).set(restoredModel.toJson());
      return restoredModel;
    } catch (e) {
      throw Exception('Failed to restore the Policy: $e');
    }
  }
}