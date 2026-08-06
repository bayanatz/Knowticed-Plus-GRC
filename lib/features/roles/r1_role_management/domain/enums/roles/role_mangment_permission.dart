import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_app_module/core/constants/strings.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
enum RoleManagement implements ModulePermissionsSectionsPermission {
  createRoleManagement,
  editRole,
  deleteRole,
  changeRoleStatus,
  exportRoleData;

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
      case createRoleManagement:
        return 'Create_Role_Management';
      case editRole:
        return 'Edit_Role';
      case deleteRole:
        return 'Delete_Role';
      case changeRoleStatus:
        return 'Change_Role_Status';
      case exportRoleData:
        return 'Export_Role_Data';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createRoleManagement:
        return 'Create Role Management';
      case editRole:
        return 'Edit Role';
      case deleteRole:
        return 'Delete Role';
      case changeRoleStatus:
        return 'Change Role Status';
      case exportRoleData:
        return 'Export Role Data';
    }
  }
}