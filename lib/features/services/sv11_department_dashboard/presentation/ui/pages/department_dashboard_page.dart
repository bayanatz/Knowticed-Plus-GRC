/// Module: services / sv11_department_dashboard / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: department_dashboard_page.dart
/// Purpose: The department dashboard: charts, the requests / employees tab,
///          search, filter and export. DepartmentDashboardScreen is the
///          stand-alone screen (an employee's own department);
///          DepartmentDashboardPage is the body, also shown inside the Admin
///          Dashboard's Statistics tab.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): renamed from DashBoardMasterMobile — it is
///     used on every screen size (Dashboards rules 16, 22); replaces the s8
///     DashBordLayout wrapper (rules 17, 20); the cubit is provided with its
///     injected collaborators, and the Admin Dashboard provides ONE cubit
///     for its Statistics tab, so opening the tab or changing the department
///     no longer downloads every request again (rule 3, SVC-DASH-15); home
///     is reached by route.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/navigation/services_navigation.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/services_load_error.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/dashboard_master_cubit.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/dashboard_master_state.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/master_action_bar.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/master_charts_section.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/master_tab_bar.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/ui/widgets/master_table_section.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [createDashboardMasterCubit]
///
/// Purpose: The department dashboard cubit with its collaborators.
DashboardMasterCubit createDashboardMasterCubit(BuildContext context) =>
    DashboardMasterCubit(
      departmentCubit: context.read<MainCoreDepartmentCubit>(),
      employeeController: AppControllers.employee,
      repository: context.read<CreateServicesRepository>(),
    );

/// Class Name: [DepartmentDashboardScreen]
///
/// Purpose: The stand-alone department dashboard (the signed-in employee's
/// department).
class DepartmentDashboardScreen extends StatelessWidget {
  const DepartmentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardMasterCubit>(
      create: createDashboardMasterCubit,
      child: const Scaffold(body: DepartmentDashboardPage()),
    );
  }
}

/// Class Name: [DepartmentDashboardPage]
///
/// Purpose: The dashboard body. Needs a [DashboardMasterCubit] above it.
class DepartmentDashboardPage extends StatefulWidget {
  final bool isAdmin;
  final String? adminSelectedDepartment;

  const DepartmentDashboardPage({
    super.key,
    this.isAdmin = false,
    this.adminSelectedDepartment,
  });

  @override
  State<DepartmentDashboardPage> createState() =>
      _DepartmentDashboardPageState();
}

class _DepartmentDashboardPageState extends State<DepartmentDashboardPage> {
  final TextEditingController _searchController = TextEditingController();

  DashboardMasterCubit get _cubit => context.read<DashboardMasterCubit>();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(DepartmentDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAdmin &&
        widget.adminSelectedDepartment != oldWidget.adminSelectedDepartment) {
      _bootstrap();
    }
  }

  void _bootstrap() {
    _cubit.bootstrap(
      isAdmin: widget.isAdmin,
      adminSelectedDepartment: widget.adminSelectedDepartment,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isTabletLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width >= 600 &&
        MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  @override
  Widget build(BuildContext context) {
    return SlideInContent(
      from: SlideFrom.bottom,
      child: BlocBuilder<DashboardMasterCubit, DashboardMasterState>(
        builder: (context, state) {
          if (!state.bootstrapped) return const CircleProgressMaster();

          // SVC-DASH-01: error with Retry instead of endless spinners.
          if (state.loadError) {
            return ServicesLoadError(
              message: S.of(context).errorLoadingDashboard,
              onRetry: _bootstrap,
            );
          }

          // SVC-DASH-07: no department → empty dashboard with a message.
          if (state.noDepartment) {
            return Center(
              child: Text(
                S.of(context).debugTestEmployeeNoDepartment,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            );
          }

          return widget.isAdmin
              ? _adminLayout(context, state)
              : _employeeLayout(context, state);
        },
      ),
    );
  }

  Widget _adminLayout(BuildContext context, DashboardMasterState state) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            MasterChartsSection(
              state: state,
              cubit: _cubit,
              isAdmin: true,
              adminSelectedDepartment: widget.adminSelectedDepartment,
              isArabic: context.svcIsArabic,
            ),
            SizedBox(height: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _employeeLayout(BuildContext context, DashboardMasterState state) {
    final locale = Localizations.localeOf(context).languageCode;
    return SafeArea(
      child: SideFrameMasterServices(
        titleText: S.of(context).services,
        onFirstTap: context.svcGoHome,
        // Bug report p.26: the breadcrumb reads "Admin Dashboard" everywhere.
        secondTitle: S.of(context).adminDashboard,
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 15.sp),
                MasterChartsSection(
                  state: state,
                  cubit: _cubit,
                  isAdmin: false,
                  adminSelectedDepartment: widget.adminSelectedDepartment,
                  isArabic: context.svcIsArabic,
                ),
                SizedBox(height: 20.sp),
                MasterTabBar(
                  state: state,
                  onToggle: () =>
                      _cubit.toggleTab(!state.showRequestedServices),
                ),
                SizedBox(height: 12.sp),
                MasterActionBar(
                  state: state,
                  cubit: _cubit,
                  searchController: _searchController,
                  locale: locale,
                  showExport: state.showRequestedServices,
                ),
                SizedBox(height: 14.sp),
                MasterTableSection(
                  state: state,
                  cubit: _cubit,
                  isTabletLandscape: _isTabletLandscape(context),
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
