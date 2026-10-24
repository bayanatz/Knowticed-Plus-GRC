import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/data/models/control_owner_firestore.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/domain/repositories/control_owner_repo.dart';

class ReadAllControlOwnerUsecase {
  final ControlOwnerRepo repository;

  ReadAllControlOwnerUsecase(this.repository);

  Future<Either<Failure, List<ControlOwnerFirestore>>> execute() async {
    return await repository.readALLControlOwners();
  }
}
