import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/control_firestore.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/repositories/control_repo.dart';

class DeleteControlUsecase {
  final ControlRepo repository;

  DeleteControlUsecase(this.repository);

  Future<Either<Failure, void>> execute(ControlFirestore params) async {
    return await repository.deleteControl(params);
  }
}
