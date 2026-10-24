import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/domain/repositories/crud_repo.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/data/modules/module_firestore.dart';

class EditModuleUsecase {
  final CrudRepo repository;

  EditModuleUsecase(this.repository);

  Future<Either<Failure, void>> execute(ModuleFirestore params) async {
    return await repository.editModule(params);
  }
}
