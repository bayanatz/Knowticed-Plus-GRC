// ****************** FILE INFO ******************
// File Name: crm_client_types_page.dart
// Purpose: Controls page for managing Client Types with search and grid display
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_client_types_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_client_types_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_client_type_form_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_client_type_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmClientTypesPage extends StatefulWidget {
  const CrmClientTypesPage({super.key});

  @override
  State<CrmClientTypesPage> createState() => _CrmClientTypesPageState();
}

class _CrmClientTypesPageState extends State<CrmClientTypesPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CrmClientTypesCubit>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = kpIsPhoneLayout(context);
    final int crossAxisCount = isMobile
        ? 1
        : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmControlClientsTypes,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: BlocBuilder<CrmClientTypesCubit, CrmClientTypesState>(
          builder: (BuildContext context, CrmClientTypesState state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSearchFilterSortBar<Object?, Object?>(
                    searchController: _searchController,
                    searchHint: S.current.crmSearch,
                    onSearchChanged: context.read<CrmClientTypesCubit>().search,
                    trailingActionsBuilder:
                        (BuildContext context, bool isPhone) => <Widget>[
                      customButtonWithSvg(
                        title: isPhone ? '' : S.current.crmAdd,
                        function: () =>
                            CrmNavigationHelper.navigateToClientTypeForm(
                          context,
                          mode: CrmClientTypeFormMode.add,
                        ),
                        // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                        textStyle: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                        color: AppColors.primary,
                        colorBorder: AppColors.transparent,
                        image: AppAssets.add,
                        widthImage: 20.sp,
                        heightImage: 20.sp,
                        svgColor: AppColors.black,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.sp),
                  if (state.isLoading && state.items.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 40.sp),
                      child: const CircleProgressMaster(),
                    )
                  else if (state.errorMessage != null && state.items.isEmpty)
                    Text(
                      state.errorMessage!,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.red,
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisExtent: 56.sp,
                        crossAxisSpacing: 14.sp,
                        mainAxisSpacing: 14.sp,
                      ),
                      itemCount: state.filteredItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        final CrmClientTypeModel item =
                            state.filteredItems[index];
                        return CrmClientTypeCard(
                          item: item.copyWith(
                            onTap: () {
                              context
                                  .read<CrmClientTypesCubit>()
                                  .selectType(item);
                              CrmNavigationHelper.navigateToClientTypeForm(
                                context,
                                mode: CrmClientTypeFormMode.details,
                                clientType: item,
                              );
                            },
                          ),
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
  }
}
