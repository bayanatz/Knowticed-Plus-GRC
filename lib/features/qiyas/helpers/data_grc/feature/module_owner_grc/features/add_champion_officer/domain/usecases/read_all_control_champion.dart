import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/add_champion_officer/domain/repositories/champion_repo.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/add_champion_officer/data/modules/champion_module.dart';

class ReadAllControlChampionUsecase {
  final ChampionRepo repository;

  ReadAllControlChampionUsecase(this.repository);

  Future<Either<Failure, List<ChampionFirestore>>> execute() async {
    return await repository.readAllControlChampions();
  }
}
