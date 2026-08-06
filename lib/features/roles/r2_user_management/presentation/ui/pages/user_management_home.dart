import 'package:grc_module/core/custom/filter_bar_item.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
import 'package:grc_module/core/custom/37-custom_navigate.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/services_app_module/core/configs/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/inventory_module/core/svg_custom.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/knowledge_hub_module/core/custom_buttons.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections_main_core.dart';
// REMOVED_MODULE: import 'package:grc_module/features/services_management_module/s6_services_requests/presentation/ui/widgets/custom_button_with_image.dart' hide customButtonWithImage;
import 'package:grc_module/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/pages/request_page_approval.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/core/custom/cross_axis_count_helper.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/custom/circle_progress.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s1_create_service/upload_file/upload_file.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s2_details_service/details_service/widget/info_text.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/user_mangment_permission.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/settings/settings_permissions.dart';
import 'package:grc_module/features/roles/r2_user_management/data/user_mangment_status.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/widgets/grid_table_export.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/user_managemnt_export_dialog.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/user_managemnt_table_widget.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/user_permission_overview.dart';
import './add_new_users_access.dart';
import './import_page.dart';
import './role_user_details.dart';
import 'package:grc_module/features/roles/r5_system_logs/role_log_service.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
part '../widgets/user_management_home_methods1.dart';

class UserManagementHome extends StatefulWidget {
  @override
  State<UserManagementHome> createState() => _UserManagementHomeState();
}

class _UserManagementHomeState extends State<UserManagementHome> {
  late UserManagementAccessCubit controller;
  bool isGridView = true;

  /// Extra safety net: if a role IS present in RoleCubit but its current status
  /// is one of these, hide it anyway.
  static const Set<String> _hiddenRoleStatuses = {'inactive', 'deleted'};

  @override
  void initState() {
    super.initState();
    RoleLogService.log(RoleLogService.pageUserManagementHome);

    try {
      controller = context.read<UserManagementAccessCubit>();

      WidgetsBinding.instance.addPostFrameCallback((_) {

        controller.initializeWithAllFilter();

        controller.getUserAccess();

      });

    } catch (e, stackTrace) {
    }

  }

  /// Resolve a role from RoleCubit by its stored access key (case-insensitive).
  RoleHistoryModel? _resolveRole(String roleKey) {
    final String normalizedKey = roleKey.trim().toLowerCase();
    try {
      final RoleCubit roleCubit = context.read<RoleCubit>();
      return roleCubit.roles.firstWhereOrNull(
            (r) =>
        r.currentRoleName.trim().toLowerCase() == normalizedKey ||
            r.roleId.trim().toLowerCase() == normalizedKey,
      );
    } catch (e) {
      return null;
    }
  }



  /// ✅ Get localized role name from role ID (case-insensitive resolve).
  String _getLocalizedRoleName(String roleId) {
    final role = _resolveRole(roleId);

    if (role != null) {
      return Get.locale.toString().contains('en')
          ? role.currentRoleName
          : role.currentRoleNameAr;
    }

    return FormatHelper.capitalize(roleId);
  }


  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return BlocListener<UserManagementAccessCubit, UserManagementAccessState>(
      listenWhen: (_, state) => state is UserManagementAccessError,
      listener: (context, state) {
        if (state is UserManagementAccessError) {
          CustomDialogManager.showSuccess(
            context: context,
            lottiePath: 'assets/lottie_assets/main_lottie_assets/warning.json',
            title: state.message,
          );
        }
      },
      child: BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
        buildWhen: (_, currentState) {
          return currentState is UserPermissionsDataLoaded ||
              currentState is UserPermissionsDataLoading ||
              currentState is UserPermissionsDataError;
        },
        builder: (context, state) {
          if (state is UserPermissionsDataLoading) {
            return Center(child: CircleProgressMaster());
          }

          if (state is UserPermissionsDataError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.sp),
                  Text('Error: ${state.message}'),
                  SizedBox(height: 16.sp),
                  ElevatedButton(
                    onPressed: () => controller.getUserAccess(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final sortedRoles = _getSortedRolesWithAll();

          // ✅ Hide users whose assigned role no longer exists (deleted/inactive),
          // so the grid/table stays consistent with the filter-bar counts.
          final visiblePermissions = controller.filteredUsersPermissions
              .where((p) => _isRoleVisible(p.accessName ?? 'unknown'))
              .toList();

          return Column(
            spacing: 10.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Role filter bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 30.sp,
                  children: [
                    for (var roleEntry in sortedRoles)
                      FilterBarItem(
                        title: FormatHelper.capitalize(
                            roleEntry.key == 'all'
                                ? S.of(context).all
                                : _getLocalizedRoleName(roleEntry.key)
                        ),
                        numberOfItems: roleEntry.value,
                        onTap: () => controller.selectNewRole(roleEntry.key),
                        isSelected: controller.selectedRole == roleEntry.key,
                      ),
                  ],
                ),
              ),

              SizedBox(height: 5.sp),

              // Requests button
              Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.roles,
                section: RolePermissionsSections.userManagement,
                permission: UserManagement.usersRequests,
              )
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  customButton(
                      title: FormatHelper.capitalize(S.of(context).requests),
                      function: () => navigateTo(context, RequestPageApproval()),
                      width: 135.w,
                      height: 38.h,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton
                      )
                  ),
                ],
              )
                  : SizedBox(),

              // Search and action buttons row
              Row(
                spacing: 10.sp,
                children: [
                  Expanded(
                    child: CustomTextField(
                      hint: Get.locale?.languageCode == 'ar' ? 'بحث' : 'Search',
                      controller: controller.homePageSearchController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) => controller.filterHomePageUser(value),
                      prefixIcon: const Icon(Icons.search),
                      fillColor: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                      height: 36.h,
                    ),
                  ),

                  Get.find<MainCoreEmployeeController>().isHasPermission(
                    module: Modules.roles,
                    section: RolePermissionsSections.userManagement,
                    permission: UserManagement.giveAccess,
                  )
                      ? customButtonWithSvg(
                    title: isMobile ? "" : S.of(context).access,
                    function: () {
                      RoleCubit roleCubit = context.read<RoleCubit>();
                      final validRoles = roleCubit.roles
                          .where((e) => e.currentRoleName.isNotEmpty)
                          .toList();
                      List<String> roleNames = validRoles
                          .map((e) => e.currentRoleName)
                          .toList();
                      List<String> roleNamesAr = validRoles
                          .map((e) => e.currentRoleNameAr.trim().isNotEmpty
                          ? e.currentRoleNameAr.trim()
                          : e.currentRoleName)
                          .toList();

                      controller.initNewAccessController(roleNames, roleNamesAr);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                        return BlocProvider<UserManagementAccessCubit>.value(
                          value: controller,
                          child: AddNewUsersAccess(),
                        );
                      }));
                    },
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton,
                    ),
                    heightImage: 16.h,
                    widthImage: 16.w,
                    svgColor: AppColors.textButton,
                    image: "assets/icons_assets/main_icons_assets/user_access_workflow.svg",
                    space: 8.sp,
                    colorBorder: Colors.transparent,)
                      : SizedBox(),
                ],
              ),

              // Status filter and export row
              Row(
                spacing: 8.sp,
                children: [
                  for (UserAccessStatus status in UserAccessStatus.values)
                    customButton(
                      color: controller.selectedUserAccessStatus == status
                          ? AppColors.primary
                          : AppColors.card,
                      textStyle: controller.selectedUserAccessStatus == status
                          ? null
                          : AppTextStyles.font14BlackRegularCairo.copyWith(
                        color: status.getColor(context),
                      ),
                      title: FormatHelper.capitalize(status.name),
                      function: () => controller.selectNewAccessStatus(status),),
                  Spacer(),
                  ViewToggleButtons(
                    isGridView: isGridView,
                    onTableViewTap: () => setState(() => isGridView = false),
                    onGridViewTap: () => setState(() => isGridView = true),
                    showExport: true,
                    onExportTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => UserManagementExportDialog(
                          userPermissions: visiblePermissions,
                        ),
                      );
                    },
                  )
                ],
              ),

              // Grid or Table view
              Expanded(
                child: visiblePermissions.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                          width: 200.w,
                          height: 200.h,
                          "assets/lottie_assets/notification_lottie_assets/empty.json",
                          fit: BoxFit.fill,
                          repeat: true
                      ),
                    ],
                  ),
                )
                    : isGridView
                    ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: CrossAxisCountHelper
                          .getCrossAxisCountForDefaultTablet2(context),
                      // 96.sp was ~8sp short of the card's real content height
                      // (avatar + name/role/status stack + the dates row),
                      // which is what produced the bottom overflow stripes.
                      mainAxisExtent: isMobile ? 112.sp : 112.sp,
                      mainAxisSpacing: 10.sp,
                      crossAxisSpacing: 10.sp,
                    ),
                    itemCount: visiblePermissions.length,
                    itemBuilder: (context, index) {
                      return UserPermissionOverview(
                          userPermissionEntity: visiblePermissions[index]
                      );
                    })
                    : SingleChildScrollView(
                  child: UserManagementTableWidget(
                    userPermissions: visiblePermissions,
                    locale: Get.locale?.languageCode ?? 'en',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }











  @override
  void dispose() {
    super.dispose();
  }
}
