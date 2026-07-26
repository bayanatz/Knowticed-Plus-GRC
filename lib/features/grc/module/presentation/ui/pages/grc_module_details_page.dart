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
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_page.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:demo_app/features/grc/grc_request/presentation/ui/pages/grc_requests_list_page.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
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
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_page.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/create_champion_usecase.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_champion/presentation/ui/pages/add_champion_page.dart';
import 'package:get/get.dart' hide Trans;
import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/create_owner_usecase.dart';
import 'package:demo_app/features/grc/control_owner/presentation/ui/pages/add_owner_page.dart';
import 'package:demo_app/features/grc/control_owner/presentation/ui/pages/control_owner_details_page.dart';
import 'package:demo_app/features/grc/control_champion/presentation/ui/pages/control_champion_details_page.dart';

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

  final _searchController = TextEditingController();
  final GlobalKey _addPolicyButtonKey = GlobalKey();
  String _searchQuery = '';
  final _championSearchController = TextEditingController();
  final GlobalKey _addChampionButtonKey = GlobalKey();
  String _championSearchQuery = '';
  final _ownerSearchController = TextEditingController();
  final GlobalKey _addOwnerButtonKey = GlobalKey();
  String _ownerSearchQuery = '';
  String? _ownerDepartmentFilter;
  int _selectedTab = 0;
  String _selectedStatusFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    _championSearchController.dispose();
    _ownerSearchController.dispose();
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
    if (choice == 'add') {
      await Navigator.push<bool>(
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
      await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              PolicyBulkUploadPage(moduleId: widget.module.moduleId),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      return;
    }
    if (context.mounted) {
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
                      widget.module.localizedName(isArabic: context.isArabic),
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
                        : _selectedTab == 1
                            ? _buildControlChampionsTab(context, isTablet)
                            : _selectedTab == 2
                                ? _buildControlOwnersTab(context, isTablet)
                                : Center(
                                    child: Text(
                                      _tabs[_selectedTab].tr,
                                      style: StyleText.fontSize16Weight500
                                          .copyWith(
                                              color: AppColors.secondaryText),
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
                function: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        PolicyWeightIssuePage(module: widget.module),
                    transitionsBuilder: (_, animation, __, child) =>
                        FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                ),
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

  EmployeeEntityPro? _findEmployee(String email) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
    final employees =
        Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
    for (final e in employees) {
      if (e.email == email) return e;
    }
    return null;
  }

  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  String _employeeDisplayName(BuildContext context, String email) {
    final employee = _findEmployee(email);
    if (employee == null) return email;
    return EmployeeHelper.getEmployeeLocalizedName(
        employee: employee, context: context);
  }

  Widget _buildPersonCard(BuildContext context, String email,
      {VoidCallback? onTap}) {
    final employee = _findEmployee(email);
    final name = _employeeDisplayName(context, email);
    final department = employee != null
        ? EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: employee, context: context)
        : '';
    final jobTitle = employee != null
        ? (EmployeeHelper.getEmployeeLocalizedTitle(
                    employee: employee, context: context)
                ?.toString() ??
            '')
        : '';
    final photo = employee != null
        ? EmployeeHelper.getEmployeeImage(employee: employee)
        : 'assets/icons_assets/main_icons_assets/assets_male.svg';

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.barrierColor,
                backgroundImage:
                    photo.startsWith('http') ? NetworkImage(photo) : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name,
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (department.isNotEmpty)
                      Text(department,
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    if (jobTitle.isNotEmpty)
                      Text(jobTitle,
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              customButtonWithSvg(
                colorBorder: AppColors.primary,
                space: 6.w,
                widthImage: 14.w,
                heightImage: 14.h,
                function: () {},
                title: 'Message'.tr,
                textStyle: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.textButton),
                image: 'assets/icons_assets/data_grc_assets/messages_new.svg',
                color: AppColors.primary,
                svgColor: AppColors.textButton,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showChampionCreationMenu(BuildContext context) async {
    final buttonBox =
        _addChampionButtonKey.currentContext?.findRenderObject() as RenderBox?;
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
        PopupMenuItem(value: 'add', child: Text('Add Champion'.tr)),
        PopupMenuItem(value: 'bulk', child: Text('Bulk Upload'.tr)),
      ],
    );

    if (!context.mounted) return;
    if (choice == 'add') {
      await _openAddChampion(context);
    } else if (choice == 'bulk') {
      await _openChampionBulkUpload(context);
    }
  }

  Future<void> _openAddChampion(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddChampionPage(
          moduleId: widget.module.moduleId,
          moduleNameEn: widget.module.moduleNameEn,
          moduleNameAr: widget.module.moduleNameAr,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && context.mounted) {
      context
          .read<ChampionCubit>()
          .getAllChampions(moduleId: widget.module.moduleId);
    }
  }

  Future<void> _openChampionBulkUpload(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AssigneeBulkUploadPage(
          moduleId: widget.module.moduleId,
          assigneeLabel: 'Control Champion'.tr,
          createAssignee: ({
            required moduleId,
            required email,
            required assigningControls,
            required editorId,
          }) {
            return GetIt.instance<CreateChampionUseCase>().call(
              CreateChampionParams(
                moduleId: moduleId,
                championEmail: email,
                assigningControls: assigningControls,
                editorId: editorId,
              ),
            );
          },
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && context.mounted) {
      context
          .read<ChampionCubit>()
          .getAllChampions(moduleId: widget.module.moduleId);
    }
  }

  List<ChampionEntity> _applyChampionSearch(
      BuildContext context, List<ChampionEntity> champions) {
    if (_championSearchQuery.isEmpty) return champions;
    final q = _championSearchQuery.toLowerCase();
    return champions
        .where((c) =>
            _employeeDisplayName(context, c.championEmail)
                .toLowerCase()
                .contains(q) ||
            c.championEmail.toLowerCase().contains(q))
        .toList();
  }

  Widget _buildControlChampionsTab(BuildContext context, bool isTablet) {
    return BlocBuilder<ChampionCubit, ChampionState>(
      builder: (context, state) {
        final champions =
            state is ChampionListLoaded ? state.champions : <ChampionEntity>[];
        final filtered = _applyChampionSearch(context, champions);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  buttonText: 'My Requests',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GrcRequestsListPage(
                          module: widget.module,
                          onlyRequestedBy: _currentUserEmail,
                          typeFilter: GrcRequestType.reassignChampion,
                        ),
                      ),
                    );
                  },
                ),
                CustomButton(
                  buttonText: 'Requests',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GrcRequestsListPage(
                          module: widget.module,
                          typeFilter: GrcRequestType.reassignChampion,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 15.h),
            if (isTablet)
              Row(
                spacing: 10.w,
                children: [
                  AppSearchTextField(
                    onChanged: (v) => setState(() => _championSearchQuery = v),
                    hintText: "Search".tr,
                    controller: _championSearchController,
                  ),
                  Container(
                    key: _addChampionButtonKey,
                    child: customButtonWithSvg(
                      colorBorder: AppColors.primary,
                      space: 10.w,
                      widthImage: 16.w,
                      heightImage: 16.h,
                      function: () => _showChampionCreationMenu(context),
                      title: 'Champion',
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
                  AppSearchTextField(
                    onChanged: (v) => setState(() => _championSearchQuery = v),
                    hintText: "Search".tr,
                    controller: _championSearchController,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    key: _addChampionButtonKey,
                    child: customButtonWithSvg(
                      colorBorder: AppColors.primary,
                      space: 10.w,
                      radius: 8.r,
                      widthImage: 16.w,
                      heightImage: 16.h,
                      function: () => _showChampionCreationMenu(context),
                      title: 'Champion',
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
            Expanded(child: _buildChampionList(context, state, filtered)),
          ],
        );
      },
    );
  }

  Widget _buildChampionList(
    BuildContext context,
    ChampionState state,
    List<ChampionEntity> champions,
  ) {
    if (state is ChampionLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is ChampionFailure) {
      return Center(
        child: Text(
          state.message,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (champions.isEmpty) {
      return Center(
        child: Text(
          'No Control Champions found'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
      );
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        itemCount: champions.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) {
          final champion = champions[index];
          return _buildPersonCard(
            context,
            champion.championEmail,
            onTap: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ControlChampionDetailsPage(
                    champion: champion,
                    module: widget.module,
                  ),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
              if (context.mounted) {
                context
                    .read<ChampionCubit>()
                    .getAllChampions(moduleId: widget.module.moduleId);
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _showOwnerCreationMenu(BuildContext context) async {
    final buttonBox =
        _addOwnerButtonKey.currentContext?.findRenderObject() as RenderBox?;
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
        PopupMenuItem(value: 'add', child: Text('Add Owner'.tr)),
        PopupMenuItem(value: 'bulk', child: Text('Bulk Upload'.tr)),
      ],
    );

    if (!context.mounted) return;
    if (choice == 'add') {
      final result = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AddOwnerPage(
            moduleId: widget.module.moduleId,
            moduleNameEn: widget.module.moduleNameEn,
            moduleNameAr: widget.module.moduleNameAr,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      if (result == true && context.mounted) {
        context
            .read<OwnerCubit>()
            .getAllOwners(moduleId: widget.module.moduleId);
      }
    } else if (choice == 'bulk') {
      final result = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AssigneeBulkUploadPage(
            moduleId: widget.module.moduleId,
            assigneeLabel: 'Control Owner'.tr,
            createAssignee: ({
              required moduleId,
              required email,
              required assigningControls,
              required editorId,
            }) {
              return GetIt.instance<CreateOwnerUseCase>().call(
                CreateOwnerParams(
                  moduleId: moduleId,
                  ownerEmail: email,
                  assigningControls: assigningControls,
                  editorId: editorId,
                ),
              );
            },
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      if (result == true && context.mounted) {
        context
            .read<OwnerCubit>()
            .getAllOwners(moduleId: widget.module.moduleId);
      }
    }
  }

  List<OwnerEntity> _applyOwnerFilters(
      BuildContext context, List<OwnerEntity> owners) {
    var result = owners;
    if (_ownerDepartmentFilter != null && _ownerDepartmentFilter!.isNotEmpty) {
      result = result.where((o) {
        final employee = _findEmployee(o.ownerEmail);
        if (employee == null) return false;
        final department = EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: employee, context: context);
        return department == _ownerDepartmentFilter;
      }).toList();
    }
    if (_ownerSearchQuery.isNotEmpty) {
      final q = _ownerSearchQuery.toLowerCase();
      result = result
          .where((o) =>
              _employeeDisplayName(context, o.ownerEmail)
                  .toLowerCase()
                  .contains(q) ||
              o.ownerEmail.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  Widget _buildControlOwnersTab(BuildContext context, bool isTablet) {
    return BlocBuilder<OwnerCubit, OwnerState>(
      builder: (context, state) {
        final owners =
            state is OwnerListLoaded ? state.owners : <OwnerEntity>[];
        final filtered = _applyOwnerFilters(context, owners);
        final departmentController = Get.find<MainCoreDepartmentController>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  buttonText: 'My Requests',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GrcRequestsListPage(
                          module: widget.module,
                          onlyRequestedBy: _currentUserEmail,
                          typeFilter: GrcRequestType.reassignOwner,
                        ),
                      ),
                    );
                  },
                ),
                CustomButton(
                  buttonText: 'Requests',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GrcRequestsListPage(
                          module: widget.module,
                          typeFilter: GrcRequestType.reassignOwner,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              spacing: 10.w,
              children: [
                Expanded(
                  child: AppSearchTextField(
                    onChanged: (v) => setState(() => _ownerSearchQuery = v),
                    hintText: "Search".tr,
                    controller: _ownerSearchController,
                  ),
                ),
                SizedBox(
                  width: 160.w,
                  child: CustomDropdown<String>(
                    hint: 'Department'.tr,
                    items: [
                      DropdownItem<String>(value: '', label: 'All'.tr),
                      ...departmentController.departmentIds.map((id) {
                        final label = context.isArabic
                            ? departmentController
                                    .getArabicDepartmentNameFromDepartmentId(
                                        departmentId: id) ??
                                ''
                            : departmentController
                                    .getEnglishDepartmentNameFromDepartmentId(
                                        departmentId: id) ??
                                '';
                        return DropdownItem<String>(value: label, label: label);
                      }),
                    ],
                    value: _ownerDepartmentFilter ?? '',
                    onChanged: (v) => setState(
                        () => _ownerDepartmentFilter = v.isEmpty ? null : v),
                    fillColor: AppColors.background,
                    required: false,
                  ),
                ),
                Container(
                  key: _addOwnerButtonKey,
                  child: customButtonWithSvg(
                    colorBorder: AppColors.primary,
                    space: 10.w,
                    widthImage: 16.w,
                    heightImage: 16.h,
                    function: () => _showOwnerCreationMenu(context),
                    title: isTablet ? 'Add Owner' : '',
                    textStyle: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.textButton),
                    image:
                        'assets/icons_assets/database_builder_assets/plus_head.svg',
                    color: AppColors.primary,
                    svgColor: AppColors.textButton,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Expanded(child: _buildOwnerList(context, state, filtered)),
          ],
        );
      },
    );
  }

  Widget _buildOwnerList(
    BuildContext context,
    OwnerState state,
    List<OwnerEntity> owners,
  ) {
    if (state is OwnerLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is OwnerFailure) {
      return Center(
        child: Text(
          state.message,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (owners.isEmpty) {
      return Center(
        child: Text(
          'No Control Owners found'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
      );
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        itemCount: owners.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) {
          final owner = owners[index];
          return _buildPersonCard(
            context,
            owner.ownerEmail,
            onTap: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ControlOwnerDetailsPage(
                    owner: owner,
                    module: widget.module,
                  ),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
              if (context.mounted) {
                context
                    .read<OwnerCubit>()
                    .getAllOwners(moduleId: widget.module.moduleId);
              }
            },
          );
        },
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
        if (policy.status == PolicyStatus.draft) {
          await Navigator.push<bool>(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => CreateNewPolicyPage(
                moduleId: module.moduleId,
                moduleNameEn: module.moduleNameEn,
                moduleNameAr: module.moduleNameAr,
                existingPolicy: policy,
              ),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        } else {
          await Navigator.push<bool>(
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
        }
        if (context.mounted) {
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
