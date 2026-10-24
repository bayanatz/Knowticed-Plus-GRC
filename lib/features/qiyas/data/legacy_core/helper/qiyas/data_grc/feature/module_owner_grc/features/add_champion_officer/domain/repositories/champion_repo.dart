import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/data/modules/champion_module.dart';

abstract class ChampionRepo {
  Future<Either<Failure, void>> addChampionOfficers(
      ChampionFirestore championEntity);
  Future<Either<Failure, List<ChampionFirestore>>> readAllControlChampions();
}
