/// Module: GRC Module Management
/// Description: Provides the GRC dashboard/details page showing module
///              analytics, filter tabs, and quick-action buttons.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-28
/// Dependencies: Flutter SDK, AppColors, AppTheme, PaginationAppBar,
///               PolicyCubit, GRCModuleEntity
/// Revision History: 2026-06-28 - Initial creation
///                   2026-07-06 - Scoped to a single GRC Module: real title,
///                                real policy list/counts from PolicyCubit,
///                                Create Policy now passes moduleId
///                                (Mohamed Magdy Abdelkhalek)
///                   2026-07-27 - Split per-tab bodies into dedicated widget
///                                files and dispatch tabs via enum switch
///                                (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_details_page.dart
/// Purpose: Contains GrcModuleDetailsPage, the GRC dashboard screen scoped
///          to a single GRC Module and its Policies.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/6/2026

import 'package:demo_app/core/custom/10-custom_tabs.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/approval/presentation/ui/pages/approvals_list_page.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/my_audit/presentation/ui/pages/my_audits_list_page.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_module_champions_tab.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_module_owners_tab.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_module_policies_tab.dart';
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/ui/pages/assignment_controls_list_page.dart';

/// enum name: [GrcModuleDetailTab]
///
/// purpose: identifies which tab body is currently selected on the GRC module
///          details screen. The order matches the [_GrcModuleDetailsBodyState]
///          `_tabs` labels so `GrcModuleDetailTab.values[index]` maps a
///          CustomTabs index to its tab identity.
enum GrcModuleDetailTab { policies, champions, owners, departments }

/// class name: [GrcModuleDetailsPage]
///
/// purpose: GRC dashboard screen scoped to a single [GRCModuleEntity].
///          Provides a [PolicyCubit] that loads every Policy belonging to
///          [module] and renders the real status counts and policy list.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class GrcModuleDetailsPage extends StatelessWidget {
  final GRCModuleEntity module;

  const GrcModuleDetailsPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyCubit>(
          create: (_) => GetIt.instance<PolicyCubit>()
            ..getAllPolicies(moduleId: module.moduleId),
        ),
        BlocProvider<ChampionCubit>(
          create: (_) => GetIt.instance<ChampionCubit>()
            ..getAllChampions(moduleId: module.moduleId),
        ),
        BlocProvider<OwnerCubit>(
          create: (_) => GetIt.instance<OwnerCubit>()
            ..getAllOwners(moduleId: module.moduleId),
        ),
      ],
      child: _GrcModuleDetailsBody(module: module),
    );
  }
}

class _GrcModuleDetailsBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _GrcModuleDetailsBody({required this.module});

  @override
  State<_GrcModuleDetailsBody> createState() => _GrcModuleDetailsBodyState();
}

class _GrcModuleDetailsBodyState extends State<_GrcModuleDetailsBody> {
  static const _tabs = [
    'Policies',
    'Control Champions',
    'Control Owners',
    'Departments',
  ];

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final selectedTab = GrcModuleDetailTab.values[_selectedTab];
    final isChampionOrOwnerTab = selectedTab == GrcModuleDetailTab.champions ||
        selectedTab == GrcModuleDetailTab.owners;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [
                  'GRC'.tr,
                  widget.module.localizedName(isArabic: context.isArabic),
                ],
              ),

              // Approved Evidence + Dashboard
              Row(
                spacing: 8.w,
                mainAxisAlignment: isChampionOrOwnerTab
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (!isChampionOrOwnerTab)
                    customButtonWithSvg(
                      colorBorder: AppColors.primary,
                      space: 10.w,
                      radius: 8.r,
                      widthImage: 16.w,
                      heightImage: 16.h,
                      image:
                          "assets/icons_assets/data_grc_assets/approved-evidence-icon.svg",
                      title: "Approved Evidence".tr,
                      function: () {},
                      width: isTablet ? 200.w : 180.w,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.textButton),
                    ),
                  customButton(
                    title: "Dashboard".tr,
                    function: () {},
                    width: 135.w,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton),
                  ),
                ],
              ),
              SizedBox(height: 15.h),

              if (!isChampionOrOwnerTab) ...[
                // Approvals + Assignment Controls + My Audits
                Row(
                  spacing: 8.w,
                  children: [
                    customButton(
                      title: "Approvals".tr,
                      function: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              ApprovalsListPage(module: widget.module),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      ),
                      width: 120.w,
                      height: 38.h,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.textButton),
                    ),
                    customButton(
                      title: "Assignment Controls".tr,
                      function: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              AssignmentControlsListPage(module: widget.module),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      ),
                      width: isTablet ? 180.w : 170.w,
                      height: 38.h,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.textButton),
                    ),
                    Spacer(),
                    customButton(
                      title: "My Audits".tr,
                      function: () async {
                        await Navigator.push<bool>(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                MyAuditsListPage(module: widget.module),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 300),
                          ),
                        );
                        if (context.mounted) {
                          context
                              .read<PolicyCubit>()
                              .getAllPolicies(moduleId: widget.module.moduleId);
                        }
                      },
                      width: 135.w,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.textButton),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
              ],

              CustomTabs(
                tabs: _tabs,
                selectedValue: _selectedTab,
                onChanged: (v) => setState(() => _selectedTab = v),
              ),
              SizedBox(height: 15.h),

              Expanded(
                child: _buildTabContent(context, selectedTab),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, GrcModuleDetailTab tab) {
    switch (tab) {
      case GrcModuleDetailTab.policies:
        return GrcModulePoliciesTab(module: widget.module);
      case GrcModuleDetailTab.champions:
        return GrcModuleChampionsTab(module: widget.module);
      case GrcModuleDetailTab.owners:
        return GrcModuleOwnersTab(module: widget.module);
      case GrcModuleDetailTab.departments:
        return Center(
          child: Text(
            _tabs[_selectedTab].tr,
            style: StyleText.fontSize16Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        );
    }
  }
}
