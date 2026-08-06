import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_app_module/core/constants/strings.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
enum ApprovalPermissionsServices implements ModulePermissionsSectionsPermission {
  approveAndReject;

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
      case approveAndReject:
        return 'Approve_And_Reject';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case approveAndReject:
        return 'Approve And Reject';
    }
  }
}