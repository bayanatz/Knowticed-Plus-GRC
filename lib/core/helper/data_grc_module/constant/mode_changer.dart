import 'package:demo_app/core/helper/data_grc_module/feature/nav_bar_package.dart/model.dart';

class Mode {
  static bool showInvoice = false;
  static bool freelancer = false;
  static bool hr = false;
  static bool owner = false;

  static bool admin = false;
  static bool manager = false;
  static bool employee = false;
  static bool champion = false;
  static bool departmentManager = false;
  static int addNewEmployeeIndex = 0;
  static int signUpindex = 0;
  static PersistentTabController controller =
      PersistentTabController(initialIndex: 0);
  /*
               then change the value of the freelancer or Cliet in the card screen and services screen
               */
}

class ModeChat {
  static bool chatIndex = false;
  static PersistentTabController controller =
      PersistentTabController(initialIndex: 0);
  /*
               then change the value of the freelancer or Cliet in the card screen and services screen
               */
}
