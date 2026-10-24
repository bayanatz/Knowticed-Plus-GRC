/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: app_bar_enum.dart
/// Purpose: Enum `AppBarOptions` used by this feature.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

enum AppBarOptions {
  roles,
  userAcess,
  userManagement,
  english;

  String get icon {
    switch (this) {
      default:
        return 'assets/icons_assets/main_icons_assets/ic_module_roles.svg';
    }
  }

  String get databaseName {
    switch (this) {
      case AppBarOptions.roles:
        return 'Roles';
      case AppBarOptions.userAcess:
        return 'User_Access';
      case AppBarOptions.userManagement:
        return 'User_Management';
      case AppBarOptions.english:
        return 'English';
    }
  }
}
