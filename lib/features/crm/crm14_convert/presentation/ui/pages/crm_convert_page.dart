// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_page.dart
// Purpose: CRM Controls page for conversion-stage management
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_tab_with_container.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/domain/entities/crm_convert_stage.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/domain/interfaces/crm_convert_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/presentation/controller/crm_convert_cubit.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/presentation/controller/crm_convert_state.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/presentation/ui/pages/crm_convert_stage_form_page.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/presentation/ui/widgets/crm_convert_stage_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';

class CrmConvertPage extends StatefulWidget {
  const CrmConvertPage({super.key});

  @override
  State<CrmConvertPage> createState() => _CrmConvertPageState();
}

class _CrmConvertPageState extends State<CrmConvertPage> {
  late final CrmConvertCubit _cubit;
  late final TextEditingController _searchController;
  int _selectedTab = 1;

  @override
  void initState() {
    super.initState();
    _cubit = CrmConvertCubit(repository: Get.find<CrmConvertBaseRepository>())
      ..init();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _openForm({CrmConvertStage? stage}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => CrmConvertStageFormPage(
        convertCubit: _cubit,
        stage: stage,
        readOnly: stage != null,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crm,
          secondTitle: S.current.crmSectionControls,
          thirdTitle: S.current.crmControlConvert,
          onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
          onSecondTap: () => CrmNavigationHelper.pop(context),
          child: BlocConsumer<CrmConvertCubit, CrmConvertState>(
            bloc: _cubit,
            listener: (BuildContext context, CrmConvertState state) {
              final String? error = state.errorMessage;
              if (error != null && error.isNotEmpty) {
                _cubit.clearError();
                CrmControlDialogs.showErrorDialog(
                  context: context,
                  title: S.current.crmAlert,
                  subtitle: error,
                );
              }
            },
            builder: (BuildContext context, CrmConvertState state) {
              if (state.isLoading && state.stages.isEmpty) {
                return const Center(child: CircleProgressMaster());
              }
              final bool isMobile = kpIsPhoneLayout(context);
              final int crossAxisCount = isMobile
                  ? 1
                  : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                      context);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomSegmentedTabs(
                      tabs: <String>[
                        FormatHelper.localizedString(
                          englishName: 'Settings',
                          arabicName: 'الإعدادات',
                        ),
                        FormatHelper.localizedString(
                          englishName: 'Stages',
                          arabicName: 'المراحل',
                        ),
                      ],
                      selectedIndex: _selectedTab,
                      onTabSelected: (int index) {
                        setState(() => _selectedTab = index);
                      },
                    ),
                    SizedBox(height: 14.sp),
                    if (_selectedTab == 0)
                      _buildSettingsTab()
                    else ...<Widget>[
                      _statusFilter(state),
                      SizedBox(height: 14.sp),
                      CustomSearchFilterSortBar<String, String>(
                        searchController: _searchController,
                        onSearchChanged: _cubit.search,
                        searchHint: S.current.crmSearch,
                        showFilter: true,
                        filterTitle: S.current.crmFilter,
                        selectedFilter: state.selectedStatus == 'All'
                            ? null
                            : state.selectedStatus,
                        filterItems: const <String>[
                          'All',
                          'Active',
                          'Inactive'
                        ],
                        filterLabelBuilder: _statusLabel,
                        onFilterChanged: (String? value) {
                          if (value != null) _cubit.setStatus(value);
                        },
                        showSort: true,
                        sortTitle: S.current.crmSort,
                        selectedSort: state.selectedSort,
                        sortItems: const <String>[
                          'name_asc',
                          'name_desc',
                          'date_desc',
                          'date_asc'
                        ],
                        sortLabelBuilder: _sortLabel,
                        onSortChanged: _cubit.setSort,
                        trailingActionsBuilder:
                            (BuildContext context, bool isPhone) => <Widget>[
                          customButtonWithSvg(
                            title: isPhone ? '' : S.current.crmAdd,
                            function: _openForm,
                            color: AppColors.primary,
                            colorBorder: AppColors.transparent,
                            image: AppAssets.crmPlusBold,
                            svgColor: AppColors.black,
                            widthImage: 16.sp,
                            heightImage: 16.sp,
                            // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                            textStyle: StyleText.fontSize14Weight500
                                .copyWith(color: AppColors.blackButton),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.sp),
                      if (state.visibleStages.isEmpty)
                        const CustomEmptyState(
                          svgPath: CrmAssets.crmEmptyState,
                          size: 250,
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisExtent: 92.sp,
                            crossAxisSpacing: 12.sp,
                            mainAxisSpacing: 12.sp,
                          ),
                          itemCount: state.visibleStages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final CrmConvertStage stage =
                                state.visibleStages[index];
                            return CrmConvertStageCard(
                              stage: stage,
                              onTap: () => _openForm(stage: stage),
                            );
                          },
                        ),
                    ],
                    SizedBox(height: 32.sp),
                  ],
                ),
              );
            },
          ),
        ),
      );

  Widget _buildSettingsTab() => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: CustomEmptyState(
            svgPath: CrmAssets.crmEmptyState,
            size: 250,
          ),
        ),
      );

  Widget _statusFilter(CrmConvertState state) => StatusChipFilter(
        selectedKey: state.selectedStatus,
        onSelected: _cubit.setStatus,
        items: <StatusChipItem>[
          StatusChipItem(
              key: 'All', label: S.current.crmAll, count: state.stages.length),
          StatusChipItem(
              key: 'Active',
              label: S.current.crmActive,
              count: state.activeCount,
              labelColor: AppColors.green),
          StatusChipItem(
              key: 'Inactive',
              label: S.current.crmInactive,
              count: state.inactiveCount,
              labelColor: AppColors.orange),
        ],
      );

  String _statusLabel(String value) => switch (value) {
        'All' => S.current.crmAll,
        'Active' => S.current.crmActive,
        _ => S.current.crmInactive,
      };

  String _sortLabel(String value) => switch (value) {
        'name_asc' => S.current.crmSortNameAZ,
        'name_desc' => S.current.crmSortNameZA,
        'date_desc' => S.current.crmSortNewest,
        _ => S.current.crmSortOldest,
      };
}
