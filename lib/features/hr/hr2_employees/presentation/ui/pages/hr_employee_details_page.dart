// ***************************** FILE INFO ***************************** //
// File Name: hr_employee_details_page.dart
// Purpose: Hosts the read-only employee details page and its inner tabs.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/hr_fields/hr_employee_entity.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/controller/controller/employee_details_cubit.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/controller/controller/employee_details_state.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/employee_details_tabs.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/utils/add_employee_step.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/employee_details_header.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/employee_edit_section_dialog.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/pages/employee_edit_page.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/employee_personal_information_tab.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/pages/employee_assets_tab_page.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/pages/employee_attendance_tab_page.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/pages/employee_services_tab_page.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/pages/employee_tasks_tab_page.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Displays the selected employee's complete read-only HR profile.
class HrEmployeeDetailsPage extends StatefulWidget {
  const HrEmployeeDetailsPage({required this.employee, super.key});

  final HrEmployeeEntity employee;

  @override
  State<HrEmployeeDetailsPage> createState() => _HrEmployeeDetailsPageState();
}

/// Owns only the selected inner tab for the employee details page.
class _HrEmployeeDetailsPageState extends State<HrEmployeeDetailsPage> {
  int _selectedTab = EmployeeDetailsTabs.personalInformation.index;
  late final EmployeeDetailsCubit _detailsCubit;

  @override
  void initState() {
    super.initState();
    _detailsCubit = EmployeeDetailsCubit(employee: widget.employee)..load();
  }

  @override
  void dispose() {
    _detailsCubit.close();
    super.dispose();
  }

  /// Method Name: [_selectTab]
  ///
  /// Purpose: Updates the currently visible employee detail area.
  ///
  /// Parameters:
  /// - [index]: Selected employee detail tab index.
  ///
  /// Returns: Rebuilds the page with the selected tab content.
  void _selectTab(int index) => setState(() => _selectedTab = index);

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return BlocProvider.value(
      value: _detailsCubit,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(
                  screensTitles: [
                    localization.humanResources,
                    localization.employees,
                    localization.employeeDetails,
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<EmployeeDetailsCubit, EmployeeDetailsState>(
                          builder: (context, state) => EmployeeDetailsHeader(
                            employee: widget.employee,
                            onEdit: () => _openEdit(context, state),
                          ),
                        ),
                        CustomTabs(
                          tabs: EmployeeDetailsTabs.values
                              .map((tab) => tab.title)
                              .toList(),
                          selectedValue: _selectedTab,
                          onChanged: _selectTab,
                        ),
                        SizedBox(height: 20.h),
                        BlocBuilder<EmployeeDetailsCubit, EmployeeDetailsState>(
                          builder: (context, state) => _buildTabContent(state),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Method Name: [_buildTabContent]
  ///
  /// Purpose: Resolves content for the selected details tab and data state.
  ///
  /// Parameters:
  /// - [state]: Current employee-details loading state.
  ///
  /// Returns: The selected tab's rendered content.
  Widget _buildTabContent(EmployeeDetailsState state) {
    switch (EmployeeDetailsTabs.fromIndex(_selectedTab)) {
      case EmployeeDetailsTabs.services:
        return const EmployeeServicesTabPage();
      case EmployeeDetailsTabs.tasks:
        return const EmployeeTasksTabPage();
      case EmployeeDetailsTabs.attendance:
        return const EmployeeAttendanceTabPage();
      case EmployeeDetailsTabs.assets:
        return const EmployeeAssetsTabPage();
      case EmployeeDetailsTabs.personalInformation:
        return switch (state) {
          EmployeeDetailsInitial() || EmployeeDetailsLoading() => const Padding(
              padding: EdgeInsets.all(24),
              child: CircleProgressMaster(),
            ),
          EmployeeDetailsLoaded(:final data) =>
            EmployeePersonalInformationTab(data: data),
          EmployeeDetailsError(:final message) => _buildError(message),
        };
    }
  }

  /// Method Name: [_buildError]
  ///
  /// Purpose: Presents a retryable employee detail loading failure.
  ///
  /// Parameters:
  /// - [message]: Failure text returned by the data boundary.
  ///
  /// Returns: An error message and localized retry action.
  Widget _buildError(String message) {
    return Center(
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: withHaptic(
                () => context.read<EmployeeDetailsCubit>().retry(),
                HapticLevel.low),
            child: Text(S.of(context).retry),
          ),
        ],
      ),
    );
  }

  /// Method Name: [_openEdit]
  ///
  /// Purpose: Opens section selection and the reusable preview-based editor.
  ///
  /// Parameters:
  /// - [context]: Details-page context used for navigation and dialogs.
  /// - [state]: Loaded details state containing supplemental employee data.
  ///
  /// Returns: Completes after the optional edit route closes.
  Future<void> _openEdit(
      BuildContext context, EmployeeDetailsState state) async {
    if (state is! EmployeeDetailsLoaded) return;
    final section = await showAppDialog<AddEmployeeStep>(
      context: context,
      builder: (_) => const EmployeeEditSectionDialog(),
    );
    if (!context.mounted || section == null) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EmployeeEditPage(data: state.data, section: section),
      ),
    );
    if (context.mounted) await context.read<EmployeeDetailsCubit>().load();
  }
}
