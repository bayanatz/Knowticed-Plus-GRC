/// Module: roles / r1_role_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: role_screen.dart
/// Description: Declares `RoleScreenHost`, `RoleScreen`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Header is now SideFrameMasterServices, not PaginationAppBar.
/// Updated: 21/10/2026 - The Active Directory tab shows again when the company
///                      owns the HR module (owner, S-41).
/// Updated: 22/10/2026 - A notification's View opens its record here: the
///                      role's details, the employee's details, or the
///                      account outlined on User Access (owner: View opens
///                      the record, not the module). See [RoleScreen.openRecord].
library;

// ============================================================================
// COMPLETE WORKING IMPLEMENTATION
// ============================================================================

// FILE 1: role_screen.dart (UPDATED)
// ============================================================================

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/permission_label.dart';
// REMOVED 25/8/2026: `pagination_app_bar.dart` — replaced by the shared frame.
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/request_page_approval.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_notification_record.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/helpers/circle_progress.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/pages/user_access_container.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/pages/csv.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/role_management_home.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/user_management_home.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/ui/pages/system_logs_table.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:knowticed_plus/core/helper/access/constants.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_controller.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart'
    show RoleHistoryModel, RoleHistoryModelMethods;
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:collection/collection.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/role_management_module/role_management_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/user_access_module/user_access_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/user_management_module/user_management_notification_pages.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/adding_new_role.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/role_details_page.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/employee_details.dart';

/// Navigator key for the Roles module's nested navigator.
///
/// The app shell (left rail + CustomAppBar) is built by CustomDrawer, which is
/// itself a route on the root MaterialApp navigator. Without a nested navigator
/// here, every `Navigator.of(context).push` inside the roles module resolves to
/// the ROOT navigator and the pushed page covers the whole shell. Wrapping the
/// module in its own Navigator (same pattern as settings_screen.dart) keeps
/// sub-pages — AddingNewRole, RoleDetailsPage, RolePermissionSwitches, the user
/// management details pages — inside the frame.
///
/// CHANGED 22/10/2026: the key was one global `rolesNavigatorKey`. When the
/// drawer remounted this module (a calendar card / notification asking for a
/// tab), Flutter MOVED the old navigator and its RoleScreen instead of building
/// new ones, so the requested tab was never read; and a second Roles page in
/// the phone's Roles tab would have shared the key. Each host now owns its key.

/// RoleScreen wrapped in its own Navigator. Use this wherever the roles module
/// is mounted as a drawer/nav destination; use [RoleScreen] directly only when
/// it is already inside a navigator that should own its pushes.
class RoleScreenHost extends StatefulWidget {
  const RoleScreenHost({super.key, this.selectedIndex});
  final int? selectedIndex;

  /// Tab this module should open on, set by whoever is about to navigate here.
  ///
  /// Added 22/8/2026 so a notification can land the user on the right tab.
  /// `Modules.roles` is one drawer entry covering five tabs (Role Management,
  /// User Management, User Access, Active Directory, System Logs), and
  /// `modules_enum.dart` builds `RoleScreenHost()` with no index — so an
  /// account-locked notification, which belongs to User Access, dropped the
  /// admin on Role Management with no hint of where to go next.
  ///
  /// A static rather than a constructor argument because the caller is the
  /// notification inbox, which does not build this widget: it asks
  /// AppDrawerCubit to select the Roles entry, and `modules_enum` constructs
  /// the host afterwards. Indices match [Constants.tabletRolePageTabs].
  ///
  /// Consumed once and cleared by [RoleScreen], so it cannot silently pin the
  /// module to one tab for the rest of the session. It is honoured only if the
  /// user's permissions make that tab visible.
  static int? pendingInitialTab;

  @override
  State<RoleScreenHost> createState() => _RoleScreenHostState();
}

class _RoleScreenHostState extends State<RoleScreenHost> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// The tab to open on: the constructor's, else a request left in
  /// [RoleScreenHost.pendingInitialTab] (consumed here, once).
  late final int? _openOnTab;

  /// The record a notification's View asked for (consumed here, once).
  late final PendingNotificationRecord? _openRecord;

  @override
  void initState() {
    super.initState();
    final int? pending = RoleScreenHost.pendingInitialTab;
    RoleScreenHost.pendingInitialTab = null;
    _openOnTab = widget.selectedIndex ?? pending;
    _openRecord = PendingNotificationRecord.take(Modules.roles);
  }

  @override
  Widget build(BuildContext context) {
    // WATERMARK 25/8/2026. This host is the whole of `Modules.roles` —
    // `modules_enum.dart` builds exactly one `RoleScreenHost()` for every form
    // factor — so one wrap here covers the module.
    //
    // The layer sits ABOVE the nested Navigator on purpose. Everything the
    // module pushes (AddingNewRole, RoleDetailsPage, RolePermissionSwitches,
    // the user-management detail pages) goes into THIS navigator by design —
    // that is the whole reason it exists — so stamping above it covers all five
    // tabs and every page reachable from them, and a roles page added later is
    // watermarked without touching this file.
    // `module: Modules.roles` ADDED 28/9/2026 — without it this layer always
    // stamped, whatever the Roles tile in the Watermark grid said.
    return WatermarkLayer(
      module: Modules.roles,
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => RoleScreen(
            selectedIndex: _openOnTab,
            openRecord: _openRecord,
          ),
        ),
      ),
    );
  }
}

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key, this.selectedIndex, this.openRecord});
  final int? selectedIndex;

  /// The record a notification's View asked for, opened once the screen has
  /// loaded — only when its tab is the one shown (the user may see it).
  /// `recordId` is a role id (Role Management) or the account's email
  /// (User Management, User Access); `pageKey` says which tab and page.
  /// Pages are pushed on this module's navigator, so Back lands on the tab.
  final PendingNotificationRecord? openRecord;

  /// The tab [record] belongs to, from its `pageKey`; null when unknown.
  /// Indices match [Constants.tabletRolePageTabs].
  static int? tabForRecord(PendingNotificationRecord record) {
    final String key = record.pageKey;
    if (RoleManagementNotificationPage.fromKey(key) != null) return 0;
    if (UserManagementNotificationPage.fromKey(key) != null) return 1;
    // 22/10/2026 — a change request waiting for review lives in User
    // Management → Requests.
    if (SettingsNotificationRecord.isReviewPage(key)) return 1;
    if (UserAccessNotificationPage.fromKey(key) != null) return 2;
    return null;
  }

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
    controller = AppControllers.employee;

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

    // Set initial selected index.
    //
    // Precedence: an explicit constructor argument, then a deep link left by
    // whoever navigated here (see RoleScreenHost.pendingInitialTab), then the
    // first tab this user is allowed to see. The deep link is consumed here so
    // it applies exactly once.
    final int? requestedTab =
        widget.selectedIndex ?? RoleScreenHost.pendingInitialTab;
    RoleScreenHost.pendingInitialTab = null;

    if (requestedTab != null && visibleTabIndices.contains(requestedTab)) {
      selectedIndex = requestedTab;
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

    // The screen can be closed while permissions load (e.g. a window resize
    // swaps the layout) — then there is nothing left to update.
    if (!mounted) return;
    // Owner 21/10/2026: the opening tab's one-time work runs here, not in build.
    _onTabEntered(selectedIndex);

    // A notification's record — only on its own tab, which the user's
    // permissions made visible. User Access is told before the tab builds.
    final PendingNotificationRecord? record = widget.openRecord;
    final bool openRecord =
        record != null && RoleScreen.tabForRecord(record) == selectedIndex;
    if (openRecord && selectedIndex == 2) {
      context.read<UserAccessCubit>().focusAccount(record.recordId);
    }

    setState(() {
      isLoading = false;
    });
    _showSelectedTab();

    if (openRecord && selectedIndex == 0) await _openRole(record);
    if (openRecord &&
        selectedIndex == 1 &&
        SettingsNotificationRecord.isReviewPage(record.pageKey)) {
      _openReviewRequest(record);
    } else if (openRecord && selectedIndex == 1) {
      await _openEmployee(record);
    }
  }

  /// Function Name: [_openReviewRequest]
  ///
  /// Purpose: A change request waiting for this reviewer (owner 22/10/2026):
  /// User Management → Requests → the request, so Back goes to the Requests
  /// queue, then to User Management.
  void _openReviewRequest(PendingNotificationRecord record) {
    final NavigatorState navigator = Navigator.of(context);
    navigator.push(
        MaterialPageRoute<void>(builder: (_) => const RequestPageApproval()));
    navigator.push(MaterialPageRoute<void>(
        builder: (_) => SettingsNotificationRecord.pageFor(
            requestId: record.recordId, pageKey: record.pageKey)));
  }

  /// Function Name: [_openRole]
  ///
  /// Purpose: Open the notification's role, as tapping its card does — its
  /// details (a draft opens in the editor), and on top of them the editor
  /// when the notification says the role was edited.
  ///
  /// A role that is gone (deleted since) is not in the list, so the admin
  /// stays on Role Management. Role-deleted notifications carry no id at all.
  ///
  /// Parameters:
  /// - [record]: `recordId` is the role document id.
  ///
  /// Returns: [Future<void>]
  Future<void> _openRole(PendingNotificationRecord record) async {
    final RoleCubit cubit = context.read<RoleCubit>();
    // The list's own roles (deleted and Master Admin already left out).
    final RoleHistoryModel? role = cubit.filteredRoles.firstWhereOrNull(
      (RoleHistoryModel r) => r.roleId == record.recordId,
    );
    if (role == null) return;

    await cubit.selectRole(role);
    if (!mounted) return;

    final NavigatorState navigator = Navigator.of(context);
    Route<void> page(Widget child) => MaterialPageRoute<void>(
          builder: (_) =>
              BlocProvider<RoleCubit>.value(value: cubit, child: child),
        );

    if (role.currentStatus == RoleStatus.draft) {
      navigator.push(page(AddingNewRole()));
      return;
    }
    navigator.push(page(RoleDetailsPage()));
    if (RoleManagementNotificationPage.fromKey(record.pageKey) ==
        RoleManagementNotificationPage.editingRolePage) {
      navigator.push(page(AddingNewRole()));
    }
  }

  /// Function Name: [_openEmployee]
  ///
  /// Purpose: Open the notification's employee's details (their access and
  /// permissions), as tapping their card on User Management does.
  ///
  /// An employee who no longer holds any access (revoked since) is not in the
  /// list, so the admin stays on User Management.
  ///
  /// Parameters:
  /// - [record]: `recordId` is the employee's email (or employee id).
  ///
  /// Returns: [Future<void>]
  Future<void> _openEmployee(PendingNotificationRecord record) async {
    if (userManagementController.usersPermissionEntity.isEmpty) {
      await userManagementController.getUsersPermissionsData();
    }
    if (!mounted) return;

    final String key = record.recordId.toLowerCase();
    final UserPermissionEntity? employee =
        userManagementController.usersPermissionEntity.firstWhereOrNull(
      (UserPermissionEntity u) =>
          u.employeeEmail.trim().toLowerCase() == key ||
          u.employeeId.trim().toLowerCase() == key,
    );
    if (employee == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoleEmployeeDetailsPage(userPermission: employee),
      ),
    );
  }

  /// Owner 21/10/2026: one-time work when a tab is entered — was inside
  /// indexContainer (build), so it re-ran on every rebuild (a new 'open Logs'
  /// entry + geolocation each time, and tab 1's selection reset each time).
  void _onTabEntered(int index) {
    switch (index) {
      case 1:
        roleCubit.selectedRole = null;
        userManagementController.filterUsersPermissionEntity(searchText: "");
        break;
      case 4:
        AppControllers.systemLogs.systemLogsAction(
          'open Logs',
          module: Modules.roles,
        );
        break;
    }
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

    // ── Active Directory ──────────────────────────────────────────────────
    //
    // CHANGED 21/10/2026 (owner, S-41): the tab shows whenever the role has
    // the permission, whether or not the company owns the HR module. The
    // 30/8/2026 "HR present ⇒ hide the tab" gate is removed.
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
    // REMOVED 25/8/2026: a local `isTablet` that nothing in this method read.
    // The frame does its own breakpoint work.

    // ✅ Show loading indicator while everything loads
    if (isLoading) {
      return Scaffold(body: Center(child: CircleProgressMaster()));
    }

    // FRAME 25/8/2026: the page header is now the shared
    // [SideFrameMasterServices] instead of `PaginationAppBar`, so the roles
    // module wears the same breadcrumb as the rest of the app (and the same one
    // its own sub-pages already use — see `employee_details_methods2.dart`).
    //
    // No `secondTitle` here: this IS the module's root screen, and the frame
    // only draws the back chevron when a deeper crumb is supplied.
    //
    // The frame also owns the 15.sp horizontal padding the page used to apply
    // itself, so the manual `Padding` is gone.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints pageConstraints) {
            return SideFrameMasterServices(
              // Role QA p.2: on a phone the long title was cut to
              // "Platform Controls and Manage..."; the shorter title fits.
              titleText: ContextExtension(context).isPhone
                  ? S.of(context).controlsAndManagement
                  : S.of(context).platformControlsAndManagement,
              child: _buildTabsAndContent(pageConstraints.maxHeight),
            );
          },
        ),
      ),
    );
  }

  /// The tab strip and the selected tab's page.
  ///
  /// [pageHeight] is the bounded height of the whole screen, measured OUTSIDE
  /// the frame — it is only consulted on the phone branch, see below.
  ///
  /// WHY THE HEIGHT DANCE
  /// --------------------
  /// [SideFrameMasterServices] lays its child out two different ways. On tablet
  /// and desktop the child goes into an `Expanded`, so it arrives with a bounded
  /// height and the `Expanded` below works normally. On a phone the frame wraps
  /// the child in a `SingleChildScrollView`, so the incoming height is
  /// UNBOUNDED — and an `Expanded` under an unbounded constraint throws
  /// ("RenderFlex children have non-zero flex but incoming height constraints
  /// are unbounded").
  ///
  /// Every tab this hosts (RoleManagementHome, UserManagementHome, the user
  /// access and logs tables) uses `Expanded` internally and therefore needs a
  /// bounded height. So on the phone branch the content is given one
  /// explicitly, leaving room for the frame's own header.
  Widget _buildTabsAndContent(double pageHeight) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget body = _tabsAndSelectedPage();

        if (constraints.hasBoundedHeight) return body;

        // Phone branch. `_phoneFrameHeaderHeight` is the frame's title row plus
        // the 20.sp gap it puts under it; the clamp keeps the content usable on
        // a very short viewport rather than collapsing to nothing.
        final double available = (pageHeight - _phoneFrameHeaderHeight).clamp(
          200.sp,
          pageHeight,
        );
        return SizedBox(height: available, child: body);
      },
    );
  }

  /// Height of [SideFrameMasterServices]'s phone header: 15.sp top padding +
  /// 10.h vertical padding either side of a `fontSize24Weight600` title, plus
  /// the 20.sp spacer the frame adds beneath it.
  double get _phoneFrameHeaderHeight => 90.sp;

  /// The selected tab in the strip — see [_showSelectedTab].
  final GlobalKey _selectedTabKey = GlobalKey();

  /// Scrolls the tab strip so the selected tab is visible.
  void _showSelectedTab() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? tab = _selectedTabKey.currentContext;
      if (tab != null) {
        Scrollable.ensureVisible(tab,
            alignment: 0.5, duration: const Duration(milliseconds: 250));
      }
    });
  }

  Widget _tabsAndSelectedPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 32.sp,
            children: [
              for (int i = 0; i < visibleTabIndices.length; i++)
                GestureDetector(
                  // 22/10/2026 — the selected tab scrolls into view (a
                  // calendar card / notification opening on User Access left
                  // it hidden off the phone's edge).
                  key: selectedIndex == visibleTabIndices[i]
                      ? _selectedTabKey
                      : null,
                  onTap: () {
                    HapticController.low(); // list row: on the tap (X-117)
                    if (selectedIndex != visibleTabIndices[i]) {
                      setState(() {
                        selectedIndex = visibleTabIndices[i];
                      });
                      _onTabEntered(selectedIndex);
                    }
                  },
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          // FIXED 13/8/2026: Constants.tabletRolePageTabs
                          // is a hardcoded English List<String>. The
                          // list stays canonical (its indices drive
                          // selectedIndex -> indexContainer); only the
                          // rendered text is translated.
                          PermissionLabel.of(
                            context,
                            Constants.tabletRolePageTabs[visibleTabIndices[i]],
                          ),
                          style: StyleText.fontSize20Weight500
                              .copyWith(color: AppColors.secondaryBlack)
                              .copyWith(
                                height: 1.3,
                                color: selectedIndex == visibleTabIndices[i]
                                    ? AppColors.primary
                                    : AppColors.secondaryBlack,
                              ),
                        ),
                        SizedBox(height: 1.h),
                        if (selectedIndex == visibleTabIndices[i])
                          Container(height: 1.5.sp, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 30.sp),
        Expanded(child: indexContainer(selectedIndex)),
        SizedBox(height: 20.sp),
      ],
    );
  }

  Widget indexContainer(int index) {
    switch (index) {
      case 0:
        return PlatFormRoleContainer.roleManagementHome();
      case 1:
        return UserManagementHome();
      case 2:
        return UserAccessHomePage();
      case 3:
        return const CsvView();
      case 4:
        return SystemLogsTable();
      default:
        return Container();
    }
  }
}
