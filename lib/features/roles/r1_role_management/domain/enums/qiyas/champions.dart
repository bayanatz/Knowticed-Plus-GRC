// [module-file:qiyas] — deleted when the qiyas module is split out
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/constants/strings.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

enum Champions implements ModulePermissionsSectionsPermission {
  editEvidence,
  removeChampion,
  reassignChampion,
  exportChampionTable;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case editEvidence:
        return 'Edit_Evidence';
      case removeChampion:
        return 'Remove_Champion';
      case reassignChampion:
        return 'Reassign_Champion';
      case exportChampionTable:
        return 'Export_Champion_Table';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case editEvidence:
        return AppConstanstForm.editEvidence.tr;
      case removeChampion:
        return AppConstanstForm.removeChampion.tr;
      case reassignChampion:
        return AppConstanstForm.reassignChampion.tr;
      case exportChampionTable:
        return AppConstanstForm.exportChampionTable.tr;
    }
  }
}
