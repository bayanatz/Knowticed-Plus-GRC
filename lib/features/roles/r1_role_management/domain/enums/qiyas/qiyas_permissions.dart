// [module-file:qiyas] — deleted when the qiyas module is split out
import 'package:get/get.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/constants/strings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

enum QiyasPermissions implements ModulePermissionsSectionsPermission {
  bulkUpload,
  editQiyasDetails,
  deleteQiyas,
  visionBadges,
  exportTable,
  assignChampion;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case bulkUpload:
        return 'Bulk_Upload';
      case editQiyasDetails:
        return 'Edit_Qiyas_Details';
      case deleteQiyas:
        return 'Delete_Qiyas';
      case visionBadges:
        return 'Vision_Badges';
      case exportTable:
        return 'Export_Table';
      case assignChampion:
        return 'Assign_Champion';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case bulkUpload:
        return AppConstanstForm.bulkUpload.tr;
      case editQiyasDetails:
        return AppConstanstForm.editQiyasDetails.tr;
      case deleteQiyas:
        return AppConstanstForm.deleteQiyas.tr;
      case visionBadges:
        return AppConstanstForm.visionBadges.tr;
      case exportTable:
        return AppConstanstForm.exportTable.tr;
      case assignChampion:
        return AppConstanstForm.assignChampion.tr;
    }
  }
}
