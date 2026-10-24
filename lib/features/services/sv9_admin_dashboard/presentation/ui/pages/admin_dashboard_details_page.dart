/// Module: services / sv9_admin_dashboard / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: admin_dashboard_details_page.dart
/// Purpose: The Admin Dashboard's page for one service — a thin shell over
///          DashboardDetailsCubit and its section widgets.
/// Author: Amr Mesbah / Knowticed Team
/// Created At: 05/03/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): renamed from AdminDashBoardDetailsTablet
///     (dashboard_details_admin.dart) — used on every screen size
///     (Dashboards rules 20, 22); the toggle wrapper is gone; the repository
///     is injected, not created here (rule 3).
library;

import 'package:knowticed_plus/features/services/presentation/widgets/services_load_error.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/dashboard_details_cubit.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/dashboard_details_state.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/details_action_bar.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/details_pie_charts_section.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/details_tab_bar.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/details_table_section.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/dashboard_admin_details_export_widget.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/number_of_services.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

class AdminDashboardDetailsPage extends StatelessWidget {
  final String? header;
  final String? selectedServiceName;

  const AdminDashboardDetailsPage({
    super.key,
    this.header,
    this.selectedServiceName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardDetailsCubit(
        repository: context.read<CreateServicesRepository>(),
        departmentCubit: context.read<MainCoreDepartmentCubit>(),
        employeeController: AppControllers.employee,
      )..bootstrap(selectedServiceName: selectedServiceName ?? ''),
      child: _AdminDashboardDetailsView(
        selectedServiceName: selectedServiceName,
      ),
    );
  }
}

// ─── View ──────────────────────────────────────────────────────────────────────

class _AdminDashboardDetailsView extends StatefulWidget {
  final String? selectedServiceName;

  const _AdminDashboardDetailsView({this.selectedServiceName});

  @override
  State<_AdminDashboardDetailsView> createState() =>
      _AdminDashboardDetailsViewState();
}

class _AdminDashboardDetailsViewState
    extends State<_AdminDashboardDetailsView> {
  final TextEditingController _searchController = TextEditingController();
  final ServiceRequestExportHelper _exportHelper = ServiceRequestExportHelper();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideInContent(
      from: SlideFrom.bottom,
      child: BlocBuilder<DashboardDetailsCubit, DashboardDetailsState>(
        builder: (context, state) {
          final cubit = context.read<DashboardDetailsCubit>();
          final locale = Localizations.localeOf(context).languageCode;

          if (state.bootstrapping || !state.bootstrapped) {
            return const Scaffold(body: Center(child: CircleProgressMaster()));
          }

          // SVC-DASH-01: error with Retry instead of zeros.
          if (state.loadError) {
            return Scaffold(
              body: ServicesLoadError(
                message: S.of(context).errorLoadingDashboard,
                onRetry: () => cubit.bootstrap(
                  selectedServiceName: widget.selectedServiceName ?? '',
                ),
              ),
            );
          }

          return Scaffold(
            body: SafeArea(
              child: SideFrameMasterServices(
                titleText: S.of(context).service,
                onFirstTap: () => Navigator.pop(context),
                // Bug report p.26: the breadcrumb reads "Admin Dashboard" in every
                // state (it said "Dashboard" while loading and on the details page).
                secondTitle: S.of(context).adminDashboard,
                onSecondTap: () => Navigator.pop(context),
                thirdTitle: _resolveDisplayName(state, locale),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Pie Charts ──────────────────────────────────────────
                      DetailsPieChartsSection(
                        state: state,
                        cubit: cubit,
                        locale: locale,
                      ),

                      SizedBox(height: 15.sp),

                      // ── Monthly Chart ───────────────────────────────────────
                      ServicesChartCard(
                        monthCounts: state.monthCounts,
                        monthHours: state.monthHours,
                        isLoading: state.isLoading,
                        onToggleToServiceCount: () => cubit.toggleChartMode(
                          true,
                          selectedServiceName: widget.selectedServiceName ?? '',
                        ),
                        onToggleToTotalHours: () => cubit.toggleChartMode(
                          false,
                          selectedServiceName: widget.selectedServiceName ?? '',
                        ),
                      ),

                      SizedBox(height: 20.sp),

                      // ── Tab Bar ─────────────────────────────────────────────
                      DetailsTabBar(
                        showRequestedServices: state.showRequestedServices,
                        onTabChanged: cubit.toggleTab,
                      ),

                      SizedBox(height: 12.sp),

                      // ── Search + Filter + Export ────────────────────────────
                      DetailsActionBar(
                        state: state,
                        searchController: _searchController,
                        onSearchChanged: cubit.onSearchChanged,
                        onFilterApplied: () {},
                        onFilterResult: ({
                          String? department,
                          String? status,
                          DateTime? date,
                          bool clearDepartment = false,
                          bool clearStatus = false,
                          bool clearDate = false,
                        }) {
                          cubit.applyFilters(
                            department: department,
                            status: status,
                            date: date,
                            clearDepartment: clearDepartment,
                            clearStatus: clearStatus,
                            clearDate: clearDate,
                          );
                        },
                        locale: locale,
                        exportHelper: _exportHelper,
                      ),

                      SizedBox(height: 14.sp),

                      // ── Table / Employee Cards ──────────────────────────────
                      DetailsTableSection(
                        state: state,
                        cubit: cubit,
                        locale: locale,
                      ),

                      SizedBox(height: 20.sp),
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

  String _resolveDisplayName(DashboardDetailsState state, String locale) {
    if (widget.selectedServiceName == null ||
        widget.selectedServiceName!.isEmpty) {
      return '';
    }
    if (locale == 'ar' && state.serviceNamesArabic.isNotEmpty) {
      final index = state.serviceNames.indexOf(widget.selectedServiceName!);
      if (index >= 0 && index < state.serviceNamesArabic.length) {
        return state.serviceNamesArabic[index];
      }
    }
    return widget.selectedServiceName ?? '';
  }
}
