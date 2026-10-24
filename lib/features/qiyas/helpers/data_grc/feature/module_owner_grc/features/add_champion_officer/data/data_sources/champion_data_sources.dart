// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/add_champion_officer/data/modules/champion_module.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/firebase_helper.dart';

abstract class ChampionDataSources {
  Future<void> addChampionOfficer(ChampionFirestore moduleEntity);
  Future<List<ChampionFirestore>> readAllControlChampion();
}

class ChampionDataSourcesImpl extends ChampionDataSources {
  FireBaseHelper<ChampionFirestore> helper;
  ChampionDataSourcesImpl({
    required this.helper,
  });
  @override
  Future<void> addChampionOfficer(ChampionFirestore championEntity) async {
    try {
      return await helper.addItem(championEntity.toMap());
    } on ServerFailure {
      rethrow;
    }
  }

  @override
  Future<List<ChampionFirestore>> readAllControlChampion() async {
    try {
      return await helper.getItems();
    } on ServerFailure {
      rethrow;
    }
  }
}
