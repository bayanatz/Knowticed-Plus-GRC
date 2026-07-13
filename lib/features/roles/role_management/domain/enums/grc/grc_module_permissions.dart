import 'package:demo_app/features/roles/helper/form_builder_module/core/constants/strings.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/form_builder_module/core/constants/strings.dart';
import 'package:demo_app/features/roles/role_management/domain/interfaces/module_permissions_sections_permissions.dart';

enum GrcModulePermissions implements ModulePermissionsSectionsPermission {
  createModule,
  editModule,
  changeStatusOfModule,
  deleteModule,
  restoreModule,
  previousModuleOwnerHistory,
  showComplianceScore;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case createModule:
        return 'Create_Module';
      case editModule:
        return 'Edit_Module';
      case changeStatusOfModule:
        return 'Change_Status_Of_Module';
      case deleteModule:
        return 'Delete_Module';
      case restoreModule:
        return 'Restore_Module';
      case previousModuleOwnerHistory:
        return 'Previous_Module_Owner_History';
      case showComplianceScore:
        return 'Show_Compliance_Score';
      
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createModule:
        return AppConstanstForm.createModule.tr;
      case editModule:
        return AppConstanstForm.editModule.tr;
      case changeStatusOfModule:
        return AppConstanstForm.changeStatusOfModule.tr;
      case deleteModule:
        return AppConstanstForm.deleteModule.tr;
      case restoreModule:
        return AppConstanstForm.restoreModule.tr;
      case previousModuleOwnerHistory:
        return AppConstanstForm.previousModuleOwnerHistory.tr;
      case showComplianceScore:
        return AppConstanstForm.showComplianceScore.tr;
    }
  }
}

      