import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/domain/repositories/control_owner_repo.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/data/data_sources/control_owner_data_source.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/data/models/control_owner_firestore.dart';

class ControlOwnerRepoImpl extends ControlOwnerRepo {
  final ControlOwnerDataSource controlOwnerDataSource;

  ControlOwnerRepoImpl(this.controlOwnerDataSource);

  @override
  Future<Either<Failure, void>> createControlOwner(
      ControlOwnerFirestore controlOwner) async {
    try {
      return Right(
          await controlOwnerDataSource.createControlOwner(controlOwner));
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<ControlOwnerFirestore>>>
      readALLControlOwners() async {
    try {
      return Right(await controlOwnerDataSource.readALLControlOwners());
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }
}
