/// Module: services / sv10_services_provider / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: employee_services.dart
/// Purpose: "My assigned services" — the provider's requests as a grid or
///          a table, with status chips, search and export. The data, counts,
///          filter and sort come from EmployeeServicesCubit (BlocBuilder,
///          suggestion 1); the page only draws them.
/// Author: Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): one real page file (the two part files and
///     the toggle whose branches all returned this page are gone, rules 6,
///     14, 25, 26); renamed from EmployeeServicesScreenTablet (rule 17); the
///     cubit is provided with its injected collaborators (rule 4); the home
///     page is reached by route, not by importing it (rule 3).
library;

import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/service_card_metrics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/layout/custom_grid_view.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';
import 'package:knowticed_plus/features/services/presentation/navigation/services_navigation.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/export_file.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/services_load_error.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/controller/employee_services_cubit.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/controller/employee_services_state.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/pages/employee_details_services.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/widgets/provider_service_card.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/widgets/provider_services_toolbar.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/widgets/provider_status_chips.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/widgets/services_table_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [EmployeeServicesScreen]
///
/// Purpose: Provides the list cubit and shows the provider's requests.
class EmployeeServicesScreen extends StatelessWidget {
  const EmployeeServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmployeeServicesCubit>(
      create: (context) => EmployeeServicesCubit(
        employeeController: AppControllers.employee,
        repository: context.read<CreateServicesRepository>(),
      )..loadAndCacheServices(_providerEmail),
      child: const _EmployeeServicesView(),
    );
  }
}

String get _providerEmail =>
    (AppControllers.employee.employeeEntity?.email ?? '').trim().toLowerCase();

class _EmployeeServicesView extends StatefulWidget {
  const _EmployeeServicesView();

  @override
  State<_EmployeeServicesView> createState() => _EmployeeServicesViewState();
}

class _EmployeeServicesViewState extends State<_EmployeeServicesView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGrid = true;

  EmployeeServicesCubit get _cubit => context.read<EmployeeServicesCubit>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String _formatStartDate(dynamic v) {
    if (v is Timestamp) return DateFormat('dd MMM yyyy').format(v.toDate());
    if (v is DateTime) return DateFormat('dd MMM yyyy').format(v);
    return '-';
  }

  /// Opens a request's details one frame after the tap (MouseTracker
  /// re-entrancy fix of 26/8/2026) and reloads when it reports a change
  /// (SVC-PROV-15).
  void _openServiceDetails(ServicesHistoryModel service) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final changed = await Navigator.of(context).push<bool>(
        appSlideRoute<bool>(
          EmployeeDetailsServicesScreen(approvalModel: service),
        ),
      );
      if (changed == true && mounted) {
        _cubit.loadAndCacheServices(_providerEmail);
      }
    });
  }

  Widget _emptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.sp),
      child: Center(
        child: CustomEmptyState(
          lottiePath: ServicesLottie.emptyState,
          size: 300,
          verticalPadding: 0,
        ),
      ),
    );
  }

  Widget _content(EmployeeServicesState state) {
    if (state is EmployeeServicesError) {
      // SVC-PROV-11: a failed load shows an error with Retry.
      return ServicesLoadError(
        message: S.of(context).errorLoadingServices,
        onRetry: () => _cubit.loadAndCacheServices(_providerEmail),
      );
    }
    if (state is! EmployeeServicesLoaded) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.55,
        child: Center(
          child: CircleProgressMaster.inline(color: AppColors.primary),
        ),
      );
    }
    final visible = state.visible;
    if (visible.isEmpty) return _emptyState();
    return BounceSwitcher(
      triggerValue: _isGrid,
      child: _isGrid
          ? GridView.builder(
              itemCount: visible.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: CrossAxisCountHelperResponsive
                    .getCrossAxisCountForDefaultTabletResponsive(
                  context,
                ),
                mainAxisExtent: ServiceCardMetrics.providerCardExtent(context),
                mainAxisSpacing: 15.sp,
                crossAxisSpacing: 15.sp,
              ),
              itemBuilder: (context, index) => GestureDetector(
                onTap: withHaptic(
                  () => _openServiceDetails(visible[index]),
                  HapticLevel.low,
                ),
                child: ProviderServiceCard(service: visible[index]),
              ),
            )
          : ServicesTableWidget(
              services: visible,
              onRowTap: _openServiceDetails,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).service,
          onFirstTap: context.svcGoHome,
          secondTitle: S.of(context).requestedServices,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: BlocBuilder<EmployeeServicesCubit, EmployeeServicesState>(
              builder: (context, state) {
                final loaded = state is EmployeeServicesLoaded ? state : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProviderStatusChips(
                      counts: loaded?.counts ?? const {},
                      selectedKey: loaded?.statusKey ?? ProviderListKeys.all,
                      onSelected: _cubit.selectStatus,
                    ),
                    SizedBox(height: 15.sp),
                    ProviderServicesToolbar(
                      searchController: _searchController,
                      onSearch: _cubit.search,
                      isGrid: _isGrid,
                      onViewChanged: (grid) =>
                          setState(() => _isGrid = withLowHaptic(grid)),
                      canExport:
                          ServicesModuleAccess.canExportRequestedServices,
                      onExport: () => showAppDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) => ExportDialog(
                          filteredModel: loaded?.visible ?? const [],
                          selectedProviders: const {},
                          formatStartDate: _formatStartDate,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    _content(state),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
