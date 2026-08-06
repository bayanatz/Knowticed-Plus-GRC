/******************** FILE INFO ********************/
/// File Name: settings_permissions.dart
/// Purpose: Enum for Settings Permissions in the application
/// Created by: Mohamed Elrashidy
/// Created on: 3/9/2025
/// Updated: Added debug logging to find translation issue
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_app_module/core/constants/strings.dart';

import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
enum SettingsPermissions implements ModulePermissionsSectionsPermission {
  takeScreenShot,
  restrictedLocation,
  companyInformation,
  animation,
  biometricsForLogin,
  branding,
  screenShare;

  @override
  String get getDataBaseName {
    switch (this) {
      case takeScreenShot:
        return 'Take_Screen_Shot';

      case biometricsForLogin:
        return 'Biometrics_For_Login';

      case restrictedLocation:
        return 'Restricted_Location';

      case companyInformation:
        return 'Company_Information';

      case animation:
        return 'Animation';

      case branding:
        return 'Branding';

      case screenShare:
        return 'Screen_Share';
    }
  }

  @override
  String get getUiName {
    String result;

    switch (this) {
      case takeScreenShot:
        result = 'Take Screen Shot';
        break;

      case biometricsForLogin:
        result = 'Biometrics For Login';
        break;

      case restrictedLocation:
        result = 'Restricted Location';
        break;

      case companyInformation:
        result = 'Company Information';
        break;

      case animation:
        result = 'Animation';
        break;

      case branding:
        result = 'Branding';
        break;

      case screenShare:
        result = 'Screen Share';
        break;
    }

    return result;
  }

  @override
  bool get isChild {
    return false;
  }
}