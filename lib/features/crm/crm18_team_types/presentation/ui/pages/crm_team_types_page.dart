// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_types_page.dart
// Purpose: Lists and filters CRM team types
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_bar_item.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/interfaces/crm_team_types_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/presentation/controller/crm_team_types_cubit.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/presentation/controller/crm_team_types_state.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/presentation/ui/widgets/crm_team_type_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';

/// Control page for creating and managing selectable team types.
class CrmTeamTypesPage extends StatefulWidget {
  const CrmTeamTypesPage({super.key});

  @override
  State<CrmTeamTypesPage> createState() => _CrmTeamTypesPageState();
}

class _CrmTeamTypesPageState extends State<CrmTeamTypesPage> {
  late final CrmTeamTypesCubit _cubit;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _cubit = CrmTeamTypesCubit(
      repository: Get.find<CrmTeamTypesBaseRepository>(),
    )..init();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _openForm({CrmTeamType? teamType}) =>
      CrmNavigationHelper.navigateToControlTeamTypeForm(
        context,
        teamType: teamType,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crm,
          secondTitle: S.current.crmSectionControls,
          thirdTitle: 'Team Types',
          onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
          onSecondTap: () => CrmNavigationHelper.pop(context),
          child: BlocConsumer<CrmTeamTypesCubit, CrmTeamTypesState>(
            bloc: _cubit,
            listener: (BuildContext context, CrmTeamTypesState state) {
              if (state.errorMessage != null) {
                _cubit.clearError();
                CrmControlDialogs.showErrorDialog(
                  context: context,
                  title: S.current.crmAlert,
                  subtitle: state.errorMessage!,
                );
              }
            },
            builder: (BuildContext context, CrmTeamTypesState state) {
              if (state.isLoading && state.items.isEmpty) {
                return const Center(child: CircleProgressMaster());
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _tabs(state),
                    SizedBox(height: 16.sp),
                    CustomSearchFilterSortBar<String, String>(
                      searchController: _searchController,
                      onSearchChanged: _cubit.search,
                      searchHint: S.current.crmSearch,
                      showFilter: true,
                      filterTitle: S.current.crmFilter,
                      filterItems: const <String>[
                        'All',
                        'Active',
                        'Inactive',
                      ],
                      selectedFilter: state.status,
                      filterLabelBuilder: (String item) => item,
                      onFilterChanged: (String? value) {
                        if (value != null) _cubit.setStatus(value);
                      },
                      showSort: false,
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
                    if (state.visibleItems.isEmpty)
                      const CustomEmptyState(
                        svgPath: CrmAssets.crmEmptyState,
                        size: 250,
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: CrossAxisCountHelper
                              .getCrossAxisCountForDefaultTablet2(context),
                          mainAxisExtent: 74.sp,
                          crossAxisSpacing: 12.sp,
                          mainAxisSpacing: 12.sp,
                        ),
                        itemCount: state.visibleItems.length,
                        itemBuilder: (BuildContext context, int index) =>
                            CrmTeamTypeCard(
                          teamType: state.visibleItems[index],
                          onTap: () =>
                              _openForm(teamType: state.visibleItems[index]),
                        ),
                      ),
                    SizedBox(height: 32.sp),
                  ],
                ),
              );
            },
          ),
        ),
      );

  Widget _tabs(CrmTeamTypesState state) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            FilterBarItem(
              title: 'All',
              numberOfItems: state.items.length,
              isSelected: state.status == 'All',
              color: AppColors.text,
              onTap: () => _cubit.setStatus('All'),
            ),
            SizedBox(width: 16.sp),
            FilterBarItem(
              title: 'Active',
              numberOfItems: state.activeCount,
              isSelected: state.status == 'Active',
              color: AppColors.green,
              onTap: () => _cubit.setStatus('Active'),
            ),
            SizedBox(width: 16.sp),
            FilterBarItem(
              title: 'Inactive',
              numberOfItems: state.inactiveCount,
              isSelected: state.status == 'Inactive',
              color: AppColors.orange,
              onTap: () => _cubit.setStatus('Inactive'),
            ),
          ],
        ),
      );
}
