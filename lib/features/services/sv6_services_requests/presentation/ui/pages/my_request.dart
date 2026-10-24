/// Module: services / sv6_services_requests / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: my_request.dart
/// Purpose: The "My requests" page: status chips, search, department filter,
///          sort and the grid of the signed-in user's requests. All loading
///          and filtering is done by MyRequestCubit.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/layout/custom_grid_view.dart';
import 'package:knowticed_plus/core/custom/layout/custom_gridview_with_animation.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_status_chips.dart';
import 'package:knowticed_plus/features/services/presentation/controller/request_details_lookup.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/requested_services_filter_dialog.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/my_request_cubit.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/my_request_state.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/my_request_details_toggle.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/custom_multi.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/my_requests_service_card.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/service_card_metrics.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/sort.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MyRequestServices extends StatelessWidget {
  const MyRequestServices({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final email = CurrentUserContext.email ?? '';
        return MyRequestCubit(
          repository: context.read<CreateServicesRepository>(),
          departments: context.read<MainCoreDepartmentCubit>(),
          requesterEmail: email,
          requester: context.read<RequestDetailsLookup>().requesterInfo(email),
        )..loadAllData();
      },
      child: const MyRequestServicesView(),
    );
  }
}

class MyRequestServicesView extends StatefulWidget {
  const MyRequestServicesView({super.key});

  @override
  State<MyRequestServicesView> createState() => _MyRequestServicesViewState();
}

class _MyRequestServicesViewState extends State<MyRequestServicesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Only the abbreviation in brackets at the end of a job title, if any.
  String _displayJobTitle(
    BuildContext context,
    String? titleEn,
    String? titleAr,
  ) {
    final english = (titleEn ?? '').trim();
    final title = context.svcIsArabic
        ? context.svcPick(english, titleAr)
        : FormatHelper.capitalize(context.svcPick(english, titleAr));
    final match = RegExp(r'\(([^)]+)\)\s*$').firstMatch(title);
    return match?.group(1) ?? title;
  }

  Future<void> _openMobileFilter(
    BuildContext context,
    MyRequestCubit cubit,
    MyRequestLoaded state,
  ) async {
    final result = await showFilterDialog(context, state.filteredModel);
    if (result == null) return;
    cubit.applyMobileFilter(
      departmentNames: List<String>.from(result['departments'] ?? const []),
      statuses: List<String>.from(result['statuses'] ?? const []),
      date: result['date'] as DateTime?,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideInContent(
      from: SlideFrom.bottom,
      child: BlocConsumer<MyRequestCubit, MyRequestState>(
        listener: (context, state) {
          if (state is MyRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).errorLoadingServices)),
            );
          }
        },
        builder: (context, state) {
          if (state is MyRequestLoading) {
            return const Center(child: CircleProgressMaster());
          }
          if (state is! MyRequestLoaded) return const SizedBox.shrink();
          return SafeArea(
            child: SideFrameMasterServices(
              titleText: FormatHelper.capitalize(S.of(context).services),
              onFirstTap: () => Navigator.pop(context),
              secondTitle: FormatHelper.capitalize(
                S.of(context).serviceRequests,
              ),
              onSecondTap: () => Navigator.pop(context),
              thirdTitle: FormatHelper.capitalize(S.of(context).myRequests),
              onThirdTap: () => Navigator.pop(context),
              // Not a bare scroll view — see `SideFrameScrollableBody`.
              child: SideFrameScrollableBody(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChipFilter(
                      selectedKey: state.selectedStatus,
                      onSelected: context.read<MyRequestCubit>().updateStatus,
                      items: servicesStatusChips(
                        context,
                        total: state.totalServices,
                        counts: state.statusCounts,
                      ),
                    ),
                    SizedBox(height: 15.sp),
                    _buildToolbar(context, state),
                    SizedBox(height: 15.sp),
                    _buildGrid(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, MyRequestLoaded state) {
    final cubit = context.read<MyRequestCubit>();
    final isMobile = ContextExtension(context).isPhone;
    return Row(
      children: [
        AppSearchTextField(
          controller: _searchController,
          onChanged: cubit.search,
        ),
        SizedBox(width: 9.sp),
        if (!isMobile) ...[
          DepartmentMultiSelectPage(
            selectedKeys: state.selectedDepartmentKeys,
            onChanged: cubit.updateDepartments,
          ),
          SizedBox(width: 9.sp),
          ServicesSortButton(
            selectedOption: state.selectedSort,
            onSortSelected: cubit.updateSort,
          ),
        ],
        if (isMobile)
          CustomFilterIcon(
            color: AppColors.card,
            borderColor: AppColors.transparent,
            svgColor: AppColors.secondaryText,
            title: '',
            onTap: () => _openMobileFilter(context, cubit, state),
          ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, MyRequestLoaded state) {
    if (state.displayedItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 40.sp),
        child: const CustomEmptyState(
          lottiePath: ServicesLottie.emptyState,
          size: 400,
          verticalPadding: 0,
        ),
      );
    }
    return AnimatedCustomGridView(
      itemCount: state.displayedItems.length,
      crossAxisCount: CrossAxisCountHelperResponsive
          .getCrossAxisCountForDefaultTabletResponsive(
        context,
      ),
      // The card's height comes from ServiceCardMetrics so the grid extent
      // always matches what the card's rows need.
      mainAxisExtent: ServiceCardMetrics.myRequestCardExtent(context),
      mainAxisSpacing: 15.sp,
      crossAxisSpacing: 15.sp,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      animationDuration: const Duration(milliseconds: 1000),
      staggerDelay: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      itemBuilder: (context, index) =>
          _buildCard(context, state.displayedItems[index]),
    );
  }

  Widget _buildCard(BuildContext context, MyRequestItem item) {
    final service = item.model;
    final providers = service.currentProviderServices;
    if (providers.isEmpty) return const SizedBox();

    // The provider the request was assigned to, not just the first one.
    final assignedEmail =
        service.currentAssignedProviderEmail.toLowerCase().trim();
    final provider = assignedEmail.isEmpty
        ? providers.first
        : providers.firstWhere(
            (p) => (p.email?.toLowerCase().trim() ?? '') == assignedEmail,
            orElse: () => providers.first,
          );

    final timestamps = service.timestamps;
    final requestDate = timestamps.isEmpty
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(timestamps.first);
    final lastUpdate = timestamps.isEmpty
        ? requestDate
        : DateTime.fromMillisecondsSinceEpoch(timestamps.last);
    final locale = Localizations.localeOf(context).toString();

    return GestureDetector(
      onTap: () => navigateTo(
        context,
        MyRequestDetailsServicesToggle(myRequestDetailsModel: service),
      ),
      child: CustomServiceCardMyRequest(
        imageUrl: service.currentImageUrl,
        owningDepartment: context.svcPick(
          item.departmentEnglish,
          item.departmentArabic,
        ),
        duration: context.svcDuration(
          service.currentDurationOfServices,
          service.currentSelectedDurationUnit,
        ),
        title: context.svcPick(
          service.currentServiceNameEnglish,
          service.currentServiceNameArabic,
        ),
        jobTitle: _displayJobTitle(
          context,
          provider.title,
          provider.titleInArabic,
        ),
        status: item.status,
        dateRequest: DateFormat('dd MMM yyyy', locale).format(requestDate),
        lastUpdate: DateFormat('dd MMM yyyy h:mm a', locale).format(lastUpdate),
        pointOfContact: context.svcPick(
          '${provider.firstName ?? ''} ${provider.lastName ?? ''}',
          '${provider.firstNameInArabic ?? ''} ${provider.lastNameInArabic ?? ''}',
        ),
      ),
    );
  }
}
