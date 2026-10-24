/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_table_section.dart
/// Purpose: The requests section — ServiceRequestTableWidget on a tablet,
///          RequestsListWidget on a phone. No logic here.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/service_request_table.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/requests_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardTableSection extends StatelessWidget {
  final String selectStatus;
  final String searchQuery;
  final List<String> activeDepartments;
  final List<String> activeStatuses;
  final DateTime? activeDate;

  // Mobile-only params
  final bool isMobile;
  final List<Map<String, dynamic>> displayedItems;
  final bool isLoadingRequests;

  const DashboardTableSection({
    super.key,
    required this.selectStatus,
    required this.searchQuery,
    required this.activeDepartments,
    required this.activeStatuses,
    required this.activeDate,
    this.isMobile = false,
    this.displayedItems = const [],
    this.isLoadingRequests = false,
  });

  /// [displayedItems] is ALREADY filtered by the search and the Filter
  /// dialog (see DashboardFilterableRequestsTable), so phone and tablet show
  /// the same rows (SVC-DASH-09) without downloading the requests again
  /// (SVC-DASH-15).
  @override
  Widget build(BuildContext context) {
    final enToAr = context.read<MainCoreDepartmentCubit>().enToAr;
    if (isMobile) {
      return RequestsListWidget(
        isLoadingRequests: isLoadingRequests,
        displayedItems: displayedItems,
        enToArDepartments: enToAr,
        // SVC-DASH-18: no tap handler, so no tap feedback either.
        onItemTap: null,
      );
    }

    if (isLoadingRequests) {
      return const Center(child: CircleProgressMaster());
    }
    if (displayedItems.isEmpty) {
      return Center(
        child: CustomEmptyState(
          lottiePath: ServicesLottie.emptyState,
          size: 350,
          verticalPadding: 0,
        ),
      );
    }
    return ServiceRequestTableWidget(
      filteredItems: displayedItems,
      // SVC-DASH-19: the company's real department names, not a fixed list.
      enToArDepartments: enToAr,
      selectedDepartment: selectStatus,
    );
  }
}
