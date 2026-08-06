import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_app_module/core/constants/strings.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
enum RequestServicePermission implements ModulePermissionsSectionsPermission {
  requestService,
  cancelService;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case requestService:
        return 'Request_Service';
      case cancelService:
        return 'Cancel_Service';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case requestService:
        return 'Request Service';
      case cancelService:
        return 'Cancel Service';
    }
  }
}