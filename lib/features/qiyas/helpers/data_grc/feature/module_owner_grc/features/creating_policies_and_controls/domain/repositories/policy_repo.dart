import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/policy_firestore.dart';

abstract class PolicyRepo {
  Future<Either<Failure, void>> createPolicy(PolicyFirestore moduleEntity);
  Future<Either<Failure, void>> editPolicy(PolicyFirestore moduleEntity);
  Future<Either<Failure, void>> deletePolicy(PolicyFirestore moduleEntity);
  Future<Either<Failure, List<PolicyFirestore>>> readALLPolicies();
}
