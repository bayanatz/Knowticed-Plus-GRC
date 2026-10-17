/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: module_switches_builder.dart
/// Description: Declares `ModuleSwitchesBuilder`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'dart:math';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/widgets/permission_label.dart';

import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/knowledge_hub/submissions_permissions_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/helper/format_title.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/core/helper/access/modules_enum.dart';
import 'package:flutter/services.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/custom/inputs/default_switch_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/core/di/app_controllers.dart';

part 'module_switches_builder/module_switches_builder_builders.dart';

/// The permission switches for one module.
///
/// EXTENDED 29/8/2026 — the role DETAILS screen used to draw its own summary of
/// the same data (a hand-packed row of chips in module_permissions_widget.dart)
/// and drifted from this layout. It now renders this widget instead, in
/// read-only mode, so the two screens cannot disagree about how a module's
/// permissions look. The three parameters below are what that needs:
///
///  * [permissions] — read the values from this map instead of the cubit's live
///    `modulePermissions`. The details screen holds a Firestore SNAPSHOT of the
///    saved role, which is not what the cubit carries mid-edit.
///  * [readOnly] — draw the switches exactly as here but swallow their gestures.
///    The details screen has nothing to save a change with.
///  * [showHeader] — hide the collapsible bar and the icon/name row, for a
///    caller that already draws its own module header.
class ModuleSwitchesBuilder extends StatefulWidget {
  const ModuleSwitchesBuilder({
    required this.module,
    this.permissions,
    this.readOnly = false,
    this.showHeader = true,
    super.key,
  });

  final Modules module;
  final Map<String, bool>? permissions;
  final bool readOnly;
  final bool showHeader;

  @override
  State<ModuleSwitchesBuilder> createState() => _ModuleSwitchesBuilderState();
}

class _ModuleSwitchesBuilderState extends State<ModuleSwitchesBuilder> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  late bool isTablet;
  late RoleCubit controller;
  bool isExpanded = true;

  /// Where this instance reads its values from: the caller's snapshot when one
  /// was supplied, otherwise the cubit's live map. Writes always go to the
  /// cubit, and are only reachable when [ModuleSwitchesBuilder.readOnly] is
  /// false — a caller passing a snapshot passes `readOnly: true` with it.
  Map<String, bool>? _permsFor(String moduleName) =>
      widget.permissions ?? controller.modulePermissions[moduleName];

  /// [DefaultSwitchButton], with its gestures removed in read-only mode.
  /// [AbsorbPointer] rather than a disabled style, so the control looks
  /// identical on both screens.
  Widget _switch({required bool value, required ValueChanged<bool> onChanged}) {
    final Widget control =
        DefaultSwitchButton(value: value, onChanged: onChanged);

    return widget.readOnly ? AbsorbPointer(child: control) : control;
  }

  @override
  Widget build(BuildContext context) {
    controller = context.read<RoleCubit>();
    isTablet = !kpIsPhoneLayout(context);

    return BlocBuilder<RoleCubit, RoleState>(
      buildWhen: (previous, current) =>
          current is RoleSwitchToggled ||
          current is RoleSelected ||
          current is RolePermissionLoaded ||
          current is RolePermissionUpdated,
      builder: (context, state) {
        String moduleName = controller.moduleEnumToString(widget.module);

        // ✅ If no permissions, hide completely
        final Map<String, bool>? perms = _permsFor(moduleName);
        if (perms == null || perms.isEmpty) {
          return SizedBox.shrink();
        }

        return modulePermissionsBuilder(widget.module);
      },
    );
  }

  Widget modulePermissionsBuilder(Modules module) {
    String moduleName = controller.moduleEnumToString(module);
    // Settings is skipped in the EDIT flow only — its switches have their own
    // page there (settings_switches_page.dart). A read-only viewer showing a
    // role's saved permissions has no such page to defer to, so it lists them
    // here like any other module.
    if (!widget.readOnly &&
        (moduleName.toLowerCase() == 'settings' ||
            module.getModuleName.toLowerCase().contains('settings'))) {
      return SizedBox.shrink();
    }
    // ✅ Check if module has enum-based permissions
    bool hasEnumPermissions = module.moduleFirstColumnPermissions.isNotEmpty ||
        module.moduleLastColumnPermissions.isNotEmpty;

    // A caller that draws its own module header gets the switches alone, with
    // no card of its own to nest inside theirs.
    final bool showChrome = widget.showHeader;

    return Container(
      padding: showChrome ? EdgeInsets.all(15.sp) : EdgeInsets.zero,
      decoration: showChrome
          ? BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            )
          : null,
      child: Column(
        spacing: 15.sp,
        children: [
          // Module header (collapsible bar)
          if (showChrome)
            InkWell(
              onTapDown: (_) => HapticController.low(),
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.sp),
                // Role QA p.5 (per Figma): the collapsible module bar is grey
                // with white text in the add/edit wizard.
                decoration: BoxDecoration(
                  color: widget.readOnly
                      ? AppColors.background
                      : AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      module.getModuleName,
                      style: StyleText.fontSize16Weight400.copyWith(
                          color: widget.readOnly
                              ? AppColors.text
                              : AppColors.colorWhite),
                    ),
                    Transform.rotate(
                      angle: isExpanded ? 0 : pi,
                      child: CustomSvgImage(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg",
                          height: 16.sp,
                          width: 16.sp,
                          fit: BoxFit.fill,
                          color: widget.readOnly
                              ? AppColors.secondaryText
                              : AppColors.colorWhite),
                    )
                  ],
                ),
              ),
            ),

          // Module content — always shown when this instance draws no header of
          // its own, since there is then nothing to collapse it with.
          if (isExpanded || !showChrome) ...[
            // Module icon and name row
            if (showChrome)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20.r,
                    child: CustomSvgImage(
                      assetPath: module.iconPath,
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
                      style: StyleText.fontSize16Weight400,
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

  /// ✅ Resolves the Firebase key for a permission, tolerating the different
  /// naming conventions used across modules. Shared by the row builder and the
  /// section master switch so both always target the same key.
  String? _findPermissionKey(
    ModulePermissionsSectionsPermission permission,
    Map<String, bool> modulePerms,
  ) {
    String uiName = permission.getUiName;

    List<String> possibleKeys = [
      uiName, // "Add Product"
      uiName.replaceAll(' ', '_'), // "Add_Product"
      uiName.replaceAll(' ', ''), // "AddProduct"
      permission.getDataBaseName, // Try database name too
      permission.getDataBaseName.replaceAll(' ', '_'),
    ];

    for (String key in possibleKeys) {
      if (modulePerms.containsKey(key)) return key;
    }
    return null;
  }

  Widget _buildEnumPermissionRow(
    ModulePermissionsSectionsPermission permission,
    ModulePermissionsSections section,
    Modules module,
  ) {
    String moduleName = controller.moduleEnumToString(module);

    // ✅ Get value from Firebase
    final Map<String, bool>? sourcePerms = _permsFor(moduleName);
    if (sourcePerms == null) {
      return SizedBox.shrink();
    }

    Map<String, bool> modulePerms = sourcePerms;

    // ✅ Try multiple possible keys for permission
    String? foundKey = _findPermissionKey(permission, modulePerms);
    // 14/10/2026 — KH large-screen report p.31 "show this switch": "Create
    // Without Need Approval" was added after most role templates were saved,
    // so its key is missing and the row showed no switch. It is offered OFF
    // (the safe default — creating still needs approval) and stored under its
    // own key once toggled.
    if (foundKey == null &&
        permission == SubmissionsPermissions.createWithoutNeedApproval) {
      foundKey = permission.getDataBaseName;
    }
    bool permissionValue =
        foundKey != null ? (modulePerms[foundKey] ?? false) : false;

    // ✅ FIXED: Show switch if permission EXISTS in Firebase (regardless of value)
    // The admin dashboard controls WHICH permissions appear
    // The user can toggle ON/OFF the permissions that ARE visible
    bool shouldShowSwitch = (foundKey != null);

    return Row(
      children: [
        // ALIGNMENT 8/9/2026: removed `if (permission.isChild) SizedBox(width:
        // 20.sp)`. Child permissions were indented 20.sp under their parent, so
        // the page showed permission labels starting at three different x
        // positions. Every label now starts at the same edge.
        Expanded(child: Builder(builder: (context) {
          // FIXED 13/8/2026: see note above.
          String displayText =
              PermissionLabel.of(context, permission.getUiName);

          // 🐛 DEBUG: Print what's being displayed

          return Text(
            displayText,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryBlack),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        })),
        SizedBox(width: 8.sp),
        // ✅ Show switch if permission exists in Firebase (can be true or false)
        if (shouldShowSwitch)
          _switch(
              value: permissionValue,
              onChanged: (value) {
                setState(() {
                  controller.modulePermissions[moduleName]![foundKey!] = value;
                });
                controller.emitSafely(RoleSwitchToggled());
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
    Map<String, bool> permissions = _permsFor(moduleName) ?? <String, bool>{};

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
      // PADDING 8/9/2026: 10.sp all round — see the enum path above.
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        spacing: 10.sp,
        children: [
          // Module toggles first. These are master switches over every regular
          // permission in the same module — see [_buildPermissionRow].
          ...modulePermissions.entries.map((entry) => _buildPermissionRow(
                moduleName,
                entry.key,
                entry.value,
                true,
                childKeys: regularPermissions.keys.toList(),
              )),

          // Regular permissions
          ...regularPermissions.entries.map((entry) =>
              _buildPermissionRow(moduleName, entry.key, entry.value, false)),
        ],
      ),
    );
  }

  /// FIXED 13/8/2026: the module-level switch (`*_Module`) wrote only its own
  /// key, so turning "CRM Module" off left every permission under it switched
  /// on — a role kept the individual grants while the module read as disabled.
  /// The section-header switch a few hundred lines up already cascaded and
  /// documented itself as "a master switch"; this renderer never did.
  ///
  /// [childKeys] are the sibling permissions the master switch governs; it is
  /// empty for a regular row.
  ///
  /// The cascade is deliberately **one-directional — off only**. Turning the
  /// module off revokes everything under it, which is what the reviewer asked
  /// for and is the safe direction. Turning it back on does *not* re-grant
  /// every child, because auto-granting a whole module's permissions from one
  /// tap is how a role silently ends up over-privileged; the admin re-enables
  /// the specific ones they want. Flag this if you want symmetric behaviour.
  Widget _buildPermissionRow(
    String moduleName,
    String permissionKey,
    bool currentValue,
    bool isModulePermission, {
    List<String> childKeys = const <String>[],
  }) {
    // Convert key to readable name.
    // FIXED 13/8/2026: this screen builds its labels straight off the Firestore
    // permission keys ('CRM_Module' -> 'CRM Module'), so it never went near the
    // enums and stayed English regardless of locale. fromStorageKey does the
    // same underscore fold and then translates.
    String displayName = PermissionLabel.fromStorageKey(context, permissionKey);

    return Container(
      // PADDING 8/9/2026: the module row draws its own background box, so it
      // gets the same 10.sp horizontal padding every text-and-switch container
      // gets. A plain row has no box of its own and takes its padding from the
      // container around it — the old 15.sp indent here is gone, so plain rows
      // start where the section header does.
      padding: EdgeInsets.symmetric(
        vertical: 5.sp,
        horizontal: isModulePermission ? 10.sp : 0,
      ),
      decoration: isModulePermission
          ? BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(6.r),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: isModulePermission
                  ? StyleText.fontSize14Weight400.copyWith(
                      fontWeight: FontWeight.w600,
                    )
                  : StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryBlack),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.sp),
          _switch(
            value: currentValue,
            onChanged: (value) {
              setState(() {
                final Map<String, bool> perms =
                    controller.modulePermissions[moduleName]!;
                perms[permissionKey] = value;

                // Master switch turned off: revoke everything under it.
                if (isModulePermission && !value) {
                  for (final String childKey in childKeys) {
                    perms[childKey] = false;
                  }
                }
              });
              controller.emitSafely(RoleSwitchToggled());
            },
          ),
        ],
      ),
    );
  }
}
