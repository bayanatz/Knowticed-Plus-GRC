import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/domain/repositories/champion_repo.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/data/modules/champion_module.dart';

class AddChampionOfficersUsecase {
  final ChampionRepo repository;

  AddChampionOfficersUsecase(this.repository);

  Future<Either<Failure, void>> execute(ChampionFirestore params) async {
    return await repository.addChampionOfficers(params);
  }
}
