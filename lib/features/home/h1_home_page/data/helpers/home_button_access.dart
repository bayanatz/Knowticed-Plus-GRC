/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_button_access.dart
/// Purpose: Declares `HomeButtonAccess` — which buttons of a Home action card
///          the signed-in role may see, and which of them the card shows
///          (the gear's "Buttons shown" choice AND the role's permission).
/// Author: Knowticed Plus team
/// Created at: 24/10/2026
///
/// Owner 24/10/2026: every Home card made of buttons has a gear to pick its
/// buttons, and a button the role has no permission for never shows — not on
/// the card and not as a choice in the gear. A module that is not open for the
/// role shows none of its buttons. Fail-closed: any lookup error hides the
/// button.
library;

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form_builder/form_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/messages/messages_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/approval_permission_work.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/request_service_permission.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/service_permissions.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart'; // [module:time_tracker]

abstract final class HomeButtonAccess {
  const HomeButtonAccess._();

  static MainCoreEmployeeController? get _employee {
    try {
      return Get.find<MainCoreEmployeeController>();
    } catch (_) {
      return null;
    }
  }

  /// True when [module] is open for the signed-in role.
  static bool moduleOpen(Modules module) =>
      _employee?.hasModuleAccess(module) ?? false;

  static bool _can(Modules module, String permission) =>
      _employee?.hasSpecificPermission(module, permission) ?? false;

  /// True when the role may use the button [key] of [component].
  static bool allowed(HomeComponents component, String key) {
    try {
      switch (component) {
        case HomeComponents.serviceActions:
          switch (key) {
            case HomeButtonKey.createService:
              return _can(Modules.services,
                  ServicePermissions.createService.getDataBaseName);
            case HomeButtonKey.myRequests:
              return _can(Modules.services,
                  RequestServicePermission.requestService.getDataBaseName);
            case HomeButtonKey.viewApproval:
              return _can(Modules.services,
                  ApprovalPermissionsServices.approveAndReject.getDataBaseName);
          }
        case HomeComponents.formActions:
          switch (key) {
            case HomeButtonKey.createForm:
            case HomeButtonKey.viewDraftForm:
              return _can(Modules.formBuilder,
                  FormPermissions.createNewForm.getDataBaseName);
            case HomeButtonKey.viewRequestedForm:
              return _can(Modules.formBuilder,
                  FormPermissions.fillOutForm.getDataBaseName);
          }
        case HomeComponents.knowledgeHubActions:
          final MainCoreEmployeeController? employee = _employee;
          if (employee == null) return false;
          switch (key) {
            case HomeButtonKey.createHub:
              return employee.isHasPermission(
                module: Modules.knowledgeHub,
                section:
                    KnowledgeHubPermissionsSections.knowledgeHubPermissions,
                permission: KnowledgeHubPermissions.createKnowledgeHub,
              );
            case HomeButtonKey.viewDashboard:
              return employee.isHasPermission(
                module: Modules.knowledgeHub,
                section: KnowledgeHubPermissionsSections.dashboard,
                permission: null,
              );
          }
        case HomeComponents.scheduleMessages:
          switch (key) {
            case HomeButtonKey.forGroup:
              return _can(Modules.messages,
                  MessagesPermissions.createGroup.getDataBaseName);
            case HomeButtonKey.forDirectMessage:
              return moduleOpen(Modules.messages);
          }
        case HomeComponents.inventoryActions:
        case HomeComponents.inventoryNewRequest:
          // Inventory has no per-button permission yet: the module being open
          // is the only gate.
          return moduleOpen(Modules.inventory);
        // [module:time_tracker]
        case HomeComponents.timeTrackerQuickRequests:
        case HomeComponents.timeTrackerQuickApprovals:
          final GetIt sl = GetIt.instance;
          if (!sl.isRegistered<TimeTrackerAccess>()) return false;
          final TimeTrackerAccess access = sl<TimeTrackerAccess>();
          switch (key) {
            case HomeButtonKey.checkInOut:
              return access.canCheckInAndOut;
            case HomeButtonKey.requests:
              return access.canViewRequests;
            case HomeButtonKey.timeTrackerApprovals:
              return access.canViewApprovals;
          }
        // [/module:time_tracker]
        default:
          return false;
      }
    } catch (_) {
      // Not signed in yet / controller missing: show nothing.
    }
    return false;
  }

  /// The buttons of [model] the card draws: the gear's choice (all when never
  /// set), minus every button the role may not use. [all] is the card's own
  /// list of keys, in drawing order.
  static List<String> shown(HomeComponentModel model, List<String> all) {
    final List<String> chosen =
        model.widgetSettings.list(HomeSettingKey.buttons, all);
    return <String>[
      for (final String key in all)
        if (chosen.contains(key) && allowed(model.component, key)) key,
    ];
  }
}
