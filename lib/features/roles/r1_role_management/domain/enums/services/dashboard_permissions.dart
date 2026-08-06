import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_app_module/core/constants/strings.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
enum DashboardPermissions implements ModulePermissionsSectionsPermission {
  adminDashboard,
  departmentDashboard;

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
      case adminDashboard:
        return 'Admin_Dashboard';
      case departmentDashboard:
        return 'Department_Dashboard';
      default:
        return '';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case adminDashboard:
        return 'Admin Dashboard';
      case departmentDashboard:
        return 'Department Dashboard';
      default:
        return '';
    }
  }
}