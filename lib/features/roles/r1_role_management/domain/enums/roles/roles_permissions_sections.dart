import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_app_module/core/constants/strings.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/role_mangment_permission.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/user_access_permission.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/user_mangment_permission.dart';

import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
import './active_directory_permission.dart';
enum RolePermissionsSections implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  roleManagement,
  userAccess,
  userManagement,
  activeDirectory;

  @override
  String get getName {
    switch (this) {
      case RolePermissionsSections.roleManagement:
        return 'Role Management';
      case RolePermissionsSections.userAccess:
        return 'User Access';
      case RolePermissionsSections.userManagement:
        return 'User Management';
      case RolePermissionsSections.activeDirectory:
        return 'Active Directory';
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case RolePermissionsSections.roleManagement:
        return 'Role_Management_Module';
      case RolePermissionsSections.userAccess:
        return 'User_Access_Module';
      case RolePermissionsSections.userManagement:
        return 'User_Management_Module';
      case RolePermissionsSections.activeDirectory:
        return 'Active_Directory_Module';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case RolePermissionsSections.roleManagement:
        return 'Role Management Module';
      case RolePermissionsSections.userAccess:
        return 'User Access Module';
      case RolePermissionsSections.userManagement:
        return 'User Management Module';
      case RolePermissionsSections.activeDirectory:
        return 'Active Directory Module';
    }
  }

  @override
  bool get isChild {
    switch (this) {
      default:
        return false;
    }
  }

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case RolePermissionsSections.roleManagement:
        return RoleManagement.values;
      case RolePermissionsSections.userAccess:
        return UserAccess.values;
      case RolePermissionsSections.userManagement:
        return UserManagement.values;
      case RolePermissionsSections.activeDirectory:
        return ActiveDirectory.values;
    }
  }

  static List<Enum> get lastColumnValues {
    return [
      userManagement,
      activeDirectory,
    ];
  }

  static List<Enum> get firstColumnValues {
    return [
      roleManagement,
      userAccess,
    ];
  }
}