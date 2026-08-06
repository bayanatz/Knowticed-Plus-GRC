import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_app_module/core/constants/strings.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
enum RequestServicesModule implements ModulePermissionsSectionsPermission {
  statusRequested;

  @override
  bool get isChild {
    switch (this) {
      default:
        return false;
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case statusRequested:
        return 'Status_Requested';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case statusRequested:
        return 'Status Requested';
    }
  }
}