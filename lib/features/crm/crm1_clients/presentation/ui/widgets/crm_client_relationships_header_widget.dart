// ****************** FILE INFO ******************
// File Name: crm_client_relationships_header_widget.dart
// Purpose: Header controls for the Client Profile relationships tab
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_view_mode_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Presents the status, list-management, and view controls in design order.
class CrmClientRelationshipsHeaderWidget extends StatelessWidget {
  final List<StatusChipItem> statusItems;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<String> categoryFilters;
  final String? selectedCategoryFilter;
  final ValueChanged<String?> onCategoryFilterChanged;
  final String? selectedSort;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback onAddTap;
  final VoidCallback onExportTap;
  final bool isGridView;
  final VoidCallback onGridTap;
  final VoidCallback onTableTap;

  const CrmClientRelationshipsHeaderWidget({
    super.key,
    required this.statusItems,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.searchController,
    required this.onSearchChanged,
    required this.categoryFilters,
    required this.selectedCategoryFilter,
    required this.onCategoryFilterChanged,
    required this.selectedSort,
    required this.onSortChanged,
    required this.onAddTap,
    required this.onExportTap,
    required this.isGridView,
    required this.onGridTap,
    required this.onTableTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPhone = kpIsPhoneLayout(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StatusChipFilter(
          items: statusItems,
          selectedKey: selectedStatus,
          onSelected: onStatusChanged,
          selectedColor: AppColors.primary,
          unselectedColor: AppColors.card,
        ),
        SizedBox(height: 16.sp),
        if (isPhone) ...<Widget>[
          CustomSearchFilterSortBar<String, String>(
            searchController: searchController,
            onSearchChanged: onSearchChanged,
            searchHint: S.current.crmSearch,
            showFilter: true,
            filterItems: categoryFilters,
            selectedFilter: selectedCategoryFilter,
            filterLabelBuilder: (String item) => item,
            onFilterChanged: onCategoryFilterChanged,
            showSort: true,
            selectedSort: selectedSort,
            sortTitle: S.current.crmSort,
            sortItems: const <String>['newest', 'oldest', 'name'],
            sortLabelBuilder: _sortLabel,
            onSortChanged: onSortChanged,
            mobileBreakpoint: 0,
          ),
          SizedBox(height: 10.sp),
          Align(
            alignment: Alignment.centerRight,
            child: _buildAddButton(iconOnly: true),
          ),
        ] else
          CustomSearchFilterSortBar<String, String>(
            searchController: searchController,
            onSearchChanged: onSearchChanged,
            searchHint: S.current.crmSearch,
            showFilter: true,
            filterItems: categoryFilters,
            selectedFilter: selectedCategoryFilter,
            filterLabelBuilder: (String item) => item,
            onFilterChanged: onCategoryFilterChanged,
            showSort: true,
            selectedSort: selectedSort,
            sortTitle: S.current.crmSort,
            sortItems: const <String>['newest', 'oldest', 'name'],
            sortLabelBuilder: _sortLabel,
            onSortChanged: onSortChanged,
            mobileBreakpoint: 0,
            trailingChildren: <Widget>[_buildAddButton()],
          ),
        SizedBox(height: 16.sp),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 10.sp,
            runSpacing: 10.sp,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              customButtonWithSvg(
                title: isPhone ? '' : S.current.crmExport,
                function: onExportTap,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
                color: AppColors.primary,
                colorBorder: AppColors.transparent,
                image: AppAssets.export,
                widthImage: 20.sp,
                heightImage: 20.sp,
                svgColor: AppColors.black,
              ),
              customViewModeButton(
                mode: ViewMode.grid,
                function: onGridTap,
                isSelected: isGridView,
                color: AppColors.card,
                selectedColor: AppColors.primary,
                svgColor: AppColors.black,
                selectedSvgColor: AppColors.black,
              ),
              customViewModeButton(
                mode: ViewMode.list,
                function: onTableTap,
                isSelected: !isGridView,
                color: AppColors.card,
                selectedColor: AppColors.primary,
                svgColor: AppColors.black,
                selectedSvgColor: AppColors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton({bool iconOnly = false}) {
    return customButtonWithSvg(
      title: iconOnly ? '' : S.current.crmAdd,
      function: onAddTap,
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
    );
  }

  String _sortLabel(String option) {
    switch (option) {
      case 'newest':
        return S.current.crmSortNewest;
      case 'oldest':
        return S.current.crmSortOldest;
      case 'name':
        return S.current.crmSortNameAsc;
      default:
        return option;
    }
  }
}
