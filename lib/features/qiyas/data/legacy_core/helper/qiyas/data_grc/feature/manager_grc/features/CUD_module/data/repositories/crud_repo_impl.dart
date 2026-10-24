import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/data/data_sources/crud_data_sources.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/data/modules/module_firestore.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/domain/repositories/crud_repo.dart';

class CrudRepoImpl extends CrudRepo {
  final CrudDataSources crudDataSources;

  CrudRepoImpl(this.crudDataSources);
  @override
  Future<Either<Failure, void>> createModule(
      ModuleFirestore moduleEntity) async {
    try {
      return Right(await crudDataSources.createModule(moduleEntity));
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteModule(
      ModuleFirestore moduleEntity) async {
    try {
      return Right(await crudDataSources.deleteModule(moduleEntity));
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> editModule(ModuleFirestore moduleEntity) async {
    try {
      return Right(await crudDataSources.editModule(moduleEntity));
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<ModuleFirestore>>> readALLModules() async {
    try {
      return Right(await crudDataSources.readALLModules());
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }
}
