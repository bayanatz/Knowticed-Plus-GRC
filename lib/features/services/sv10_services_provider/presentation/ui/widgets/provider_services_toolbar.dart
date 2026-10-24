/// Module: services / sv10_services_provider / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: provider_services_toolbar.dart
/// Purpose: Search field and the Export / table / grid buttons above the
///          provider's list.
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [ProviderServicesToolbar]
///
/// Purpose: The row above the list.
class ProviderServicesToolbar extends StatelessWidget {
  const ProviderServicesToolbar({
    required this.searchController,
    required this.onSearch,
    required this.isGrid,
    required this.onViewChanged,
    required this.canExport,
    required this.onExport,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final bool isGrid;

  /// Called with `true` for the grid, `false` for the table.
  final ValueChanged<bool> onViewChanged;
  final bool canExport;
  final VoidCallback onExport;

  bool _isTabletLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width >= 600 &&
        MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  Widget _viewButton({
    required bool selected,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.sp,
        height: 38.sp,
        decoration: BoxDecoration(
          // Unselected is a visible surface, not white on white (p23/p30).
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: CustomSvgImage.natural(
            assetPath: icon,
            width: 18.sp,
            height: 18.sp,
            fit: BoxFit.fill,
            color: selected ? AppColors.textButton : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final wide = _isTabletLandscape(context);
    return Row(
      children: [
        // NO Expanded here: AppSearchTextField already returns one.
        AppSearchTextField(controller: searchController, onChanged: onSearch),
        SizedBox(width: 15.sp),
        if (!isMobile) ...[
          if (canExport) ...[
            GestureDetector(
              onTap: onExport,
              child: Container(
                width: wide ? 100.sp : 38.sp,
                height: 38.sp,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSvgImage.natural(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_action_export.svg',
                      width: 18.sp,
                      height: 18.sp,
                      fit: BoxFit.fill,
                      color: AppColors.textButton,
                      semanticsLabel: S.of(context).export,
                    ),
                    if (wide) ...[
                      SizedBox(width: 8.sp),
                      Text(
                        S.of(context).export,
                        style: StyleText.fontSize18Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.sp),
          ],
          _viewButton(
            selected: !isGrid,
            icon:
                'assets/icons_assets/main_icons_assets/ic_action_list_bulleted.svg',
            onTap: () => onViewChanged(false),
          ),
          SizedBox(width: 15.sp),
          _viewButton(
            selected: isGrid,
            icon: 'assets/icons_assets/main_icons_assets/ic_nav_grid.svg',
            onTap: () => onViewChanged(true),
          ),
        ],
      ],
    );
  }
}
