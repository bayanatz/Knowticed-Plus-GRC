/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: details_table_section.dart
/// Purpose: Table (tablet) or Cards (mobile) for Dashboard Details
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/service_request_table.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/dashboard_details_cubit.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/dashboard_details_state.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/build_services_card.dart';

import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class DetailsTableSection extends StatelessWidget {
  final DashboardDetailsState state;
  final DashboardDetailsCubit cubit;
  final String locale;

  const DetailsTableSection({
    super.key,
    required this.state,
    required this.cubit,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    if (state.showRequestedServices) {
      if (isMobile) {
        return ServiceRequestMobileCard(
          displayedItems: state.displayedItems,
          locale: locale,
          enToArDepartments: state.enToArDepartments,
          onTap: (item) {},
        );
      }
      return ServiceRequestTableWidget(
        filteredItems: state.displayedItems,
        enToArDepartments: state.enToArDepartments,
        // SVC-DASH-18: no empty tap handler → no misleading ripple.
      );
    }

    return EmployeeStatsCard(
      filteredItems: state.filteredItems,
      locale: locale,
      enToArDepartments: state.enToArDepartments,
      getUniqueProviderEmails: cubit.getUniqueProviderNames,
      calculateProviderStats: cubit.calculateProviderStats,
    );
  }
}
