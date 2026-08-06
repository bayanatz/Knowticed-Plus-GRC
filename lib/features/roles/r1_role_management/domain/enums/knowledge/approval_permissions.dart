import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';

enum ApprovalPermissions implements ModulePermissionsSectionsPermission {
  approvedAndRejected,
  approvedOnly;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case approvedAndRejected:
        return 'Approved And Rejected';
      case approvedOnly:
        return 'Approved Only';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case approvedAndRejected:
        return 'Approved And Rejected';
      case approvedOnly:
        return 'Approved Only';
    }
  }
}
