import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/module_page_stubs.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:grc_module/features/grc/module/presentation/ui/pages/grc_page.dart';

// REMOVED_MODULE: import 'package:grc_module/features/external/database_builder/database_builder_responsive_page.dart';
import 'package:grc_module/features/home/main_controller/helper/home_layout_helper.dart';
import 'package:grc_module/features/messaging/m4_messaging_home/presentation/ui/pages/home_layout_helper.dart';
// REMOVED_MODULE: import 'package:grc_module/features/services_mangment_module/responsive_services.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';

// REMOVED_MODULE: import'package:grc_module/features/external/services_app_module/core/configs/extensions/extensions.dart';
// REMOVED_MODULE: import'package:grc_module/features/external/services_app_module/core/routes/app_routes.dart';
// REMOVED_MODULE: import'package:grc_module/features/external/services_app_module/core/routes/get_pages.dart';
// REMOVED_MODULE: import'package:grc_module/features/external/services_app_module/core/services/form_navigator_service.dart';
// REMOVED_MODULE: import'package:grc_module/features/roles/database_builder/database_responsive_page.dart';


// REMOVED_MODULE: import'package:grc_module/features/roles/inventory_module/inventory_responsive_page.dart';
// REMOVED_MODULE: import'package:grc_module/features/roles/knowledge_hub_module/knowledge_hub_responsive_page.dart';
// REMOVED_MODULE: import'package:grc_module/features/external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s1_create_service/home_services/home_page_services_toggle.dart';

// REMOVED_MODULE: import'package:grc_module/features/external/todo_module/todo_responsive_page.dart';
// REMOVED_MODULE: import'package:grc_module/features/roles/todo_new_module/todo_responsive_page.dart';

// REMOVED_MODULE: import'package:grc_module/features/external/tracking_module/tracking_responsive_page.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/pages/home_responsive_page.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/ui/pages/more_page.dart';
import 'package:grc_module/features/notification/presentation/ui/pages/notification_control.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/pages/role_screen.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';


// ✅ DECLARE GLOBAL KEYS OUTSIDE THE ENUM (at file level)
// This ensures only ONE instance of each key exists
GlobalKey? servicesKey;
GlobalKey? trackerAppKey;
GlobalKey? grcNavKey;

enum Modules {
  home,
  tasks,
  employees,
  messages,
  inventory,
  roles,
  services,
  todo,
  requests,
  grc,
  events,
  notes,
  tracking,
  knowledgeHub,
  qiyas,
  database,
  formBuilder,
  settings,
  hr,           // ✅ ADDED
  crm,          // ✅ ADDED
  notification, // ✅ ADDED
  more;

  String get iconPath {
    switch (this) {
      case Modules.home:
        return 'assets/icons_assets/roles_assets/home.svg';
      case Modules.tasks:
        return 'assets/icons_assets/home_assets/todo_checklist_clipboard.svg';
      case Modules.employees:
        return 'assets/icons_assets/roles_assets/organization_chart_tree.svg';
      case Modules.messages:
        return 'assets/icons_assets/roles_assets/chat_messages_bubbles.svg';
      case Modules.inventory:
        return 'assets/icons_assets/roles_assets/inventory_warehouse.svg';
      case Modules.roles:
        return 'assets/icons_assets/roles_assets/roles_people_gear.svg';
      case Modules.services:
        return 'assets/icons_assets/services_assets/headset_support.svg';
      case Modules.todo:
        return 'assets/icons_assets/roles_assets/todo_list_document.svg';
      case Modules.grc:
        return 'assets/icons_assets/roles_assets/governance_gavel_warning.svg';
      case Modules.requests:
        return 'assets/icons_assets/main_icons_assets/doc_file_blue.svg';
      case Modules.events:
        return 'assets/icons_assets/home_assets/calendar_event_star_white.svg';
      case Modules.notes:
        return 'assets/icons_assets/home_assets/quotation_marks.svg';
      case Modules.tracking:
        return 'assets/icons_assets/roles_assets/time_tracking_dashed_clock.svg';
      case Modules.knowledgeHub:
        return 'assets/icons_assets/roles_assets/knowledge_book_idea.svg';
      case Modules.qiyas:
        return 'assets/icons_assets/roles_assets/governance_gavel_warning.svg';
      case Modules.formBuilder:
        return 'assets/icons_assets/roles_assets/form_document.svg';
      case Modules.database:
        return 'assets/icons_assets/main_icons_assets/hierarchy_nodes.svg';
      case Modules.settings:
        return 'assets/icons_assets/roles_assets/settings_gear.svg';
      case Modules.hr:  // ✅ ADDED
        return 'assets/icons_assets/roles_assets/hr_desk.svg';
      case Modules.crm:  // ✅ ADDED — TODO: replace with CRM icon
        return 'assets/icons_assets/roles_assets/team_gear_people.svg';
      case Modules.notification:  // ✅ ADDED
        return 'assets/icons_assets/main_icons_assets/notification_bell.svg';
      case Modules.more:
        return 'assets/icons_assets/roles_assets/menu_lines_bold.svg';
      default:
        return 'home';
    }
  }

  String get iconPathRole {
    switch (this) {
      case Modules.home:
        return 'assets/icons_assets/roles_assets/home.svg';
      case Modules.tasks:
        return 'assets/icons_assets/home_assets/todo_checklist_clipboard.svg';
      case Modules.employees:
        return 'assets/icons_assets/roles_assets/organization_chart_tree.svg';
      case Modules.messages:
        return 'assets/icons_assets/roles_assets/chat_messages_bubbles.svg';
      case Modules.inventory:
        return 'assets/icons_assets/roles_assets/inventory_warehouse.svg';
      case Modules.roles:
        return 'assets/icons_assets/roles_assets/roles_people_gear.svg';
      case Modules.services:
        return 'assets/icons_assets/services_assets/headset_support.svg';
      case Modules.todo:
        return 'assets/icons_assets/roles_assets/todo_list_document.svg';
      case Modules.requests:
        return 'assets/icons_assets/main_icons_assets/doc_file_blue.svg';
      case Modules.events:
        return 'assets/icons_assets/home_assets/calendar_event_star_white.svg';
      case Modules.notes:
        return 'assets/icons_assets/home_assets/quotation_marks.svg';
      case Modules.tracking:
        return 'assets/icons_assets/roles_assets/time_tracking_dashed_clock.svg';
      case Modules.knowledgeHub:
        return 'assets/icons_assets/roles_assets/knowledge_book_idea.svg';
      case Modules.qiyas:
        return 'assets/icons_assets/roles_assets/analytics_chart_cycle.svg';
      case Modules.grc:
        return 'assets/icons_assets/roles_assets/governance_gavel_warning.svg';
      case Modules.formBuilder:
        return 'assets/icons_assets/roles_assets/form_document.svg';
      case Modules.database:
        return 'assets/icons_assets/main_icons_assets/hierarchy_nodes.svg';
      case Modules.settings:
        return 'assets/icons_assets/roles_assets/settings_gear.svg';
      case Modules.hr:  // ✅ ADDED
        return 'assets/icons_assets/roles_assets/hr_desk.svg';
      case Modules.crm:  // ✅ ADDED — TODO: replace with CRM icon
        return 'assets/icons_assets/roles_assets/team_gear_people.svg';
      case Modules.notification:  // ✅ ADDED
        return 'assets/icons_assets/main_icons_assets/notification_bell.svg';
      case Modules.more:
        return 'assets/icons_assets/roles_assets/menu_lines_bold.svg';
      default:
        return 'home';
    }
  }

  String get getModuleName {
    switch (this) {
      case Modules.home:
        return Get.locale.toString().contains('ar') ? 'الرئيسية' : 'Home';
      case Modules.employees:
        return Get.locale.toString().contains('ar') ? 'الموظفين' : 'Org Chart';
      case Modules.services:
        return Get.locale.toString().contains('ar') ? 'الخدمات' : 'Services';
      case Modules.tasks:
        return Get.locale.toString().contains('ar') ? 'المهام' : 'Tasks';
      case Modules.todo:
        return Get.locale.toString().contains('ar') ? 'قائمة المهام' : 'Todo';
      case Modules.events:
        return Get.locale.toString().contains('ar') ? 'الأحداث' : 'Events';
      case Modules.notes:
        return Get.locale.toString().contains('ar') ? 'الملاحظات' : 'Notes';
      case Modules.grc:
        return Get.locale.toString().contains('ar') ? ' الحوكمة و المخاطر و الآلتزام' : 'GRC';
      case Modules.requests:
        return Get.locale.toString().contains('ar') ? 'الطلبات' : 'Requests';
      case Modules.knowledgeHub:
        return Get.locale.toString().contains('ar') ? 'مركز المعرفة' : 'Knowledge Hub';
      case Modules.qiyas:
        return Get.locale.toString().contains('ar') ? 'قياس' : 'Qiyas';
      case Modules.tracking:
        return Get.locale.toString().contains('ar') ? 'التتبع' : 'Tracking';
      case Modules.inventory:
        return Get.locale.toString().contains('ar') ? 'المخزون' : 'Inventory';
      case Modules.messages:
        return Get.locale.toString().contains('ar') ? 'الرسائل' : 'Messages';
      case Modules.database:
        return Get.locale.toString().contains('ar') ? 'قاعدة البيانات' : 'Database';
      case Modules.formBuilder:
        return Get.locale.toString().contains('ar') ? 'منشئ النماذج' : 'Form Builder';
      case Modules.roles:
        return Get.locale.toString().contains('ar') ? 'الأدوار' : 'Roles';
      case Modules.settings:
        return Get.locale.toString().contains('ar') ? 'الإعدادات' : 'Settings';
      case Modules.hr:  // ✅ ADDED
        return Get.locale.toString().contains('ar') ? 'الموارد البشرية' : 'HR';
      case Modules.crm:  // ✅ ADDED
        return Get.locale.toString().contains('ar') ? 'إدارة علاقات العملاء' : 'CRM';
      case Modules.notification:  // ✅ ADDED
        return Get.locale.toString().contains('ar') ? 'الإشعارات' : 'Notification';
      case Modules.more:
        return Get.locale.toString().contains('ar') ? 'المزيد' : 'More';
      default:
        return name;
    }
  }

  Widget get widget {
    switch (this) {
      case Modules.home:
        return HomeResponsivePage();
      case Modules.tasks:
        return TasksResponsivePage();
      case Modules.employees:
        return Container();
      case Modules.tracking:
        return TrackerPageResponsivePageRefactor();
      case Modules.inventory:
        return Container();
      case Modules.grc:
        return GrcResponsivePageLayout();
      case Modules.roles:
        // RoleScreen is used for every form factor, so no responsive split is
        // needed here — it only requires these three cubits to be in scope.
        return BlocProvider<UserAccessCubit>.value(
          value: accountStatusCubit,
          child: BlocProvider<UserManagementAccessCubit>.value(
            value: userManagementCubit,
            child: BlocProvider<RoleCubit>.value(
              value: roleCubit,
              // RoleScreenHost wraps RoleScreen in a nested Navigator so that
              // pushes inside the module (AddingNewRole, RoleDetailsPage, ...)
              // render inside the app shell instead of covering it.
              child: RoleScreenHost(),
            ),
          ),
        );

      case Modules.services:
        if (servicesKey == null) {
          servicesKey = GlobalKey();
        }
        return Container();

      case Modules.todo:
        return Container();
      case Modules.database:
        return Container();
      case Modules.messages:
        return HomePageHelperLayout();

      case Modules.formBuilder:
        return Container();

      case Modules.tracking:
        if (trackerAppKey == null) {
          trackerAppKey = GlobalKey();
        }
        return TrackerPageResponsivePageRefactor();

      case Modules.knowledgeHub:
        return Container();
      case Modules.settings:
        return SettingsScreen();
      case Modules.more:
        return MorePage();

      case Modules.qiyas:
        if (grcNavKey == null) {
          grcNavKey = GlobalKey();
        } else {
        }
        return GrcResponsivePage();

    // ✅ ADDED: HR Module
      case Modules.hr:
        return Container();  // TODO: Create this page

    // ✅ ADDED: CRM Module
      case Modules.crm:
        return Container();  // TODO: Create this page

    // ✅ ADDED: Notification Module
      case Modules.notification:
        return NotificationControlPage();  // TODO: Create this page

      default:
        return Scaffold();
    }
  }

  List<Enum> get moduleFirstColumnPermissions {
    switch (this) {
      case Modules.services:
        return ServicePermissionsSections.firstColumnValues;
      case Modules.formBuilder:
        return FormPermissionsSections.firstColumnValues;
      case Modules.settings:
        return SettingsPermissionsSections.firstColumnValues;
      case Modules.roles:
        return RolePermissionsSections.firstColumnValues;
      default:
        return [];
    }
  }

  List<Enum> get moduleLastColumnPermissions {
    switch (this) {
      case Modules.services:
        return ServicePermissionsSections.lastColumnValues;
      case Modules.formBuilder:
        return FormPermissionsSections.lastColumnValues;
      case Modules.settings:
        return SettingsPermissionsSections.lastColumnValues;
      case Modules.roles:
        return RolePermissionsSections.lastColumnValues;
      default:
        return [];
    }
  }

  /// Modules whose permission switches are rendered on the "Role Permissions"
  /// step (role_permission_switches.dart). A module missing from this list is
  /// filtered out there and shows NO switches at all, even when the admin
  /// dashboard has written permissions for it into Demo_Permissions.
  ///
  /// Modules without enum-backed permission sections (crm, hr, notification)
  /// fall through to ModuleSwitchesBuilder._buildFirebaseOnlySwitches, which
  /// builds the switch list straight from the Demo_Permissions document — so
  /// adding them here is safe: if the doc has no entry for the module, the
  /// builder still collapses to SizedBox.shrink().
  static List<Modules> get modulesHasPermission {
    return [
      Modules.services,
      Modules.formBuilder,
      Modules.roles,
      Modules.settings,
      Modules.crm,  // ✅ ADDED
      Modules.hr,   // ✅ ADDED
    ];
  }
}