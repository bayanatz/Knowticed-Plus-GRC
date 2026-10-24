import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/data_sources/policy_data_source.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/repositories/policy_repo.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/policy_firestore.dart';

class PolicyRepoImpl extends PolicyRepo {
  final PolicyDataSource policyDataSource;

  PolicyRepoImpl(this.policyDataSource);

  @override
  Future<Either<Failure, void>> createPolicy(PolicyFirestore policy) async {
    try {
      return Right(await policyDataSource.createPolicy(policy));
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> deletePolicy(PolicyFirestore policy) {
    // TODO: implement deleteModule
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> editPolicy(PolicyFirestore policy) async {
    try {
      return Right(await policyDataSource.editPolicy(policy));
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<PolicyFirestore>>> readALLPolicies() async {
    try {
      return Right(await policyDataSource.readALLPolicies());
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }
}
