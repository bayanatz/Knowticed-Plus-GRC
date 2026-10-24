/// Module: services / sv5_service_details / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: details_services.dart
/// Purpose: Details services — declares DetailsServicesPage,
///          DetailsServicesView, _DetailsServicesViewState.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/presentation/widgets/services_load_error.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/employees_tab_widget.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/export_file_name_dialog.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/requested_services_filter_dialog.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/info_text.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/requested_services_tab_widget.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/service_header_widget.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/service_info_card_widget.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/service_stats_widget.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/widgets/success_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/sv5_service_details/presentation/controller/details_services_cubit.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/controller/details_services_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/presentation/controller/request_details_lookup.dart';

class DetailsServicesPage extends StatelessWidget {
  final ServicesHistoryModel createServicesModel;

  const DetailsServicesPage({required this.createServicesModel, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsServicesCubit(
        manager: ServicesManagerCubit.get(context),
        lookup: context.read<RequestDetailsLookup>(),
        departmentNameToId: (name) => context
            .read<MainCoreDepartmentCubit>()
            .getDepartmentIdFromDepartmentName(departmentName: name),
      )..initialize(createServicesModel.currentId, createServicesModel),
      child: DetailsServicesView(createServicesModel: createServicesModel),
    );
  }
}

class DetailsServicesView extends StatefulWidget {
  final ServicesHistoryModel createServicesModel;

  const DetailsServicesView({required this.createServicesModel, super.key});

  @override
  State<DetailsServicesView> createState() => _DetailsServicesViewState();
}

class _DetailsServicesViewState extends State<DetailsServicesView> {
  final TextEditingController _searchController = TextEditingController();

  Map<String, String> get enToArDepartments =>
      context.read<MainCoreDepartmentCubit>().enToAr;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = DetailsServicesCubit.get(context);
    ContextExtension(context).isPhone;

    return SlideInContent(
      from: SlideFrom.bottom,
      child: Scaffold(
        body: SafeArea(
          child: SideFrameMasterServices(
            titleText: S.of(context).service,
            onFirstTap: () {
              navigateTo(context, LayoutScreenServices());
            },
            secondTitle: FormatHelper.capitalize(
              context.svcPick(
                widget.createServicesModel.currentServiceNameEnglish,
                widget.createServicesModel.currentServiceNameArabic,
              ),
            ),
            child: BlocBuilder<DetailsServicesCubit, DetailsServicesState>(
              builder: (context, state) {
                if (state is DetailsServicesLoading) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(child: CircleProgressMaster()),
                  );
                }

                // SVC-HOME-05: a failed load shows an error with Retry
                // (not "0 requests", and not the raw exception text).
                if (state is DetailsServicesError) {
                  return ServicesLoadError(
                    message: S.of(context).errorLoadingServices,
                    onRetry: () => DetailsServicesCubit.get(context).refresh(
                      widget.createServicesModel.currentId,
                      widget.createServicesModel,
                    ),
                  );
                }

                // NOT a bare `SingleChildScrollView` (10/9/2026). This is the
                // direct child of `SideFrameMasterServices`, which already wraps
                // it in a scroll view on the PHONE branch — so on a phone this
                // was a vertical viewport inside a vertical viewport with an
                // unbounded height, and layout threw "Vertical viewport was given
                // unbounded height" before the body painted. What reached the
                // console was the downstream
                // `'!semantics.parentDataDirty': is not true`, once per frame.
                //
                // On tablet and desktop the frame gives an `Expanded` instead and
                // a scroll view here is required, so it cannot simply be deleted.
                // `SideFrameScrollableBody` adds one only on that branch.
                return SideFrameScrollableBody(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // Header with Edit/Delete buttons
                      ServiceHeaderWidget(
                        createServicesModel: widget.createServicesModel,
                      ),
                      SizedBox(height: 8.sp),

                      // Service Info Card
                      ServiceInfoCardWidget(
                        createServicesModel: widget.createServicesModel,
                      ),
                      SizedBox(height: 20.sp),

                      // Stats Widget
                      ServiceStatsWidget(stats: cubit.stats),
                      SizedBox(height: 20.sp),

                      // Tabs Section
                      _buildTabsSection(context, cubit),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabsSection(BuildContext context, DetailsServicesCubit cubit) {
    return Column(
      children: [
        _buildTabHeaders(context, cubit),
        SizedBox(height: 20.sp),
        _buildSearchAndFilters(context, cubit),
        SizedBox(height: 15.sp),
        BlocBuilder<DetailsServicesCubit, DetailsServicesState>(
          builder: (context, state) {
            // View Requesters is off → the Requested Services tab does not
            // exist, and its content must not be what the page opens on.
            // `isEmployeesTab` starts false, so gate the content too rather
            // than only hiding the tab header.
            if (cubit.isEmployeesTab ||
                !ServicesModuleAccess.canViewRequesters) {
              return EmployeesTabWidget(
                searchController: _searchController,
                createServicesModel: widget.createServicesModel,
              );
            } else {
              return RequestedServicesTabWidget(
                createServicesModel: widget.createServicesModel,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTabHeaders(BuildContext context, DetailsServicesCubit cubit) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;
    return Row(
      children: [
        // Requested Services Tab
        if (ServicesModuleAccess.canViewRequesters) ...[
          GestureDetector(
            onTapDown: (_) => HapticController.low(),
            onTap: () => cubit.changeTab(false),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).RequestedServices,
                    style: isMobile
                        ? StyleText.fontSize20Weight600.copyWith(
                            fontSize: 18.sp,
                            color: !cubit.isEmployeesTab
                                ? AppColors.secondaryPrimary
                                : lightMode
                                    ? AppColors.secondaryBlack
                                    : AppColors.grey,
                          )
                        : StyleText.fontSize20Weight600.copyWith(
                            color: !cubit.isEmployeesTab
                                ? AppColors.secondaryPrimary
                                : lightMode
                                    ? AppColors.secondaryBlack
                                    : AppColors.grey,
                          ),
                  ),
                  if (!cubit.isEmployeesTab)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      height: 2.h,
                      width: double.infinity,
                      color: AppColors.secondaryPrimary,
                    ),
                ],
              ),
            ),
          ),

          // Spacing
          SizedBox(width: 47.w),
        ],

        // Employees Tab
        GestureDetector(
          onTapDown: (_) => HapticController.low(),
          onTap: () => cubit.changeTab(true),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  S.of(context).Employees,
                  style: StyleText.fontSize20Weight600.copyWith(
                    color: cubit.isEmployeesTab
                        ? AppColors.secondaryPrimary
                        : lightMode
                            ? AppColors.secondaryBlack
                            : AppColors.grey,
                  ),
                ),
                if (cubit.isEmployeesTab)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    height: 2.h,
                    width: double.infinity,
                    color: AppColors.secondaryPrimary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    DetailsServicesCubit cubit,
  ) {
    ContextExtension(context).isPhone;
    ContextExtension(context).isTablet;
    final isFilterActive = cubit.hasActiveFilters;

    return Row(
      children: [
        // Search Field
        AppSearchTextField(
          controller: _searchController,
          onChanged: (val) => cubit.applySearch(val),
        ),

        SizedBox(width: ButtonSizing.toolbarGap(context)),

        // Filter Button
        CustomFilterIcon(
          color: isFilterActive ? AppColors.primary : AppColors.card,
          borderColor: AppColors.transparent,
          svgColor:
              isFilterActive ? AppColors.textButton : AppColors.secondaryText,
          title: S.of(context).Filter,
          onTap: () async {
            if (mounted) {
              // P01: no try/catch in a widget onTap callback (§11.2).
              final result = await showFilterDialog(
                context,
                cubit.filteredItems
                    .map((item) => item["model"] as ServicesHistoryModel)
                    .toList(),
                initialDepartments: cubit.selectedDepartments, // ✅ List
                initialStatuses: cubit.selectedStatuses, // ✅ List
                initialDate: cubit.selectedDate,
                initialSortBy: cubit.selectedSortBy, // ✅ NEW: For employees tab
                isEmployeesTab: cubit
                    .isEmployeesTab, // ✅ NEW: Determine which fields to show
              );

              if (result != null && mounted) {
                cubit.applyFilter(
                  departments: result['departments'] as List<String>?,
                  statuses: result['statuses'] as List<String>?,
                  date: result['date'] as DateTime?,
                  sortBy: result['sortBy']
                      as String?, // ✅ NEW: For employees sorting
                );
              }
            }
          },
        ),

        // Export Button (Only for Requested Services Tab)
        if (!cubit.isEmployeesTab &&
            ServicesModuleAccess.canExportRequestedServices) ...[
          SizedBox(width: ButtonSizing.toolbarGap(context)),
          GestureDetector(
            onTapDown: (_) => HapticController.low(),
            onTap: () async {
              final fileName = await showFileNameDialog(context);
              if (fileName != null && fileName.isNotEmpty) {
                if (!context.mounted) return;
                await _exportToCSV(context, cubit, fileName);
              }
            },
            child: !isTabletLandscape(context)
                ? Container(
                    width: 38.sp,
                    height: ButtonSizing.height,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: CustomSvgImage.natural(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                        width: 24.sp,
                        height: 24.sp,
                        color: AppColors.textButton,
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                : Container(
                    width: 100.sp,
                    height: ButtonSizing.height,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomSvgImage.natural(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                          width: 24.sp,
                          height: 24.sp,
                          color: AppColors.textButton,
                          fit: BoxFit.scaleDown,
                        ),
                        SizedBox(width: 8.sp),
                        Text(
                          S.of(context).export,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  /// H8: the CSV is built and saved by the cubit; the page only supplies the
  /// translated headers and the reader's formatting.
  Future<void> _exportToCSV(
    BuildContext context,
    DetailsServicesCubit cubit,
    String fileName,
  ) async {
    final s = S.of(context);
    final result = await cubit.exportRequests(
      fileName: fileName,
      headers: [
        s.num,
        s.serviceRequester,
        s.department,
        s.jobTitle,
        s.RequestedDate,
        s.status,
        s.serviceProvider,
      ],
      requesterName: (m) => context.svcPick(
        '${m.currentFirstNameRequester} ${m.currentLastNameRequester}',
        '${m.currentFirstNameRequesterArabic} ${m.currentLastNameRequesterArabic}',
      ),
      departmentName: context.svcDepartmentName,
      statusLabel: context.svcStatus,
      pick: context.svcPick,
    );
    if (!context.mounted) return;
    if (result.isLeft()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.exportFailed)));
      return;
    }
    // SVC-HOME-23: save sheet dismissed on a phone — nothing was written.
    if (result.getOrElse(() => '') == CSVHelper.exportCancelled) return;
    await showDownloadSuccessDialog(context);
  }
}
