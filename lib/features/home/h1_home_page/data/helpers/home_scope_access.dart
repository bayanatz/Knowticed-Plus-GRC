/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_scope_access.dart
/// Purpose: Declares `HomeScopeAccess` — which "whose requests" scopes the
///          signed-in role may pick in a home widget's settings (D-242 (5)):
///          a dialog must never reveal more than the module itself.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Services: everyone sees "My requests"; "My department" needs the
/// Department or Admin dashboard permission; "All requests" needs the Admin
/// dashboard permission. Fail-closed: any lookup error leaves "My requests".
library;

import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/dashboard_permissions.dart';

abstract final class HomeScopeAccess {
  const HomeScopeAccess._();

  /// The scopes the signed-in role may choose for a Services widget.
  static Set<HomeWidgetScope> servicesAllowed() {
    final Set<HomeWidgetScope> allowed = <HomeWidgetScope>{
      HomeWidgetScope.mine,
    };
    try {
      final MainCoreEmployeeController access =
          Get.find<MainCoreEmployeeController>();
      final bool admin = access.hasSpecificPermission(Modules.services,
          DashboardPermissions.adminDashboard.getDataBaseName);
      final bool department = access.hasSpecificPermission(Modules.services,
          DashboardPermissions.departmentDashboard.getDataBaseName);
      if (admin || department) allowed.add(HomeWidgetScope.department);
      if (admin) allowed.add(HomeWidgetScope.all);
    } catch (_) {
      // Not signed in yet / controller missing: stay at "My requests".
    }
    return allowed;
  }
}
