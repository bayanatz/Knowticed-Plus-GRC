import 'package:demo_app/features/grc/presentation/ui/pages/grc_page.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/grc/grc_permissions_sections.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/roles/widgets/module_page_stubs.dart';
import 'package:get/get_core/src/get_main.dart';

// REMOVED_MODULE: import 'package:demo_app/features/external/database_builder/database_builder_responsive_page.dart';
import 'package:demo_app/features/messaging/features/home/presentation/ui/pages/home_layout_helper.dart';
// REMOVED_MODULE: import 'package:demo_app/features/services_mangment_module/responsive_services.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/services/services_permissions_sections.dart';

// REMOVED_MODULE: import '../../../../external/form_builder_module/core/configs/extensions/extensions.dart';
// REMOVED_MODULE: import '../../../../external/form_builder_module/core/routes/app_routes.dart';
// REMOVED_MODULE: import '../../../../external/form_builder_module/core/routes/get_pages.dart';
// REMOVED_MODULE: import '../../../../external/form_builder_module/core/services/form_navigator_service.dart';
// REMOVED_MODULE: import '../../../database_builder/database_responsive_page.dart';

// REMOVED_MODULE: import '../../../inventory_module/inventory_responsive_page.dart';
// REMOVED_MODULE: import '../../../knowledge_hub_module/knowledge_hub_responsive_page.dart';
// REMOVED_MODULE: import '../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s1_create_service/home_services/home_page_services_toggle.dart';

// REMOVED_MODULE: import '../../../../external/todo_module/todo_responsive_page.dart';
// REMOVED_MODULE: import '../../../todo_new_module/todo_responsive_page.dart';

// REMOVED_MODULE: import '../../../../external/tracking_module/tracking_responsive_page.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/employees_responsive_page.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/pages/home_responsive_page.dart';
import 'package:demo_app/features/home/nav_bar/presentation/ui/pages/more_page.dart';
import 'package:demo_app/features/notification/presentation/ui/pages/notification_control.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/role_responsive_page.dart';
import 'form/form_permissions_sections.dart';
import 'hr/hr_subsSections_enums.dart';
import 'inventory/inventory_permissions_sections.dart';
import 'knowledge/knowledge_hubsSections_enum.dart';
import 'messages/messages_permissions_sections.dart';
import 'notification/notification_subSections_enums.dart';
import 'qiyas/qiyas_permissions_sections.dart';
import 'roles/roles_permissions_sections.dart';
import 'settings/settings_permissions_sections.dart';

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
  hr, // ✅ ADDED
  notification, // ✅ ADDED
  more;

  String get iconPath {
    switch (this) {
      case Modules.home:
        return 'assets/icons_assets/roles_assets/Home_last_icon.svg';
      case Modules.tasks:
        return 'assets/icons_assets/main_icons_assets/task_manage.svg';
      case Modules.employees:
        return 'assets/icons_assets/roles_assets/org_new.svg';
      case Modules.messages:
        return 'assets/icons_assets/main_icons_assets/message_new_icon.svg';
      case Modules.inventory:
        return 'assets/icons_assets/roles_assets/inventory_news_icons.svg';
      case Modules.roles:
        return 'assets/icons_assets/roles_assets/icons_roles_news.svg';
      case Modules.services:
        return 'assets/icons_assets/roles_assets/services_last_icon.svg';
      case Modules.todo:
        return 'assets/icons_assets/roles_assets/todo_last_icon.svg';
      case Modules.grc:
        return 'assets/icons_assets/roles_assets/grc_new.svg';
      case Modules.requests:
        return 'assets/icons_assets/main_icons_assets/DocumentAdd.svg';
      case Modules.events:
        return 'assets/icons_assets/main_icons_assets/events_knwoticed.svg';
      case Modules.notes:
        return 'assets/icons_assets/todo_new_assets/Notes.svg';
      case Modules.tracking:
        return 'assets/icons_assets/roles_assets/tracking_new.svg';
      case Modules.knowledgeHub:
        return 'assets/icons_assets/roles_assets/Knowledge_last_icon.svg';
      case Modules.qiyas:
        return 'assets/icons_assets/roles_assets/grs_icons_new.svg';
      case Modules.formBuilder:
        return 'assets/icons_assets/roles_assets/form_last_icon.svg';
      case Modules.database:
        return 'assets/icons_assets/home_assets/database.svg';
      case Modules.settings:
        return 'assets/icons_assets/roles_assets/settings_new_icon.svg';
      case Modules.hr: // ✅ ADDED
        return 'assets/icons_assets/roles_assets/hr_modules.svg';
      case Modules.notification: // ✅ ADDED
        return 'assets/icons_assets/main_icons_assets/Bell.svg';
      case Modules.more:
        return 'assets/icons_assets/roles_assets/more_horizontal_lines.svg';
      default:
        return 'home';
    }
  }

  String get iconPathRole {
    switch (this) {
      case Modules.home:
        return 'assets/icons_assets/roles_assets/Home_last_icon.svg';
      case Modules.tasks:
        return 'assets/icons_assets/main_icons_assets/task_manage.svg';
      case Modules.employees:
        return 'assets/icons_assets/roles_assets/org_new.svg';
      case Modules.messages:
        return 'assets/roles_module/Messages.svg';
      case Modules.inventory:
        return 'assets/roles_icons/Inventory.svg';
      case Modules.roles:
        return 'assets/roles_icons/Roles.svg';
      case Modules.services:
        return 'assets/roles_icons/Services.svg';
      case Modules.todo:
        return 'assets/roles_icons/To Do List.svg';
      case Modules.requests:
        return 'assets/icons_assets/main_icons_assets/DocumentAdd.svg';
      case Modules.events:
        return 'assets/icons_assets/main_icons_assets/events_knwoticed.svg';
      case Modules.notes:
        return 'assets/icons_assets/todo_new_assets/Notes.svg';
      case Modules.tracking:
        return 'assets/icons_assets/roles_assets/tracking_new.svg';
      case Modules.knowledgeHub:
        return 'assets/roles_icons/Knowledge Hub.svg';
      case Modules.qiyas:
        return 'assets/roles_icons/Qiyas.svg';
      case Modules.grc:
        return 'assets/icons_assets/roles_assets/grc_new.svg';
      case Modules.formBuilder:
        return 'assets/roles_icons/Form.svg';
      case Modules.database:
        return 'assets/icons_assets/home_assets/database.svg';
      case Modules.settings:
        return 'assets/roles_icons/Settings.svg';
      case Modules.hr: // ✅ ADDED
        return 'assets/roles_icons/HR.svg';
      case Modules.notification: // ✅ ADDED
        return 'assets/icons_assets/main_icons_assets/Bell.svg';
      case Modules.more:
        return 'assets/icons_assets/roles_assets/more_horizontal_lines.svg';
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
        return Get.locale.toString().contains('ar')
            ? ' الحوكمة و المخاطر و الآلتزام'
            : 'GRC';
      case Modules.requests:
        return Get.locale.toString().contains('ar') ? 'الطلبات' : 'Requests';
      case Modules.knowledgeHub:
        return Get.locale.toString().contains('ar')
            ? 'مركز المعرفة'
            : 'Knowledge Hub';
      case Modules.qiyas:
        return Get.locale.toString().contains('ar') ? 'قياس' : 'Qiyas';
      case Modules.tracking:
        return Get.locale.toString().contains('ar') ? 'التتبع' : 'Tracking';
      case Modules.inventory:
        return Get.locale.toString().contains('ar') ? 'المخزون' : 'Inventory';
      case Modules.messages:
        return Get.locale.toString().contains('ar') ? 'الرسائل' : 'Messages';
      case Modules.database:
        return Get.locale.toString().contains('ar')
            ? 'قاعدة البيانات'
            : 'Database';
      case Modules.formBuilder:
        return Get.locale.toString().contains('ar')
            ? 'منشئ النماذج'
            : 'Form Builder';
      case Modules.roles:
        return Get.locale.toString().contains('ar') ? 'الأدوار' : 'Roles';
      case Modules.settings:
        return Get.locale.toString().contains('ar') ? 'الإعدادات' : 'Settings';
      case Modules.hr: // ✅ ADDED
        return Get.locale.toString().contains('ar') ? 'الموارد البشرية' : 'HR';
      case Modules.notification: // ✅ ADDED
        return Get.locale.toString().contains('ar')
            ? 'الإشعارات'
            : 'Notification';
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
        return EmployeesResponsivePage();
      case Modules.tracking:
        return TrackerPageResponsivePageRefactor();
      case Modules.inventory:
        return Container();
      case Modules.grc:
        return GrcResponsivePage();
      case Modules.roles:
        return RoleResponsivePage();

      case Modules.services:
        servicesKey ??= GlobalKey();
        return Container();

      case Modules.todo:
        return Container();
      case Modules.database:
        return Container();
      case Modules.messages:
        return HomePageHelper();

      case Modules.formBuilder:
        return FormResponsivePage();

      case Modules.tracking:
        trackerAppKey ??= GlobalKey();
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
        } else {}
        return GrcResponsivePage();

      // ✅ ADDED: HR Module
      case Modules.hr:
        return Container(); // TODO: Create this page

      // ✅ ADDED: Notification Module
      case Modules.notification:
        return NotificationControlPage(); // TODO: Create this page

      default:
        return Scaffold();
    }
  }

  List<Enum> get moduleFirstColumnPermissions {
    switch (this) {
      case Modules.services:
        return ServicePermissionsSections.firstColumnValues;
      case Modules.messages:
        return MessagesPermissionsSections.firstColumnValues;
      case Modules.inventory:
        return InventoryPermissionsSections.firstColumnValues;
      case Modules.formBuilder:
        return FormPermissionsSections.firstColumnValues;
      case Modules.qiyas:
        return QiyasPermissionsSections.firstColumnValues;
      case Modules.settings:
        return SettingsPermissionsSections.firstColumnValues;
      case Modules.roles:
        return RolePermissionsSections.firstColumnValues;
      case Modules.knowledgeHub:
        return KnowledgeHubPermissionsSections.firstColumnValues;
      case Modules.hr: // ✅ ADDED
        return HRPermissionsSections.firstColumnValues;
      case Modules.notification: // ✅ ADDED
        return NotificationPermissionsSections.firstColumnValues;
      case Modules.grc:
        return GrcPermissionsSections.firstColumnValues;

      default:
        return [];
    }
  }

  List<Enum> get moduleLastColumnPermissions {
    switch (this) {
      case Modules.services:
        return ServicePermissionsSections.lastColumnValues;
      case Modules.messages:
        return MessagesPermissionsSections.lastColumnValues;
      case Modules.inventory:
        return InventoryPermissionsSections.lastColumnValues;
      case Modules.formBuilder:
        return FormPermissionsSections.lastColumnValues;
      case Modules.qiyas:
        return QiyasPermissionsSections.lastColumnValues;
      case Modules.settings:
        return SettingsPermissionsSections.lastColumnValues;
      case Modules.roles:
        return RolePermissionsSections.lastColumnValues;
      case Modules.knowledgeHub:
        return KnowledgeHubPermissionsSections.lastColumnValues;
      case Modules.hr: // ✅ ADDED
        return HRPermissionsSections.lastColumnValues;
      case Modules.notification: // ✅ ADDED
        return NotificationPermissionsSections.lastColumnValues;
      case Modules.grc:
        return GrcPermissionsSections.lastColumnValues;
      default:
        return [];
    }
  }

  static List<Modules> get modulesHasPermission {
    return [
      Modules.messages,
      Modules.services,
      Modules.inventory,
      Modules.formBuilder,
      Modules.qiyas,
      Modules.roles,
      Modules.settings,
      Modules.knowledgeHub,
      Modules.hr, // ✅ ADDED
      Modules.notification, // ✅ ADDED
      Modules.grc,
    ];
  }
}
