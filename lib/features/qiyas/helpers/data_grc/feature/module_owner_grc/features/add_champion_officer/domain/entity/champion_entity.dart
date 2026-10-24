// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:knowticed_plus/core/helper/localized_date.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/enums/enum.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/add_champion_officer/data/modules/champion_module.dart';

class ChamponEntity {
  String timeStamp;
  String moduleId;
  String controlChampion;
  String controls;
  String policies;
  String championStatus;
  String startDate;
  String endDate;
  ChamponEntity({
    required this.timeStamp,
    required this.moduleId,
    required this.controlChampion,
    required this.controls,
    required this.policies,
    required this.championStatus,
    required this.startDate,
    required this.endDate,
  });

  static ChamponEntity championFireBasetoEntity(
      ChampionFirestore championFirestore) {
    return ChamponEntity(
      controlChampion: championFirestore.controlChampion.isNotEmpty
          ? capitalize(championFirestore.controlChampion.last)
          : '',
      championStatus: championFirestore.championStatus.isNotEmpty
          ? capitalize(championFirestore.championStatus.last)
          : '',
      controls: championFirestore.controls.isNotEmpty
          ? capitalize(championFirestore.controls.last)
          : '',
      endDate: championFirestore.endDate.isNotEmpty
          ? capitalize(championFirestore.endDate.last)
          : '',
      moduleId: championFirestore.moduleId.isNotEmpty
          ? championFirestore.moduleId.last
          : '',
      policies: championFirestore.policies.isNotEmpty
          ? capitalize(championFirestore.policies.last)
          : '',
      startDate: championFirestore.startDate.isNotEmpty
          ? capitalize(championFirestore.startDate.last)
          : '',
      timeStamp: championFirestore.timeStamp.isNotEmpty
          ? capitalize(LocalizedDate.forLocale(
              championFirestore.timeStamp.last.toDate(), 'en'))
          : '',
    );
  }
}
