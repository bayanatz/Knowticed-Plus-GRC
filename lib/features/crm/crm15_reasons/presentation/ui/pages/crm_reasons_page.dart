// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reasons_page.dart
// Purpose: Browse CRM client-status reason-set categories
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/domain/entities/crm_reason.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/presentation/controller/crm_reason_sets_cubit.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/presentation/controller/crm_reason_sets_state.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/presentation/ui/pages/crm_reason_details_page.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/presentation/ui/widgets/crm_reason_set_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmReasonsPage extends StatefulWidget {
  const CrmReasonsPage({super.key});

  @override
  State<CrmReasonsPage> createState() => _CrmReasonsPageState();
}

class _CrmReasonsPageState extends State<CrmReasonsPage> {
  late final CrmReasonSetsCubit _cubit;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _cubit = CrmReasonSetsCubit();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _openReasonSet(CrmReasonSetDefinition reasonSet) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            CrmReasonDetailsPage(reasonSet: reasonSet),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crm,
          secondTitle: S.current.crmSectionControls,
          thirdTitle: S.current.crmControlReasons,
          onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
          onSecondTap: () => CrmNavigationHelper.pop(context),
          child: BlocBuilder<CrmReasonSetsCubit, CrmReasonSetsState>(
            bloc: _cubit,
            builder: (BuildContext context, CrmReasonSetsState state) =>
                SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomSearchFilterSortBar<String, String>(
                    searchController: _searchController,
                    onSearchChanged: _cubit.search,
                    searchHint: S.current.crmSearch,
                    showFilter: true,
                    filterTitle: S.current.crmFilter,
                    showSort: true,
                    sortTitle: S.current.crmSort,
                    selectedSort: state.selectedSort,
                    sortItems: const <String>['name_asc', 'name_desc'],
                    sortLabelBuilder: _sortLabel,
                    onSortChanged: _cubit.setSort,
                  ),
                  SizedBox(height: 16.sp),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossAxisCount(context),
                      mainAxisExtent: 76.sp,
                      crossAxisSpacing: 12.sp,
                      mainAxisSpacing: 12.sp,
                    ),
                    itemCount: state.visibleReasonSets.length,
                    itemBuilder: (BuildContext context, int index) {
                      final CrmReasonSetDefinition reasonSet =
                          state.visibleReasonSets[index];
                      return CrmReasonSetCard(
                        reasonSet: reasonSet,
                        onTap: () => _openReasonSet(reasonSet),
                      );
                    },
                  ),
                  SizedBox(height: 32.sp),
                ],
              ),
            ),
          ),
        ),
      );

  int _crossAxisCount(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 900) return 3;
    return CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);
  }

  String _sortLabel(String value) =>
      value == 'name_desc' ? 'Name: Z to A' : 'Name: A to Z';
}
