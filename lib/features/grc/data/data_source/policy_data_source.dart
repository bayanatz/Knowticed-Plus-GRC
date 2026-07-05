/// Module: Policy Management
/// Description: Defines the data source contract for Policy CRUD operations,
///              independent of any specific backend implementation.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-5
/// Dependencies: PolicyModel
/// Revision History: 2026-07-5 - Initial creation

import 'package:demo_app/features/grc/data/models/policy_model.dart';


/// ************************* FILE INFO *************************** ///
/// File Name: policy_data_source.dart
/// Purpose: Contains the PolicyDataSource abstract class (interface) that
///          any concrete data source implementation must follow.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026

/// class name: [PolicyDataSource]
///
/// purpose: define the contract that any concrete implementation (Firebase,
///          REST API, local database, etc.) must follow to provide
///          create/read/update/soft-delete/restore operations for Policy
///          records, including their nested Controls.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 5/7/2026
abstract class PolicyDataSource {
  /// function name: [create]
  ///
  /// purpose: persist a brand new Policy record (first revision, where every
  ///          history List starts with a single element and every nested
  ///          Control starts with its own single-element Lists).
  ///
  /// parameters:
  ///            [PolicyModel] model: the policy model instance to be created
  ///
  /// return type: [Future<PolicyModel>] - the created model instance, or throws an Exception on failure
  Future<PolicyModel> create(PolicyModel model);

  /// function name: [get]
  ///
  /// purpose: fetch a single Policy record, including its full revision
  ///          history and all nested Controls, by its unique id.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to fetch
  ///
  /// return type: [Future<PolicyModel?>] - the matching model, null if not found, or throws an Exception on failure
  Future<PolicyModel?> get(String id);

  /// function name: [getAll]
  ///
  /// purpose: fetch Policy records currently stored in the data source.
  ///
  /// parameters:
  ///            [bool] includeDeleted: when false (default), soft-deleted
  ///            policies (latest revision has isDeleted = true) are excluded
  ///
  /// return type: [Future<List<PolicyModel>>] - the list of matching model instances, or throws an Exception on failure
  Future<List<PolicyModel>> getAll({bool includeDeleted = false});

  /// function name: [update]
  ///
  /// purpose: persist an updated Policy record. The caller is expected to
  ///          have already produced [updatedModel] via
  ///          [PolicyModel.copyWithUpdate] so every history List already
  ///          contains the new revision before this method is called.
  ///
  /// parameters:
  ///            [PolicyModel] updatedModel: the model instance with the new revision appended
  ///
  /// return type: [Future<PolicyModel>] - the persisted updated model instance, or throws an Exception on failure
  Future<PolicyModel> update(PolicyModel updatedModel);

  /// function name: [delete]
  ///
  /// purpose: soft-delete a Policy record. The document is NOT physically
  ///          removed; instead a new revision is appended with isDeleted = true
  ///          so the full history and the ability to restore are preserved.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to soft-delete
  ///            [String] editorId: id of the user performing the delete
  ///
  /// return type: [Future<PolicyModel>] - the model after the delete revision has been appended, or throws an Exception on failure
  Future<PolicyModel> delete(String id, {required String editorId});

  /// function name: [restore]
  ///
  /// purpose: restore a previously soft-deleted Policy record by appending
  ///          a new revision with isDeleted = false.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the policy to restore
  ///            [String] editorId: id of the user performing the restore
  ///
  /// return type: [Future<PolicyModel>] - the model after the restore revision has been appended, or throws an Exception on failure
  Future<PolicyModel> restore(String id, {required String editorId});
}