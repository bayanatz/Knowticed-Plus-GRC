import 'package:demo_app/features/notification/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/side_frame_master.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/features/notification/core_widgets/grc/custom_button_with_image.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:demo_app/features/notification/data/repository/notification_template_service.dart';
import 'package:demo_app/features/notification/presentation/custom_tab_ar.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/custom_drop_down.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/text_single_field.dart';
import '../../generated/l10n.dart';

// REMOVED_MODULE: import '../../external/knowledge_hub_module/core/theming/new_theme.dart';
// REMOVED_MODULE: import '../knowledge_hub_module/core/app_multi_select_drop_down.dart';
import 'package:demo_app/core/custom/31-custom_multi_select_dropdown.dart';
import '../../core/theme/app_colors.dart';
import '../employee/presentation/controller/main_core_employee_controller.dart';
// REMOVED_MODULE: import '../../external/todo_module/core/components/other_components/flutter_switch.dart';
import 'data/models/notification_modle.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/notification/notification_permissions.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/notification/notification_permissions_sections.dart';
import 'mobile/notification_edit_page.dart';

enum NotificationTab {
  employees,
  tasks,
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
  hr,
}


class NotificationControlPage extends StatefulWidget {
  const NotificationControlPage({super.key});

  @override
  State<NotificationControlPage> createState() =>
      _NotificationControlPageState();
}

class _NotificationControlPageState extends State<NotificationControlPage> {
  NotificationTab selectedTab = NotificationTab.services;

  // Edit mode state
  bool isEditMode = false;
  bool isSaving = false;

  // ✅ Add loading state
  bool isLoadingTemplates = true;

  // Selected notification types
  List<String> selectedNotificationTypes = [];

  TextEditingController subjectEn = TextEditingController();
  TextEditingController subjectAr = TextEditingController();
  TextEditingController bodyArController = TextEditingController();
  TextEditingController bodyEnController = TextEditingController();

  // Add selected notification item index
  int? selectedNotificationIndex;

  // ✅ Current template being edited
  NotificationTemplateModel? currentTemplate;

  // ✅ Notification template service
  final NotificationTemplateService _templateService =
  NotificationTemplateService();

  // ✅ Toggle state for notification status
  bool isNotificationEnabled = true;

  // ✅ Store loaded templates from Firebase for each event
  Map<String, NotificationTemplateModel> loadedTemplates = {};

  // ✅ Cache the notification items list to prevent rebuilding
  List<NotificationItem>? _cachedNotificationItems;

  @override
  void initState() {
    super.initState();

    //print('');
    //print('╔══════════════════════════════════════════════════════════╗');
    //print('║           NOTIFICATION CONTROL INITIALIZATION           ║');
    //print('╚══════════════════════════════════════════════════════════╝');
    //print('📋 Total available tabs: ${NotificationTab.values.length}');
    //print('📋 Tab list: ${NotificationTab.values.map((t) => t.name).join(', ')}');
    //print('');

    // ✅ CRITICAL DEBUG: Check if controller exists BEFORE filtering
    _debugControllerState();

    // ✅ Set selected tab to first visible tab
    final visibleTabs = _getVisibleTabs();
    //print('✅ Visible tabs after permission check: ${visibleTabs.length}');
    //print('✅ Visible tab names: ${visibleTabs.map((t) => t.name).join(', ')}');
    //print('');

    if (visibleTabs.isNotEmpty) {
      selectedTab = visibleTabs.first;
      //print('🎯 Selected tab SET TO: ${selectedTab.name}');
    } else {
      //print('⚠️ WARNING: No visible tabs found!');
      // Fallback to home if no tabs are visible
     // selectedTab = NotificationTab.home;
      //print('🏠 FALLBACK: Selected tab SET TO: ${selectedTab.name}');
    }
    //print('══════════════════════════════════════════════════════════');
    //print('');

    // ✅ Load templates AFTER first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllTemplatesForTab();
    });
  }

  // ✅ NEW: Debug method to check controller state
  void _debugControllerState() {
    //print('');
    //print('╔══════════════════════════════════════════════════════════╗');
    //print('║              CONTROLLER STATE CHECK                      ║');
    //print('╚══════════════════════════════════════════════════════════╝');

    try {
      final controller = Get.find<MainCoreEmployeeController>();
      //print('✅ MainCoreEmployeeController FOUND');
      //print('   Controller type: ${controller.runtimeType}');
      //print('   Is initialized: ${controller.initialized}');

      // Try to get current employee data
      try {
        //print('   Attempting to access employee data...');
        // Add any relevant employee controller properties here
        //print('   ✅ Employee data accessible');
      } catch (e) {
        //print('   ⚠️ Cannot access employee data: $e');
      }
    } catch (e) {
      //print('❌ MainCoreEmployeeController NOT FOUND');
      //print('   Error: $e');
      //print('   Error type: ${e.runtimeType}');
    }
    //print('══════════════════════════════════════════════════════════');
    //print('');
  }

  // ✅ Load all templates for current tab from Firebase
  Future<void> _loadAllTemplatesForTab() async {
    if (!mounted) return;

    setState(() {
      isLoadingTemplates = true;
      _cachedNotificationItems = null;
    });

    final items = _getDefaultNotificationItems();
    final moduleName = getModuleName(selectedTab);

    loadedTemplates.clear();

    //print('');
    //print('════════════════════════════════════════════════════');
    //print('🔄 Loading all templates for: $moduleName');
    //print('════════════════════════════════════════════════════');

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final template = await _templateService.getTemplate(
        module: moduleName,
        eventType: item.eventType,
      );

      if (template != null) {
        loadedTemplates[item.eventType] = template;
        //print(
           // '✅ Loaded: ${item.eventType} - Enabled: ${template.isEnabled}, Email: ${template.hasEmail}, Push: ${template.hasPush}');
      } else {
        //print('⚠️ No template in Firebase for: ${item.eventType}');
      }
    }

    //print('════════════════════════════════════════════════════');
    //print('✅ All templates loaded. Total: ${loadedTemplates.length}');
    //print('════════════════════════════════════════════════════');
    //print('');

    if (!mounted) return;

    setState(() {
      isLoadingTemplates = false;
      _cachedNotificationItems = _buildNotificationItems();
    });
  }

  // ✅ Build notification items with Firebase data
  List<NotificationItem> _buildNotificationItems() {
    final items = _getDefaultNotificationItems();

    return items.map((item) {
      final template = loadedTemplates[item.eventType];
      if (template != null) {
        return NotificationItem(
          title: item.title,
          eventType: item.eventType,
          isEnabled: template.isEnabled,
          hasEmail: template.hasEmail,
          hasPush: template.hasPush,
        );
      }
      return item;
    }).toList();
  }

  // ✅ Get notification items (uses cache to prevent rebuilds)
  List<NotificationItem> getNotificationItems() {
    if (_cachedNotificationItems != null) {
      return _cachedNotificationItems!;
    }
    return _buildNotificationItems();
  }

  // ✅ ENHANCED: Add detailed debugging for tab visibility checking
  bool _isTabVisible(NotificationTab tab) {
    //print('');
    //print('┌────────────────────────────────────────────────────────┐');
    //print('│  CHECKING TAB: ${tab.name.toUpperCase().padRight(44)} │');
    //print('└────────────────────────────────────────────────────────┘');


    final permission = _getPermissionForTab(tab);

    if (permission == null) {
      //print('⚠️ No permission mapping defined');
      //print('   Result: ✅ TRUE (default behavior)');
      //print('');
      return true;
    }

    //print('🔑 Permission Mapping for ${tab.name}:');
    //print('   ├─ Enum: $permission');
    //print('   ├─ Enum name: ${permission.toString().split('.').last}');
    //print('   └─ Database name: ${permission.getDataBaseName}');
    //print('');

    // ✅ Check if MainCoreEmployeeController is available
    try {
      //print('🔍 Attempting to find MainCoreEmployeeController...');
      final controller = Get.find<MainCoreEmployeeController>();
      //print('✅ Controller found successfully');
      //print('');

      // ✅ NEW: Check controller state
      //print('🔬 DEEP CONTROLLER INSPECTION:');
      //print('   ├─ Controller type: ${controller.runtimeType}');
      //print('   ├─ Employee entity exists: ${controller.employeeEntity != null}');
      if (controller.employeeEntity != null) {
        //print('   ├─ Employee email: ${controller.employeeEntity!.email}');
        //print('   ├─ Employee role: ${controller.employeeEntity!.role}');
      }
      //print('   ├─ Current role exists: ${controller.currentEmployeeRole != null}');
      if (controller.currentEmployeeRole != null) {
        //print('   ├─ Role name: ${controller.currentEmployeeRole!.currentRoleName}');
        //print('   ├─ Role ID: ${controller.currentEmployeeRole!.roleId}');
        //print('   ├─ Selected modules: ${controller.currentEmployeeRole!.currentSelectedModules}');
      }
      //print('   └─ Permission cache size: ${controller.getPermissionCacheStatus()}');
      //print('');

      // ✅ NEW: Check if notification module is accessible
      //print('🔍 MODULE ACCESS CHECK:');
      final hasModuleAccess = controller.hasModuleAccess(Modules.notification);
      //print('   ├─ hasModuleAccess(Modules.notification): $hasModuleAccess');
      //print('   └─ Is "notification" in selected modules: ${controller.currentEmployeeRole?.currentSelectedModules.contains("notification") ?? false}');
      //print('');

      // ✅ NEW: Try to get cached permission directly
      //print('🔍 DIRECT CACHE LOOKUP:');
      final moduleName = 'notification';
      final permissionName = permission.getDataBaseName;
      final cachedPermissions = controller.getModulePermissions(Modules.notification);
      //print('   ├─ Module: $moduleName');
      //print('   ├─ Permission: $permissionName');
      //print('   ├─ All cached permissions for notification module: ${cachedPermissions.keys.toList()}');
      //print('   └─ Cached value for $permissionName: ${cachedPermissions[permissionName]}');
      //print('');

      // ✅ ENHANCED DEBUG: Show permission details
      //print('📋 Permission Details:');
      //print('   ├─ Module: ${Modules.notification}');
      //print('   ├─ Module name: ${Modules.notification.toString().split('.').last}');
      //print('   ├─ Section: ${NotificationPermissionsSections.notificationModule}');
      //print('   ├─ Section name: ${NotificationPermissionsSections.notificationModule.toString().split('.').last}');
      //print('   ├─ Permission enum: $permission');
      //print('   └─ Permission name: ${permission.toString().split('.').last}');
      //print('');

      //print('🔐 Calling isHasPermission...');
      final hasPermission = controller.isHasPermission(
        module: Modules.notification,
        section: NotificationPermissionsSections.notificationModule,
        permission: permission,
      );

      //print('📊 Permission Check Result:');
      //print('   ├─ Has Permission: $hasPermission');
      //print('   ├─ Type: ${hasPermission.runtimeType}');
      //print('   └─ Final Result: ${hasPermission ? "✅ VISIBLE" : "❌ HIDDEN"}');
      //print('');

      // ✅ NEW: If permission is false, try to understand why
      if (!hasPermission) {
        //print('🔍 DEBUGGING WHY PERMISSION IS FALSE:');
        //print('   Step 1: Module access check');
        //print('      └─ hasModuleAccess returned: $hasModuleAccess');

        if (!hasModuleAccess) {
          //print('   ❌ PROBLEM FOUND: Module "notification" is NOT in selected modules!');
          //print('      └─ Selected modules are: ${controller.currentEmployeeRole?.currentSelectedModules}');
          //print('      └─ SOLUTION: Add "notification" to this role\'s selected modules in Firebase');
        } else {
          //print('   ✅ Module access OK');
          //print('   Step 2: Specific permission check');
          final specificPermCheck = controller.hasSpecificPermission(Modules.notification, permissionName);
          //print('      └─ hasSpecificPermission returned: $specificPermCheck');

          if (!specificPermCheck) {
            //print('   ❌ PROBLEM FOUND: Permission $permissionName is FALSE in cache/database!');
            //print('      └─ SOLUTION: Set $permissionName = true in Firebase');
            //print('      └─ Path: Demo/75440689/notification_module_permissions/{roleId}');
            //print('      └─ Field: $permissionName');
          }
        }
        //print('');
      }

      return hasPermission;
    } catch (e, stackTrace) {
      //print('❌ ERROR checking permission');
      //print('   ├─ Error: $e');
      //print('   ├─ Error Type: ${e.runtimeType}');
      //print('   └─ Stack trace:');
      //print(stackTrace.toString().split('\n').take(5).map((line) => '      $line').join('\n'));
      //print('   Result: ❌ FALSE (error occurred)');
      //print('');
      return false;
    }
  }

  List<NotificationTab> _getVisibleTabs() {
    //print('');
    //print('╔══════════════════════════════════════════════════════════╗');
    //print('║              CHECKING TAB VISIBILITY                    ║');
    //print('╚══════════════════════════════════════════════════════════╝');
    //print('⏱️ Starting visibility check at: ${DateTime.now()}');
    //print('');

    final visibleTabs = <NotificationTab>[];

    for (var tab in NotificationTab.values) {
      final isVisible = _isTabVisible(tab);
      if (isVisible) {
        visibleTabs.add(tab);
        //print('➕ Added ${tab.name} to visible tabs');
      } else {
        //print('➖ Excluded ${tab.name} from visible tabs');
      }
      //print('');
    }

    //print('══════════════════════════════════════════════════════════');
    //print('📊 VISIBILITY CHECK SUMMARY:');
    //print('   ├─ Total tabs checked: ${NotificationTab.values.length}');
    //print('   ├─ Visible tabs: ${visibleTabs.length}');
    //print('   ├─ Hidden tabs: ${NotificationTab.values.length - visibleTabs.length}');
    //print('   └─ Visible tab names: ${visibleTabs.map((t) => t.name).join(', ')}');
    //print('══════════════════════════════════════════════════════════');
    //print('');

    return visibleTabs;
  }

  // ✅ ENHANCED: Add permission enum to database name mapping debug
  NotificationPermissions? _getPermissionForTab(NotificationTab tab) {
    final permission = switch (tab) {
     // NotificationTab.home => null,
      NotificationTab.employees => NotificationPermissions.showEmployeesNotifications,
      NotificationTab.services => NotificationPermissions.showServicesNotifications,
      NotificationTab.tasks => NotificationPermissions.showTasksNotifications,
      NotificationTab.todo => NotificationPermissions.showTodoNotifications,
      NotificationTab.events => NotificationPermissions.showEventsNotifications,
      NotificationTab.notes => NotificationPermissions.showNotesNotifications,
      NotificationTab.requests => NotificationPermissions.showRequestsNotifications,
      NotificationTab.knowledgeHub => NotificationPermissions.showKnowledgeHubNotifications,
      NotificationTab.qiyas => NotificationPermissions.showQiyasNotifications,
      NotificationTab.tracking => NotificationPermissions.showTrackingNotifications,
      NotificationTab.inventory => NotificationPermissions.showInventoryNotifications,
      NotificationTab.messages => NotificationPermissions.showMessagesNotifications,
      NotificationTab.database => NotificationPermissions.showDatabaseNotifications,
      NotificationTab.formBuilder => NotificationPermissions.showFormBuilderNotifications,
      NotificationTab.roles => NotificationPermissions.showRolesNotifications,
      NotificationTab.settings => NotificationPermissions.showSettingsNotifications,
      NotificationTab.grc => NotificationPermissions.showGRCNotifications,
      NotificationTab.hr => NotificationPermissions.showHRNotifications,
    };

    if (permission != null) {
      //print('🔑 Permission Mapping for ${tab.name}:');
      //print('   ├─ Enum: $permission');
      //print('   ├─ Enum name: ${permission.toString().split('.').last}');
      //print('   └─ Database name: ${permission.getDataBaseName}');
    } else {
      //print('🔑 No permission mapping for ${tab.name} (null)');
    }

    return permission;
  }


  // ✅ Get default notification items (structure only)
  List<NotificationItem> _getDefaultNotificationItems() {
    switch (selectedTab) {
      // case NotificationTab.home:
      //   return [
      //     NotificationItem(
      //       title: 'System Update',
      //       eventType: 'system_update',
      //       isEnabled: true,
      //       hasEmail: true,
      //       hasPush: true,
      //     ),
      //     NotificationItem(
      //       title: 'General Announcement',
      //       eventType: 'general_announcement',
      //       isEnabled: true,
      //       hasEmail: true,
      //       hasPush: true,
      //     ),
      //   ];

      case NotificationTab.employees:
        return [
          NotificationItem(
            title: 'New Employee Added',
            eventType: 'employee_added',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Employee Updated',
            eventType: 'employee_updated',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Employee Deactivated',
            eventType: 'employee_deactivated',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.services:
        return [
          NotificationItem(
            title: S.of(context).requestSubmitted,
            eventType: 'request_submitted',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: S.of(context).requestApproved,
            eventType: 'request_approved',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: S.of(context).requestRejected,
            eventType: 'request_rejected',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: S.of(context).requestCancelled,
            eventType: 'request_cancelled',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: S.of(context).requestInProgress,
            eventType: 'request_in_progress',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: S.of(context).requestDone,
            eventType: 'request_done',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: S.of(context).requestSLAExceed,
            eventType: 'request_sla_exceed',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Needs Approval',
            eventType: 'needs_approval',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.tasks:
        return [
          NotificationItem(
            title: 'Task Created',
            eventType: 'task_created',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Task Assigned',
            eventType: 'task_assigned',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Task Completed',
            eventType: 'task_completed',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Task Overdue',
            eventType: 'task_overdue',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.todo:
        return [
          NotificationItem(
            title: 'Todo Item Created',
            eventType: 'todo_created',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Todo Item Completed',
            eventType: 'todo_completed',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Todo Due Reminder',
            eventType: 'todo_reminder',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.events:
        return [
          NotificationItem(
            title: 'Event Created',
            eventType: 'event_created',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Event Updated',
            eventType: 'event_updated',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Event Reminder',
            eventType: 'event_reminder',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Event Cancelled',
            eventType: 'event_cancelled',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.notes:
        return [
          NotificationItem(
            title: 'Note Created',
            eventType: 'note_created',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Note Shared',
            eventType: 'note_shared',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Note Updated',
            eventType: 'note_updated',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.requests:
        return [
          NotificationItem(
            title: 'Request Submitted',
            eventType: 'request_submitted',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Request Approved',
            eventType: 'request_approved',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Request Rejected',
            eventType: 'request_rejected',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.qiyas:
        return [
          NotificationItem(
            title: 'Perspectives & Axes Created',
            eventType: 'perspectives_axes_created',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Champion Assigned to Evidence',
            eventType: 'champion_assigned_to_evidence',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Evidence Submitted for Supervisor Review',
            eventType: 'evidence_submitted_for_review',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Approval Status — Approved',
            eventType: 'evidence_status_approved',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Approval Status — Rejected',
            eventType: 'evidence_status_rejected',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Evidence Overdue',
            eventType: 'evidence_overdue',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Champion Reassigned',
            eventType: 'champion_reassigned',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.inventory:
        return [
          NotificationItem(
            title: 'Low Stock Alert',
            eventType: 'low_stock_alert',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Item Added',
            eventType: 'item_added',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Item Updated',
            eventType: 'item_updated',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.knowledgeHub:
        return [
          NotificationItem(
            title: 'New Article',
            eventType: 'new_article',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Article Updated',
            eventType: 'article_updated',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.messages:
        return [
          NotificationItem(
            title: 'New Message Received',
            eventType: 'message_received',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Message Read',
            eventType: 'message_read',
            isEnabled: false,
            hasEmail: false,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Group Message',
            eventType: 'group_message',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.tracking:
        return [
          NotificationItem(
            title: 'Location Update',
            eventType: 'location_update',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Tracking Started',
            eventType: 'tracking_started',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Tracking Stopped',
            eventType: 'tracking_stopped',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.database:
        return [
          NotificationItem(
            title: 'Database Record Added',
            eventType: 'record_added',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Database Record Updated',
            eventType: 'record_updated',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Database Record Deleted',
            eventType: 'record_deleted',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.formBuilder:
        return [
          NotificationItem(
            title: 'Form Submitted',
            eventType: 'form_submitted',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Form Approved',
            eventType: 'form_approved',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Form Rejected',
            eventType: 'form_rejected',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.roles:
        return [
          NotificationItem(
            title: 'Role Assigned',
            eventType: 'role_assigned',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Role Updated',
            eventType: 'role_updated',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Permission Changed',
            eventType: 'permission_changed',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.settings:
        return [
          NotificationItem(
            title: 'Settings Updated',
            eventType: 'settings_updated',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Configuration Changed',
            eventType: 'config_changed',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.grc:
        return [
          NotificationItem(
            title: 'Risk Assessment Created',
            eventType: 'risk_created',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Compliance Report',
            eventType: 'compliance_report',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Audit Scheduled',
            eventType: 'audit_scheduled',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
        ];

      case NotificationTab.hr:
        return [
          NotificationItem(
            title: 'Leave Request Submitted',
            eventType: 'leave_request_submitted',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Leave Request Approved',
            eventType: 'leave_request_approved',
            isEnabled: true,
            hasEmail: true,
            hasPush: true,
          ),
          NotificationItem(
            title: 'Payroll Notification',
            eventType: 'payroll_notification',
            isEnabled: false,
            hasEmail: true,
            hasPush: true,
          ),
        ];
    }
  }

  String getTabName(NotificationTab tab) {
    switch (tab) {
      // case NotificationTab.home:
      //   return S.of(context).home;
      case NotificationTab.employees:
        return S.of(context).employees;
      case NotificationTab.services:
        return S.of(context).service;
      case NotificationTab.tasks:
        return "tasks";
      case NotificationTab.todo:
        return S.of(context).toDo;
      case NotificationTab.events:
        return "events";
      case NotificationTab.notes:
        return "notes";
      case NotificationTab.requests:
        return S.of(context).requests;
      case NotificationTab.knowledgeHub:
        return S.of(context).knowledgeHub;
      case NotificationTab.qiyas:
        return S.of(context).qiyas;
      case NotificationTab.tracking:
        return "tracking";
      case NotificationTab.inventory:
        return S.of(context).inventory;
      case NotificationTab.messages:
        return "messages";
      case NotificationTab.database:
        return "database";
      case NotificationTab.formBuilder:
        return "formBuilder";
      case NotificationTab.roles:
        return "roles";
      case NotificationTab.settings:
        return S.of(context).settings;
      case NotificationTab.grc:
        return 'GRC';
      case NotificationTab.hr:
        return 'HR';
    }
  }

  String getModuleName(NotificationTab tab) {
    switch (tab) {
      // case NotificationTab.home:
      //   return 'home';
      case NotificationTab.employees:
        return 'employees';
      case NotificationTab.services:
        return 'services';
      case NotificationTab.tasks:
        return 'tasks';
      case NotificationTab.todo:
        return 'todo';
      case NotificationTab.events:
        return 'events';
      case NotificationTab.notes:
        return 'notes';
      case NotificationTab.requests:
        return 'requests';
      case NotificationTab.knowledgeHub:
        return 'knowledge_hub';
      case NotificationTab.qiyas:
        return 'qiyas';
      case NotificationTab.tracking:
        return 'tracking';
      case NotificationTab.inventory:
        return 'inventory';
      case NotificationTab.messages:
        return 'messages';
      case NotificationTab.database:
        return 'database';
      case NotificationTab.formBuilder:
        return 'form_builder';
      case NotificationTab.roles:
        return 'roles';
      case NotificationTab.settings:
        return 'settings';
      case NotificationTab.grc:
        return 'grc';
      case NotificationTab.hr:
        return 'hr';
    }
  }

  // ✅ Load template when notification item is selected
  Future<void> _loadTemplate() async {
    if (selectedNotificationIndex == null) {
      //print('⚠️ No notification selected');
      return;
    }

    final items = getNotificationItems();
    final selectedItem = items[selectedNotificationIndex!];
    final moduleName = getModuleName(selectedTab);

    //print('');
    //print('═══════════════════════════════════════════════════');
    //print('🔍 Loading template: $moduleName - ${selectedItem.eventType}');
    //print('═══════════════════════════════════════════════════');

    NotificationTemplateModel? template = await _templateService.getTemplate(
      module: moduleName,
      eventType: selectedItem.eventType,
    );

    if (template != null) {
      //print('✅ Template loaded from Firebase');
      //print('   - Subject (EN): ${template.subjectEnglish}');
      //print('   - Enabled: ${template.isEnabled}');
      //print('   - Selected types: ${template.selectedNotificationTypes}');
      //print('   - Has Email: ${template.hasEmail}');
      //print('   - Has Push: ${template.hasPush}');

      setState(() {
        currentTemplate = template;
        isNotificationEnabled = template.isEnabled;
        selectedNotificationTypes =
            List.from(template.selectedNotificationTypes);

        subjectEn.text = template.subjectEnglish;
        subjectAr.text = template.subjectArabic;
        bodyEnController.text = template.bodyEnglish;
        bodyArController.text = template.bodyArabic;
      });

      //print('✅ UI updated with loaded template');
    } else {
      //print('⚠️ No template found in Firebase for: ${selectedItem.eventType}');
    }
    //print('═══════════════════════════════════════════════════');
    //print('');
  }

  String _getSelectedNotificationTypesText(bool isRTL) {
    if (selectedNotificationTypes.isEmpty) {
      return isRTL ? "اختر نوع الإشعار" : "Select Notification Type";
    }

    List<String> displayNames = selectedNotificationTypes.map((type) {
      if (isRTL) {
        return type == "email" ? "البريد الإلكتروني" : "إشعار الهاتف";
      } else {
        return type == "email" ? "Email" : "Push Notification";
      }
    }).toList();

    return displayNames.join(", ");
  }

  String _getNotificationTypeKey(String displayName, bool isRTL) {
    if (isRTL) {
      return displayName == "البريد الإلكتروني" ? "email" : "push";
    } else {
      return displayName == "Email" ? "email" : "push";
    }
  }

  Future<void> _saveTemplate() async {
    if (currentTemplate == null) {
      return;
    }

    if (subjectEn.text.trim().isEmpty ||
        subjectAr.text.trim().isEmpty ||
        bodyEnController.text.trim().isEmpty ||
        bodyArController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final updatedTemplate = currentTemplate!.copyWith(
      subjectEnglish: subjectEn.text.trim(),
      subjectArabic: subjectAr.text.trim(),
      bodyEnglish: bodyEnController.text.trim(),
      bodyArabic: bodyArController.text.trim(),
      isEnabled: isNotificationEnabled,
      selectedNotificationTypes: selectedNotificationTypes,
      updatedAt: DateTime.now(),
    );

    final success = await _templateService.saveTemplate(updatedTemplate);

    setState(() {
      isSaving = false;
    });

    if (success) {
      setState(() {
        currentTemplate = updatedTemplate;
        loadedTemplates[updatedTemplate.eventType] = updatedTemplate;
        _cachedNotificationItems = null;
      });
    }
  }

  Future<void> _resetToDefault() async {
    if (selectedNotificationIndex == null) {
      return;
    }

    final items = getNotificationItems();
    final selectedItem = items[selectedNotificationIndex!];
    final moduleName = getModuleName(selectedTab);

    final success = await _templateService.resetToDefault(
      module: moduleName,
      eventType: selectedItem.eventType,
    );

    if (success) {
      await _loadTemplate();
      await _loadAllTemplatesForTab();
    }
  }

  void _clearFields() {
    subjectEn.clear();
    subjectAr.clear();
    bodyEnController.clear();
    bodyArController.clear();
    currentTemplate = null;
    isNotificationEnabled = true;
    selectedNotificationTypes = [];
  }

  String _getVariablesHintText(bool isRTL) {
    if (selectedNotificationIndex == null) {
      return isRTL
          ? "اختر نوع إشعار أولاً"
          : "Select a notification type first";
    }

    final items = getNotificationItems();
    final selectedItem = items[selectedNotificationIndex!];

    if (selectedTab == NotificationTab.services) {
      switch (selectedItem.eventType) {
        case 'request_submitted':
          return isRTL
              ? "المتغيرات المتاحة: {{serviceName}}"
              : "Available variables: {{serviceName}}";

        case 'needs_approval':
          return isRTL
              ? "المتغيرات المتاحة: {{serviceName}}, {{requesterName}}"
              : "Available variables: {{serviceName}}, {{requesterName}}";

        case 'request_approved':
        case 'request_rejected':
          return isRTL
              ? "المتغيرات المتاحة: {{serviceName}}, {{approverName}}, {{rejectionReason}}"
              : "Available variables: {{serviceName}}, {{approverName}}, {{rejectionReason}}";

        case 'request_cancelled':
          return isRTL
              ? "المتغيرات المتاحة: {{serviceName}}, {{cancelledBy}}"
              : "Available variables: {{serviceName}}, {{cancelledBy}}";

        default:
          return isRTL
              ? "المتغيرات المتاحة: {{serviceName}}"
              : "Available variables: {{serviceName}}";
      }
    }

    if (selectedTab == NotificationTab.qiyas) {
      switch (selectedItem.eventType) {
        case 'perspectives_axes_created':
          return isRTL
              ? "المتغيرات المتاحة: {{FrameworkName}}, {{EmployeeName}}"
              : "Available variables: {{FrameworkName}}, {{EmployeeName}}";

        case 'champion_assigned_to_evidence':
          return isRTL
              ? "المتغيرات المتاحة: {{DocumentName}}"
              : "Available variables: {{DocumentName}}";

        case 'evidence_submitted_for_review':
          return isRTL
              ? "المتغيرات المتاحة: {{DocumentName}}"
              : "Available variables: {{DocumentName}}";

        case 'evidence_status_approved':
          return isRTL
              ? "المتغيرات المتاحة: {{DocumentName}}"
              : "Available variables: {{DocumentName}}";

        case 'evidence_status_rejected':
          return isRTL
              ? "المتغيرات المتاحة: {{DocumentName}}"
              : "Available variables: {{DocumentName}}";

        case 'evidence_overdue':
          return isRTL
              ? "المتغيرات المتاحة: {{DocumentName}}"
              : "Available variables: {{DocumentName}}";

        case 'champion_reassigned':
          return isRTL
              ? "المتغيرات المتاحة: {{DocumentName}}"
              : "Available variables: {{DocumentName}}";

        default:
          return isRTL
              ? "المتغيرات المتاحة: {{DocumentName}}"
              : "Available variables: {{DocumentName}}";
      }
    }

    if (selectedTab == NotificationTab.inventory) {
      return isRTL
          ? "المتغيرات المتاحة: {{itemName}}, {{quantity}}"
          : "Available variables: {{itemName}}, {{quantity}}";
    }

    if (selectedTab == NotificationTab.knowledgeHub) {
      return isRTL
          ? "المتغيرات المتاحة: {{articleTitle}}, {{authorName}}"
          : "Available variables: {{articleTitle}}, {{authorName}}";
    }

    if (selectedTab == NotificationTab.todo) {
      return isRTL
          ? "المتغيرات المتاحة: {{taskName}}, {{assignerName}}, {{completedBy}}"
          : "Available variables: {{taskName}}, {{assignerName}}, {{completedBy}}";
    }

    return isRTL
        ? "المتغيرات المتاحة: {{serviceName}}"
        : "Available variables: {{serviceName}}";
  }

  void _showPreviewDialog(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? "معاينة الإشعار" : "Notification Preview"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? "العنوان:" : "Subject:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(isArabic ? subjectAr.text : subjectEn.text),
            SizedBox(height: 16),
            Text(
              isArabic ? "النص:" : "Body:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(isArabic ? bodyArController.text : bodyEnController.text),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isArabic
                    ? "ملاحظة: سيتم استبدال المتغيرات مثل {{serviceName}} بالقيم الفعلية عند إرسال الإشعار"
                    : "Note: Variables like {{serviceName}} will be replaced with actual values when sending notifications",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? "إغلاق" : "Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // ✅ DEBUG: //print build state
    //print('🏗️ BUILD CALLED - Selected Tab: ${selectedTab.name}');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SideFrameMaster(
          titleText: S.of(context).notificationControl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Tab Bar
              Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _getVisibleTabs().map((tab) {
                        final isSelected = selectedTab == tab;
                        final tabName = getTabName(tab);

                        return Padding(
                          padding: EdgeInsets.only(
                            right: isRTL ? 0 : 24,
                            left: isRTL ? 24 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              //print('');
                              //print('🔄 TAB CHANGED: ${tab.name}');
                              setState(() {
                                selectedTab = tab;
                                isEditMode = false;
                                selectedNotificationIndex = null;
                                currentTemplate = null;
                                _clearFields();
                              });
                              await _loadAllTemplatesForTab();
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tabName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomTabUnderline(
                                  text: tabName,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  height: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
              ),

              SizedBox(height: 20.h),
              if (_getVisibleTabs().isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 64.sp,
                          color: AppColors.secondaryText,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          isRTL
                              ? "لا توجد صلاحيات لعرض الإشعارات"
                              : "No notification permissions available",
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                isMobile
                    ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isEditMode)
                          customButtonWithImageMas(
                            title: isMobile ? "" : S.of(context).edit,
                            function: () {
                              setState(() {
                                isEditMode = true;
                                if (selectedNotificationIndex == null &&
                                    getNotificationItems().isNotEmpty) {
                                  selectedNotificationIndex = 0;
                                }
                              });
                              if (selectedNotificationIndex != null) {
                                _loadTemplate();
                              }
                            },
                            width: isMobile ? 38 : 135.w,
                            height: 38.h,
                            color: AppColors.primary,
                            textStyle:
                            StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            radius: 8.r,
                            heightImage: isMobile ? 20 : 16.h,
                            widthImage: isMobile ? 20 : 16.w,
                            svgColor: AppColors.textButton,
                            image: isMobile
                                ? "assets/edit.svg"
                                : "assets/Access_icons.svg",
                            space: isMobile ? 0.sp : 8.sp,
                            colorBorder: Colors.transparent,
                          ),

                        Spacer(),
                        _buildToggleButtons(context),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    if (isEditMode) ...[
                      Container(
                        padding: EdgeInsets.only(
                          top: 15.h,
                          right: 15.w,
                          left: 15.w,
                          bottom: 15.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomSvg(
                                  assetPath: "assets/status.svg",
                                  width: 16.w,
                                  height: 16.h,
                                  fit: BoxFit.fill,
                                  color: AppColors.secondaryText,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "Notification Status",
                                  style: StyleText.fontSize18Weight500
                                      .copyWith(color: AppColors.text),
                                ),
                                SizedBox(width: 8.w),
                                FlutterSwitch(
                                  activeColor: AppColors.secondaryPrimary,
                                  height: 22.sp,
                                  width: 38.sp,
                                  padding: 3.sp,
                                  borderRadius: 20.sp,
                                  toggleSize: 16.sp,
                                  toggleColor: Colors.white,
                                  inactiveColor:
                                  Color(0xFF787880).withOpacity(0.16),
                                  value: isNotificationEnabled,
                                  onToggle: (newValue) {
                                    setState(() {
                                      isNotificationEnabled = newValue;
                                    });
                                  },
                                ),
                                Spacer(),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditMode = false;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.text,
                                    size: 20.sp,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                                SizedBox(width: 8.w),
                                customButton(
                                  title: "Reset Default Messages",
                                  function: _resetToDefault,
                                  color: AppColors.primary,
                                  radius: 4.r,
                                  width: 220.w,
                                  height: 30.h,
                                  textStyle: StyleText.fontSize14Weight500
                                      .copyWith(
                                    color: AppColors.textButton,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                        EdgeInsets.only(bottom: 8.h),
                                        child: Text(
                                          isRTL
                                              ? "نوع الإشعار"
                                              : "Notification Type",
                                          style: StyleText
                                              .fontSize12Weight400
                                              .copyWith(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ),
                                      CustomMultiSelectDropdown<String>(
                                        values: selectedNotificationTypes
                                            .map((type) {
                                          if (isRTL) {
                                            return type == "email"
                                                ? "البريد الإلكتروني"
                                                : "إشعار الهاتف";
                                          } else {
                                            return type == "email"
                                                ? "Email"
                                                : "Push Notification";
                                          }
                                        }).toList(),
                                        items: (isRTL
                                            ? [
                                          "البريد الإلكتروني",
                                          "إشعار الهاتف"
                                        ]
                                            : [
                                          "Email",
                                          "Push Notification"
                                        ])
                                            .map((e) => MultiSelectDropdownItem<String>(value: e, label: e))
                                            .toList(),
                                        selectedTextBuilder: (_) => _getSelectedNotificationTypesText(
                                            isRTL),
                                        hint: isRTL
                                            ? "اختر نوع الإشعار"
                                            : "Select Notification Type",
                                        onChanged: (selected) {
                                          setState(() {
                                            selectedNotificationTypes
                                              ..clear()
                                              ..addAll(selected
                                                  .map((label) => _getNotificationTypeKey(label, isRTL)));
                                          });
                                        },
                                        fillColor: AppColors.background,
                                        valueStyle: StyleText
                                            .fontSize12Weight400
                                            .copyWith(
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 15.w),
                                Expanded(child: Container()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isLoadingTemplates
                              ? Center(child: CircleProgressMaster())
                              : Container(
                            height: 300.h,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: getNotificationItems().length,
                              itemBuilder: (context, index) {
                                final item =
                                getNotificationItems()[index];
                                final isSelected =
                                    selectedNotificationIndex == index;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedNotificationIndex = index;
                                    });
                                    _loadTemplate();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    padding: EdgeInsets.all(15.r),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isSelected
                                                  ? AppColors.textButton
                                                  : AppColors.text,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: item.isEnabled
                                                ? Colors.green
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (item.hasEmail)
                                          CustomSvg(
                                            assetPath:
                                            "assets/notification_module/notification_msg.svg",
                                            width: 20.w,
                                            height: 20.h,
                                            color: isSelected
                                                ? AppColors.textButton
                                                : null,
                                          ),
                                        const SizedBox(width: 8),
                                        if (item.hasPush)
                                          CustomSvg(
                                            assetPath:
                                            "assets/notification_module/notification_phone.svg",
                                            width: 20.w,
                                            height: 20.h,
                                            color: isSelected
                                                ? AppColors.textButton
                                                : null,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        customButton(
                            title: S.of(context).next,
                            function: () {
                              if (selectedNotificationIndex == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        isRTL
                                            ? "يرجى اختيار إشعار أولاً"
                                            : "Please select a notification first"
                                    ),
                                  ),
                                );
                                return;
                              }

                              final selectedItem = getNotificationItems()[selectedNotificationIndex!];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationEditPage(
                                    notificationItem: selectedItem,
                                    moduleName: getModuleName(selectedTab),
                                    currentTab: selectedTab,
                                  ),
                                ),
                              );
                            },
                            width: 150.w,
                            height: 38.h,
                            radius: 8.r,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.textButton
                            ),
                            color: AppColors.primary
                        ),
                      ],
                    )
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 300.w,
                      child: Text(
                        S.of(context).requestStatus,
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                    ),
                    SizedBox(width: 40.w),
                    if (!isEditMode)
                      customButtonWithImageMas(
                        title: isMobile ? "" : S.of(context).edit,
                        function: () {
                          setState(() {
                            isEditMode = true;
                            if (selectedNotificationIndex == null &&
                                getNotificationItems().isNotEmpty) {
                              selectedNotificationIndex = 0;
                            }
                          });
                          if (selectedNotificationIndex != null) {
                            _loadTemplate();
                          }
                        },
                        width: isMobile ? 38.w : 135.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        radius: 8.r,
                        heightImage: 16.h,
                        widthImage: 16.w,
                        svgColor: AppColors.textButton,
                        image: "assets/Access_icons.svg",
                        space: isMobile ? 0.sp : 8.sp,
                        colorBorder: Colors.transparent,
                      ),
                    Spacer(),
                    _buildToggleButtons(context),
                  ],
                ),

              SizedBox(height: 8.h),

              // ✅ Show loading indicator while fetching data
              if (isLoadingTemplates)
                isMobile
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: CircleProgressMaster()),
                  ],
                )
                    : Expanded(
                  child: Center(child: CircleProgressMaster()),
                )
              else
              // Content Area
                isMobile
                    ? Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isLoadingTemplates
                              ? Center(child: CircleProgressMaster())
                              : Container(
                            height: 300.h,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: getNotificationItems().length,
                              itemBuilder: (context, index) {
                                final item =
                                getNotificationItems()[index];
                                final isSelected =
                                    selectedNotificationIndex == index;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedNotificationIndex = index;
                                    });
                                    _loadTemplate();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    padding: EdgeInsets.all(15.r),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isSelected
                                                  ? AppColors.textButton
                                                  : AppColors.text,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: item.isEnabled
                                                ? Colors.green
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (item.hasEmail)
                                          CustomSvg(
                                            assetPath:
                                            "assets/notification_module/notification_msg.svg",
                                            width: 20.w,
                                            height: 20.h,
                                            color: isSelected
                                                ? AppColors.textButton
                                                : null,
                                          ),
                                        const SizedBox(width: 8),
                                        if (item.hasPush)
                                          CustomSvg(
                                            assetPath:
                                            "assets/notification_module/notification_phone.svg",
                                            width: 20.w,
                                            height: 20.h,
                                            color: isSelected
                                                ? AppColors.textButton
                                                : null,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        customButton(
                            title: S.of(context).next,
                            function: () {
                              if (selectedNotificationIndex == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        isRTL
                                            ? "يرجى اختيار إشعار أولاً"
                                            : "Please select a notification first"
                                    ),
                                  ),
                                );
                                return;
                              }

                              final selectedItem = getNotificationItems()[selectedNotificationIndex!];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationEditPage(
                                    notificationItem: selectedItem,
                                    moduleName: getModuleName(selectedTab),
                                    currentTab: selectedTab,
                                  ),
                                ),
                              );
                            },
                            width: 150.w,
                            height: 38.h,
                            radius: 8.r,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.textButton
                            ),
                            color: AppColors.primary
                        ),
                      ],
                    )
                  ],
                )
                    : Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 320.w,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: isLoadingTemplates
                                  ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                                  : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount:
                                getNotificationItems().length,
                                itemBuilder: (context, index) {
                                  final item =
                                  getNotificationItems()[index];
                                  final isSelected =
                                      selectedNotificationIndex ==
                                          index;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedNotificationIndex =
                                            index;
                                      });
                                      _loadTemplate();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      padding: EdgeInsets.all(15.r),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius:
                                        BorderRadius.circular(
                                            8.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isSelected
                                                    ? AppColors
                                                    .textButton
                                                    : AppColors
                                                    .text,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration:
                                            BoxDecoration(
                                              color: item.isEnabled
                                                  ? Colors.green
                                                  : Colors.red,
                                              shape:
                                              BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (item.hasEmail)
                                            CustomSvg(
                                              assetPath:
                                              "assets/notification_module/notification_msg.svg",
                                              width: 20.w,
                                              height: 20.h,
                                              color: isSelected
                                                  ? AppColors
                                                  .textButton
                                                  : null,
                                            ),
                                          const SizedBox(width: 8),
                                          if (item.hasPush)
                                            CustomSvg(
                                              assetPath:
                                              "assets/notification_module/notification_phone.svg",
                                              width: 20.w,
                                              height: 20.h,
                                              color: isSelected
                                                  ? AppColors
                                                  .textButton
                                                  : null,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: isLoadingTemplates
                            ? Center(child: CircleProgressMaster())
                            : ScrollConfiguration(
                          behavior: const ScrollBehavior()
                              .copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            physics:
                            const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: Column(
                              children: [
                                if (isEditMode) ...[
                                  Container(
                                    padding: EdgeInsets.only(
                                      top: 15.h,
                                      right: 15.w,
                                      left: 15.w,
                                      bottom: 15.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius:
                                      BorderRadius.circular(
                                          8.r),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CustomSvg(
                                              assetPath:
                                              "assets/status.svg",
                                              width: 16.w,
                                              height: 16.h,
                                              fit: BoxFit.fill,
                                              color: AppColors
                                                  .secondaryText,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              "Notification Status",
                                              style: StyleText
                                                  .fontSize18Weight500
                                                  .copyWith(
                                                  color:
                                                  AppColors
                                                      .text),
                                            ),
                                            SizedBox(width: 8.w),
                                            FlutterSwitch(
                                              activeColor: AppColors
                                                  .secondaryPrimary,
                                              height: 22.sp,
                                              width: 38.sp,
                                              padding: 3.sp,
                                              borderRadius: 20.sp,
                                              toggleSize: 16.sp,
                                              toggleColor:
                                              Colors.white,
                                              inactiveColor:
                                              Color(0xFF787880)
                                                  .withOpacity(
                                                  0.16),
                                              value:
                                              isNotificationEnabled,
                                              onToggle: (newValue) {
                                                setState(() {
                                                  isNotificationEnabled =
                                                      newValue;
                                                });
                                              },
                                            ),
                                            Spacer(),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isEditMode =
                                                  false;
                                                });
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                color:
                                                AppColors.text,
                                                size: 20.sp,
                                              ),
                                              padding:
                                              EdgeInsets.zero,
                                              constraints:
                                              BoxConstraints(),
                                            ),
                                            SizedBox(width: 8.w),
                                            customButton(
                                              title:
                                              "Reset Default Messages",
                                              function:
                                              _resetToDefault,
                                              color:
                                              AppColors.primary,
                                              radius: 4.r,
                                              width: 190.w,
                                              height: 30.h,
                                              textStyle: StyleText
                                                  .fontSize14Weight500
                                                  .copyWith(
                                                color: AppColors
                                                    .textButton,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .only(
                                                        bottom:
                                                        8.h),
                                                    child: Text(
                                                      isRTL
                                                          ? "نوع الإشعار"
                                                          : "Notification Type",
                                                      style: StyleText
                                                          .fontSize12Weight400
                                                          .copyWith(
                                                        color: AppColors
                                                            .secondaryText,
                                                      ),
                                                    ),
                                                  ),
                                                  CustomMultiSelectDropdown<String>(
                                                    values: selectedNotificationTypes
                                                        .map(
                                                            (type) {
                                                          if (isRTL) {
                                                            return type ==
                                                                "email"
                                                                ? "البريد الإلكتروني"
                                                                : "إشعار الهاتف";
                                                          } else {
                                                            return type ==
                                                                "email"
                                                                ? "Email"
                                                                : "Push Notification";
                                                          }
                                                        }).toList(),
                                                    items: (isRTL
                                                        ? [
                                                      "البريد الإلكتروني",
                                                      "إشعار الهاتف"
                                                    ]
                                                        : [
                                                      "Email",
                                                      "Push Notification"
                                                    ])
                                                        .map((e) => MultiSelectDropdownItem<String>(value: e, label: e))
                                                        .toList(),
                                                    selectedTextBuilder: (_) => _getSelectedNotificationTypesText(
                                                        isRTL),
                                                    hint: isRTL
                                                        ? "اختر نوع الإشعار"
                                                        : "Select Notification Type",
                                                    onChanged: (selected) {
                                                      setState(() {
                                                        selectedNotificationTypes
                                                          ..clear()
                                                          ..addAll(selected
                                                              .map((label) => _getNotificationTypeKey(label, isRTL)));
                                                      });
                                                    },
                                                    fillColor: AppColors
                                                        .background,
                                                    valueStyle: StyleText
                                                        .fontSize12Weight400
                                                        .copyWith(
                                                      color:
                                                      AppColors
                                                          .text,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 15.w),
                                            Expanded(
                                                child: Container()),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                ],
                                Container(
                                  padding: EdgeInsets.all(15.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius:
                                    BorderRadius.circular(8.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextSingleField(
                                              typeName: "Subject",
                                              hintText: "Text Here",
                                              maxLines: 1,
                                              height: 36.h,
                                              isArabic: false,
                                              controller: subjectEn,
                                              onChange: (_) =>
                                                  setState(() {}),
                                              enabled: isEditMode,
                                            ),
                                          ),
                                          SizedBox(width: 15.w),
                                          Expanded(
                                            child: TextSingleField(
                                              typeName: "عنوان",
                                              hintText: "اكتب هنا",
                                              maxLines: 1,
                                              height: 36.h,
                                              isArabic: true,
                                              controller: subjectAr,
                                              onChange: (_) =>
                                                  setState(() {}),
                                              enabled: isEditMode,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                      Container(
                                        padding:
                                        EdgeInsets.all(8.r),
                                        decoration: BoxDecoration(
                                          color: Colors.blue
                                              .withOpacity(0.1),
                                          borderRadius:
                                          BorderRadius.circular(
                                              4.r),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              size: 16.sp,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                _getVariablesHintText(
                                                    isRTL),
                                                style: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                    color: Colors
                                                        .blue),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15.h),
                                      TextSingleField(
                                        typeName: "Body",
                                        hintText: "Text Here",
                                        maxLines: 7,
                                        minLines: 7,
                                        height: 150.h,
                                        maxLength: 500,
                                        showCounter: true,
                                        isArabic: false,
                                        controller:
                                        bodyEnController,
                                        onChange: (_) =>
                                            setState(() {}),
                                        enabled: isEditMode,
                                      ),
                                      SizedBox(height: 15.h),
                                      TextSingleField(
                                        typeName: "نص الرسالة",
                                        hintText: "اكتب هنا",
                                        maxLines: 7,
                                        minLines: 7,
                                        height: 150.h,
                                        maxLength: 500,
                                        showCounter: true,
                                        isArabic: true,
                                        controller:
                                        bodyArController,
                                        onChange: (_) =>
                                            setState(() {}),
                                        enabled: isEditMode,
                                      ),
                                      SizedBox(height: 15.h),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          customButton(
                                            title: S
                                                .of(context)
                                                .preview,
                                            textStyle: StyleText
                                                .fontSize18Weight500
                                                .copyWith(
                                                color: lightMode
                                                    ? Colors
                                                    .black
                                                    : Colors
                                                    .white),
                                            function: () {
                                              _showPreviewDialog(
                                                  context);
                                            },
                                            width: 150.w,
                                            height: 38.h,
                                            color: lightMode
                                                ? Colors.grey[400]
                                                : Colors.grey[700],
                                            radius: 8.r,
                                          ),
                                          Spacer(),
                                          customButton(
                                            title:
                                            S.of(context).save,
                                            textStyle: StyleText
                                                .fontSize18Weight500
                                                .copyWith(
                                                color: AppColors
                                                    .textButton),
                                            function: () {
                                              isSaving
                                                  ? null
                                                  : _saveTemplate();
                                            },
                                            width: 150.w,
                                            height: 38.h,
                                            color:
                                            AppColors.primary,
                                            radius: 8.r,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

        ),
      ),
    );
  }

  bool isEmailView = true;

  Widget _buildToggleButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 7.w),
            child: _buildToggleButton(
              context: context,
              label: S.of(context).email,
              isSelected: isEmailView,
              onTap: () {
                setState(() {
                  isEmailView = true;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 7.w),
            child: _buildToggleButton(
              context: context,
              label: S.of(context).notifications,
              isSelected: !isEmailView,
              onTap: () {
                setState(() {
                  isEmailView = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Center(
          child: Text(
            label,
            style: StyleText.fontSize12Weight500.copyWith(
              color:
              isSelected ? AppColors.textButton : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String eventType;
  final bool isEnabled;
  final bool hasEmail;
  final bool hasPush;

  NotificationItem({
    required this.title,
    required this.eventType,
    required this.isEnabled,
    required this.hasEmail,
    required this.hasPush,
  });
}