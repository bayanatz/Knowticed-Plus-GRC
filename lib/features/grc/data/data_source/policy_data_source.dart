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
  Future<PolicyModel> create(PolicyModel model, {required String moduleId});

  Future<PolicyModel?> get(String id, {required String moduleId});

  Future<List<PolicyModel>> getAll({
    required String moduleId,
    bool includeDeleted = false,
  });

  Future<PolicyModel> update(PolicyModel updatedModel, {required String moduleId});

  Future<PolicyModel> delete(
    String id, {
    required String moduleId,
    required String editorId,
  });

  Future<PolicyModel> restore(
    String id, {
    required String moduleId,
    required String editorId,
  });
}