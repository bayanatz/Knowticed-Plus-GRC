// ****************** FILE INFO ******************
// File Name: crm_billing_contracts_page.dart
// Purpose: Main listing page for Billing & Contracts with search, status filter, and grid (Edit only, fixed items)
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/presentation/controller/crm_billing_contracts_cubit.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/presentation/controller/crm_billing_contracts_state.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/presentation/ui/widgets/crm_billing_contract_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

class CrmBillingContractsPage extends StatefulWidget {
  const CrmBillingContractsPage({super.key});

  @override
  State<CrmBillingContractsPage> createState() =>
      _CrmBillingContractsPageState();
}

class _CrmBillingContractsPageState extends State<CrmBillingContractsPage> {
  late final CrmBillingContractsCubit _cubit;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _cubit = CrmBillingContractsCubit()..init();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  int _getCrossAxisCount(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width < 700) return 1;
    if (width < 1200) return 2;
    return 2;
  }

  Future<void> _onItemTap(CrmBillingContractModel item) async {
    final dynamic result =
        await CrmNavigationHelper.navigateToControlBillingContractDetails(
      context,
      arguments: <String, dynamic>{
        'item': item,
      },
    );
    await _handleFormResult(result, existingItem: item);
  }

  Future<void> _handleFormResult(
    dynamic result, {
    required CrmBillingContractModel existingItem,
  }) async {
    if (!mounted || result is! Map<String, dynamic>) return;
    final String action = (result['action'] ?? '').toString();

    if (action == 'save') {
      final CrmBillingContractModel? item =
          result['item'] as CrmBillingContractModel?;
      if (item == null) return;

      showLoadingIndicator();
      final bool saved = await _cubit.updateBillingContract(item);
      hideLoadingIndicator();

      if (!mounted || !saved) {
        if (mounted && _cubit.state.errorMessage != null) {
          CrmControlDialogs.showErrorDialog(
            context: context,
            title: S.current.crmAlert,
            subtitle: _cubit.state.errorMessage!,
          );
        }
        return;
      }

      await CrmControlDialogs.showSuccessDialog(
        context: context,
        title: S.current.crmSuccess,
        subtitle: S.current.crmBillingContractUpdatedSuccess,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CrmBillingContractsCubit>.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crm,
          secondTitle: S.current.crmSectionControls,
          thirdTitle: S.current.crmControlBillingAndContracts,
          onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
          onSecondTap: () => Navigator.pop(context),
          child:
              BlocConsumer<CrmBillingContractsCubit, CrmBillingContractsState>(
            listener: (BuildContext context, CrmBillingContractsState state) {},
            builder: (BuildContext context, CrmBillingContractsState state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search, Filter & Sort Bar (No Add button as items are fixed)
                    CustomSearchFilterSortBar<String, String>(
                      searchController: _searchController,
                      onSearchChanged: (String q) => _cubit.search(q),
                      searchHint: S.current.search,
                      showFilter: true,
                      filterTitle: S.current.status,
                      filterItems: const <String>['all', 'Active', 'Inactive'],
                      selectedFilter: state.selectedStatusFilter,
                      filterLabelBuilder: (String item) {
                        if (item == 'all' || item == 'All') {
                          return S.current.crmAll;
                        }
                        if (item == 'Active') return S.current.crmActive;
                        return S.current.crmInactive;
                      },
                      onFilterChanged: (String? status) {
                        if (status != null) _cubit.setStatusFilter(status);
                      },
                      isFilterActive: state.selectedStatusFilter != 'all' &&
                          state.selectedStatusFilter != 'All',
                      showSort: true,
                      sortTitle: S.current.sort,
                      sortItems: const <String>[
                        'name_asc',
                        'name_desc',
                        'newest',
                        'oldest',
                      ],
                      selectedSort: state.selectedSort,
                      sortLabelBuilder: (String item) {
                        switch (item) {
                          case 'name_desc':
                            return S.current.crmSortNameDesc;
                          case 'newest':
                            return S.current.crmSortNewest;
                          case 'oldest':
                            return S.current.crmSortOldest;
                          case 'name_asc':
                          default:
                            return S.current.crmSortNameAsc;
                        }
                      },
                      onSortChanged: (String? sort) => _cubit.setSort(sort),
                    ),
                    SizedBox(height: 16.sp),

                    // Content State
                    if (state.isLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 80.sp),
                        child: const Center(child: CircleProgressMaster()),
                      )
                    else if (state.filteredItems.isEmpty)
                      _buildEmptyState()
                    else
                      _buildGrid(state.filteredItems),

                    SizedBox(height: 24.sp),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.sp),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath: AppAssets.crmTemplateEmpty,
              width: 180.sp,
              height: 140.sp,
            ),
            SizedBox(height: 16.sp),
            Text(
              S.current.crmNoBillingContractsFound,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<CrmBillingContractModel> items) {
    final int crossAxisCount = _getCrossAxisCount(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 80.sp,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmBillingContractModel item = items[index];
        return CrmBillingContractCard(
          item: item,
          onTap: () => _onItemTap(item),
        );
      },
    );
  }
}
