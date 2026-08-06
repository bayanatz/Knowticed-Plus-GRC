import 'dart:math';

import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:flutter/services.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/custom/58_default_switch_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
class ModuleSwitchesBuilder extends StatefulWidget {
  ModuleSwitchesBuilder({required this.module, super.key});
  final Modules module;

  @override
  State<ModuleSwitchesBuilder> createState() => _ModuleSwitchesBuilderState();
}

class _ModuleSwitchesBuilderState extends State<ModuleSwitchesBuilder> {
  late bool isTablet;
  late RoleCubit controller;
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    controller = context.read<RoleCubit>();
    isTablet = MediaQuery.of(context).size.width > 600;

    return BlocBuilder<RoleCubit, RoleState>(
      buildWhen: (previous, current) =>
      current is RoleSwitchToggled ||
          current is RoleSelected ||
          current is RolePermissionLoaded ||
          current is RolePermissionUpdated,
      builder: (context, state) {
        String moduleName = controller.moduleEnumToString(widget.module);


        if (controller.modulePermissions.containsKey(moduleName)) {
          controller.modulePermissions[moduleName]!.forEach((key, value) {
          });
        }

        // ✅ If no permissions, hide completely
        if (!controller.modulePermissions.containsKey(moduleName) ||
            controller.modulePermissions[moduleName]!.isEmpty) {
          return SizedBox.shrink();
        }

        return modulePermissionsBuilder(widget.module);
      },
    );
  }

  Widget modulePermissionsBuilder(Modules module) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final HapticController hapticController = Get.put(HapticController());

    String moduleName = controller.moduleEnumToString(module);
    if (moduleName.toLowerCase() == 'settings' ||
        module.getModuleName.toLowerCase().contains('settings')) {
      return SizedBox.shrink();
    }
    // ✅ Check if module has enum-based permissions
    bool hasEnumPermissions = module.moduleFirstColumnPermissions.isNotEmpty ||
        module.moduleLastColumnPermissions.isNotEmpty;


    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        spacing: 15.sp,
        children: [
          // Module header (collapsible bar)
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: lightMode ?  Colors.grey[300] :Colors.grey[700] ,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    module.getModuleName,
                    style: AppTextStyles.font16BlackRegularCairo.copyWith(
                        color: lightMode ?  Colors.black : Colors.white),
                  ),
                  Transform.rotate(
                    angle: isExpanded ? 0 : pi,
                    child: CustomSvgImage(assetPath: 
                        "assets/icons_assets/main_icons_assets/chevron_down.svg",
                        height: 12.sp,
                        width: 12.sp,
                        color: lightMode ?  Colors.black : Colors.white
                    ),
                  )
                ],
              ),
            ),
          ),

          // Module content
          if (isExpanded) ...[
            // Module icon and name row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20.r,
                  child: CustomSvgImage(assetPath: module.iconPath,
                    width: 25.w,
                    height: 25.h,

                    fit: BoxFit.scaleDown,
                    color: AppColors.textButton,
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  child: Text(
                    module.getModuleName,
                    style: AppTextStyles.font16BlackRegularCairo,
                  ),
                ),
                const Spacer(),
                // DefaultSwitchButton(
                //     value: controller.isAdminAccessActive(module),
                //     onChanged: (value) {
                //       controller.toggleAdminAccess(module: module);
                //     })
              ],
            ),

            SizedBox(height: 10.sp),

            // ✅✅✅ KEEP ORIGINAL UI, BUT USE FIREBASE DATA
            if (hasEnumPermissions)
            // Use enum UI structure but fill with Firebase data
              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 20.sp,
                  children: [
                    Expanded(child: firstColumnBuilder(module)),
                    Expanded(child: lastColumnBuilder(module)),
                  ],
                )
              else
                Column(
                  children: [
                    firstColumnBuilder(module),
                    SizedBox(height: 10.sp),
                    lastColumnBuilder(module),
                  ],
                )
            else
            // For non-enum modules, use simple Firebase switches
              _buildFirebaseOnlySwitches(module, moduleName),
          ]
        ],
      ),
    );
  }

  // ============================================================================
  // ✅ KEEP ORIGINAL UI STRUCTURE - Build sections from enums
  // ============================================================================

  Widget firstColumnBuilder(Modules module) {
    if (module.moduleFirstColumnPermissions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      spacing: 10.sp,
      children: [
        for (Enum permissionSection in module.moduleFirstColumnPermissions)
          buildPermissionSection(
              permissionSection as ModulePermissionsSections, module),
      ],
    );
  }

  Widget lastColumnBuilder(Modules module) {
    if (module.moduleLastColumnPermissions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      spacing: 10.sp,
      children: [
        for (Enum permissionSection in module.moduleLastColumnPermissions)
          buildPermissionSection(
              permissionSection as ModulePermissionsSections, module),
      ],
    );
  }

  Widget buildPermissionSection<T extends ModulePermissionsSections>(
      T permissionSection, Modules module) {

    final HapticController hapticController = Get.put(HapticController());

    String moduleName = controller.moduleEnumToString(module);

    // ✅ Check if this section exists in Firebase
    if (!controller.modulePermissions.containsKey(moduleName)) {
      return SizedBox.shrink();
    }

    Map<String, bool> modulePerms = controller.modulePermissions[moduleName]!;

    // ✅ Try multiple possible keys for section
    String sectionName = permissionSection.getName;

    // 🐛 DEBUG: Print section name

    List<String> possibleKeys = [
      "${sectionName}_Module",                          // "Product Permissions_Module"
      "${sectionName.replaceAll(' ', '_')}_Module",     // "Product_Permissions_Module"
      "${sectionName} Module",                          // "Product Permissions Module"
      sectionName,                                      // "Product Permissions"
      sectionName.replaceAll(' ', '_'),                 // "Product_Permissions"
    ];

    String? foundKey;
    bool sectionValue = false;

    for (String key in possibleKeys) {
      if (modulePerms.containsKey(key)) {
        foundKey = key;
        sectionValue = modulePerms[key]!;
        break;
      }
    }


    return Column(
      spacing: 10.sp,
      children: [
        // Section header with Firebase data
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Builder(
                  builder: (context) {
                    String displayText = permissionSection.getName;

                    // 🐛 DEBUG: Print what's being displayed

                    return Text(
                      FormatHelper.capitalize(displayText),
                      style: AppTextStyles.font12SecondaryBlackCairoRegular,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
              ),
            ),
            SizedBox(width: 8.sp),
            // ✅ Only show switch if section exists in Firebase
            if (foundKey != null)
              DefaultSwitchButton(
                  value: sectionValue,
                  onChanged: (value) {
                    hapticController.triggerHapticFeedback(
                        vibration: VibrateType.mediumImpact,
                        hapticFeedback: HapticFeedback.mediumImpact
                    );
                    setState(() {
                      controller.modulePermissions[moduleName]![foundKey!] = value;
                    });
                    controller.emit(RoleSwitchToggled());
                  })
            else
              SizedBox(width: 40.sp), // Empty space for alignment
          ],
        ),

        // Section permissions from Firebase
        if (permissionSection.sectionPermissions.isNotEmpty)
          Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                spacing: 10.sp,
                children: [
                  for (int permissionIndex = 0;
                  permissionIndex < permissionSection.sectionPermissions.length;
                  permissionIndex++)
                    _buildEnumPermissionRow(
                      permissionSection.sectionPermissions[permissionIndex]
                      as ModulePermissionsSectionsPermission,
                      permissionSection,
                      module,
                    ),
                ],
              ))
      ],
    );
  }

  Widget _buildEnumPermissionRow(
      ModulePermissionsSectionsPermission permission,
      ModulePermissionsSections section,
      Modules module,
      ) {
    String moduleName = controller.moduleEnumToString(module);

    // ✅ Get value from Firebase
    if (!controller.modulePermissions.containsKey(moduleName)) {
      return SizedBox.shrink();
    }

    Map<String, bool> modulePerms = controller.modulePermissions[moduleName]!;

    // ✅ Try multiple possible keys for permission
    String uiName = permission.getUiName;

    // 🐛 DEBUG: Print permission name

    List<String> possibleKeys = [
      uiName,                              // "Add Product"
      uiName.replaceAll(' ', '_'),        // "Add_Product"
      uiName.replaceAll(' ', ''),         // "AddProduct"
      permission.getDataBaseName,          // Try database name too
      permission.getDataBaseName.replaceAll(' ', '_'),
    ];

    String? foundKey;
    bool permissionValue = false;

    for (String key in possibleKeys) {
      if (modulePerms.containsKey(key)) {
        foundKey = key;
        permissionValue = modulePerms[key]!;
        break;
      }
    }


    // ✅ FIXED: Show switch if permission EXISTS in Firebase (regardless of value)
    // The admin dashboard controls WHICH permissions appear
    // The user can toggle ON/OFF the permissions that ARE visible
    bool shouldShowSwitch = (foundKey != null);

    return Row(
      children: [
        if (permission.isChild) SizedBox(width: 20.sp),
        Expanded(
            child: Builder(
                builder: (context) {
                  String displayText = permission.getUiName;

                  // 🐛 DEBUG: Print what's being displayed

                  return Text(
                    displayText,
                    style: AppTextStyles.font12SecondaryBlackCairoRegular,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  );
                }
            )
        ),
        SizedBox(width: 8.sp),
        // ✅ Show switch if permission exists in Firebase (can be true or false)
        if (shouldShowSwitch)
          DefaultSwitchButton(
              value: permissionValue,
              onChanged: (value) {
                setState(() {
                  controller.modulePermissions[moduleName]![foundKey!] = value;
                });
                controller.emit(RoleSwitchToggled());
              })
        else
          SizedBox(width: 40.sp), // Empty space for alignment
      ],
    );
  }


  // ============================================================================
  // ✅ For modules WITHOUT enums - simple Firebase list
  // ============================================================================
  Widget _buildFirebaseOnlySwitches(Modules module, String moduleName) {
    Map<String, bool> permissions = controller.modulePermissions[moduleName]!;

    // Group permissions by type (module vs regular)
    Map<String, bool> modulePermissions = {};
    Map<String, bool> regularPermissions = {};

    permissions.forEach((key, value) {
      if (key.endsWith('_Module')) {
        modulePermissions[key] = value;
      } else {
        regularPermissions[key] = value;
      }
    });

    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        spacing: 10.sp,
        children: [
          // Module toggles first
          ...modulePermissions.entries.map((entry) =>
              _buildPermissionRow(moduleName, entry.key, entry.value, true)),

          // Regular permissions
          ...regularPermissions.entries.map((entry) =>
              _buildPermissionRow(moduleName, entry.key, entry.value, false)),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(
      String moduleName,
      String permissionKey,
      bool currentValue,
      bool isModulePermission) {

    // Convert key to readable name
    String displayName = permissionKey
        .replaceAll('_', ' ')
        .replaceAll('  ', ' ')
        .trim();

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: 5.sp,
          horizontal: isModulePermission ? 0 : 15.sp
      ),
      decoration: isModulePermission
          ? BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(6.r),
      )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: isModulePermission
                  ? AppTextStyles.font14BlackRegularCairo.copyWith(
                fontWeight: FontWeight.w600,
              )
                  : AppTextStyles.font12SecondaryBlackCairoRegular,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.sp),
          DefaultSwitchButton(
            value: currentValue,
            onChanged: (value) {
              setState(() {
                controller.modulePermissions[moduleName]![permissionKey] = value;
              });
              controller.emit(RoleSwitchToggled());
            },
          ),
        ],
      ),
    );
  }
}