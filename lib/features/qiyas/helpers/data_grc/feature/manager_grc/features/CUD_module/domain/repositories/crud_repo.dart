import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/data/modules/module_firestore.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';

abstract class CrudRepo {
  Future<Either<Failure, void>> createModule(ModuleFirestore moduleEntity);
  Future<Either<Failure, void>> editModule(ModuleFirestore moduleEntity);
  Future<Either<Failure, void>> deleteModule(ModuleFirestore moduleEntity);
  Future<Either<Failure, List<ModuleFirestore>>> readALLModules();
}
