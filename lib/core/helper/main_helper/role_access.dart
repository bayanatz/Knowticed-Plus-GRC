import 'package:grc_module/features/home/h2_nav_bar/utils/model.dart';

/// Shared UI state formerly held by `Mode` in mode_changer.dart.
abstract class RoleAccess {
  /// Controller for the persistent bottom nav bar.
  static PersistentTabController controller =
      PersistentTabController(initialIndex: 0);

  /// Current step in the multi-page "add new employee" flow.
  static int addNewEmployeeIndex = 0;
}
