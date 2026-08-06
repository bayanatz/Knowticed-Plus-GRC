import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_app_module/core/constants/strings.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
enum UserAccess implements ModulePermissionsSectionsPermission {
  reactiveUser,
  scheduleToReactivate,
  deactivateUser,
  scheduleToDeactivate,
  unlockUserAccount,
  changeDefaultPassword,
  changeExpirationDate;

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
      case reactiveUser:
        return 'Reactive_User';
      case scheduleToReactivate:
        return 'Schedule_To_Reactivate';
      case deactivateUser:
        return 'Deactivate_User';
      case scheduleToDeactivate:
        return 'Schedule_To_Deactivate';
      case unlockUserAccount:
        return 'Unlock_User_Account';
      case changeDefaultPassword:
        return 'Change_Default_Password';
      case changeExpirationDate:
        return 'Change_Expiration_Date';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case reactiveUser:
        return 'Reactive User';
      case scheduleToReactivate:
        return 'Schedule To Reactivate';
      case deactivateUser:
        return 'Deactivate User';
      case scheduleToDeactivate:
        return 'Schedule To Deactivate';
      case unlockUserAccount:
        return 'Unlock User Account';
      case changeDefaultPassword:
        return 'Change Default Password';
      case changeExpirationDate:
        return 'Change Expiration Date';
    }
  }
}