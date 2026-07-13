import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/roles/role_management/controller/role_switches_controllers.dart';

import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/features/roles/widgets/confirm_dialog.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/features/roles/widgets/default_switch_button.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/role_status.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/settings/settings_permissions_sections.dart';
import 'package:demo_app/features/roles/role_management/domain/interfaces/module_permissions_sections.dart';
import 'package:demo_app/features/roles/role_management/domain/interfaces/module_permissions_sections_permissions.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/dialog.dart';
import 'package:flutter/src/services/haptic_feedback.dart';

class SettingsSwitchesPage extends StatelessWidget {
  SettingsSwitchesPage({super.key});
  late RoleCubit controller;
  late bool isTablet;

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());

    controller = context.read<RoleCubit>();
    isTablet = MediaQuery.of(context).size.width > 600;

    return BlocBuilder<RoleCubit, RoleState>(
      buildWhen: (previous, current) => current is RoleSwitchToggled,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: isTablet ? 30.sp : 15.sp,
                end: 15.sp,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                    screensTitles: controller.isEditing
                        ? [
                      'Platform Controls and Management'.tr,
                      'Role Details'.tr,
                      'Editing Role'.tr,
                      S.of(context).editRolePermissions,
                      S.of(context).editRoleSettingsPermissions,
                    ]
                        : [
                      'Platform Controls and Management'.tr,
                      'Adding New Role'.tr,
                      'Adding New Role Permissions'.tr,
                      S.of(context).settingsPermission,
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: modulePermissionsBuilder(Modules.settings),
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        spacing: 5.sp,
                        children: [
                          CustomButton(
                            buttonText: 'Back'.tr,
                            buttonColor: AppColors.secondaryButton,
                            textStyle: AppTextStyles.font16BlackRegularCairo.copyWith(
                              color: Colors.black
                            ),
                            width: isTablet ? 135 : 120,
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          if (!controller.isEditing)
                            CustomButton(
                              buttonText: 'Save For Later'.tr,
                              buttonColor: AppColors.secondaryButton,
                              textStyle: AppTextStyles.font16BlackRegularCairo,
                              width: isTablet ? 135 : 120,
                              onTap: () {
                                RoleDialogs.showSaveForLaterDialog(
                                  context: context,
                                  controller: controller,
                                  pagesToPop: 3,

                                );
                              },
                            )
                        ],
                      ),
                      CustomButton(
                        buttonText: controller.isEditing ? S.of(context).save : S.of(context).create,
                        width: isTablet ? 135 : 120,
                        onTap: () {
                          hapticController.triggerHapticFeedback(
                              vibration: VibrateType.heavyImpact,
                              hapticFeedback: HapticFeedback.heavyImpact
                          );
                          ConfirmDialog().show(
                            context,
                            title: controller.isEditing
                                ? S.of(context).editingRole
                                : (controller.selectedRole?.currentStatus == RoleStatus.draft
                                ? S.of(context).completingDraftRole
                                : S.of(context).creatingRole),
                            subtitle: controller.isEditing
                                ? S.of(context).areYouSureEditRole
                                : (controller.selectedRole?.currentStatus == RoleStatus.draft
                                ? S.of(context).areYouSureCompleteDraftRole
                                : S.of(context).areYouSureCreateRole),
                            icon: 'assets/lottie/Edit Document.json',
                            onCancel: () {},
                            onConfirm: () async {
                              showLoadingIndicator();

                              if (controller.isEditing) {
                                await controller.updateRole();
                              } else if (controller.selectedRole?.currentStatus == RoleStatus.draft) {
                                await controller.activateDraftRole();
                              } else {
                                await controller.addNewRole();
                              }

                              hideLoadingIndicator();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              if (controller.isEditing) {
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget modulePermissionsBuilder(Modules module) {
    return Column(
      spacing: 15.sp,
      children: [
        if (isTablet)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 20.sp,
            children: [
              Expanded(child: firstColumnBuilder(module)),
              Expanded(child: lastColumnBuilder(module)),
            ],
          ),
        if (!isTablet)
          Column(
            children: [
              firstColumnBuilder(module),
              SizedBox(height: 10.sp),
              lastColumnBuilder(module),
            ],
          )
      ],
    );
  }

  Widget firstColumnBuilder(Modules module) {
    return Column(
      spacing: 10.sp,
      children: [
        for (Enum permissionSection in module.moduleFirstColumnPermissions)
          buildPermissionSection(
            permissionSection as ModulePermissionsSections,
            module,
          ),
      ],
    );
  }

  Widget lastColumnBuilder(Modules module) {
    return Column(
      spacing: 10.sp,
      children: [
        for (Enum permissionSection in module.moduleLastColumnPermissions)
          buildPermissionSection(
            permissionSection as ModulePermissionsSections,
            module,
          ),
      ],
    );
  }

  Widget buildPermissionSection(
      ModulePermissionsSections permissionSection,
      Modules module,
      ) {
    if (permissionSection.sectionPermissions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      spacing: 10.sp,
      children: [
        Container(
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            spacing: 10.sp,
            children: [
              Row(
                spacing: 5.sp,
                children: [
                  CircleAvatar(
                    radius: 12.5.r,
                    backgroundColor: AppColors.primary,
                    child: Padding(
                      padding: EdgeInsets.all(4.sp),
                      child: SvgPicture.asset(
                        (permissionSection.getName ==
                            SettingsPermissionsSections.settings.getName)
                            ? 'assets/icons_assets/main_icons_assets/setting.svg'
                            : 'assets/icons_assets/roles_assets/newSocial.svg',
                        colorFilter: ColorFilter.mode(
                          AppColors.textButton,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      permissionSection.getName.tr,
                      style: AppTextStyles.font12SecondaryBlackCairoRegular,
                    ),
                  ),
                ],
              ),
              for (int permissionIndex = 0;
              permissionIndex <
                  permissionSection.sectionPermissions.length;
              permissionIndex++)
                _buildPermissionRow(
                  permissionSection.sectionPermissions[permissionIndex]
                  as ModulePermissionsSectionsPermission,
                  permissionSection,
                  module,
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPermissionRow(
      ModulePermissionsSectionsPermission permission,
      ModulePermissionsSections section,
      Modules module,
      ) {
    final HapticController hapticController = Get.put(HapticController());

    // ✅ Check if this permission exists in Firebase
    String moduleName = controller.moduleEnumToString(module);

    bool hasPermission = false;
    if (controller.modulePermissions.containsKey(moduleName)) {
      Map<String, bool> modulePerms = controller.modulePermissions[moduleName]!;

      // Try multiple possible keys for permission
      String uiName = permission.getUiName;
      List<String> possibleKeys = [
        uiName,                              // "Change Theme"
        uiName.replaceAll(' ', '_'),        // "Change_Theme"
        uiName.replaceAll(' ', ''),         // "ChangeTheme"
        permission.getDataBaseName,
        permission.getDataBaseName.replaceAll(' ', '_'),
      ];

      for (String key in possibleKeys) {
        if (modulePerms.containsKey(key)) {
          hasPermission = true;
          break;
        }
      }
    }

    return Row(
      children: [
        // Indent for child permissions
        if (permission.isChild) SizedBox(width: 20.sp),

        // Permission name
        Expanded(
          child: Text(
            permission.getUiName.tr,
            style: AppTextStyles.font12SecondaryBlackCairoRegular,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(width: 8.sp),

        // ✅ Only show switch if permission exists in Firebase
        if (hasPermission)
          DefaultSwitchButton(
            value: controller.isSwitchActive(module, section, permission),
            onChanged: (value) {

              hapticController.triggerHapticFeedback(
                  vibration: VibrateType.mediumImpact,
                  hapticFeedback: HapticFeedback.mediumImpact
              );
              controller.toggleSwitchState(
                module: module,
                section: section,
                permission: permission,
              );
            },
          )
        else
        // Show empty space where switch would be
          SizedBox(width: 40.sp),
      ],
    );
  }
}