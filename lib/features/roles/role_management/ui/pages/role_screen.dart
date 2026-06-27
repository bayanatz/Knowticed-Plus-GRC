// ============================================================================
// COMPLETE WORKING IMPLEMENTATION
// ============================================================================

// FILE 1: role_screen.dart (UPDATED)
// ============================================================================

import 'package:demo_app/core/helper/main_helper/circle_progress.dart';
import 'package:demo_app/features/roles/active_directory/ui/pages/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/pagination_app_bar.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/helpers/circle_progress.dart';
import 'package:demo_app/features/roles/account_status/ui/pages/user_access_container.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/role_management_home.dart';
import 'package:demo_app/features/roles/user_management/ui/pages/user_management_home.dart';
import 'package:demo_app/features/roles/system_logs/ui/pages/system_logs_table.dart';
import 'package:demo_app/generated/l10n.dart';

import 'package:demo_app/features/roles/helper/form_builder_module/core/constants/strings.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_cubit.dart';
import 'package:demo_app/features/roles/system_logs/controller/system_logs_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:demo_app/features/roles/role_management/utils/constants.dart';
import 'package:demo_app/features/roles/user_management/controller/user_management_cubit.dart';
import 'package:demo_app/features/roles/user_management/controller/user_role_controller.dart';
import 'role_responsive_page.dart';

class RoleScreen extends StatefulWidget {
  RoleScreen({Key? key, this.selectedIndex}) : super(key: key);
  final int? selectedIndex;

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  int selectedIndex = 0;
  List<int> visibleTabIndices = [];
  late MainCoreEmployeeController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
//
    controller = Get.find<MainCoreEmployeeController>();

    // Load data first
    Get.find<EmployeeRoleController>().getUsersPermissionsData();
    context.read<UserManagementAccessCubit>().getUserAccess();
    context.read<AccountStatusCubit>().getAccountsStatusEntities();

    // ✅ Initialize everything including role permissions
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    final roleCubit = context.read<RoleCubit>();

    // Wait a bit to ensure permissions are loaded
    await Future.delayed(Duration(milliseconds: 500));

    // Force reload permissions to ensure cache is populated
    await controller.loadEmployeeRole();

    // Now check permissions and build visible tabs
    _buildVisibleTabs();

    // Set initial selected index
    if (widget.selectedIndex != null &&
        visibleTabIndices.contains(widget.selectedIndex)) {
      selectedIndex = widget.selectedIndex!;
    } else if (visibleTabIndices.isNotEmpty) {
      selectedIndex = visibleTabIndices.first;
    }

    // ✅ CRITICAL: Load all roles first
    await roleCubit.getUnDeletedRoles();

    // ✅ Filter out Master Admin and Operational roles
    roleCubit.filteredRoles.removeWhere((role) {
      String roleName = role.currentRoleName.toLowerCase();
      String roleNameAr = role.currentRoleNameAr.toLowerCase();

      return roleName == 'master admin' || roleNameAr == 'مسؤول رئيسي';
    });


    // ✅ CRITICAL: Preload ALL role permissions before showing screen
    if (selectedIndex == 0) {
      await roleCubit.preloadAllRolePermissions();
    }

    setState(() {
      isLoading = false;
    });
  }

  void _buildVisibleTabs() {
    visibleTabIndices.clear();

    final hasRoleManagementPermission = controller.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.roleManagement,
      permission: null,
    );
    if (hasRoleManagementPermission) {
      visibleTabIndices.add(0);
    }

    final hasUserManagementPermission = controller.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userManagement,
      permission: null,
    );
    if (hasUserManagementPermission) {
      visibleTabIndices.add(1);
    }

    final hasUserAccessPermission = controller.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.userAccess,
      permission: null,
    );
    if (hasUserAccessPermission) {
      visibleTabIndices.add(2);
    }

    final hasActiveDirectoryPermission = controller.isHasPermission(
      module: Modules.roles,
      section: RolePermissionsSections.activeDirectory,
      permission: null,
    );
    if (hasActiveDirectoryPermission) {
      visibleTabIndices.add(3);
    }

    visibleTabIndices.add(4);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    // ✅ Show loading indicator while everything loads
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircleProgress(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsetsDirectional.only(start: 15.sp, end: 15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaginationAppBar(
                screensTitles: ["Platform Controls and Management".tr]),






            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 32.sp,
                children: [
                  for (int i = 0; i < visibleTabIndices.length; i++)
                    GestureDetector(
                      onTap: () {
                        if (selectedIndex != visibleTabIndices[i]) {
                          setState(() {
                            selectedIndex = visibleTabIndices[i];
                          });
                        }
                      },
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              Constants.tabletRolePageTabs[visibleTabIndices[i]].tr,
                              style: AppTextStyles.font20SecondaryBlackMediumCairo.copyWith(
                                height: 1.3,
                                color: selectedIndex == visibleTabIndices[i]
                                    ? AppColors.primary
                                    : AppColors.secondaryBlack,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            if (selectedIndex == visibleTabIndices[i])
                              Container(
                                height: 1.5.sp,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
            SizedBox(height: 30.sp),
            Expanded(child: indexContainer(selectedIndex)),
            SizedBox(height: 20.sp),
          ],
        ),
      )),
    );
  }

  Widget indexContainer(int index) {
    switch (index) {
      case 0:
        return PlatFormRoleContainer.RoleManagementHome();
      case 1:
        roleCubit.selectedRole = null;
        Get.find<EmployeeRoleController>()
            .filterUsersPermissionEntity(searchText: "");
        return UserManagementHome();
      case 2:
        return UserAccessHomePage();
      case 3:
        return CsvView();
      case 4:
        Get.find<SystemLogsController>().systemLogsAction(
          'open Logs',
          module: Modules.roles,
        );
        return SystemLogsTable();
      default:
        return Container();
    }
  }
}
