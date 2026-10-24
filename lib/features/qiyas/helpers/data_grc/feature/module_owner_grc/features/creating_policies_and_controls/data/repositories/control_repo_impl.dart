import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/data_sources/control_data_source.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/repositories/control_repo.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/control_firestore.dart';

class ControlRepoImpl extends ControlRepo {
  final ControlDataSource controlDataSource;

  ControlRepoImpl(this.controlDataSource);

  @override
  Future<Either<Failure, void>> createControl(ControlFirestore control) async {
    try {
      return Right(await controlDataSource.createControl(control));
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteControl(ControlFirestore control) {
    // TODO: implement deleteModule
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> editControl(ControlFirestore control) async {
    try {
      return Right(await controlDataSource.editControl(control));
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<ControlFirestore>>> readALLControls() async {
    try {
      return Right(await controlDataSource.readALLControls());
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }
}
