// ****************** FILE INFO ******************
// File Name: crm_merge_levels_page.dart
// Purpose: CRM Merge settings and likelihood-level management page.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_tab_with_container.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_merge_levels_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_merge_levels_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_merge_level_form_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_merge_level_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_merge_settings_tab.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmMergeLevelsPage extends StatefulWidget {
  const CrmMergeLevelsPage({super.key});

  @override
  State<CrmMergeLevelsPage> createState() => _CrmMergeLevelsPageState();
}

class _CrmMergeLevelsPageState extends State<CrmMergeLevelsPage> {
  int _selectedTab = 0; // 0: Settings, 1: Likelihood
  late final TextEditingController _searchController;
  bool _isEditingSettings = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CrmMergeLevelsCubit>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StatusChipItem> _statusItems(CrmMergeLevelsState state) =>
      <StatusChipItem>[
        StatusChipItem(
          key: 'All',
          label: S.current.crmAll,
          count: state.items.length,
        ),
        StatusChipItem(
          key: 'Active',
          label: S.current.crmActive,
          count: state.items.where((item) => item.isActive).length,
          labelColor: AppColors.green,
        ),
        StatusChipItem(
          key: 'Inactive',
          label: S.current.crmInactive,
          count: state.items.where((item) => !item.isActive).length,
          labelColor: AppColors.orange,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = kpIsPhoneLayout(context);
    final int crossAxisCount = isMobile
        ? 1
        : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

    final String pageTitle =
        _isEditingSettings ? S.current.crmEditMerge : S.current.crmSectionMerge;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: pageTitle,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        onThirdTap: () {
          if (_isEditingSettings) {
            setState(() => _isEditingSettings = false);
          } else {
            CrmNavigationHelper.pop(context);
          }
        },
        child: BlocBuilder<CrmMergeLevelsCubit, CrmMergeLevelsState>(
          builder: (BuildContext context, CrmMergeLevelsState state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Segmented Tabs (Settings / Likelihood) - Hidden in Edit Mode
                  if (!_isEditingSettings) ...<Widget>[
                    CustomSegmentedTabs(
                      tabs: <String>[
                        S.current.crmMergeSettings,
                        S.current.crmLikelihood,
                      ],
                      selectedIndex: _selectedTab,
                      onTabSelected: (int index) {
                        setState(() {
                          _selectedTab = index;
                          _isEditingSettings = false;
                        });
                      },
                    ),
                    SizedBox(height: 14.sp),
                  ],

                  // Tab 0: Settings Content
                  if (_selectedTab == 0) ...<Widget>[
                    CrmMergeSettingsTab(
                      settings: state.settings,
                      isEditing: _isEditingSettings,
                      onStartEdit: () =>
                          setState(() => _isEditingSettings = true),
                      onCancelEdit: () =>
                          setState(() => _isEditingSettings = false),
                    ),
                  ]
                  // Tab 1: Likelihood Content
                  else ...<Widget>[
                    _buildLikelihoodTab(state, crossAxisCount),
                  ],

                  if (state.errorMessage != null) ...<Widget>[
                    SizedBox(height: 12.sp),
                    Text(
                      state.errorMessage!,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.red),
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
  }

  // ----------------------------------------------------
  // LIKELIHOOD TAB (Cards List / Search / Filters)
  // ----------------------------------------------------
  Widget _buildLikelihoodTab(CrmMergeLevelsState state, int crossAxisCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (state.items.isNotEmpty) ...<Widget>[
          StatusChipFilter(
            selectedKey: state.selectedStatus,
            onSelected: context.read<CrmMergeLevelsCubit>().selectStatus,
            items: _statusItems(state),
          ),
          SizedBox(height: 14.sp),
        ],
        _buildToolbar(state),
        SizedBox(height: 16.sp),
        if (state.isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40.sp),
            child: const Center(child: CircleProgressMaster()),
          )
        else if (state.filteredItems.isEmpty)
          _buildEmptyState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 84.sp,
              crossAxisSpacing: 14.sp,
              mainAxisSpacing: 14.sp,
            ),
            itemCount: state.filteredItems.length,
            itemBuilder: (BuildContext context, int index) {
              final CrmMergeLevelModel item = state.filteredItems[index];
              return CrmMergeLevelCard(
                level: item,
                onTap: () => CrmNavigationHelper.navigateToControlMergeForm(
                  context,
                  arguments: <String, dynamic>{
                    'mode': CrmMergeLevelFormMode.details,
                    'level': item,
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildToolbar(CrmMergeLevelsState state) {
    return CustomSearchFilterSortBar<String, String>(
      searchController: _searchController,
      searchHint: S.current.crmSearch,
      onSearchChanged: context.read<CrmMergeLevelsCubit>().search,
      showFilter: true,
      filterItems: const <String>['All', 'Active', 'Inactive'],
      selectedFilter: state.selectedStatus,
      filterTitle: S.current.crmFilter,
      filterLabelBuilder: (String value) => value == 'All'
          ? S.current.crmAll
          : value == 'Active'
              ? S.current.crmActive
              : S.current.crmInactive,
      onFilterChanged: (String? value) =>
          context.read<CrmMergeLevelsCubit>().selectStatus(value ?? 'All'),
      showSort: true,
      selectedSort: state.selectedSort,
      sortTitle: S.current.crmSort,
      sortItems: const <String>[
        'name_asc',
        'name_desc',
        'range_asc',
        'range_desc'
      ],
      sortLabelBuilder: (String value) => switch (value) {
        'name_asc' => S.current.crmSortNameAZ,
        'name_desc' => S.current.crmSortNameZA,
        'range_asc' => S.current.crmMergeSortRangeAsc,
        _ => S.current.crmMergeSortRangeDesc,
      },
      onSortChanged: context.read<CrmMergeLevelsCubit>().setSort,
      trailingActionsBuilder: (BuildContext context, bool isPhone) => <Widget>[
        customButtonWithSvg(
          title: isPhone ? '' : S.current.crmAdd,
          function: () => CrmNavigationHelper.navigateToControlMergeForm(
            context,
            arguments: <String, dynamic>{'mode': CrmMergeLevelFormMode.add},
          ),
          // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.blackButton),
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: AppAssets.add,
          widthImage: 20.sp,
          heightImage: 20.sp,
          svgColor: AppColors.black,
        ),
      ],
    );
  }

  Widget _buildEmptyState() => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.sp),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            CustomSvgImage(
              assetPath: AppAssets.crmRelationshipEmpty,
              width: 140.sp,
              height: 140.sp,
            ),
            SizedBox(height: 16.sp),
            Text(
              S.current.crmMergeNoLevels,
              style: StyleText.fontSize16Weight600,
            ),
          ]),
        ),
      );
}
