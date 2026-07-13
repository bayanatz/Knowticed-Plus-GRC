import 'package:demo_app/features/roles/helper/form_builder_module/core/constants/strings.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/form_builder_module/core/constants/strings.dart';
import 'package:demo_app/features/roles/role_management/domain/interfaces/module_permissions_sections_permissions.dart';

enum GrcModulePermissions implements ModulePermissionsSectionsPermission {
  mainModuleDashboard,
  cancelService;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case mainModuleDashboard:
        return 'Main_Module_Dashboard';
      case cancelService:
        return 'Cancel_Service';
     
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case mainModuleDashboard:
        return AppConstanstForm.mainModuleDashboard.tr;
      case cancelService:
        return AppConstanstForm.cancelService.tr;
     
    }
  }
}
