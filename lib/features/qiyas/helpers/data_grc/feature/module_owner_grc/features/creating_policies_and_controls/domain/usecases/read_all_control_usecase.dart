import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/control_firestore.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/repositories/control_repo.dart';

class ReadAllControlUsecase {
  final ControlRepo repository;

  ReadAllControlUsecase(this.repository);

  Future<Either<Failure, List<ControlFirestore>>> execute() async {
    return await repository.readALLControls();
  }
}
