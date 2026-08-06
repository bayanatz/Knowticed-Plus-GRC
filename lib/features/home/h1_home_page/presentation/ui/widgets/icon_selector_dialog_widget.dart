import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_theme.dart';
// REMOVED_MODULE: import 'package:grc_module/features/services_mangment_module/presentation/s7_approvals/ui/services_management_module/approval_request_toggle.dart';
// REMOVED_MODULE: import 'package:grc_module/features/services_mangment_module/presentation/s9_admin_dashboard/ui/services_management_module/dashBoard_admin.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/features/home/main_controller/core_widgets/removed_module_placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
// REMOVED_MODULE: import 'package:grc_module/features/inventory_module/category/presentation/ui/tablet/s7_dashboard/p7_dashboard/p7_dashboard_toogel.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/pages/role_management_home.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/pages/user_management_home.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
class HeaderIconItem {
  final String svgPath;
  final String Function(BuildContext) getTitle;
  final Widget Function(BuildContext) navigateTo;

  HeaderIconItem({
    required this.svgPath,
    required this.getTitle,
    required this.navigateTo,
  });

  // ✅ Localized title at render time
  String title(BuildContext context) => getTitle(context);

  // ✅ Used in dialog with context
  static List<HeaderIconItem> getAllAvailableIcons(BuildContext context) {
    return [
      HeaderIconItem(
        svgPath: 'assets/icons_assets/roles_assets/roles_people_gear.svg',
        getTitle: (ctx) => S.of(ctx).roles,
        navigateTo: (context) => PlatFormRoleContainer.RoleManagementHome(),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/home_assets/user_access_lock.svg',
        getTitle: (ctx) => S.of(ctx).userAccess,
        navigateTo: (context) => const Placeholder(),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/main_icons_assets/user_access_workflow.svg',
        getTitle: (ctx) => S.of(ctx).userManagement,
        navigateTo: (context) => UserManagementHome(),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/home_assets/language_letter_a.svg',
        getTitle: (ctx) => S.of(ctx).english,
        navigateTo: (context) => const Placeholder(),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/settings_assets/dark_mode_toggle_moon.svg',
        getTitle: (ctx) => S.of(ctx).lightDarkMode,
        navigateTo: (context) => const Placeholder(),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/main_icons_assets/services_building_stars.svg',
        getTitle: (ctx) => S.of(ctx).serviceDashboard,
        navigateTo: (context) => RemovedModulePage(moduleName: S.of(context).services),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/roles_assets/inventory_warehouse.svg',
        getTitle: (ctx) => S.of(ctx).inventoryDashboard,
        navigateTo: (context) => RemovedModulePage(moduleName: S.of(context).inventory),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/home_assets/analytics_charts.svg',
        getTitle: (ctx) => S.of(ctx).qiyasDashboard,
        navigateTo: (context) => const Placeholder(),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/roles_assets/roles_people_gear.svg',
        getTitle: (ctx) => S.of(ctx).serviceApprovals,
        navigateTo: (context) => RemovedModulePage(moduleName: S.of(context).services),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/home_assets/todo_checklist_clipboard.svg',
        getTitle: (ctx) => S.of(ctx).createToDo,
        navigateTo: (context) => const Placeholder(),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/home_assets/todo_checklist_clipboard.svg',
        getTitle: (ctx) => S.of(ctx).createTask,
        navigateTo: (context) => const Placeholder(),
      ),
      HeaderIconItem(
        svgPath: 'assets/icons_assets/home_assets/check_in_out_clock.svg',
        getTitle: (ctx) => S.of(ctx).checkInOut,
        navigateTo: (context) => const Placeholder(),
      ),
    ];
  }

  // ✅ Used in cubit (no context needed) — title localized at render time
  static HeaderIconItem? fromSvgPath(String svgPath) {
    const validPaths = [
      'assets/icons_assets/roles_assets/roles_people_gear.svg',
      'assets/icons_assets/home_assets/user_access_lock.svg',
      'assets/icons_assets/main_icons_assets/user_access_workflow.svg',
      'assets/icons_assets/home_assets/language_letter_a.svg',
      'assets/icons_assets/settings_assets/dark_mode_toggle_moon.svg',
      'assets/icons_assets/main_icons_assets/services_building_stars.svg',
      'assets/icons_assets/roles_assets/inventory_warehouse.svg',
      'assets/icons_assets/home_assets/analytics_charts.svg',
      'assets/icons_assets/roles_assets/roles_people_gear.svg',
      'assets/icons_assets/home_assets/todo_checklist_clipboard.svg',
      'assets/icons_assets/home_assets/todo_checklist_clipboard.svg',
      'assets/icons_assets/home_assets/check_in_out_clock.svg',
    ];

    if (!validPaths.contains(svgPath)) {
      print('Icon not found for path: $svgPath');
      return null;
    }

    return HeaderIconItem(
      svgPath: svgPath,
      getTitle: (ctx) {
        final l = S.of(ctx);
        switch (svgPath) {
          case 'assets/icons_assets/roles_assets/roles_people_gear.svg':              return l.roles;
          case 'assets/icons_assets/home_assets/user_access_lock.svg':        return l.userAccess;
          case 'assets/icons_assets/main_icons_assets/user_access_workflow.svg':      return l.userManagement;
          case 'assets/icons_assets/home_assets/language_letter_a.svg':            return l.english;
          case 'assets/icons_assets/settings_assets/dark_mode_toggle_moon.svg':         return l.lightDarkMode;
          case 'assets/icons_assets/main_icons_assets/services_building_stars.svg': return l.serviceDashboard;
          case 'assets/icons_assets/roles_assets/inventory_warehouse.svg':return l.inventoryDashboard;
          case 'assets/icons_assets/home_assets/analytics_charts.svg':     return l.qiyasDashboard;
          case 'assets/icons_assets/roles_assets/roles_people_gear.svg':  return l.serviceApprovals;
          case 'assets/icons_assets/home_assets/todo_checklist_clipboard.svg':        return l.createToDo;
          case 'assets/icons_assets/home_assets/todo_checklist_clipboard.svg':        return l.createTask;
          case 'assets/icons_assets/home_assets/check_in_out_clock.svg':       return l.checkInOut;
          default:                                      return svgPath;
        }
      },
      navigateTo: (ctx) => const Placeholder(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IconSelectorDialog
// ─────────────────────────────────────────────────────────────────────────────
class IconSelectorDialog extends StatefulWidget {
  final Function(HeaderIconItem) onIconSelected;

  const IconSelectorDialog({
    Key? key,
    required this.onIconSelected,
  }) : super(key: key);

  @override
  State<IconSelectorDialog> createState() => _IconSelectorDialogState();
}

class _IconSelectorDialogState extends State<IconSelectorDialog> {
  HeaderIconItem? selectedItem;

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final l = S.of(context);

    // ✅ Built inside build so context is available for localization
    final availableIcons = HeaderIconItem.getAllAvailableIcons(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 550.w,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: lightMode
              ? AppColors.white
              : AppColors.background,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ───────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 28.sp,
                  height: 28.sp,
                  padding: EdgeInsets.all(8.sp),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: CustomSvgImage(
                      assetPath: "assets/icons_assets/main_icons_assets/grid_four_squares.svg",
                      width: 14.sp,
                      height: 14.sp,
                      fit: BoxFit.scaleDown,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  l.icons,
                  style: AppTextStyles.font16BlackRegularCairo.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // ── Grid of icons ─────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    mainAxisExtent: 60.sp,
                  ),
                  itemCount: availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = availableIcons[index];
                    final isSelected =
                        selectedItem?.svgPath == icon.svgPath;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedItem = isSelected ? null : icon;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                        child: Row(
                          children: [
                            CustomSvgImage(
                              assetPath: icon.svgPath,
                              width: 24.w,
                              height: 24.h,
                              color: AppColors.textButton,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                icon.title(context), // ✅ localized
                                style: AppTextStyles.font16BlackRegularCairo
                                    .copyWith(color: AppColors.textButton),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // ── Bottom buttons ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: lightMode ?  Colors.grey[400] : Colors.grey[700],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l.discard,
                        style: AppTextStyles.font16BlackRegularCairo.copyWith(
                          fontWeight: FontWeight.w600,
                          color: lightMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (selectedItem != null) {
                        widget.onIconSelected(selectedItem!);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l.save,
                        style: AppTextStyles.font16BlackRegularCairo.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textButton,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}