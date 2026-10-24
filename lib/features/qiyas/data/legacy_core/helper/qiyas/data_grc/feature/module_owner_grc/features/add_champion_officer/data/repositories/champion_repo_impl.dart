import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/data/modules/champion_module.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/domain/repositories/champion_repo.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/data/data_sources/champion_data_sources.dart';

class ChampionRepoImpl extends ChampionRepo {
  final ChampionDataSources championDataSources;

  ChampionRepoImpl(this.championDataSources);

  @override
  Future<Either<Failure, void>> addChampionOfficers(
      ChampionFirestore championEntity) async {
    try {
      return Right(
          await championDataSources.addChampionOfficer(championEntity));
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<ChampionFirestore>>>
      readAllControlChampions() async {
    try {
      return Right(await championDataSources.readAllControlChampion());
    } on ServerFailure catch (e) {
      return Left(e);
    }
  }
}
