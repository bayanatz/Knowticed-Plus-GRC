// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/firebase_helper.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/policy_firestore.dart';

abstract class PolicyDataSource {
  Future<void> createPolicy(PolicyFirestore moduleEntity);
  Future<void> editPolicy(PolicyFirestore moduleEntity);
  Future<void> deletePolicy(PolicyFirestore moduleEntity);
  Future<List<PolicyFirestore>> readALLPolicies();
}

class PolicyDataSourceImpl extends PolicyDataSource {
  FireBaseHelper<PolicyFirestore> helper;
  PolicyDataSourceImpl({
    required this.helper,
  });
  @override
  Future<void> createPolicy(PolicyFirestore policy) async {
    try {
      return await helper.addItem(policy.toMap());
    } on ServerFailure {
      rethrow;
    }
  }

  @override
  Future<void> deletePolicy(PolicyFirestore policy) {
    // TODO: implement deleteModule
    throw UnimplementedError();
  }

  @override
  Future<void> editPolicy(PolicyFirestore policy) async {
    try {
      return await helper.editItem("name", policy.name.last, policy.toMap());
    } on ServerFailure {
      rethrow;
    }
  }

  @override
  Future<List<PolicyFirestore>> readALLPolicies() async {
    try {
      return await helper.getItems();
    } on ServerFailure {
      rethrow;
    }
  }
}
