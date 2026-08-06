enum AppBarOptions {
  roles,
  userAcess,
  UserManagement,
  English;

  String get icon {
    switch (this) {
      default:
        return 'assets/icons_assets/roles_assets/roles_people_gear.svg';
    }
  }

  String get databaseName {
    switch (this) {
      case AppBarOptions.roles:
        return 'Roles';
      case AppBarOptions.userAcess:
        return 'User_Access';
      case AppBarOptions.UserManagement:
        return 'User_Management';
      case AppBarOptions.English:
        return 'English';
    }
  }
}
