/// Module: roles/r1_role_management
///
///*************************** FILE INFO ****************************///
/// File Name: module_switches_builder_builders.dart
/// Description: UI builder methods of `_ModuleSwitchesBuilderState` — split out of `module_switches_builder.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../module_switches_builder.dart';

// Split from module_switches_builder.dart to keep every file under 700 lines.

extension _ModuleSwitchesBuilderStateBuilders on _ModuleSwitchesBuilderState {
  Widget buildPermissionSection<T extends ModulePermissionsSections>(
      T permissionSection, Modules module) {
    final HapticController hapticController = AppControllers.haptic;

    String moduleName = controller.moduleEnumToString(module);

    // ✅ Check if this section exists in Firebase
    final Map<String, bool>? sourcePerms = _permsFor(moduleName);
    if (sourcePerms == null) {
      return SizedBox.shrink();
    }

    Map<String, bool> modulePerms = sourcePerms;

    // ✅ Try multiple possible keys for section
    String sectionName = permissionSection.getName;

    // FIXED 2/9/2026 — the section key was resolved from `getName` ALONE, and
    // `getName` is LOCALIZED on the newer enums (Messages and Notification both
    // return `S.current.…`). With the app in Arabic every candidate below
    // became an Arabic string, none of which is a Firestore key, so the
    // section's own key was never found: the master switch fell back to
    // deriving itself from its children and stopped writing the section key at
    // all. `getDataBaseName` is on-disk vocabulary and never localized, so it
    // is tried as well — which also covers any enum whose display name and
    // storage name differ for ordinary reasons.
    final String? sectionDbName =
        permissionSection is ModulePermissionsSectionsPermission
            ? (permissionSection as ModulePermissionsSectionsPermission)
                .getDataBaseName
            : null;

    List<String> possibleKeys = [
      "${sectionName}_Module", // "Product Permissions_Module"
      "${sectionName.replaceAll(' ', '_')}_Module", // "Product_Permissions_Module"
      "$sectionName Module", // "Product Permissions Module"
      sectionName, // "Product Permissions"
      sectionName.replaceAll(' ', '_'), // "Product_Permissions"
      if (sectionDbName != null) ...<String>[
        sectionDbName, // "Notification_Control"
        "${sectionDbName}_Module", // "Notification_Control_Module"
      ],
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

    // ── The section's master switch ──────────────────────────────────────
    //
    // ADDED 28/8/2026. The header used to draw a switch ONLY when the
    // section's own `*_Module` key was present, and an empty 40.sp gap
    // otherwise — which is why Form Builder sections ("Form Permissions",
    // "Results Permissions") showed a bare title with no way to turn the whole
    // group on or off, even though every child under them had a working
    // switch.
    //
    // ⚠️ WHY A MISSING KEY IS NOT SIMPLY CREATED HERE.
    // `modulePermissions` only ever holds keys the company's admin template
    // allows: `_loadAllModulePermissions` filters every key through
    // `isPermissionAllowedByAdmin`, which is DEFAULT-DENY by design (unknown
    // key, unknown module or an unloaded template all deny). So a missing
    // `*_Module` key means the administrator's template does not grant that
    // section, and writing it from here would hand a role a permission the
    // template withholds.
    //
    // The switch is therefore DERIVED when the key is absent: it reflects and
    // drives only the child keys ALREADY in the map — ones the admin already
    // allows and the user can already toggle one at a time. It is a bulk
    // operation over existing switches, so it grants nothing new. When the
    // section key IS present the behaviour is unchanged: the key is written
    // and the children follow it.
    //
    // A section with no key AND no resolvable children (e.g. Create Group
    // Permissions, whose `sectionPermissions` is empty) still renders no
    // switch — there is nothing to drive, and inventing the key would be the
    // escalation described above. That one needs the admin template fixed.
    final List<String> childKeys = <String>[];
    for (final Enum permission in permissionSection.sectionPermissions) {
      final String? childKey = _findPermissionKey(
        permission as ModulePermissionsSectionsPermission,
        modulePerms,
      );
      if (childKey != null) childKeys.add(childKey);
    }

    final bool hasMasterSwitch = foundKey != null || childKeys.isNotEmpty;

    // With a real key the stored value wins; without one the group reads as
    // "on" only when every child under it is on.
    final bool masterValue = foundKey != null
        ? sectionValue
        : childKeys.every((String key) => modulePerms[key] == true);

    return Column(
      spacing: 10.sp,
      children: [
        // Section header with Firebase data
        //
        // PADDING 8/9/2026: the 10.sp horizontal here is what keeps this header
        // aligned with the permission rows in the padded container below it.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Builder(builder: (context) {
                  // FIXED 13/8/2026: rendered the raw English
                  // identifier. getName is also a Firestore map key,
                  // so it is translated here, not at the enum.
                  String displayText =
                      PermissionLabel.of(context, permissionSection.getName);

                  // 🐛 DEBUG: Print what's being displayed

                  return Text(
                    FormatHelper.capitalize(displayText),
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryBlack),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
              SizedBox(width: 8.sp),
              // Shown when the section has its own key OR any child to drive.
              if (hasMasterSwitch)
                _switch(
                    value: masterValue,
                    onChanged: (value) {
                      hapticController.triggerHapticFeedback(
                          vibration: VibrateType.mediumImpact,
                          hapticFeedback: HapticFeedback.mediumImpact);
                      rebuild(() {
                        final Map<String, bool> perms =
                            controller.modulePermissions[moduleName]!;

                        // Only ever write the section key when the admin
                        // template actually granted it — see the note above.
                        if (foundKey != null) {
                          perms[foundKey] = value;
                        }

                        // ✅ The section header acts as a master switch: every
                        // permission inside its container follows it.
                        for (final String childKey in childKeys) {
                          perms[childKey] = value;
                        }
                      });
                      controller.emitSafely(RoleSwitchToggled());
                    })
              else
                SizedBox(width: 40.sp), // Empty space for alignment
            ],
          ),
        ),

        // Section permissions from Firebase
        if (permissionSection.sectionPermissions.isNotEmpty)
          Container(
              // PADDING 8/9/2026: 10.sp all round — every container that holds
              // text-and-switch rows keeps 10.sp of horizontal breathing room
              // inside its background. The section header row above carries the
              // same 10.sp, so the labels still line up across both.
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                spacing: 10.sp,
                children: [
                  for (int permissionIndex = 0;
                      permissionIndex <
                          permissionSection.sectionPermissions.length;
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
}
