// ============================================================================
// COMPLETE WORKING IMPLEMENTATION
// ============================================================================

// FILE 1: role_screen.dart (UPDATED)
// ============================================================================

import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/helpers/circle_progress.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/ui/pages/user_access_container.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/ui/pages/csv.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/pages/role_management_home.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/pages/user_management_home.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/ui/pages/system_logs_table.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:grc_module/core/helper/role/constants.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_controller.dart';
/// Navigator key for the Roles module's nested navigator.
///
/// The app shell (left rail + CustomAppBar) is built by CustomDrawer, which is
/// itself a route on the root MaterialApp navigator. Without a nested navigator
/// here, every `Navigator.of(context).push` inside the roles module resolves to
/// the ROOT navigator and the pushed page covers the whole shell. Wrapping the
/// module in its own Navigator (same pattern as settings_screen.dart) keeps
/// sub-pages — AddingNewRole, RoleDetailsPage, RolePermissionSwitches, the user
/// management details pages — inside the frame.
GlobalKey rolesNavigatorKey = GlobalKey();

/// RoleScreen wrapped in its own Navigator. Use this wherever the roles module
/// is mounted as a drawer/nav destination; use [RoleScreen] directly only when
/// it is already inside a navigator that should own its pushes.
class RoleScreenHost extends StatelessWidget {
  const RoleScreenHost({Key? key, this.selectedIndex}) : super(key: key);
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: rolesNavigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => RoleScreen(selectedIndex: selectedIndex),
      ),
    );
  }
}

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
    userManagementController.getUsersPermissionsData();
    context.read<UserManagementAccessCubit>().getUserAccess();
    context.read<UserAccessCubit>().getAccountsStatusEntities();

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
                screensTitles: [S.of(context).platformControlsAndManagement]),






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
                              Constants.tabletRolePageTabs[visibleTabIndices[i]],
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
        userManagementController.filterUsersPermissionEntity(searchText: "");
        return UserManagementHome();
      case 2:
        return UserAccessHomePage();
      case 3:
        return const CsvView();
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
