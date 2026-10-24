// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commissions_page.dart
// Purpose: CRM Controls list page for flat-rate commission packages
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_bar_item.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/interfaces/crm_commissions_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/controller/crm_commissions_cubit.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/controller/crm_commissions_state.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/ui/pages/crm_commission_package_form_page.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/ui/widgets/crm_commission_package_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';

class CrmCommissionsPage extends StatefulWidget {
  const CrmCommissionsPage({super.key});

  @override
  State<CrmCommissionsPage> createState() => _CrmCommissionsPageState();
}

class _CrmCommissionsPageState extends State<CrmCommissionsPage> {
  late final CrmCommissionsCubit _cubit;
  late final TextEditingController _searchController;

  int _packageCardColumns(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth >= 1920) {
      return 3;
    }
    if (screenWidth >= 768) {
      return 2;
    }
    return 1;
  }

  @override
  void initState() {
    super.initState();
    _cubit = CrmCommissionsCubit(
      repository: Get.find<CrmCommissionsBaseRepository>(),
    )..init();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _openForm({CrmCommissionPackage? package}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          CrmCommissionPackageFormPage(package: package),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crm,
          secondTitle: S.current.crmSectionControls,
          thirdTitle: S.current.crmControlCommissions,
          onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
          onSecondTap: () => CrmNavigationHelper.pop(context),
          child: BlocConsumer<CrmCommissionsCubit, CrmCommissionsState>(
            bloc: _cubit,
            listener: (BuildContext context, CrmCommissionsState state) {
              if (state.errorMessage != null) {
                _cubit.clearError();
                CrmControlDialogs.showErrorDialog(
                  context: context,
                  title: S.current.crmAlert,
                  subtitle: state.errorMessage!,
                );
              }
            },
            builder: (BuildContext context, CrmCommissionsState state) {
              if (state.isLoading && state.packages.isEmpty) {
                return const Center(child: CircleProgressMaster());
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _categoryTabs(state),
                    SizedBox(height: 16.sp),
                    CustomSearchFilterSortBar<String, String>(
                      searchController: _searchController,
                      onSearchChanged: _cubit.search,
                      searchHint: S.current.crmSearch,
                      showFilter: true,
                      filterTitle: S.current.crmFilter,
                      filterItems: const <String>['All', 'Commission'],
                      selectedFilter: state.category,
                      filterLabelBuilder: (String item) => item,
                      onFilterChanged: (String? item) {
                        if (item != null) _cubit.setCategory(item);
                      },
                      showSort: true,
                      sortTitle: S.current.crmSort,
                      sortItems: const <String>['name_asc', 'name_desc'],
                      selectedSort: state.selectedSort,
                      sortLabelBuilder: (String item) =>
                          item == 'name_desc' ? 'Name: Z to A' : 'Name: A to Z',
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
                    if (state.visiblePackages.isEmpty)
                      const CustomEmptyState(
                        svgPath: CrmAssets.crmEmptyState,
                        size: 250,
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _packageCardColumns(context),
                          mainAxisExtent: 128.sp,
                          crossAxisSpacing: 12.sp,
                          mainAxisSpacing: 12.sp,
                        ),
                        itemCount: state.visiblePackages.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CrmCommissionPackage package =
                              state.visiblePackages[index];
                          return CrmCommissionPackageCard(
                            package: package,
                            onTap: () => _openForm(package: package),
                          );
                        },
                      ),
                    SizedBox(height: 32.sp),
                  ],
                ),
              );
            },
          ),
        ),
      );

  Widget _categoryTabs(CrmCommissionsState state) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            FilterBarItem(
              title: 'All',
              numberOfItems: state.packages.length,
              isSelected: state.category == 'All',
              color: AppColors.text,
              onTap: () => _cubit.setCategory('All'),
            ),
            SizedBox(width: 16.sp),
            FilterBarItem(
              title: 'Commission',
              numberOfItems: state.packages.length,
              isSelected: state.category == 'Commission',
              color: AppColors.green,
              onTap: () => _cubit.setCategory('Commission'),
            ),
          ],
        ),
      );
}
