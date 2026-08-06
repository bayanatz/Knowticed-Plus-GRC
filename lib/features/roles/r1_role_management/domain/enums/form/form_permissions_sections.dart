import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_app_module/core/constants/strings.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';

import './form_permissions.dart';
import './results_permissions.dart';
enum FormPermissionsSections implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  formPermissions,
  resultsPermissions,
  createGroupPermissions;

  @override
  String get getName {
    switch (this) {
      case FormPermissionsSections.formPermissions:
        return 'Form Permissions';
      case FormPermissionsSections.resultsPermissions:
        return 'Results Permissions';
      case FormPermissionsSections.createGroupPermissions:
        return 'Create Group Permissions';
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case FormPermissionsSections.formPermissions:
        return 'Form_Permissions_Module';
      case FormPermissionsSections.resultsPermissions:
        return 'Results_Permissions_Module';
      case FormPermissionsSections.createGroupPermissions:
        return 'Create_Group_Permissions_Module';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case FormPermissionsSections.formPermissions:
        return 'Form Permissions Module';
      case FormPermissionsSections.resultsPermissions:
        return 'Results Permissions Module';
      case FormPermissionsSections.createGroupPermissions:
        return 'Create Group Permissions Module';
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
      case FormPermissionsSections.formPermissions:
        return FormPermissions.values;
      case FormPermissionsSections.resultsPermissions:
        return ResultsPermissions.values;
      case FormPermissionsSections.createGroupPermissions:
        return [];
    }
  }

  static List<Enum> get firstColumnValues {
    return [
      formPermissions,
    ];
  }

  static List<Enum> get lastColumnValues {
    return [
      resultsPermissions,
      createGroupPermissions,
    ];
  }
}