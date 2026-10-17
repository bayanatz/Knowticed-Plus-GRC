/// Module: roles/r1_role_management
///
///*************************** FILE INFO ****************************///
/// File Name: role_cubit_methods_3.dart
/// Description: Methods of `RoleCubit` — split out of `role_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../role_cubit.dart';

// Split from role_cubit.dart to keep every file under 700 lines.

extension RoleCubitMethods3 on RoleCubit {
  /// Function Name: [moduleEnumsFor]
  ///
  /// Purpose: Map stored module names to [Modules], dropping names this build
  /// does not know how to render.
  ///
  /// Why this exists: [stringToModuleEnum] throws on an unknown name, so every
  /// caller wrapped it in `try/catch` — including three widgets and a page,
  /// which §11.2 forbids from containing `try`. The skip rule is a business
  /// decision, not a rendering one, so it lives here and the UI just calls this.
  ///
  /// Parameters:
  /// - [moduleNames]: Stored module names, e.g. `Current_Selected_Modules`.
  ///
  /// Returns: [List<Modules>] in input order, unknown names omitted.
  List<Modules> moduleEnumsFor(Iterable<String> moduleNames) {
    final List<Modules> result = <Modules>[];
    for (final String name in moduleNames) {
      try {
        result.add(stringToModuleEnum(name));
      } catch (e) {
        // Unknown/retired module name — not renderable, so skip it. Logged so
        // a genuinely missing case (as 'hr' once was) is still discoverable.
      }
    }
    return result;
  }

  /// Inverse of [stringToModuleEnum], used to test membership of
  /// [selectedModules] while the user picks modules for a new role.
  String moduleEnumToSelectionString(Modules module) {
    switch (module) {
      case Modules.services:
        return 'services';
      case Modules.employees:
        return 'employees';
      case Modules.tasks:
        return 'tasks';
      case Modules.todo:
        return 'todo';
      case Modules.notes:
        return 'notes';
      case Modules.events:
        return 'events';
      case Modules.requests:
        return 'requests';
      case Modules.knowledgeHub:
        return 'knowledge_hub';
      case Modules.qiyas:
        return 'qiyas';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.database:
        return 'database';
      case Modules.formBuilder:
        return 'services_app';
      case Modules.grc:
        return 'grc';
      case Modules.tracking:
        return 'tracking';
      case Modules.notification:
        return 'notification';
      case Modules.hr:
        return 'hr';
      case Modules.crm:
        return 'crm';
      case Modules.timeTracker:
        return 'time_tracker'; // ADDED 8/10/2026
      case Modules.roles:
        return 'roles';
      case Modules.settings:
        return 'settings';
      default:
        return 'settings';
    }
  }

  /// Function Name: [_refreshSignedInUserPermissionsIfAffected]
  ///
  /// Purpose: Reload the signed-in employee's permission cache when the role
  ///          just saved is their OWN role.
  ///
  /// ADDED 23/8/2026. `MainCoreEmployeeController` loads
  /// `_modulePermissionsCache` once at startup and nothing invalidated it when
  /// a role was edited. So an admin who switched a Social Permission off and
  /// saved kept seeing the fields it guards — Email, Academic History, Skills
  /// and Hobbies on the org-chart profile — until the app was restarted, and it
  /// looked as though the switch had not saved at all.
  ///
  /// Only the signed-in user's own role matters here: editing anyone else's
  /// role changes nothing about what THIS session may see, and the affected
  /// users pick it up when they next sign in. The role is matched by name,
  /// which is what `loadEmployeeRole` itself matches on.
  ///
  /// Best-effort: a failure to refresh must not fail the save that already
  /// succeeded, so the screens keep the permissions they had.
  Future<void> _refreshSignedInUserPermissionsIfAffected() async {
    final String? savedRoleName = selectedRole?.currentRoleName;
    if (savedRoleName == null || savedRoleName.isEmpty) return;

    if (!AppControllers.isEmployeeRegistered) return;

    final String? currentRoleName =
        AppControllers.employee.employeeEntity?.role;
    if (currentRoleName == null) return;

    if (currentRoleName.trim().toLowerCase() !=
        savedRoleName.trim().toLowerCase()) {
      return;
    }

    await AppControllers.employee.refreshRolePermissions();
  }

  /// Function Name: [saveDraft]
  ///
  /// Purpose: Persist the in-progress role as a draft.
  ///
  /// Contract change: this used to be `Future<void>` and could throw — the
  /// creator email was read with `!` on two nullable hops, so a missing
  /// employee record blew up mid-save. `dialog.dart` compensated with a
  /// `try/catch` around the call, which §11.2 forbids in the UI layer. It now
  /// validates first, never throws, and reports the outcome.
  ///
  /// Returns: [Future<bool>] `true` when the draft was written; `false` after
  /// a `RoleError` has been emitted.
  Future<bool> saveDraft() async {
    final String? currentUserEmail =
        AppControllers.employee.employeeEntity?.email;

    if (currentUserEmail == null || currentUserEmail.isEmpty) {
      emitSafely(
        RoleError(
          'Your account details are unavailable, so the draft was not saved.',
        ),
      );
      return false;
    }

    if (selectedRole != null &&
        selectedRole!.currentStatus == RoleStatus.draft) {
      Either<Failure, dynamic> result = await roleRepository.updateRole(
        role: selectedRole!,
        currentUserEmail: currentUserEmail,
        roleDescription: roleDescriptionController.text,
        roleDescriptionAr: roleDescriptionControllerAr.text,
        roleNameAr: roleNameControllerAr.text,
        roleImage: roleImage?.path,
        selectedModules: selectedModules,
        modulePermissions: modulePermissions,
        restrictedCountryCodes: restrictedCountryCodes,
      );

      if (result.isRight()) {
        // CLEAR SEARCH TEXT HERE
        searchController.clear();

        await getUnDeletedRoles();
        emitSafely(RoleDraftSaved());
        return true;
      } else {
        emitSafely(
          RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')),
        );
        return false;
      }
    } else {
      Either<Failure, dynamic> result = await roleRepository.addNewRole(
        selectedModules: selectedModules,
        roleName: roleNameController.text,
        roleNameAr: roleNameControllerAr.text,
        roleDescription: roleDescriptionController.text,
        roleDescriptionAr: roleDescriptionControllerAr.text,
        createdBy: currentUserEmail,
        roleImage: roleImage?.path,
        modulePermissions: modulePermissions,
        restrictedCountryCodes: restrictedCountryCodes,
        status: RoleStatus.draft,
      );

      if (result.isRight()) {
        // CLEAR SEARCH TEXT HERE
        searchController.clear();

        await initAddingRoleController();
        await getUnDeletedRoles();
        emitSafely(RoleDraftSaved());
        return true;
      } else {
        emitSafely(
          RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')),
        );
        return false;
      }
    }
  }

  void toggleSectionPermissionState({
    required Modules module,
    required ModulePermissionsSections section,
  }) async {
    String moduleName = moduleEnumToString(module);
    bool currentState = isSectionActive(module, section);
    bool newState = !currentState;

    if (!modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(
        moduleName,
      );
    }

    if (section is ModulePermissionsSectionsPermission) {
      String sectionKey = _convertToDbFormat(
        (section as ModulePermissionsSectionsPermission).getDataBaseName,
      );

      if (newState == true &&
          !isPermissionAllowedByAdmin(moduleName, sectionKey)) {
        emitSafely(
          RoleError(
            "Cannot enable this section: It is restricted by the administrator.",
          ),
        );
        return;
      }

      modulePermissions[moduleName]![sectionKey] = newState;
    }

    for (var permission in section.sectionPermissions) {
      String permissionKey = _convertToDbFormat(
        (permission as ModulePermissionsSectionsPermission).getDataBaseName,
      );

      if (newState == true &&
          !isPermissionAllowedByAdmin(moduleName, permissionKey)) {
        continue;
      }

      modulePermissions[moduleName]![permissionKey] = newState;
    }

    emitSafely(RoleSwitchToggled());
  }

  Future<void> activateDraftRole() async {
    if (selectedRole == null) {
      throw Exception("No role selected");
    }

    RoleHistoryModel updatedRole = selectedRole!.copyWith(
      status: RoleStatus.active.name,
      selectedModules: selectedModules,
    );

    Either<Failure, dynamic> result = await roleRepository.updateRole(
      role: updatedRole,
      currentUserEmail: AppControllers.employee.employeeEntity!.email!,
      roleDescription: roleDescriptionController.text,
      roleDescriptionAr: roleDescriptionControllerAr.text,
      roleNameAr: roleNameControllerAr.text,
      roleImage: roleImage?.path,
      selectedModules: selectedModules,
      modulePermissions: modulePermissions,
      restrictedCountryCodes: restrictedCountryCodes,
    );

    if (result.isRight()) {
      // CLEAR SEARCH TEXT HERE
      searchController.clear();

      await initAddingRoleController();
      await getUnDeletedRoles();
      await _refreshSignedInUserPermissionsIfAffected();
      emitSafely(RoleActivated());
    } else {
      emitSafely(
        RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')),
      );
    }
  }

  List<Map<String, dynamic>> getRoleHistory(RoleHistoryModel role) {
    List<Map<String, dynamic>> history = [];

    for (int i = 0; i < role.timestamps.length; i++) {
      Map<String, dynamic> historyEntry = {
        'timestamp': DateTime.fromMillisecondsSinceEpoch(role.timestamps[i]),
        'roleName': i < role.roleName.length ? role.roleName[i] : '',
        'roleNameAr': i < role.roleNameAr.length ? role.roleNameAr[i] : '',
        'roleDescription':
            i < role.roleDescription.length ? role.roleDescription[i] : '',
        'roleDescriptionAr':
            i < role.roleDescriptionAr.length ? role.roleDescriptionAr[i] : '',
        'status': i < role.status.length ? role.status[i] : '',
        'roleImage': i < role.roleImage.length ? role.roleImage[i] : '',
        'selectedModules':
            i < role.selectedModules.length ? role.selectedModules[i] : [],
      };
      history.add(historyEntry);
    }

    return history;
  }

  List<Map<String, dynamic>> getRoleChangesByDateRange(
    RoleHistoryModel role,
    DateTime startDate,
    DateTime endDate,
  ) {
    List<Map<String, dynamic>> changes = [];

    for (int i = 0; i < role.timestamps.length; i++) {
      DateTime changeDate = DateTime.fromMillisecondsSinceEpoch(
        role.timestamps[i],
      );
      if (changeDate.isAfter(startDate) && changeDate.isBefore(endDate)) {
        Map<String, dynamic> change = {
          'timestamp': changeDate,
          'roleName': i < role.roleName.length ? role.roleName[i] : '',
          'roleNameAr': i < role.roleNameAr.length ? role.roleNameAr[i] : '',
          'roleDescription':
              i < role.roleDescription.length ? role.roleDescription[i] : '',
          'roleDescriptionAr': i < role.roleDescriptionAr.length
              ? role.roleDescriptionAr[i]
              : '',
          'status': i < role.status.length ? role.status[i] : '',
          'roleImage': i < role.roleImage.length ? role.roleImage[i] : '',
          'selectedModules':
              i < role.selectedModules.length ? role.selectedModules[i] : [],
        };
        changes.add(change);
      }
    }

    return changes;
  }

  Future<void> loadModulePermissions(String moduleName) async {
    if (selectedRole == null) return;

    String roleId = selectedRole!.currentRoleName;
    Either<FirebaseFailure, Map<String, dynamic>?> result = await roleRepository
        .getRolePermissions(roleId: roleId, module: moduleName);

    if (result.isRight()) {
      Map<String, dynamic>? permissions = result.getOrElse(() => null);
      if (permissions != null) {
        modulePermissions[moduleName] = {};
        permissions.forEach((key, value) {
          if (key != 'Role_Id' &&
              key != 'timestamps' &&
              value is List &&
              value.isNotEmpty) {
            modulePermissions[moduleName]![key] = value.last == true;
          }
        });
        emitSafely(RolePermissionLoaded());
      }
    }
  }

  void importRoleConfiguration(Map<String, dynamic> config) async {
    roleNameController.text = config['roleName'] ?? '';
    roleNameControllerAr.text = config['roleNameAr'] ?? '';
    roleDescriptionController.text = config['roleDescription'] ?? '';
    roleDescriptionControllerAr.text = config['roleDescriptionAr'] ?? '';
    selectedModules = List<String>.from(config['selectedModules'] ?? []);

    if (config['modulePermissions'] != null) {
      modulePermissions.clear();
      Map<String, dynamic> permissions = config['modulePermissions'];
      permissions.forEach((module, perms) {
        modulePermissions[module] = Map<String, bool>.from(perms);
      });
    }

    await ensureSettingsSelected();

    emitSafely(RoleConfigurationImported());
  }
}
