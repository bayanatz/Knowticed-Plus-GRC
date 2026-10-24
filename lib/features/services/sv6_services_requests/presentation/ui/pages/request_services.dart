/// Module: services / sv6_services_requests / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: request_services.dart
/// Purpose: The "Service requests" page: owning-department chips, search,
///          the phone filter and the grid of services the user can request.
///          Services are loaded by ServicesManagerCubit and filtered by
///          RequestServicesCubit.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/helpers/service_visibility_keys.dart';
import 'package:knowticed_plus/features/services/presentation/controller/request_details_lookup.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart'
    hide RequestServicesLoading, RequestServicesError, RequestServicesLoaded;
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/new_request_cubit.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/request_services_cubit.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/request_services_state.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/my_request_toggle.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/department_filter_chips_widget.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/service_requests_filter_dialog.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/services_grid_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestServicesPage extends StatelessWidget {
  const RequestServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = ServicesManagerCubit.get(context);
    final currentUser =
        manager.hasEmployeeEntity ? manager.employeeEntity : null;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RequestServicesCubit(
            departmentCubit: context.read<MainCoreDepartmentCubit>(),
            repository: context.read<CreateServicesRepository>(),
            currentUser: currentUser,
            findEmployee: context.read<RequestDetailsLookup>().findEmployee,
          ),
        ),
        BlocProvider(
          create: (context) => NewRequestCubit(
            manager: manager,
            notifications: context.read<ServicesNotificationService>(),
            requester: currentUser,
          ),
        ),
      ],
      child: const RequestServicesView(),
    );
  }
}

class RequestServicesView extends StatefulWidget {
  const RequestServicesView({super.key});

  @override
  State<RequestServicesView> createState() => _RequestServicesViewState();
}

class _RequestServicesViewState extends State<RequestServicesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RequestServicesCubit>().startLoading();
    // SVC-HOME-01: only the services this user may request are downloaded.
    final manager = ServicesManagerCubit.get(context);
    manager.getAllRequestServices(
      visibleToKeys: serviceVisibilityKeys(
        context.read<MainCoreDepartmentCubit>(),
        manager.hasEmployeeEntity ? manager.employeeEntity.departmentId : null,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilter(RequestServicesCubit cubit) async {
    final ids = cubit.departmentCounts.departmentCounts.keys;
    final result = await showServiceRequestsFilterDialog(
      context: context,
      departments: {for (final id in ids) id: context.svcDepartmentName(id)},
      selectedDepartment: cubit.filterModel.selectedDepartment,
      allKey: RequestServicesCubit.allDepartments,
    );
    if (result != null) cubit.changeDepartmentFilter(result);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RequestServicesCubit>();
    return SlideInContent(
      from: SlideFrom.bottom,
      child: Scaffold(
        body: SafeArea(
          child: SideFrameMasterServices(
            titleText: FormatHelper.capitalize(S.of(context).services),
            onFirstTap: () => navigateTo(context, LayoutScreenServices()),
            secondTitle: FormatHelper.capitalize(S.of(context).serviceRequests),
            child: BlocListener<ServicesManagerCubit, ServicesManagerState>(
              listener: (context, managerState) {
                if (managerState is GetServiceLoaded) {
                  cubit.loadServices(
                    ServicesManagerCubit.get(context).servicesRequest,
                  );
                } else if (managerState is GetServiceError) {
                  cubit.showLoadError();
                }
              },
              child: BlocBuilder<RequestServicesCubit, RequestServicesState>(
                builder: (context, state) => SideFrameScrollableBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      SizedBox(height: 15.sp),
                      if (state is RequestServicesLoaded)
                        DepartmentFilterChipsWidget(
                          selectedDepartment:
                              cubit.filterModel.selectedDepartment,
                          departmentCounts: cubit.departmentCounts,
                          onDepartmentChanged: cubit.changeDepartmentFilter,
                        ),
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          AppSearchTextField(
                            controller: _searchController,
                            onChanged: cubit.searchServices,
                          ),
                          if (state is RequestServicesLoaded) ...[
                            SizedBox(width: 9.sp),
                            CustomFilterIcon(
                              color: AppColors.card,
                              borderColor: AppColors.transparent,
                              svgColor: AppColors.secondaryText,
                              title: '',
                              onTap: () => _openFilter(cubit),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 15.h),
                      _buildContent(context, state),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        SizedBox(width: 15.w),
        customButton(
          title: FormatHelper.capitalize(S.of(context).myRequests),
          function: () => navigateTo(context, MyRequestServicesToggle()),
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          width: 135.sp,
          height: 36.sp,
          radius: 8.r,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, RequestServicesState state) {
    if (state is RequestServicesLoading || state is RequestServicesInitial) {
      return Padding(
        padding: EdgeInsets.only(top: 100.sp),
        child: const CircleProgressMaster(),
      );
    }
    if (state is RequestServicesError) {
      return Center(child: Text(S.of(context).errorLoadingServices));
    }
    if (state is RequestServicesLoaded) {
      return state.filteredServices.isEmpty
          ? const CustomEmptyState(
              lottiePath: ServicesLottie.emptyState,
              size: 400,
              verticalPadding: 50,
            )
          : ServicesGridWidget(services: state.filteredServices);
    }
    return const SizedBox.shrink();
  }
}
