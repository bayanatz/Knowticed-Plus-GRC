import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/policy_firestore.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/repositories/policy_repo.dart';

class DeletePolicyUsecase {
  final PolicyRepo repository;

  DeletePolicyUsecase(this.repository);

  Future<Either<Failure, void>> execute(PolicyFirestore params) async {
    return await repository.deletePolicy(params);
  }
}
