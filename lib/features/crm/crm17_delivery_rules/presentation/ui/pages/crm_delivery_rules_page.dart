// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rules_page.dart
// Purpose: CRM Controls list page for delivery fee rules
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/interfaces/crm_delivery_rules_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/presentation/controller/crm_delivery_rules_cubit.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/presentation/controller/crm_delivery_rules_state.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/presentation/ui/pages/crm_delivery_rule_form_page.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/presentation/ui/widgets/crm_delivery_rule_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';

class CrmDeliveryRulesPage extends StatefulWidget {
  const CrmDeliveryRulesPage({super.key});

  @override
  State<CrmDeliveryRulesPage> createState() => _CrmDeliveryRulesPageState();
}

class _CrmDeliveryRulesPageState extends State<CrmDeliveryRulesPage> {
  late final CrmDeliveryRulesCubit _cubit;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _cubit = CrmDeliveryRulesCubit(
        repository: Get.find<CrmDeliveryRulesBaseRepository>())
      ..init();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _openForm({CrmDeliveryRule? rule}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => CrmDeliveryRuleFormPage(rule: rule)));

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crm,
          secondTitle: S.current.crmSectionControls,
          thirdTitle: S.current.crmControlDeliveryRules,
          onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
          onSecondTap: () => CrmNavigationHelper.pop(context),
          child: BlocConsumer<CrmDeliveryRulesCubit, CrmDeliveryRulesState>(
            bloc: _cubit,
            listener: (BuildContext context, CrmDeliveryRulesState state) {
              if (state.errorMessage != null) {
                _cubit.clearError();
                CrmControlDialogs.showErrorDialog(
                    context: context,
                    title: S.current.crmAlert,
                    subtitle: state.errorMessage!);
              }
            },
            builder: (BuildContext context, CrmDeliveryRulesState state) {
              if (state.isLoading && state.rules.isEmpty) {
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
                    _statusFilter(state),
                    SizedBox(height: 14.sp),
                    CustomSearchFilterSortBar<String, String>(
                      searchController: _searchController,
                      onSearchChanged: _cubit.search,
                      searchHint: S.current.crmSearch,
                      showFilter: true,
                      filterTitle: S.current.crmFilter,
                      filterItems: const <String>['All', 'Active', 'Inactive'],
                      selectedFilter:
                          state.status == 'All' ? null : state.status,
                      filterLabelBuilder: (String item) => switch (item) {
                        'Active' => S.current.crmActive,
                        'Inactive' => S.current.crmInactive,
                        _ => S.current.crmAll,
                      },
                      onFilterChanged: (String? value) {
                        if (value != null) _cubit.setStatus(value);
                      },
                      showSort: true,
                      sortTitle: S.current.crmSort,
                      sortItems: const <String>['name_asc', 'name_desc'],
                      selectedSort: state.sort,
                      sortLabelBuilder: (String item) => item == 'name_desc'
                          ? S.current.crmSortNameZA
                          : S.current.crmSortNameAZ,
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
                    if (state.visibleRules.isEmpty)
                      const CustomEmptyState(
                          svgPath: CrmAssets.crmEmptyState, size: 250)
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent: 80.sp,
                          crossAxisSpacing: 12.sp,
                          mainAxisSpacing: 12.sp,
                        ),
                        itemCount: state.visibleRules.length,
                        itemBuilder: (BuildContext context, int index) =>
                            CrmDeliveryRuleCard(
                          rule: state.visibleRules[index],
                          onTap: () =>
                              _openForm(rule: state.visibleRules[index]),
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

  Widget _statusFilter(CrmDeliveryRulesState state) => StatusChipFilter(
        selectedKey: state.status,
        onSelected: _cubit.setStatus,
        items: <StatusChipItem>[
          StatusChipItem(
            key: 'All',
            label: S.current.crmAll,
            count: state.rules.length,
          ),
          StatusChipItem(
            key: 'Active',
            label: S.current.crmActive,
            count: state.activeCount,
            labelColor: AppColors.green,
          ),
          StatusChipItem(
            key: 'Inactive',
            label: S.current.crmInactive,
            count: state.inactiveCount,
            labelColor: AppColors.orange,
          ),
        ],
      );
}
