/// Module: services / sv9_admin_dashboard / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: admin_dashboard_page.dart
/// Purpose: The Admin Dashboard: department chips, the service cards of one
///          department, status cards, charts and the requests table, or the
///          department dashboard on the Statistics tab. A thin view — every
///          number comes from DashboardAdminCubit.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): renamed from AdminDashBoardMasterTablet
///     (dashboard_admin.dart) — used on every screen size (Dashboards rules
///     18, 20, 22); the toggle wrapper is gone; both cubits are provided
///     with injected collaborators (rule 3).
library;

import 'package:knowticed_plus/features/services/presentation/widgets/services_load_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_cubit.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_state.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/dashboard_service_grid.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/dashboard_charts_section.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/dashboard_department_filter.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/dashboard_status_cards.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/dashboard_table_action_bar.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/pages/department_dashboard_page.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/presentation/navigation/services_navigation.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/dashboard_master_cubit.dart';

import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/dashboard_tab_bar.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardAdminCubit>(
          create: (context) => DashboardAdminCubit(
            departmentCubit: context.read<MainCoreDepartmentCubit>(),
            employeeController: AppControllers.employee,
            repository: context.read<CreateServicesRepository>(),
          )..bootstrap(),
        ),
        // ONE department-dashboard cubit for the Statistics tab: its data is
        // loaded once and reused when the tab reopens or the department
        // changes (SVC-DASH-15).
        BlocProvider<DashboardMasterCubit>(create: createDashboardMasterCubit),
      ],
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return SlideInContent(
      from: SlideFrom.bottom,
      child: BlocBuilder<DashboardAdminCubit, DashboardAdminState>(
        builder: (context, state) {
          if (!state.bootstrapped) {
            return Scaffold(
              body: SideFrameMasterServices(
                titleText: S.of(context).services,
                onFirstTap: () => Navigator.pop(context),
                // Bug report p.26: the breadcrumb reads "Admin Dashboard" in every
                // state (it said "Dashboard" while loading and on the details page).
                secondTitle: S.of(context).adminDashboard,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(child: CircleProgressMaster()),
                ),
              ),
            );
          }

          // SVC-DASH-01: a failed load shows an error with Retry instead
          // of 0 on every card.
          if (state.loadError) {
            return Scaffold(
              body: SideFrameMasterServices(
                titleText: S.of(context).services,
                onFirstTap: () => Navigator.pop(context),
                secondTitle: S.of(context).adminDashboard,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: ServicesLoadError(
                    message: S.of(context).errorLoadingDashboard,
                    onRetry: context.read<DashboardAdminCubit>().bootstrap,
                  ),
                ),
              ),
            );
          }

          final isMobile = ContextExtension(context).isPhone;
          final lightMode = Theme.of(context).brightness == Brightness.light;

          return Scaffold(
            body: SafeArea(
              child: SideFrameMasterServices(
                titleText: S.of(context).services,
                onFirstTap: context.svcGoHome,
                secondTitle: S.of(context).adminDashboard,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Department Filter ──────────────────────────────────────
                      DashboardDepartmentFilter(state: state),
                      SizedBox(height: 20.sp),

                      // ── Service Grid (filtered dept only) ──────────────────────
                      if (!state.isServiceListLoading &&
                          state.selectStatus != "All" &&
                          state.allServices.isNotEmpty)
                        DashboardServiceGrid(state: state),

                      if (state.selectStatus != "All") SizedBox(height: 32.sp),

                      // ── Status Cards ───────────────────────────────────────────
                      DashboardStatusCards(
                        statusCounts: state.statusCounts,
                        isMobile: isMobile,
                        lightMode: lightMode,
                      ),

                      SizedBox(height: 20.sp),

                      // ── Charts (All only) ──────────────────────────────────────
                      if (state.selectStatus == "All") ...[
                        AdminDashboardChartsSection(state: state),
                        SizedBox(height: 20.sp),
                      ],

                      // ── Table / Stats (All) ────────────────────────────────────
                      if (state.selectStatus == "All") ...[
                        DashboardFilterableRequestsTable(
                          state: state,
                          isMobile: isMobile,
                        ),
                      ],

                      if (state.selectStatus != "All") SizedBox(height: 20.sp),

                      // ── Table / Stats (Filtered dept) ──────────────────────────
                      if (state.selectStatus != "All")
                        _buildFilteredDeptSection(
                          context,
                          state,
                          isMobile,
                          lightMode,
                        ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilteredDeptSection(
    BuildContext context,
    DashboardAdminState state,
    bool isMobile,
    bool lightMode,
  ) {
    final cubit = context.read<DashboardAdminCubit>();

    return Column(
      children: [
        DashboardTabBar(
          showRequests: state.showRequests,
          onRequestsTap: () => cubit.toggleShowRequests(true),
          onStatisticsTap: () => cubit.toggleShowRequests(false),
        ),
        SizedBox(height: 20.sp),
        // The Statistics tab brings its own search/filter/export bar, so the
        // requests bar is only drawn on the Requests tab.
        if (state.showRequests)
          DashboardFilterableRequestsTable(state: state, isMobile: isMobile)
        else
          DepartmentDashboardPage(
            isAdmin: true,
            adminSelectedDepartment: state.selectStatus,
          ),
      ],
    );
  }
}
