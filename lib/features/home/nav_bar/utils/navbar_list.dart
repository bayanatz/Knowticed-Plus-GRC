// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:demo_app/features/settings/mode_changer.dart';
// import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
// import 'package:demo_app/core/theme/app_colors.dart';
//
//
// import 'package:demo_app/core/theme/app_font_size.dart';
// import 'package:demo_app/core/widgets/custom_appbar.dart';
// import 'package:demo_app/feature/notification/notification_screen_mobile.dart';
// import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
// import 'package:demo_app/features/skeleton/employees/presentation/ui/pages/mobile/employees_screen_mobile.dart';
// import 'package:demo_app/features/skeleton/home/presentation/ui/pages/mobile/home_screen_mobile.dart';
// import 'package:demo_app/features/skeleton/settings/presentation/ui/pages/settings_screen.dart';
// import 'package:demo_app/core/nav_bar_package.dart/model.dart';
//
// import '../../../external/data_grc_module/core/extensions/extensions.dart';
// import '../../../external/main_core/features/employee/presentation/controller/main_core_employee_controller.dart';
// import '../../roles_module/data/models/role_model.dart';
// import '../../roles_module/presentation/ui/pages/role_responsive_page.dart';
// import '../../roles_module/presentation/ui/pages/role_screen.dart';
// import '../../settings/presentation/controller/settings_controller.dart';
//
// ////////////////////////////////////////////////////
//
// bool hasNotifications = false;
// bool hasSettings = false;
// List<String> screenNames = [];
//
// // List<Widget> buildScreensEmployee(String view) {
// //   Get.put(SettingsController());
// //   employeeNavBarItems = [];
// //
// //   // Core items based on role
// //   List<Widget> navItems = [
// //     const HomeScreenMobile(),
// //     if (view == 'owner') RoleScreen(),
// //   ];
// //
// //   // Get role using RoleHistoryModel
// //   RoleHistoryModel role = roleCubit.roles_module.firstWhere(
// //         (element) => element.currentRoleName == Get.find<MainCoreEmployeeController>().employeeEntity!.role,
// //     orElse: () => throw Exception('Role not found for employee'),
// //   );
// //
// //   // Get selected modules for this role
// //   List<String> selectedModules = role.currentSelectedModules;
// //
// //   screenNames = [
// //     'home',
// //     if (view == 'employee') 'todo',
// //     if (view == 'owner') 'role',
// //   ];
// //
// //   employeeNavBarItems = [
// //     PersistentBottomNavBarItem(
// //         icon: SvgPicture.asset(
// //           'assets/icons_assets/home_assets/newHomeIconFinal.svg',
// //         ),
// //         inactiveIcon: SvgPicture.asset(
// //           'assets/icons_assets/home_assets/newHomeIconFinal.svg',
// //           color: themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite,
// //         ),
// //         title: ("Home".tr),
// //         activeColorPrimary: AppColors.primary,
// //         inactiveColorPrimary:
// //         themeController.currentTheme == AppColors.lightTheme
// //             ? AppColors.colorGreyDark
// //             : AppColors.colorWhite),
// //     if (view == 'employee')
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/clipboardList.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/clipboardList.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("To Do".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     if (view == 'owner')
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/NewRoleIconMobile.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/NewRoleIconMobile.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Roles".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite)
// //   ];
// //
// //   // Helper function to check if module is selected
// //   bool hasModule(String moduleName) {
// //     return selectedModules.contains(moduleName);
// //   }
// //
// //   // Add items based on selected modules
// //   if (hasModule('Employee_Module') && view == 'hr') {
// //     navItems.add(EmployeesScreenMobile());
// //     screenNames.add('employees');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           activeColorSecondary: AppColors.primary,
// //           icon: SvgPicture.asset(
// //             'assets/icons_assets/main_icons_assets/Case.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons_assets/main_icons_assets/Case.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Employees".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check message module permission
// //   if (hasModule('Message_Module')) {
// //     screenNames.add('Inventory');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             "assets/icons_assets/main_icons_assets/DocumentAdd.svg",
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             "assets/icons_assets/main_icons_assets/message_without_notif.svg",
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Inventory".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check task module permission
// //   if (hasModule('Task_Module')) {
// //     screenNames.add('board');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/boredIcon.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/boredIcon.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Boards".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check service module permission
// //   if (hasModule('Service_Module')) {
// //     screenNames.add('service');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/service.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/service.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                   ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Services".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check request module permission
// //   if (hasModule('Reqest_Module')) {
// //     screenNames.add('requests');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/request.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/request.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Requests".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check event module permission
// //   if (hasModule('Event_Module')) {
// //     screenNames.add('events');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons/event.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons/event.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Events".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check note module permission
// //   if (hasModule('Note_Module')) {
// //     screenNames.add('notes');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons/note.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons/note.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Notes".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check form builder module permission
// //   if (hasModule('Form_Builder_Module')) {
// //     screenNames.add('forms');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons/form.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons/form.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Forms".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check database builder module permission
// //   if (hasModule('Database_Builder_Module')) {
// //     screenNames.add('database');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/database.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/database.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Database".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check GRC module permission
// //   if (hasModule('Data_GRC_Module')) {
// //     screenNames.add('grc');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons/grc.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons/grc.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("GRC".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check knowledge hub module permission
// //   if (hasModule('Knowledge_Hub_Module')) {
// //     screenNames.add('knowledge');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons/knowledge.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons/knowledge.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Knowledge".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check tracking module permission
// //   if (hasModule('Time_Tracking_Module')) {
// //     screenNames.add('tracking');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons/tracking.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons/tracking.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Tracking".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check inventory module permission
// //   if (hasModule('Inventory_Module')) {
// //     screenNames.add('inventory');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons/inventory.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons/inventory.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Inventory".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Check todo module permission
// //   if (hasModule('Todo_Module') && view == 'hr' && navItems.length < 5) {
// //     screenNames.add('todo');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/clipboardList.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons_assets/home_assets/clipboardList.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("To Do".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Add fallback items if less than 5 items
// //   if (navItems.length < 5) {
// //     hasNotifications = true;
// //     navItems.add(NotificationScreenMobile(
// //       hasBack: false,
// //     ));
// //     screenNames.add('notification');
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             "assets/icons_assets/main_icons_assets/bellIcon.svg",
// //           ),
// //           inactiveIcon: StreamBuilder<QuerySnapshot>(
// //             stream: appNotificationController.getUnseenNotificationsStream(),
// //             builder: (context, snapshot) {
// //               if (snapshot.connectionState == ConnectionState.waiting) {
// //                 return SvgPicture.asset(
// //                   "assets/icons_assets/main_icons_assets/bellIcon.svg",
// //                   color: themeController.currentTheme == AppColors.lightTheme
// //                       ? AppColors.colorGreyDark
// //                       : AppColors.colorGreydark,
// //                 );
// //               } else if (snapshot.hasError ||
// //                   snapshot.data?.docs.isEmpty == true) {
// //                 return SvgPicture.asset(
// //                   "assets/icons_assets/main_icons_assets/bellIcon.svg",
// //                   color: themeController.currentTheme == AppColors.lightTheme
// //                       ? AppColors.colorGreyDark
// //                       : AppColors.colorGreydark,
// //                 );
// //               } else {
// //                 final unseenCount = snapshot.data?.docs.length ?? 0;
// //                 return Badge(
// //                   textColor: Colors.white,
// //                   label: Text(
// //                     Get.locale.toString().contains('en')
// //                         ? '$unseenCount'
// //                         : convertNumberToArabic('$unseenCount'),
// //                   ),
// //                   largeSize: 16,
// //                   textStyle: AppFontStyle.cairoRegularStyle.copyWith(
// //                     height: 1.3,
// //                     fontSize: FontConstants.fontSize010.h,
// //                     fontWeight: FontWeight.w600,
// //                     color: Theme.of(context).colorScheme.inverseSurface,
// //                   ),
// //                   child: SvgPicture.asset(
// //                     "assets/icons_assets/main_icons_assets/bellIcon.svg",
// //                     color:
// //                     themeController.currentTheme == AppColors.lightTheme
// //                         ? AppColors.colorGreyDark
// //                         : AppColors.colorGreydark,
// //                   ),
// //                 );
// //               }
// //             },
// //           ),
// //           title: ("Notifications".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Ensure SettingsScreen is always at the end of the navigation bar
// //   if (!navItems.any((item) => item is SettingsScreen) && navItems.length < 5) {
// //     navItems.add(SettingsScreen(
// //       hasBack: false,
// //     ));
// //     screenNames.add('settings');
// //     hasSettings = true;
// //     employeeNavBarItems.add(
// //       PersistentBottomNavBarItem(
// //           icon: SvgPicture.asset(
// //             "assets/icons_assets/main_icons_assets/SettingHome.svg",
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             "assets/icons_assets/main_icons_assets/SettingHome.svg",
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Settings".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   // Add EmployeesScreen if still less than 5 items after adding Settings
// //   if (navItems.length < 5) {
// //     print('navItems.length: ${navItems.length}');
// //     navItems.insert(navItems.length - 1, EmployeesScreenMobile());
// //     screenNames.insert(screenNames.length - 1, 'employees');
// //     employeeNavBarItems.insert(
// //       employeeNavBarItems.length - 1,
// //       PersistentBottomNavBarItem(
// //           activeColorSecondary: AppColors.primary,
// //           icon: SvgPicture.asset(
// //             'assets/icons_assets/main_icons_assets/Case.svg',
// //           ),
// //           inactiveIcon: SvgPicture.asset(
// //             'assets/icons_assets/main_icons_assets/Case.svg',
// //             color: themeController.currentTheme == AppColors.lightTheme
// //                 ? AppColors.colorGreyDark
// //                 : AppColors.colorWhite,
// //           ),
// //           title: ("Employees".tr),
// //           activeColorPrimary: AppColors.primary,
// //           inactiveColorPrimary:
// //           themeController.currentTheme == AppColors.lightTheme
// //               ? AppColors.colorGreyDark
// //               : AppColors.colorWhite),
// //     );
// //   }
// //
// //   return navItems;
// // }
// //
// // List<PersistentBottomNavBarItem> employeeNavBarItems = [];
// // List<PersistentBottomNavBarItem> navBarsItemsEmployee() {
// //   return employeeNavBarItems;
// // }