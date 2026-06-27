import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/shared_action_widgets.dart';
// new_theme imported from main_core above
import 'package:demo_app/features/notification/core_widgets/main_widget/side_frame_master.dart';
import 'package:lottie/lottie.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:demo_app/core/helper/main_helper/cross_axis_count_helper.dart';
import '../../generated/l10n.dart';
// using package:demo_app/core/widgets/custom_svg.dart (already imported)

import '../../core/theme/app_colors.dart';
import '../employee/presentation/controller/main_core_employee_controller.dart';
// shared_action_widgets.dart already imported above
// shared_action_widgets.dart already imported above
import '../home/app_drawer/presentation/controller/drawer_controller.dart';
import 'data/models/notification_data_model.dart';
import 'data/repository/notification_services.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';

// ✅ CLEANED NOTIFICATIONS PAGE - Shows only isClean == true
class CleanedNotificationLandPage extends StatefulWidget {
  const CleanedNotificationLandPage({super.key});

  @override
  State<CleanedNotificationLandPage> createState() => _CleanedNotificationLandPageState();
}

class _CleanedNotificationLandPageState extends State<CleanedNotificationLandPage> {
  final FirestoreNotificationService _notificationService = FirestoreNotificationService();
  final MainCoreEmployeeController _employeeController = Get.find<MainCoreEmployeeController>();

  String? _currentUserEmail;
  List<Modules> _allowedModules = [];

  @override
  void initState() {
    super.initState();
    _currentUserEmail = _employeeController.employeeEntity?.email;
    _loadAllowedModules();
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: User email not found',
            style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
          ),
        ),
      );
    }

    return Scaffold(
      body: SideFrameMaster(
        titleText: s.notifications,
        onFirstTap: () {
          final appDrawerController = Get.find<AppDrawerController>();
          appDrawerController.updateSelectedIndex(19);
        },
        secondTitle: s.cleared,
        child: StreamBuilder<List<NotificationModelSystem>>(
          stream: _notificationService.streamNotificationsForUser(_currentUserEmail!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading notifications: ${snapshot.error}',
                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
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
  TextEditingController searchController = TextEditingController();
  String sortOrder = "newest";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ✅ ONLY show CLEANED notifications (isClean == true) - EXACT MATCH TO MAIN PAGE
  List<NotificationModelSystem> _getFilteredNotifications() {
    List<NotificationModelSystem> filtered = widget.allNotifications;

    // ✅ DEBUG: Print all notifications before filtering
    debugPrint('📊 [CLEARED PAGE] Total notifications received: ${filtered.length}');
    for (var n in filtered) {
      debugPrint('📌 [CLEARED PAGE] Module: ${n.nameOfModule}, Title: ${n.title}, isPinned: ${n.isPinned}, isClean: ${n.isClean}');
    }

    // ✅ ONLY show CLEANED notifications (isClean == true)
    filtered = filtered.where((n) => n.isClean == true).toList();
    debugPrint('📊 [CLEARED PAGE] After filtering isClean=true: ${filtered.length}');

    // ✅ FIXED: Module filter with better debugging (EXACT MATCH TO MAIN PAGE)
    if (selectStatus != "All") {
      String moduleFilter = _getModuleKeyFromName(selectStatus);
      debugPrint('🔍 [CLEARED PAGE] Filtering by module: $selectStatus -> $moduleFilter');

      filtered = filtered.where((n) {
        bool matches = n.nameOfModule.toLowerCase() == moduleFilter.toLowerCase();
        debugPrint('  [CLEARED PAGE] Checking: ${n.nameOfModule} == $moduleFilter ? $matches');
        return matches;
      }).toList();

      debugPrint('📊 [CLEARED PAGE] After module filter: ${filtered.length}');
    }

    // Search filter
    if (searchController.text.isNotEmpty) {
      String query = searchController.text.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(query) ||
            n.body.toLowerCase().contains(query);
      }).toList();
      debugPrint('📊 [CLEARED PAGE] After search filter: ${filtered.length}');
    }

    // Sort by timestamp
    filtered.sort((a, b) {
      if (sortOrder == "newest") {
        return (b.timestamp ?? 0).compareTo(a.timestamp ?? 0);
      } else {
        return (a.timestamp ?? 0).compareTo(b.timestamp ?? 0);
      }
    });

    debugPrint('📊 [CLEARED PAGE] Final filtered count: ${filtered.length}');
    return filtered;
  }

  // ✅ FIXED: Better module name matching (EXACT MATCH TO MAIN PAGE)
  String _getModuleKeyFromName(String displayName) {
    debugPrint('🔑 [CLEARED PAGE] Looking for module key for: $displayName');

    for (Modules module in widget.allowedModules) {
      if (module.getModuleName == displayName) {
        String key = _moduleEnumToKey(module);
        debugPrint('✅ [CLEARED PAGE] Found match: $displayName -> $key');
        return key;
      }
    }

    debugPrint('❌ [CLEARED PAGE] No match found for: $displayName');
    return displayName.toLowerCase();
  }

  // ✅ FIXED: Ensure exact match with Firebase naming (EXACT MATCH TO MAIN PAGE)
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
        return 'formBuilder'; // ✅ Changed from 'form_builder'
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

  // ✅ Count ONLY cleaned notifications (EXACT MATCH TO MAIN PAGE)
  Map<String, int> _getNotificationCountsByModule() {
    Map<String, int> counts = {'all': 0};

    for (Modules module in widget.allowedModules) {
      String key = _moduleEnumToKey(module);
      counts[key] = 0;
    }

    for (var notification in widget.allNotifications) {
      // ✅ ONLY count CLEANED notifications
      if (!notification.isClean) continue;

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

    debugPrint('📊 [CLEARED PAGE] Module counts: $counts');
    return counts;
  }

  // ✅ RESTORE notification - set isClean to false
  Future<void> _handleRestore(NotificationModelSystem notification) async {
    try {
      // ✅ Set isClean to false (restore notification)
      await widget.notificationService.updateCleanStatus(notification.id!, false);

      if (context.mounted) {
        Get.snackbar(
          'Success',
          'Notification restored successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Get.snackbar(
          'Error',
          'Failed to restore notification',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.red?.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
      debugPrint('❌ Error restoring notification: $e');
    }
  }

  // ✅ DELETE permanently
  Future<void> _handleDelete(NotificationModelSystem notification) async {
    final s = S.of(context);
    final confirmed = await CustomConfirmationDialog.show(
      context: context,
      title: 'Delete Notification',
      message: 'Are you sure you want to permanently delete this notification?',
      lottieAsset: 'assets/lottie/trash.json',
      confirmText: s.yes,
      cancelText: s.no,
      confirmButtonColor: AppColors.primary ?? AppColors.primary,
    );

    if (confirmed) {
      try {
        await widget.notificationService.deleteNotification(notification.id!);
      } catch (e) {
        if (context.mounted) {
          Get.snackbar(
            'Error',
            'Failed to delete notification',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.red?.withOpacity(0.8),
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
        debugPrint('❌ Error deleting notification: $e');
      }
    }
  }

  // ✅ FIXED: Simplified navigation (EXACT MATCH TO MAIN PAGE)
  void _handleViewNotification(NotificationModelSystem notification) {
    debugPrint('🔔 [CLEARED PAGE] Attempting navigation for: ${notification.nameOfPage}');
    debugPrint('📦 [CLEARED PAGE] Module: ${notification.nameOfModule}');

    // Map module name to Modules enum
    Modules? targetModule = _getModuleFromString(notification.nameOfModule);

    if (targetModule == null) {
      debugPrint('❌ [CLEARED PAGE] Could not find module for: ${notification.nameOfModule}');
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
      final appDrawerController = Get.find<AppDrawerController>();
      int moduleIndex = appDrawerController.allowedDrawerModules.indexOf(targetModule);

      if (moduleIndex == -1) {
        debugPrint('❌ [CLEARED PAGE] Module ${targetModule.name} not in allowed modules');
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

      debugPrint('✅ [CLEARED PAGE] Navigated to ${targetModule.name} at index $moduleIndex');

    } catch (e) {
      debugPrint('❌ [CLEARED PAGE] Navigation error: $e');
      Get.snackbar(
        'Error',
        'Failed to navigate: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red?.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // ✅ NEW: Convert string to Modules enum (EXACT MATCH TO MAIN PAGE)
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
      case 'form_builder':
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

  String _getModuleIcon(String moduleName) {
    Modules? module = _getModuleFromString(moduleName);
    if (module != null) {
      return module.iconPath;
    }
    return "assets/notification_module/services_Info.svg";
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.sizeOf(context).width >= 900;
    var isMobile = context.isPhone;
    final s = S.of(context);

    List<NotificationModelSystem> filteredNotifications = _getFilteredNotifications();
    Map<String, int> moduleCounts = _getNotificationCountsByModule();

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // Search and Sort
          Row(
            children: [
              AppSearchTextField(
                controller: searchController,
                onChanged: (val) => setState(() {}),
              ),
              SizedBox(width: 15.w),
              CustomPopupMenuButton(
                title: isMobile ? "" : s.sort,
                iconPath: "assets/images/Sort_services.svg",
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
            ],
          ),
          SizedBox(height: 15.sp),

          // Grid or Empty
          filteredNotifications.isEmpty
              ? Center(
            child: Padding(
              padding: EdgeInsets.all(40.sp),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50.h),
                    Lottie.asset(
                      'assets/lottie/empty.json',
                      width: 250.w,
                      height: 250.h,
                      fit: BoxFit.fill,
                      repeat: true,
                    ),
                  ],
                ),
              ),
            ),
          )
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              mainAxisExtent: 140.sp,
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

  Widget _buildNotificationCard(NotificationModelSystem notification, bool isMobile, S s) {
    String senderName = widget.employeeController.getEmployeeName(notification.senderEmail);
    String senderDepartment = widget.employeeController.getEmployeeDepartmentName(notification.senderEmail);
    String senderJobTitle = widget.employeeController.getEmployeeJobTitle(notification.senderEmail);

    return GestureDetector(
      onTap: () => _handleViewNotification(notification),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.secondaryText.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryText.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: CustomSvg(
                      assetPath: _getModuleIcon(notification.nameOfModule),
                      width: 15.w,
                      height: 15.h,
                      color: AppColors.textButton,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.sp),
              Text(
                notification.body,
                maxLines: 1,
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 15.sp),
              Row(
                children: [
                  Container(
                    height: 55.sp,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            clipBehavior: Clip.hardEdge,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Center(
                                child: CustomSvg(
                                  assetPath: "assets/male.svg",
                                  width: 40.w,
                                  height: 40.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5.sp),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(senderName, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText)),
                              SizedBox(height: 3.sp),
                              Text(senderDepartment, style: StyleText.fontSize10Weight500.copyWith(color: AppColors.secondaryText)),
                              SizedBox(height: 3.sp),
                              Text(senderJobTitle, style: StyleText.fontSize10Weight500.copyWith(color: AppColors.secondaryText))
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  Column(
                    children: [
                      customButtonWithImage(
                        title: S.of(context).restore,
                        function: () => _handleRestore(notification),
                        padding: EdgeInsets.symmetric(horizontal: 42.5.sp),
                        height: 25.h,
                        color: AppColors.primary,
                        svgColor: AppColors.textButton,
                        textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
                        space: 8,
                        radius: 4.r,
                        image: "assets/notification_module/new_view_icon.svg",
                        widthImage: 16.sp,
                        heightImage: 16.sp,
                        colorBorder: Colors.transparent,
                      ),
                      SizedBox(height: 5.sp),
                      Row(
                        children: [
                          customButtonWithImage(
                            title: S.of(context).delete,
                            function: () => _handleDelete(notification),
                            padding: EdgeInsets.symmetric(horizontal: 8.sp),
                            height: 25.h,
                            color: AppColors.red ?? AppColors.secondaryText,
                            svgColor: AppColors.white,
                            textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
                            space: 8.sp,
                            radius: 4.r,
                            image: "assets/notification_module/clean_icon_all.svg",
                            widthImage: 16.sp,
                            heightImage: 16.sp,
                            colorBorder: Colors.transparent,
                          ),
                          SizedBox(width: 6.sp),
                          customButtonWithImage(
                            title: s.view,
                            function: () => _handleViewNotification(notification),
                            padding: EdgeInsets.symmetric(horizontal: 8.sp),
                            height: 25.h,
                            color: AppColors.primary,
                            svgColor: AppColors.textButton,
                            textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
                            space: 8.sp,
                            radius: 4.r,
                            image: "assets/notification_module/new_view_icon.svg",
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

  Widget _statusChip(String count, String label, {required bool isSelected, required Color labelColor, required VoidCallback onTap}) {
    var light = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: light ? (isSelected ? AppColors.primary : AppColors.card) : (isSelected ? AppColors.primary : AppColors.card),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    ? StyleText.fontSize14Weight400.copyWith(
                    color: light
                        ? (AppColors.secondaryText)
                        : (isSelected ? AppColors.textButton : AppColors.text))
                    : StyleText.fontSize20Weight500.copyWith(
                    color: light
                        ? (isSelected ? AppColors.textButton : AppColors.secondaryText)
                        : (isSelected ? AppColors.textButton : AppColors.text))
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            label,
            style: isMobile ? StyleText.fontSize14Weight600.copyWith(color: labelColor) : StyleText.fontSize16Weight600.copyWith(color: labelColor),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}