import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/custom/39_custom_grid_button.dart';
import 'package:grc_module/core/custom/40_custom_table_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/role_mangment_permission.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/user_mangment_permission.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class ViewToggleButtons extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onTableViewTap;
  final VoidCallback onGridViewTap;
  final bool showExport;
  final VoidCallback? onExportTap;

  const ViewToggleButtons({
    super.key,
    required this.isGridView,
    required this.onTableViewTap,
    required this.onGridViewTap,
    this.showExport = false,
    this.onExportTap,
  });

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    var isMobile = ContextExtension(context).isPhone;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showExport ||
            Get.find<MainCoreEmployeeController>().isHasPermission(
              module: Modules.roles,
              section: RolePermissionsSections.roleManagement,
              permission: RoleManagement.exportRoleData,
            )|| Get.find<MainCoreEmployeeController>().isHasPermission(
          module: Modules.roles,
          section: RolePermissionsSections.userManagement,
          permission: UserManagement.exportUsersData,
        ))

        GestureDetector(
            onTap: onExportTap,
            child: Padding(
              padding: isMobile
                  ? EdgeInsets.symmetric(horizontal: 0.sp)
                  : EdgeInsets.symmetric(horizontal: 8.sp),
              child: Container(
                width: isTabletLandscape(context) ? 100.sp : 38.sp,
                height: 38.sp,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: isTabletLandscape(context)
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: CustomSvgImage(assetPath: 
                        "assets/icons_assets/main_icons_assets/export_arrow.svg",
                        fit: BoxFit.scaleDown,
                        width: 20.sp,
                        height: 20.sp,
                        color: AppColors.textButton,
                        semanticsLabel: 'Export',
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).export,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.textButton
                      ),
                    )
                  ],
                )
                    : Center(
                  child: CustomSvgImage(assetPath: 
                    "assets/icons_assets/main_icons_assets/export_arrow.svg",
                    fit: BoxFit.scaleDown,
                    width: 20.sp,
                    height: 20.sp,
                    color: AppColors.textButton,
                    semanticsLabel: 'Export',
                  ),
                ),
              ),
            ),
          ),
        // Table / grid toggles use the shared core buttons. Colours are passed
        // explicitly so the selected/unselected look matches what was here
        // before (the core defaults are transparent + white icon).
        isMobile
            ? SizedBox()
            : customTableButton(
                function: onTableViewTap,
                isSelected: !isGridView,
                color: lightMode ? AppColors.white : AppColors.chatBackground,
                selectedColor: AppColors.primary,
                svgColor:
                    lightMode ? AppColors.blackButton : AppColors.white,
                selectedSvgColor: AppColors.textButton,
              ),
        isMobile ? SizedBox() : SizedBox(width: 8.sp),
        isMobile
            ? SizedBox()
            : customGridButton(
                function: onGridViewTap,
                isSelected: isGridView,
                color: lightMode ? AppColors.white : AppColors.chatBackground,
                selectedColor: AppColors.primary,
                svgColor:
                    lightMode ? AppColors.blackButton : AppColors.white,
                selectedSvgColor: AppColors.textButton,
              ),
      ],
    );
  }
  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }
}