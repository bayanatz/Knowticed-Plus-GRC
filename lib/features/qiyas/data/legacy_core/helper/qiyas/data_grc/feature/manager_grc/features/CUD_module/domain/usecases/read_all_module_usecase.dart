import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/data/modules/module_firestore.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/domain/repositories/crud_repo.dart';

class ReadAllModuleUsecase {
  final CrudRepo repository;

  ReadAllModuleUsecase(this.repository);

  Future<Either<Failure, List<ModuleFirestore>>> execute() async {
    return await repository.readALLModules();
  }
}
