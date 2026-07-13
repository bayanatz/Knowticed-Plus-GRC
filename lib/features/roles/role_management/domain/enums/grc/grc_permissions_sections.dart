import 'package:demo_app/features/roles/helper/form_builder_module/core/constants/strings.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/grc/grc_module_permissions.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/form_builder_module/core/constants/strings.dart';
import 'package:demo_app/features/roles/role_management/domain/interfaces/module_permissions_sections.dart';

enum GrcPermissionsSections implements ModulePermissionsSections {
  modulePermissions,
  policyPermissions,
  controlPermissions,
  dashboardsPermissions;

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case GrcPermissionsSections.modulePermissions:
        return GrcModulePermissions.values;
      case GrcPermissionsSections.policyPermissions:
        return GrcModulePermissions.values;
      case GrcPermissionsSections.controlPermissions:
        return GrcModulePermissions.values;
      case GrcPermissionsSections.dashboardsPermissions:
        return GrcModulePermissions.values;

      default:
        return [];
    }
  }

  static List<Enum> get firstColumnValues =>
      [modulePermissions, policyPermissions];
  static List<Enum> get lastColumnValues =>
      [dashboardsPermissions, controlPermissions];

  @override
  String get getName {
    switch (this) {
      case GrcPermissionsSections.modulePermissions:
        return AppConstanstForm.modulePermissions.tr;
      case GrcPermissionsSections.policyPermissions:
        return AppConstanstForm.policyPermissions.tr;
      case GrcPermissionsSections.controlPermissions:
        return AppConstanstForm.controlPermissions.tr;
      case GrcPermissionsSections.dashboardsPermissions:
        return AppConstanstForm.dashboardsPermissions.tr;

      default:
        return '';
    }
  }
}
