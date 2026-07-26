/// Module: GRC Module Management
/// Description: Provides the main list page for GRC Modules with status
///              filtering, search, sort, and navigation to the details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-28
/// Dependencies: flutter_bloc, GRCModuleCubit, GRCModuleEntity, get_it
/// Revision History: 2026-06-28 - Initial creation
///                    2026-06-30 - Connected to GRCModuleCubit with real data (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_page.dart
/// Purpose: Contains GrcResponsivePage (root shell), GovernanceRiskAndCompliancePage
///          (list page), and _GrcModuleCard (list item card).
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/6/2026

import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/custom/43_custom_module_info_card.dart';
import 'package:demo_app/core/custom/47_custom_sort_button.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/local_widgets/services_management/W2_Navigator.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_status.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_module_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/ui/pages/grc_details_page.dart';
import 'package:demo_app/features/grc/module/presentation/ui/pages/grc_module_details_page.dart';
import 'package:demo_app/features/grc/module/presentation/ui/pages/grc_previous_module_owners_page.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/responsive_helper.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// class name: [GrcResponsivePage]
///
/// purpose: root shell that provides [GRCModuleCubit] and switches between
///          the mobile and tablet layouts via [ResponsiveHelper].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class GrcResponsivePage extends StatelessWidget {
  const GrcResponsivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<GRCModuleCubit>()..getAllModules(includeDeleted: true),
      child: Builder(
        builder: (ctx) => ResponsiveHelper(
          mobileWidget: const GovernanceRiskAndCompliancePage(),
          tabletWidget: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: ctx.read<GRCModuleCubit>(),
                  child: const GovernanceRiskAndCompliancePage(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// class name: [GovernanceRiskAndCompliancePage]
///
/// purpose: main list page for GRC Modules. Reads from [GRCModuleCubit] and
///          renders a filtered, searchable, sortable list of module cards.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class GovernanceRiskAndCompliancePage extends StatefulWidget {
  const GovernanceRiskAndCompliancePage({super.key});

  @override
  State<GovernanceRiskAndCompliancePage> createState() =>
      _GovernanceRiskAndCompliancePageState();
}

class _GovernanceRiskAndCompliancePageState
    extends State<GovernanceRiskAndCompliancePage> {
  String _selectedStatus = 'all';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortOrder = 'Creation Date';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering logic ───────────────────────────────────────────────────────

  List<GRCModuleEntity> _applyFilters(List<GRCModuleEntity> modules) {
    var result = modules;

    // Status filter — Removed is treated as a status alongside Active/Inactive.
    // "all" shows everything; each other tab filters by its own condition.
    if (_selectedStatus == GrcModuleStatus.active.value) {
      result = result
          .where((m) => !m.isRemoved && m.status == GrcModuleStatus.active.value)
          .toList();
    } else if (_selectedStatus == GrcModuleStatus.inactive.value) {
      result = result
          .where((m) => !m.isRemoved && m.status == GrcModuleStatus.inactive.value)
          .toList();
    } else if (_selectedStatus == GrcModuleStatus.scheduled.value) {
      result = result
          .where((m) => !m.isRemoved && m.status == GrcModuleStatus.scheduled.value)
          .toList();
    } else if (_selectedStatus == GrcModuleStatus.removed.value) {
      result = result.where((m) => m.isRemoved).toList();
    }
    // 'all' → no filter, show everything

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((m) =>
              m.moduleNameEn.toLowerCase().contains(q) ||
              m.moduleNameAr.toLowerCase().contains(q))
          .toList();
    }

    // Sort
    if (_sortOrder == 'ASC') {
      result.sort((a, b) => a.moduleNameEn.compareTo(b.moduleNameEn));
    } else if (_sortOrder == 'DES') {
      result.sort((a, b) => b.moduleNameEn.compareTo(a.moduleNameEn));
    } else if (_sortOrder == 'Last Update') {
      result.sort((a, b) => b.modificationDate.compareTo(a.modificationDate));
    } else if (_sortOrder == 'Creation Date') {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return result;
  }

  Map<String, int> _countByStatus(List<GRCModuleEntity> modules) {
    return {
      'all': modules.length,
      GrcModuleStatus.active.value: modules
          .where((m) => !m.isRemoved && m.status == GrcModuleStatus.active.value)
          .length,
      GrcModuleStatus.inactive.value: modules
          .where(
              (m) => !m.isRemoved && m.status == GrcModuleStatus.inactive.value)
          .length,
      GrcModuleStatus.scheduled.value: modules
          .where(
              (m) => !m.isRemoved && m.status == GrcModuleStatus.scheduled.value)
          .length,
      GrcModuleStatus.removed.value:
          modules.where((m) => m.isRemoved).length,
    };
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  Future<void> _openDetails(
    BuildContext context,
    GrcPageMode mode, {
    GRCModuleEntity? entity,
    bool autoDelete = false,
  }) async {
    final reloaded = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => GovernanceRiskAndComplianceDetails(
          mode: mode,
          entity: entity,
          autoDelete: autoDelete,
        ),
      ),
    );

    if (reloaded == true && context.mounted) {
      context.read<GRCModuleCubit>().getAllModules(includeDeleted: true);
    }
  }

  Future<void> _showModuleMenu(
    BuildContext context,
    GRCModuleEntity module,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromLTRB(
      overlay.size.width - 72.w,
      110.h,
      16.w,
      overlay.size.height - 110.h,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      items: module.isRemoved
          ? [
              PopupMenuItem<String>(
                value: 'restore',
                child: Text('Restore'.tr),
              ),
            ]
          : [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'.tr),
              ),
              PopupMenuItem<String>(
                value: 'previousModuleOwners',
                child: Text('Previous Module Owners'.tr),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'.tr),
              ),
            ],
    );

    if (!context.mounted || selected == null) {
      return;
    }

    if (selected == 'edit') {
      await _openDetails(context, GrcPageMode.view, entity: module);
      return;
    }

    if (selected == 'delete') {
      await _openDetails(
        context,
        GrcPageMode.view,
        entity: module,
        autoDelete: true,
      );
      return;
    }

    if (selected == 'previousModuleOwners') {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GrcPreviousModuleOwnersPage(module: module),
        ),
      );
      return;
    }

    if (selected == 'restore') {
      await _openDetails(context, GrcPageMode.restore, entity: module);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GRCModuleCubit, GRCModuleState>(
      builder: (context, state) {
        final allModules =
            state is GRCModuleListLoaded ? state.modules : <GRCModuleEntity>[];
        final counts = _countByStatus(allModules);
        final filtered = _applyFilters(allModules);

        const statusLabels = {
          'all': 'All',
          'Active': 'Active',
          'Inactive': 'Inactive',
          'Scheduled': 'Scheduled',
          'Removed': 'Removed',
        };

        final List<MapEntry<String, Map<String, dynamic>>> statusEntries = [
          MapEntry('all', {'num': counts['all'] ?? 0, 'color': AppColors.text}),
          MapEntry('Active',
              {'num': counts['Active'] ?? 0, 'color': AppColors.green}),
          MapEntry('Inactive',
              {'num': counts['Inactive'] ?? 0, 'color': AppColors.red}),
          MapEntry('Scheduled',
              {'num': counts['Scheduled'] ?? 0, 'color': AppColors.primary}),
          MapEntry('Removed',
              {'num': counts['Removed'] ?? 0, 'color': AppColors.colorGrey}),
        ];

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                      screensTitles: ["Governance, Risk, and Compliance".tr]),
                  SizedBox(height: 16.h),
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 30.sp,
                        children: [
                          for (var entry in statusEntries)
                            FilterBarItem(
                              title: statusLabels[entry.key]!.tr,
                              numberOfItems: entry.value['num'] as int,
                              color: entry.value['color'] as Color,
                              onTap: () =>
                                  setState(() => _selectedStatus = entry.key),
                              isSelected: _selectedStatus == entry.key,
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildActionBar(context),
                  SizedBox(height: 16.h),

                  // ── List ─────────────────────────────────────────────────
                  Expanded(
                    child: _buildBody(context, state, filtered),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final sortButton = CustomSortButton<String>(
      value: _sortOrder,
      items: const ['ASC', 'DES', 'Creation Date', 'Last Update'],
      labelBuilder: (o) => o.tr,
      onChanged: (value) {
        if (value != null) setState(() => _sortOrder = value);
      },
      showTitle: false,
      svgPath: "assets/icons_assets/data_grc_assets/icons_sort.svg",
      width: 40.w,
      height: 35.h,
    );

    final createButton = customButtonWithSvg(
      colorBorder: AppColors.primary,
      function: () => _openDetails(context, GrcPageMode.create),
      title: isTablet ? 'Create GRC Module'.tr : '',
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
      image: 'assets/icons_assets/data_grc_assets/module.svg',
      widthImage: 16.w,
      heightImage: 16.h,
      color: AppColors.primary,
      width: isTablet ? 200.w : 40.w,
      svgColor: AppColors.textButton,
    );

    return Row(
      spacing: 10.w,
      children: [
        AppSearchTextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          hintText: 'Search'.tr,
          controller: _searchController,
        ),
        sortButton,
        createButton,
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    GRCModuleState state,
    List<GRCModuleEntity> modules,
  ) {
    if (state is GRCModuleLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is GRCModuleFailure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.message,
              style:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => context.read<GRCModuleCubit>().getAllModules(),
              child: Text('Retry'.tr),
            ),
          ],
        ),
      );
    }

    if (modules.isEmpty) {
      return Center(
        child: Text(
          'No GRC Modules found'.tr,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final columns = w >= 900
            ? 3
            : w >= 600
                ? 2
                : 1;

        GRCModuleEntity moduleAt(int i) => modules[i];

        _GrcModuleCard cardFor(int index) => _GrcModuleCard(
              module: moduleAt(index),
              onTap: () {
                final entity = moduleAt(index);
                if (entity.isRemoved) {
                  _openDetails(context, GrcPageMode.restore, entity: entity);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GrcModuleDetailsPage(module: entity),
                    ),
                  );
                }
              },
              onMenuTap: () => _showModuleMenu(context, moduleAt(index)),
            );

        if (columns == 1) {
          return ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.separated(
              itemCount: modules.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, index) => cardFor(index),
            ),
          );
        }

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              mainAxisExtent: 140.h,
            ),
            itemCount: modules.length,
            itemBuilder: (_, index) => cardFor(index),
          ),
        );
      },
    );
  }
}

// ── Module list card ─────────────────────────────────────────────────────────

/// class name: [_GrcModuleCard]
///
/// purpose: private list-item card that displays a single [GRCModuleEntity]
///          with its name, department, and status badge. Tapping navigates
///          to the details page in view or restore mode.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class _GrcModuleCard extends StatelessWidget {
  final GRCModuleEntity module;
  final VoidCallback onTap;
  final VoidCallback? onMenuTap;

  const _GrcModuleCard({
    required this.module,
    required this.onTap,
    this.onMenuTap,
  });

  String _resolveOwnerName(BuildContext context, String ownerEmail) {
    try {
      return EmployeeHelper.getEmployeeLocalizedNameWithEmail(
        employeeEmail: ownerEmail,
      );
    } catch (_) {
      return ownerEmail;
    }
  }

  /// Capitalizes only the first character — display formatting, doesn't
  /// touch how the value is stored.
  String _capitalizeFirst(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return ModuleInfoCard(
      width: double.infinity,
      onTap: onTap,
      title: _capitalizeFirst(
        module.localizedName(isArabic: context.isArabic),
      ),
      infoRows: [
        if (module.moduleOwners.isNotEmpty)
          CardInfo(
            label: '${'Owner'.tr}:',
            value: _capitalizeFirst(
              _resolveOwnerName(context, module.moduleOwners.first),
            ),
          ),
        CardInfo(
          label: '${'Creation Date'.tr}:',
          value: DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
              .format(module.createdAt),
        ),
      ],
      complianceLabel: '${'Compliance Score'.tr}:',
      complianceScore: '-',
      footerLabel: '${'Last Update'.tr}:',
      footerValue: DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en')
          .format(module.modificationDate),
      onMenuTap: onMenuTap,
    );
  }
}
