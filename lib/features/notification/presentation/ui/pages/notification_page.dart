import 'package:grc_module/core/custom/35-custom_search_widget_custom.dart';
import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
import 'package:grc_module/core/custom/51_custom_pop_up.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/knowledge_hub_module/core/theming/new_theme.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/todo_new_module/external/tasks_module/core/custom_widgets/SideFrameMasterServices.dart';
import 'package:grc_module/features/notification/presentation/ui/pages/pin_notification.dart';
import 'package:lottie/lottie.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:grc_module/core/custom/cross_axis_count_helper.dart';
import 'package:grc_module/generated/l10n.dart';
// REMOVED_MODULE: import 'package:grc_module/external/inventory_module/core/drop_down.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import 'package:grc_module/external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import 'package:grc_module/external/services_mangment_module/core/custom_pop_up.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:grc_module/features/notification/data/models/notification_data_model.dart';
import 'package:grc_module/features/notification/data/repository/notification_services.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/notification/presentation/ui/pages/clear_page_notification.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';

import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
final List<Map<String, String>> NotificationTypeList = [
  {'key': 'approval_requests', 'value': 'Approval Requests'},
  {'key': 'approvals_updates', 'value': 'Approvals Updates'},
  {'key': 'assignments', 'value': 'Assignments'},
  {'key': 'reminders', 'value': 'Reminders'},
  {'key': 'scheduled_reminders', 'value': 'Scheduled Reminders'},
  {'key': 'messages_announcements', 'value': 'Messages / Announcements'},
  {'key': 'comments_mentions', 'value': 'Comments / Mentions'},
  {'key': 'document_record_changes', 'value': 'Document / Record Changes'},
  {'key': 'task_workflow_updates', 'value': 'Task / Workflow Updates'},
  {'key': 'sla_alerts', 'value': 'SLA Alerts'},
  {'key': 'due_dates', 'value': 'Due Dates'},
  {'key': 'compliance_alerts', 'value': 'Compliance Alerts'},
  {'key': 'risk_warnings', 'value': 'Risk Warnings'},
  {'key': 'hr_updates', 'value': 'HR Updates'},
  {'key': 'attendance_logs', 'value': 'Attendance Logs'},
  {'key': 'low_inventory', 'value': 'Low Inventory'},
  {'key': 'stock_updates', 'value': 'Stock Updates'},
  {'key': 'maintenance_needed', 'value': 'Maintenance Needed'},
  {'key': 'form_submissions', 'value': 'Form Submissions'},
  {'key': 'role_changes', 'value': 'Role Changes'},
  {'key': 'access_notifications', 'value': 'Access Notifications'},
  {'key': 'user_account_updates', 'value': 'User Account Updates'},
  {'key': 'events', 'value': 'Events'},
  {'key': 'service_closure', 'value': 'Service Closure'},
];

final List<Map<String, String>> notificationByeType = [
  {'key': 'system', 'value': 'System'},
  {'key': 'employee', 'value': 'Employee'},
  {'key': 'manager', 'value': 'Manager'},
];

final List<Map<String, String>> TimeFilterList = [
  {'key': 'day', 'value': 'Day'},
  {'key': 'week', 'value': 'Week'},
  {'key': 'month', 'value': 'Month'},
  {'key': 'year', 'value': 'Year'},
  {'key': 'custom', 'value': 'Custom'},
];

final List<Map<String, String>> NotificationTypeListArabic = [
  {'key': 'approval_requests', 'value': 'طلبات الموافقة'},
  {'key': 'approvals_updates', 'value': 'تحديثات الموافقات'},
  {'key': 'assignments', 'value': 'التعيينات'},
  {'key': 'reminders', 'value': 'التذكيرات'},
  {'key': 'scheduled_reminders', 'value': 'التذكيرات المجدولة'},
  {'key': 'messages_announcements', 'value': 'الرسائل / الإعلانات'},
  {'key': 'comments_mentions', 'value': 'التعليقات / الإشارات'},
  {'key': 'document_record_changes', 'value': 'تغييرات المستندات / السجلات'},
  {'key': 'task_workflow_updates', 'value': 'تحديثات المهام / سير العمل'},
  {'key': 'sla_alerts', 'value': 'تنبيهات اتفاقية مستوى الخدمة'},
  {'key': 'due_dates', 'value': 'تواريخ الاستحقاق'},
  {'key': 'compliance_alerts', 'value': 'تنبيهات الامتثال'},
  {'key': 'risk_warnings', 'value': 'تحذيرات المخاطر'},
  {'key': 'hr_updates', 'value': 'تحديثات الموارد البشرية'},
  {'key': 'attendance_logs', 'value': 'سجلات الحضور'},
  {'key': 'low_inventory', 'value': 'انخفاض المخزون'},
  {'key': 'stock_updates', 'value': 'تحديثات المخزون'},
  {'key': 'maintenance_needed', 'value': 'الصيانة المطلوبة'},
  {'key': 'form_submissions', 'value': 'تقديم النماذج'},
  {'key': 'role_changes', 'value': 'تغييرات الأدوار'},
  {'key': 'access_notifications', 'value': 'إشعارات الوصول'},
  {'key': 'user_account_updates', 'value': 'تحديثات حساب المستخدم'},
  {'key': 'events', 'value': 'الأحداث'},
  {'key': 'service_closure', 'value': 'إغلاق الخدمة'},
];

final List<Map<String, String>> notificationByeTypeArabic = [
  {'key': 'system', 'value': 'النظام'},
  {'key': 'employee', 'value': 'الموظفين'},
  {'key': 'manager', 'value': 'المدير'},
];

final List<Map<String, String>> TimeFilterListArabic = [
  {'key': 'day', 'value': 'يوم'},
  {'key': 'week', 'value': 'أسبوع'},
  {'key': 'month', 'value': 'شهر'},
  {'key': 'year', 'value': 'سنة'},
  {'key': 'custom', 'value': 'مخصص'},
];

List<Map<String, String>> getNotificationTypeList() {
  final isArabic = Get.locale.toString().toLowerCase().contains('ar');
  return isArabic ? NotificationTypeListArabic : NotificationTypeList;
}

List<Map<String, String>> getNotificationByeType() {
  final isArabic = Get.locale.toString().toLowerCase().contains('ar');
  return isArabic ? notificationByeTypeArabic : notificationByeType;
}

List<Map<String, String>> getTimeFilterList() {
  final isArabic = Get.locale.toString().toLowerCase().contains('ar');
  return isArabic ? TimeFilterListArabic : TimeFilterList;
}

// ============================================
// MAIN PAGE
// ============================================

class NotificationLandPage extends StatefulWidget {
  const NotificationLandPage({super.key});

  @override
  State<NotificationLandPage> createState() => _NotificationLandPageState();
}

class _NotificationLandPageState extends State<NotificationLandPage> {
  final FirestoreNotificationService _notificationService =
  FirestoreNotificationService();
  final MainCoreEmployeeController _employeeController =
  Get.find<MainCoreEmployeeController>();

  String? _currentUserEmail;
  bool _hasMarkedAllAsRead = false;
  List<Modules> _allowedModules = [];

  @override
  void initState() {
    super.initState();
    _currentUserEmail = _employeeController.employeeEntity?.email;
    _loadAllowedModules();

    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      _markAllNotificationsAsRead();
    }
  }

  void _loadAllowedModules() {
    List<Modules> allModules = [
      Modules.services,
      Modules.tasks,
      Modules.employees,
      Modules.inventory,
      Modules.messages,
      Modules.knowledgeHub,
      Modules.qiyas,
      Modules.formBuilder,
      Modules.tracking,
      Modules.todo,
      Modules.grc,
      Modules.database,
      Modules.roles,
    ];

    _allowedModules = allModules.where((module) {
      return _employeeController.hasModuleAccess(module);
    }).toList();
  }

  Future<void> _markAllNotificationsAsRead() async {
    if (_hasMarkedAllAsRead || _currentUserEmail == null) return;
    await _notificationService.markAllAsRead(_currentUserEmail!);
    _hasMarkedAllAsRead = true;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: User email not found',
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.text,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: s.notifications,
        child: StreamBuilder<List<NotificationModelSystem>>(
          stream: _notificationService
              .streamNotificationsForUser(_currentUserEmail!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading notifications: ${snapshot.error}',
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text,
                  ),
                ),
              );
            }

            return _NotificationContent(
              allNotifications: snapshot.data ?? [],
              allowedModules: _allowedModules,
              currentUserEmail: _currentUserEmail!,
              notificationService: _notificationService,
              employeeController: _employeeController,
            );
          },
        ),
      ),
    );
  }
}

// ✅ SEPARATE STATEFUL WIDGET FOR CONTENT
class _NotificationContent extends StatefulWidget {
  final List<NotificationModelSystem> allNotifications;
  final List<Modules> allowedModules;
  final String currentUserEmail;
  final FirestoreNotificationService notificationService;
  final MainCoreEmployeeController employeeController;

  const _NotificationContent({
    required this.allNotifications,
    required this.allowedModules,
    required this.currentUserEmail,
    required this.notificationService,
    required this.employeeController,
  });

  @override
  State<_NotificationContent> createState() => _NotificationContentState();
}

class _NotificationContentState extends State<_NotificationContent> {
  String selectStatus = "All";
  String? selectedNotificationType;
  String? selectedNotificationByeType;
  String? selectedNotificationTime;
  String? selectedNotificationDepartment;
  TextEditingController searchController = TextEditingController();
  String sortOrder = "newest";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<NotificationModelSystem> _getFilteredNotifications() {
    List<NotificationModelSystem> filtered = widget.allNotifications;

    // ✅ DEBUG: Print all notifications before filtering
    debugPrint('📊 Total notifications received: ${filtered.length}');
    for (var n in filtered) {
      debugPrint('📌 Module: ${n.nameOfModule}, Title: ${n.title}, isPinned: ${n.isPinned}, isClean: ${n.isClean}');
    }

    // Filter out pinned and cleaned
    filtered = filtered.where((n) => n.isPinned == false).toList();
    debugPrint('📊 After removing pinned: ${filtered.length}');

    filtered = filtered.where((n) => n.isClean == false).toList();
    debugPrint('📊 After removing cleaned: ${filtered.length}');

    // ✅ FIXED: Module filter with better debugging
    if (selectStatus != "All") {
      String moduleFilter = _getModuleKeyFromName(selectStatus);
      debugPrint('🔍 Filtering by module: $selectStatus -> $moduleFilter');

      filtered = filtered.where((n) {
        bool matches = n.nameOfModule.toLowerCase() == moduleFilter.toLowerCase();
        debugPrint('  Checking: ${n.nameOfModule} == $moduleFilter ? $matches');
        return matches;
      }).toList();

      debugPrint('📊 After module filter: ${filtered.length}');
    }

    // Search filter
    if (searchController.text.isNotEmpty) {
      String query = searchController.text.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.body.toLowerCase().contains(query);
      }).toList();
      debugPrint('📊 After search filter: ${filtered.length}');
    }

    // Sort by timestamp
    filtered.sort((a, b) {
      if (sortOrder == "newest") {
        return (b.timestamp ?? 0).compareTo(a.timestamp ?? 0);
      } else {
        return (a.timestamp ?? 0).compareTo(b.timestamp ?? 0);
      }
    });

    debugPrint('📊 Final filtered count: ${filtered.length}');
    return filtered;
  }

  // ✅ FIXED: Better module name matching
  String _getModuleKeyFromName(String displayName) {
    debugPrint('🔑 Looking for module key for: $displayName');

    for (Modules module in widget.allowedModules) {
      if (module.getModuleName == displayName) {
        String key = _moduleEnumToKey(module);
        debugPrint('✅ Found match: $displayName -> $key');
        return key;
      }
    }

    debugPrint('❌ No match found for: $displayName');
    return displayName.toLowerCase();
  }

  // ✅ FIXED: Ensure exact match with Firebase naming
  String _moduleEnumToKey(Modules module) {
    switch (module) {
      case Modules.services:
        return 'services';
      case Modules.roles:
        return 'roles';
      case Modules.tasks:
        return 'tasks';
      case Modules.employees:
        return 'employees';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.knowledgeHub:
        return 'knowledgeHub'; // ✅ Matches Firebase exactly
      case Modules.qiyas:
        return 'qiyas';
      case Modules.formBuilder:
        return 'formBuilder'; // ✅ Changed from 'services_app'
      case Modules.tracking:
        return 'tracking';
      case Modules.todo:
        return 'todo';
      case Modules.grc:
        return 'grc';
      case Modules.database:
        return 'database';
      default:
        return module.name.toLowerCase();
    }
  }

  Map<String, int> _getNotificationCountsByModule() {
    Map<String, int> counts = {'all': 0};

    for (Modules module in widget.allowedModules) {
      String key = _moduleEnumToKey(module);
      counts[key] = 0;
    }

    for (var notification in widget.allNotifications) {
      if (notification.isPinned || notification.isClean) continue;

      String module = notification.nameOfModule.toLowerCase();
      counts['all'] = (counts['all'] ?? 0) + 1;

      // ✅ Match case-insensitively
      for (var key in counts.keys) {
        if (key.toLowerCase() == module) {
          counts[key] = (counts[key] ?? 0) + 1;
          break;
        }
      }
    }

    debugPrint('📊 Module counts: $counts');
    return counts;
  }

  Future<void> _handleCleanAll() async {
    final s = S.of(context);
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/notification_lottie_assets/Simple Trash Clear.json',
      confirmTitle: s.cleaningNotifications,
      confirmSubtitle: s.areYouSureYouWantToCleanAll,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () async {
        try {
          await widget.notificationService
              .markAllAsCleaned(widget.currentUserEmail);
          return true;
        } catch (e) {
          debugPrint('❌ Error cleaning all notifications: $e');
          return false;
        }
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/approved.json',
      successTitle: s.allNotificationsCleared,
      successSubtitle: s.youSuccessfullyCleanedAllNotification,
    );
  }

  Future<void> _handlePinToggle(NotificationModelSystem notification) async {
    bool newPinStatus = !notification.isPinned;
    await widget.notificationService
        .updatePinStatus(notification.id!, newPinStatus);
  }

  // ✅ FIXED: Simplified navigation
  void _handleViewNotification(NotificationModelSystem notification) {
    debugPrint('🔔 Attempting navigation for: ${notification.nameOfPage}');
    debugPrint('📦 Module: ${notification.nameOfModule}');

    // Map module name to Modules enum
    Modules? targetModule = _getModuleFromString(notification.nameOfModule);

    if (targetModule == null) {
      debugPrint('❌ Could not find module for: ${notification.nameOfModule}');
      Get.snackbar(
        'Navigation Error',
        'Module "${notification.nameOfModule}" not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red?.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      final appDrawerController = Get.find<AppDrawerCubit>();
      int moduleIndex = appDrawerController.allowedDrawerModules.indexOf(targetModule);

      if (moduleIndex == -1) {
        debugPrint('❌ Module ${targetModule.name} not in allowed modules');
        Get.snackbar(
          'Access Denied',
          'You don\'t have access to ${targetModule.getModuleName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.red?.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      // Navigate to the module
      appDrawerController.updateSelectedIndex(moduleIndex);

      // Close notification page
      Navigator.of(context).pop();

      debugPrint('✅ Navigated to ${targetModule.name} at index $moduleIndex');

    } catch (e) {
      debugPrint('❌ Navigation error: $e');
      Get.snackbar(
        'Error',
        'Failed to navigate: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red?.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // ✅ NEW: Convert string to Modules enum
  Modules? _getModuleFromString(String moduleName) {
    String cleanName = moduleName.trim().toLowerCase();

    switch (cleanName) {
      case 'services':
        return Modules.services;
      case 'tasks':
        return Modules.tasks;
      case 'employees':
        return Modules.employees;
      case 'inventory':
        return Modules.inventory;
      case 'messages':
        return Modules.messages;
      case 'knowledgehub':
        return Modules.knowledgeHub;
      case 'qiyas':
        return Modules.qiyas;
      case 'formbuilder':
      case 'services_app':
        return Modules.formBuilder;
      case 'tracking':
        return Modules.tracking;
      case 'todo':
        return Modules.todo;
      case 'grc':
        return Modules.grc;
      case 'database':
        return Modules.database;
      case 'roles':
        return Modules.roles;
      default:
        return null;
    }
  }

  void _handleMessageSender(NotificationModelSystem notification) {
    Get.snackbar(
      'Message',
      'Would open message with: ${notification.senderEmail}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _getModuleIcon(String moduleName) {
    Modules? module = _getModuleFromString(moduleName);
    if (module != null) {
      return module.iconPath;
    }
    return "assets/icons_assets/notification_assets/document_search.svg";
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.sizeOf(context).width >= 900;
    var isMobile = ContextExtension(context).isPhone;
    final s = S.of(context);

    List<NotificationModelSystem> filteredNotifications =
    _getFilteredNotifications();
    Map<String, int> moduleCounts = _getNotificationCountsByModule();

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

       //   SizedBox(height: 20.sp),
          // Top buttons
          Row(
            children: [
              customButtonWithSvg(
                title: s.cleared,
                function: () {
                  final appDrawerController = Get.find<AppDrawerCubit>();
                  appDrawerController.updateSelectedIndex(20);
                },
                width: 135.w,
                height: 38.h,
                color: AppColors.primary,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
                space: 8.sp,
                radius: 8.r,
                svgColor: AppColors.textButton,
                image: "assets/icons_assets/notification_assets/broom_sweep.svg",
                widthImage: 22.sp,
                heightImage: 22.sp,
                colorBorder: Colors.transparent,
              ),
              Spacer(),
              customButtonWithSvg(
                title: s.pin,
                function: () {
                  final appDrawerController = Get.find<AppDrawerCubit>();
                  appDrawerController.updateSelectedIndex(21);
                },
                width: 135.w,
                height: 38.h,
                color: AppColors.primary,
                svgColor: AppColors.textButton,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
                space: 8.sp,
                radius: 8.r,
                image: "assets/icons_assets/notification_assets/pin_round_head.svg",
                widthImage: 22.sp,
                heightImage: 22.sp,
                colorBorder: Colors.transparent,
              ),
            ],
          ),
          SizedBox(height: 15.sp),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statusChip(
                  moduleCounts['all'].toString(),
                  s.all,
                  isSelected: selectStatus == s.all,
                  onTap: () => setState(() => selectStatus = s.all),
                  labelColor: selectStatus == s.all
                      ? AppColors.text
                      : AppColors.secondaryText,
                ),
                ...() {
                  List<Map<String, dynamic>> moduleData = widget.allowedModules
                      .map((module) {
                    String moduleKey = _moduleEnumToKey(module);
                    int count = moduleCounts[moduleKey] ?? 0;
                    return {
                      'module': module,
                      'moduleKey': moduleKey,
                      'count': count,
                      'displayName': module.getModuleName,
                    };
                  }).toList();

                  moduleData.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

                  return moduleData.map<Widget>((data) {
                    return _statusChip(
                      data['count'].toString(),
                      data['displayName'] as String,
                      isSelected: selectStatus == data['displayName'],
                      onTap: () => setState(() => selectStatus = data['displayName'] as String),
                      labelColor: selectStatus == data['displayName']
                          ? AppColors.text
                          : AppColors.secondaryText,
                    );
                  }).toList();
                }(),
              ],
            ),
          ),
          SizedBox(height: 15.sp),

          // Search and buttons
          Row(
            children: [
              AppSearchTextField(
                controller: searchController,
                onChanged: (val) => setState(() {}),
              ),
              SizedBox(width: 15.w),
              CustomPopupMenuButton(
                title: isMobile ? "" : s.sort,
                iconPath: "assets/icons_assets/main_icons_assets/sort_lines.svg",
                backgroundColor: AppColors.card,
                iconColor: AppColors.secondaryText,
                width: 100,
                height: 38,
                options: [
                  PopupOption(
                    value: "newest",
                    label: Get.locale.toString().toLowerCase().contains('ar')
                        ? "الأحدث أولاً"
                        : "Newest First",
                  ),
                  PopupOption(
                    value: "oldest",
                    label: Get.locale.toString().toLowerCase().contains('ar')
                        ? "الأقدم أولاً"
                        : "Oldest First",
                  ),
                ],
                onSelected: (value) {
                  setState(() {
                    sortOrder = value;
                  });
                },
              ),
              SizedBox(width: 15.w),
              GestureDetector(
                onTap: _handleCleanAll,
                child: Container(
                  width: isMobile ? 38.w : 120.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.primary,
                  ),
                  child: isMobile
                      ? Center(
                    child: CustomSvgImage(
                      assetPath:
                      "assets/icons_assets/notification_assets/clear_all_document_broom.svg",
                      width: 20.w,
                      height: 20.h,
                      fit: BoxFit.scaleDown,
                      color: AppColors.textButton,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSvgImage(
                        assetPath:
                        "assets/icons_assets/notification_assets/clear_all_document_broom.svg",
                        width: 20.w,
                        height: 20.h,
                        fit: BoxFit.scaleDown,
                        color: AppColors.textButton,
                      ),
                      SizedBox(width: 8.w),
                      Text(s.cleanAll,
                          style: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.textButton)),
                    ],
                  ),
                ),
              ),
            ],
          ),
         isMobile ? SizedBox() : SizedBox(height: 15.sp),

          // Grid
          filteredNotifications.isEmpty
              ? Center(
            child: Padding(
                padding: EdgeInsets.all(40.sp),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50.h),
                      Lottie.asset('assets/lottie_assets/notification_lottie_assets/empty.json',
                          width: 250.w,
                          height: 250.h,
                          fit: BoxFit.fill,
                          repeat: true),
                    ],
                  ),
                )),
          )
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              // 160.sp left the card ~37px short of its own content once the
              // sender chip and the two button rows were laid out.
              mainAxisExtent: 185.sp,
              crossAxisSpacing: 15.sp,
              mainAxisSpacing: 15.sp,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];
              return _buildNotificationCard(notification, isMobile, s);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      NotificationModelSystem notification, bool isMobile, S s) {
    String senderName =
    widget.employeeController.getEmployeeName(notification.senderEmail);
    String senderDepartment = widget.employeeController
        .getEmployeeDepartmentName(notification.senderEmail);
    String senderJobTitle =
    widget.employeeController.getEmployeeJobTitle(notification.senderEmail);

    return GestureDetector(
      onTap: () => _handleViewNotification(notification),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: SizedBox(
                      child: CustomSvgImage(
                        assetPath: _getModuleIcon(notification.nameOfModule),
                        width: 10.w,
                        height: 10.h,
                        color: AppColors.textButton,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.sp),
              // Expanded (not a fixed height): the card lives in a grid tile of
              // a fixed mainAxisExtent, so the body has to absorb whatever room
              // is left over instead of forcing the column past the tile.
              Expanded(
                child: Text(
                  notification.body,
                  maxLines: 2,
                  style: StyleText.fontSize12Weight500.copyWith(
                    height: 1.6,
                      color: AppColors.text,
                      overflow: TextOverflow.ellipsis
                  ),
                ),
              ),
              SizedBox(height: 8.sp),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4.r)),
                      child: Padding(
                        padding: EdgeInsets.all( isMobile ? 4.sp : 8.sp),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Container(
                            width: isMobile ? 30.w : 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            clipBehavior: Clip.hardEdge,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Center(
                                child: CustomSvgImage(
                                    assetPath: "assets/icons_assets/main_icons_assets/male_avatar.svg",
                                    width: isMobile ? 30.w : 40.w,
                                    height:isMobile ? 30.h :  40.h,
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          SizedBox(width: 5.sp),
                          // Flexible + single-line ellipsis: long names and job
                          // titles used to push this column past the chip.
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(FormatHelper.capitalize(senderName),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: isMobile ? StyleText.fontSize10Weight500
                                        .copyWith(color: AppColors.text) :  StyleText.fontSize12Weight500
                                        .copyWith(color: AppColors.text)

                                ),
                                SizedBox(height: 2.sp),
                                Text(FormatHelper.capitalize(senderDepartment),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: isMobile ? StyleText.fontSize8Weight400.copyWith(
                                        color: AppColors.secondaryText) : StyleText.fontSize10Weight500.copyWith(
                                        color: AppColors.secondaryText)),
                                SizedBox(height: 2.sp),
                                Text(FormatHelper.capitalize(senderJobTitle),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: isMobile ? StyleText.fontSize8Weight400.copyWith(
                                        color: AppColors.secondaryText) : StyleText.fontSize10Weight500.copyWith(
                                        color: AppColors.secondaryText))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  ),
                  SizedBox(width: 8.sp),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      customButtonWithSvg(
                        title: s.message,
                        function: () => _handleMessageSender(notification),
                        height: 25.h,
                        color: AppColors.primary,
                        svgColor: AppColors.textButton,
                        textStyle: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.textButton),
                        space: 8,
                        radius: 4.r,
                        image: "assets/icons_assets/main_icons_assets/chat_bubble_dots.svg",
                        widthImage: 16.sp,
                        heightImage: 16.sp,
                        colorBorder: Colors.transparent,
                      ),
                      SizedBox(height: 5.sp),
                      Row(
                        children: [
                          customButtonWithSvg(
                            title: s.pin,
                            function: () => _handlePinToggle(notification),
                            height: 25.h,
                            color: notification.isPinned
                                ? AppColors.secondaryText
                                : AppColors.primary,
                            svgColor: AppColors.textButton,
                            textStyle: StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.textButton),
                            space: 8.sp,
                            radius: 4.r,
                            image:
                            "assets/icons_assets/notification_assets/pushpin.svg",
                            widthImage: 16.sp,
                            heightImage: 16.sp,
                            colorBorder: Colors.transparent,
                          ),
                          SizedBox(width: 6.sp),
                          customButtonWithSvg(
                            title: s.view,
                            function: () =>
                                _handleViewNotification(notification),
                            height: 25.h,
                            color: AppColors.primary,
                            svgColor: AppColors.textButton,
                            textStyle: StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.textButton),
                            space: 8.sp,
                            radius: 4.r,
                            image:
                            "assets/icons_assets/notification_assets/document_search.svg",
                            widthImage: 16.sp,
                            heightImage: 16.sp,
                            colorBorder: Colors.transparent,
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String count, String label,
      {required bool isSelected,
        required Color labelColor,
        required VoidCallback onTap}) {
    var light = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: light
                  ? (isSelected
                  ? AppColors.primary
                  : AppColors.card)
                  : (isSelected
                  ? AppColors.primary
                  : AppColors.card),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    ? StyleText.fontSize14Weight400.copyWith(
                    color: light
                        ? (isSelected
                        ? AppColors.textButton
                        : AppColors.secondaryText)
                        : (isSelected
                        ? AppColors.textButton
                        : AppColors.text))
                    : StyleText.fontSize20Weight500.copyWith(
                    color: light
                        ? (isSelected
                        ? AppColors.textButton
                        : AppColors.secondaryText)
                        : (isSelected
                        ? AppColors.textButton
                        : AppColors.text)),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            label,
            style: isMobile
                ? StyleText.fontSize14Weight600.copyWith(color: labelColor)
                : StyleText.fontSize16Weight600.copyWith(color: labelColor),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}