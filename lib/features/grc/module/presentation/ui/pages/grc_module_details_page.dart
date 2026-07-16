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
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_details_page.dart
/// Purpose: Contains GrcModuleDetailsPage, the GRC dashboard screen scoped
///          to a single GRC Module and its Policies.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/6/2026

import 'package:demo_app/core/custom/10-custom_tabs.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/custom/43_custom_module_info_card.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/create_new_policy.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_page.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_details_page.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

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
    return BlocProvider(
      create: (_) => GetIt.instance<PolicyCubit>()
        ..getAllPolicies(moduleId: module.moduleId),
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

  final _searchController = TextEditingController();
  final GlobalKey _addPolicyButtonKey = GlobalKey();
  String _searchQuery = '';
  int _selectedTab = 0;
  String _selectedStatusFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showPolicyCreationMenu(BuildContext context) async {
    final buttonBox =
        _addPolicyButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonBox.localToGlobal(Offset(0, buttonBox.size.height),
            ancestor: overlayBox),
        buttonBox.localToGlobal(buttonBox.size.bottomRight(Offset.zero),
            ancestor: overlayBox),
      ),
      Offset.zero & overlayBox.size,
    );

    final choice = await showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(value: 'add', child: Text('Add Policy'.tr)),
        PopupMenuItem(value: 'bulk', child: Text('Bulk Upload'.tr)),
      ],
    );

    if (!context.mounted) return;
    bool? result;
    if (choice == 'add') {
      result = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => CreateNewPolicyPage(
            moduleId: widget.module.moduleId,
            moduleNameEn: widget.module.moduleNameEn,
            moduleNameAr: widget.module.moduleNameAr,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else if (choice == 'bulk') {
      result = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              PolicyBulkUploadPage(moduleId: widget.module.moduleId),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
    if (result == true && context.mounted) {
      context
          .read<PolicyCubit>()
          .getAllPolicies(moduleId: widget.module.moduleId);
    }
  }

  PolicyStatus? _statusForKey(String key) {
    switch (key) {
      case 'Active':
        return PolicyStatus.active;
      case 'Inactive':
        return PolicyStatus.inactive;
      case 'Scheduled':
        return PolicyStatus.scheduled;
      case 'Expired':
        return PolicyStatus.expired;
      case 'Draft':
        return PolicyStatus.draft;
      default:
        return null;
    }
  }

  List<PolicyEntity> _applyStatusFilter(List<PolicyEntity> policies) {
    final status = _statusForKey(_selectedStatusFilter);
    if (status == null) return policies;
    return policies.where((p) => p.status == status).toList();
  }

  List<PolicyEntity> _applySearch(List<PolicyEntity> policies) {
    if (_searchQuery.isEmpty) return policies;
    final q = _searchQuery.toLowerCase();
    return policies
        .where((p) =>
            p.policyNameEn.toLowerCase().contains(q) ||
            p.policyNameAr.toLowerCase().contains(q))
        .toList();
  }

  Map<String, int> _countByStatus(List<PolicyEntity> policies) {
    return {
      'all': policies.length,
      'Active': policies.where((p) => p.status == PolicyStatus.active).length,
      'Inactive':
          policies.where((p) => p.status == PolicyStatus.inactive).length,
      'Scheduled':
          policies.where((p) => p.status == PolicyStatus.scheduled).length,
      'Expired': policies.where((p) => p.status == PolicyStatus.expired).length,
      'Draft': policies.where((p) => p.status == PolicyStatus.draft).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return BlocBuilder<PolicyCubit, PolicyState>(
      builder: (context, state) {
        final allPolicies =
            state is PolicyListLoaded ? state.policies : <PolicyEntity>[];
        final counts = _countByStatus(allPolicies);
        final filtered = _applySearch(_applyStatusFilter(allPolicies));
        final weightIssueTotal = allPolicies
            .where((p) =>
                p.status == PolicyStatus.active ||
                p.status == PolicyStatus.scheduled)
            .fold<double>(0, (sum, p) => sum + p.policyWeight);
        final hasPolicyWeightIssue = weightIssueTotal > 100;

        final List<MapEntry<String, Map<String, dynamic>>> status = [
          MapEntry('all', {'num': counts['all'] ?? 0, 'color': AppColors.text}),
          MapEntry('Active',
              {'num': counts['Active'] ?? 0, 'color': AppColors.green}),
          MapEntry('Inactive',
              {'num': counts['Inactive'] ?? 0, 'color': AppColors.orange}),
          MapEntry('Scheduled',
              {'num': counts['Scheduled'] ?? 0, 'color': AppColors.primary}),
          MapEntry('Expired',
              {'num': counts['Expired'] ?? 0, 'color': AppColors.red}),
          MapEntry('Draft',
              {'num': counts['Draft'] ?? 0, 'color': AppColors.colorGrey}),
        ];

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
                      context.isArabic
                          ? widget.module.moduleNameAr
                          : widget.module.moduleNameEn,
                    ],
                  ),

                  // Approved Evidence + Dashboard
                  Row(
                    spacing: 8.w,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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

                  // Approvals + Assignment Controls + My Audits
                  Row(
                    spacing: 8.w,
                    children: [
                      customButton(
                        title: "Approvals".tr,
                        function: () {},
                        width: 120.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                      customButton(
                        title: "Assignment Controls".tr,
                        function: () {},
                        width: isTablet ? 180.w : 170.w,
                        height: 38.h,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                      Spacer(),
                      customButton(
                        title: "My Audits".tr,
                        function: () {},
                        width: 135.w,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  CustomTabs(
                    tabs: _tabs,
                    selectedValue: _selectedTab,
                    onChanged: (v) => setState(() => _selectedTab = v),
                  ),
                  SizedBox(height: 15.h),

                  Expanded(
                    child: _selectedTab == 0
                        ? _buildPoliciesTab(context, isTablet, status, state,
                            filtered, hasPolicyWeightIssue)
                        : Center(
                            child: Text(
                              _tabs[_selectedTab].tr,
                              style: StyleText.fontSize16Weight500
                                  .copyWith(color: AppColors.secondaryText),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPoliciesTab(
    BuildContext context,
    bool isTablet,
    List<MapEntry<String, Map<String, dynamic>>> status,
    PolicyState state,
    List<PolicyEntity> filtered,
    bool hasPolicyWeightIssue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 30.sp,
              children: [
                for (var roleEntry in status)
                  FilterBarItem(
                    title: roleEntry.key,
                    numberOfItems: roleEntry.value['num'],
                    color: roleEntry.value['color'],
                    onTap: () =>
                        setState(() => _selectedStatusFilter = roleEntry.key),
                    isSelected: roleEntry.key == _selectedStatusFilter,
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15.h),

        // Search + Create Policy — stack on mobile
        if (isTablet)
          Row(
            spacing: 10.w,
            children: [
              AppSearchTextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                hintText: "Search".tr,
                controller: _searchController,
              ),
              Container(
                key: _addPolicyButtonKey,
                child: customButtonWithSvg(
                  colorBorder: AppColors.primary,
                  space: 10.w,
                  widthImage: 16.w,
                  heightImage: 16.h,
                  function: () => _showPolicyCreationMenu(context),
                  title: 'Policy',
                  textStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.textButton),
                  image:
                      'assets/icons_assets/database_builder_assets/plus_head.svg',
                  color: AppColors.primary,
                  svgColor: AppColors.textButton,
                ),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AppSearchTextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    hintText: "Search".tr,
                    controller: _searchController,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                key: _addPolicyButtonKey,
                child: customButtonWithSvg(
                  colorBorder: AppColors.primary,
                  space: 10.w,
                  radius: 8.r,
                  widthImage: 16.w,
                  heightImage: 16.h,
                  function: () => _showPolicyCreationMenu(context),
                  title: 'Policy',
                  textStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.textButton),
                  image: 'assets/icons/add.svg',
                  color: AppColors.primary,
                  width: double.infinity,
                  height: 36.h,
                  svgColor: AppColors.textButton,
                ),
              ),
            ],
          ),
        SizedBox(height: 15.h),

        // Policy Weight Issue + view-mode icons
        Row(
          children: [
            if (hasPolicyWeightIssue)
              customButton(
                title: "Policy Weight Issue".tr,
                function: () {},
                width: isTablet ? 180.w : 160.w,
                height: 38.h,
                color: AppColors.primary,
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
              ),
            const Spacer(),
            Container(
              width: 38.sp,
              height: 38.sp,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons_assets/data_grc_assets/list_view_data.svg",
                  width: 20.sp,
                  height: 20.sp,
                  fit: BoxFit.scaleDown,
                  semanticsLabel: 'Table View',
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(width: 8.sp),
            Container(
              width: 38.sp,
              height: 38.sp,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons_assets/data_grc_assets/grid_view_view.svg",
                  width: 20.sp,
                  height: 20.sp,
                  fit: BoxFit.scaleDown,
                  semanticsLabel: 'Table View',
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),

        Expanded(
          child: _buildPolicyList(context, state, filtered),
        ),
      ],
    );
  }

  Widget _buildPolicyList(
    BuildContext context,
    PolicyState state,
    List<PolicyEntity> policies,
  ) {
    if (state is PolicyLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is PolicyFailure) {
      return Center(
        child: Text(
          state.message,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (policies.isEmpty) {
      return Center(
        child: Text(
          'No Policies found'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        itemCount: policies.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) =>
            _PolicyCard(policy: policies[index], module: widget.module),
      ),
    );
  }
}

// ── Policy list card ─────────────────────────────────────────────────────────

/// class name: [_PolicyCard]
///
/// purpose: private list-item card that displays a single [PolicyEntity]
///          with its name, number, status, and last-update date. Tapping
///          opens [PolicyDetailsPage] for that policy.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 6/7/2026
class _PolicyCard extends StatelessWidget {
  final PolicyEntity policy;
  final GRCModuleEntity module;

  const _PolicyCard({required this.policy, required this.module});

  @override
  Widget build(BuildContext context) {
    return ModuleInfoCard(
      width: double.infinity,
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => PolicyDetailsPage(
              policyId: policy.id,
              moduleId: module.moduleId,
              module: module,
            ),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        if (result == true && context.mounted) {
          context.read<PolicyCubit>().getAllPolicies(moduleId: module.moduleId);
        }
      },
      title: context.isArabic ? policy.policyNameAr : policy.policyNameEn,
      infoRows: [
        CardInfo(
          label: context.isArabic ? 'الرقم :' : 'Number :',
          value:
              context.isArabic ? policy.policyNumberAr : policy.policyNumberEn,
        ),
      ],
      complianceLabel: context.isArabic ? 'الحالة:' : 'Status:',
      complianceScore: policy.status.value.tr,
      footerLabel: context.isArabic ? 'آخر تحديث:' : 'Last Update:',
      footerValue: DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
          .format(policy.lastModifiedDate),
    );
  }
}
