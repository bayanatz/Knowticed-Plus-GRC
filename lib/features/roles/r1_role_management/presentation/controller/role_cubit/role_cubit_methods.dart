/// Module: roles/r1_role_management
///
///*************************** FILE INFO ****************************///
/// File Name: role_cubit_methods.dart
/// Description: Methods of `RoleCubit` — split out of `role_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../role_cubit.dart';

// Split from role_cubit.dart to keep every file under 700 lines.

extension RoleCubitMethods on RoleCubit {
  /// Function Name: [emitSafely]
  ///
  /// Purpose: Publish [state] only while this cubit is still open.
  ///
  /// Lifecycle note: this cubit drives long `async` flows (role add / select /
  /// delete, permission preload, image pick) that `await` Firestore. Navigating
  /// away mid-flight closes the cubit while those futures are still in the air,
  /// and the completion path then called `emit` on a closed cubit — a thrown
  /// `StateError`. Every emit in this feature (cubit, its extensions and the
  /// widgets that used to call `controller.emit` directly) goes through here,
  /// so the guard cannot be forgotten at a new call site.
  ///
  /// Parameters:
  /// - [state]: The state to publish.
  ///
  /// Returns: [void]
  void emitSafely(RoleState state) {
    if (isClosed) return;
    emitState(state);
  }

  Future<void> getUnDeletedRoles() async {
    emitSafely(RoleLoading()); // Show loading state

    Either<FirebaseFailure, dynamic> result =
        await roleRepository.getUnDeletedRoles();

    if (result.isLeft()) {
      emitSafely(
        RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')),
      );
      return;
    }

    roles = result.getOrElse(() => []);
    searchController.clear();
    filterRoles(); // This filters but doesn't emit yet

    // RoleLoading must never be the last state this method leaves behind: the
    // roles home renders a spinner for it, so a throw between here and the
    // final emit used to strand that page on a spinner forever (reported after
    // "save for later" returned to the home). The two enrichment steps below
    // are best-effort — the roles themselves are already in hand.
    try {
      await _loadAdminRestrictions();

      // ✅ Preload ALL permissions before showing roles
      await preloadAllRolePermissions();
    } catch (e) {
      debugPrint('Ignored error: $e');
    }

    // ✅ NOW emit fetched after everything is ready
    emitSafely(RoleFetched());
  }

  Future<void> _preloadRolePermissions(RoleHistoryModel role) async {
    if (_rolePermissionsCache.containsKey(role.roleId)) return;

    // Join a load already running for this role instead of starting another.
    final Future<void>? running = _preloadsInFlight[role.roleId];
    if (running != null) return running;

    // BLOCK BODY ON PURPOSE (fixed 21/9/2026): `Map.remove` returns the value
    // it removed — this very future — and `whenComplete` waits on a Future its
    // callback returns. The arrow form `() => _preloadsInFlight.remove(...)`
    // therefore made `load` wait on itself forever, which hung
    // `getUnDeletedRoles` and with it sign-in (`LoginController.getRoles`).
    final Future<void> load =
        _fetchRolePermissionsIntoCache(role).whenComplete(() {
      _preloadsInFlight.remove(role.roleId);
    });
    _preloadsInFlight[role.roleId] = load;
    return load;
  }

  Future<void> _fetchRolePermissionsIntoCache(RoleHistoryModel role) async {
    // Inside the try as well: this runs under a Future.wait, so anything that
    // escapes here fails the whole batch and aborts getUnDeletedRoles before
    // it can emit RoleFetched. One unreadable role must not cost the list.
    try {
      final activeModuleStrings = modulesCubit.getRoleActiveModules(role);

      if (activeModuleStrings.isEmpty) {
        _rolePermissionsCache[role.roleId] = {};
        return;
      }

      var result = await roleRepository.getAllRolePermissions(
        roleId: role.roleId,
        selectedModules: activeModuleStrings,
      );

      if (result.isRight()) {
        Map<String, Map<String, dynamic>> allPermissions = result.getOrElse(
          () => {},
        );
        Map<String, List<String>> rolePermissions = {};

        for (String moduleName in activeModuleStrings) {
          List<String> activePermissions = [];

          if (allPermissions.containsKey(moduleName)) {
            Map<String, dynamic> moduleData = allPermissions[moduleName]!;

            moduleData.forEach((key, value) {
              if (key != 'Role_Id' && key != 'timestamps') {
                bool isActive = false;

                if (value is List && value.isNotEmpty) {
                  var lastValue = value.last;
                  isActive =
                      (lastValue == true || lastValue == 1 || lastValue == '1');
                } else if (value is bool) {
                  isActive = value;
                }

                if (isActive) {
                  activePermissions.add(_formatPermissionNameForDisplay(key));
                }
              }
            });
          }

          rolePermissions[moduleName] = activePermissions;
        }

        _rolePermissionsCache[role.roleId] = rolePermissions;
      } else {
        _rolePermissionsCache[role.roleId] = {};
      }
    } catch (e) {
      _rolePermissionsCache[role.roleId] = {};
    }
  }

  /// Function Name: [_modulesNeedingAdminTemplate]
  ///
  /// Purpose: Every module an admin template must be loaded for.
  ///
  /// WHY NOT JUST [availableModules]: that list is hand-maintained, while the
  /// module-selection UI offers whatever `getDemoActiveModules()` returns. When
  /// the two drift — as they did for `grc` — the missing module gets no
  /// template, `isPermissionAllowedByAdmin` default-denies every one of its
  /// keys, and the role becomes unsaveable with an error no switch can clear.
  /// Taking the union means enabling a module in the admin dashboard is enough;
  /// nobody has to remember to edit a second list here.
  ///
  /// Returns: [List<String>] canonical module names, de-duplicated.
  List<String> _modulesNeedingAdminTemplate() {
    final Set<String> names = <String>{};

    for (final String m in availableModules) {
      names.add(RoleCubit.canonicalModuleName(m));
    }

    // Best-effort: this reads `roles`, which is already populated by the time
    // [_loadAdminRestrictions] runs, but a throw here must not cost us the
    // hand-maintained list above.
    try {
      for (final String m in getDemoActiveModules()) {
        names.add(RoleCubit.canonicalModuleName(m));
      }
    } catch (e) {
      debugPrint('Ignored error: $e');
    }

    return names.toList();
  }

  Future<void> _loadAdminRestrictions() async {
    // Reset before each load so a previously failed attempt does not leave the
    // gate permanently closed after a successful retry, and a previously
    // successful one does not mask a new failure.
    _adminRestrictionsLoaded = true;
    adminRestrictionsError = null;

    try {
      String companyId = _getCompanyId();

      for (String moduleName in _modulesNeedingAdminTemplate()) {
        // Every spelling this module is known by, canonical first. The
        // `Demo_Permissions` document is keyed by whatever the company wrote,
        // so a template stored under `form_builder` has to be found when we
        // ask for `services_app` — otherwise the module reads as having no
        // template at all and default-deny blocks every one of its
        // permissions. See [ModuleNameAliases].
        final List<String> spellings = ModuleNameAliases.spellingsOf(
          moduleName,
        );

        Either<FirebaseFailure, Map<String, bool>>? result;
        for (final String spelling in spellings) {
          result = await roleRepository.getAdminRestrictionsForModule(
            companyId: companyId,
            moduleName: spelling,
          );

          // Stop at the first spelling that actually returned a template; a
          // Right({}) means "this key is not in the document", so keep looking.
          if (result.isRight() &&
              result.getOrElse(() => <String, bool>{}).isNotEmpty) {
            break;
          }
        }

        if (result!.isRight()) {
          Map<String, bool> restrictions = result.getOrElse(() => {});

          if (restrictions.isNotEmpty) {
            // Stored under the CANONICAL name whichever spelling found it.
            _adminRestrictions[moduleName] = restrictions;
          }
        } else {
          // A per-module read failure means we do not know what this company
          // is allowed to grant, so the whole load is treated as failed rather
          // than leaving the module silently unrestricted.
          _adminRestrictionsLoaded = false;
          adminRestrictionsError = result.fold(
            (FirebaseFailure l) => l.errMessage,
            (_) => null,
          );
        }
      }
    } catch (e) {
      // Previously this catch was empty with every log commented out, so a
      // failed load left _adminRestrictions empty and the gate below allowed
      // everything.
      _adminRestrictionsLoaded = false;
      adminRestrictionsError = e.toString();
    }

    if (!_adminRestrictionsLoaded) {
      // Surface it: the permission UI is now default-deny, and without this
      // the user would just see every toggle blocked with no explanation.
      emitSafely(
        RoleError(
          'Could not load the administrator permission template'
          '${adminRestrictionsError == null ? '' : ': $adminRestrictionsError'}. '
          'Permission editing is restricted until it loads.',
        ),
      );
    }
  }

  /// Function Name: [isPermissionAllowedByAdmin]
  ///
  /// Purpose: Gate a single permission against the company's admin template.
  ///
  /// SECURITY (default-deny): every branch here used to `return true` —
  /// an unloaded template, an unknown module and an unknown permission key all
  /// granted the permission. Combined with the swallowed load error above, a
  /// Firestore hiccup silently unlocked every permission in the editor. All
  /// three now deny.
  ///
  /// Operational note: this makes the editor strict. A company whose
  /// `Demo_Permissions` template is missing entries will see those permissions
  /// blocked rather than open.
  ///
  /// Parameters:
  /// - [moduleName]: Module the permission belongs to.
  /// - [permissionKey]: The permission being checked.
  ///
  /// Returns: [bool] `true` only when the template explicitly allows it.
  bool isPermissionAllowedByAdmin(String moduleName, String permissionKey) {
    if (!_adminRestrictionsLoaded) return false;

    // Canonical first, raw second: the template is stored under the canonical
    // name by [_loadAdminRestrictions], but a caller may still hand us the
    // stored spelling (`form_builder`) — see [_moduleNameAliases].
    final Map<String, bool>? moduleRestrictions =
        _adminRestrictions[RoleCubit.canonicalModuleName(moduleName)] ??
            _adminRestrictions[moduleName];
    if (moduleRestrictions == null) return false;

    return moduleRestrictions[permissionKey] == true;
  }

  /// Fills [modulePermissions] for every module a saved role has selected.
  ///
  /// REWRITTEN 29/8/2026 — a resumed DRAFT opened its permission page with no
  /// switches at all. Two faults, both of which this rewrite removes:
  ///
  ///  1. DESTRUCTIVE. The old body cleared `modulePermissions` on entry and
  ///     then went to Firestore. If any of those awaits threw or never came
  ///     back, the map stayed empty for the rest of the session — every
  ///     ModuleSwitchesBuilder short-circuits to SizedBox.shrink() when its
  ///     module has no bucket, so the page rendered blank. It is now built in
  ///     a LOCAL map and published in one assignment at the end, so a failure
  ///     leaves the previous contents alone instead of wiping them.
  ///  2. NOT GUARANTEED. Only the admin branch backfilled missing modules with
  ///     their defaults. The non-admin branch seeds `{}` for a module and then
  ///     adds only admin-allowed keys, so a module could finish EMPTY — a
  ///     present-but-empty bucket hides the switches exactly like a missing
  ///     one. The backfill is now a single pass at the end, after every branch,
  ///     so no selected module can end up without permissions.
  ///
  /// This is why picking a fresh module in the grid always worked while the
  /// draft's own modules did not: [selectModule] fills that one module from
  /// [_getDefaultPermissionsForModule] directly and never went through here.
  Future<void> _loadAllModulePermissions(RoleHistoryModel role) async {
    String roleId = role.roleId;
    // Normalised on the way in (23/8/2026): a document listing `form_builder`
    // used to land in a `modulePermissions` bucket no switch page could reach,
    // because the pages key themselves by [moduleEnumToString]. See
    // [ModuleNameAliases].
    final Set<String> modulesToLoadSet =
        role.currentSelectedModules.map(RoleCubit.canonicalModuleName).toSet();
    // ADDED 29/8/2026: settings is mandatory and its switches live on their own
    // page; guarantee it is always loaded so those switches render for a
    // resumed draft even if the saved document omitted it from the module list.
    modulesToLoadSet.add('settings');
    List<String> modulesToLoad = modulesToLoadSet.toList();

    // Built up here, assigned to the field only once at the very end.
    final Map<String, Map<String, bool>> loaded = <String, Map<String, bool>>{};

    String? currentUserEmail;
    try {
      currentUserEmail = AppControllers.employee.employeeEntity?.email;
    } catch (e) {
      // Not fatal — the backfill below covers every module with its defaults
      // when the email is unavailable. Recorded rather than swallowed (§11.5).
    }

    if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
      final bool isCurrentUserAdmin = roleRepository.isCompanyAdminByEmail(
        currentUserEmail,
      );

      if (isCurrentUserAdmin) {
        Either<FirebaseFailure, Map<String, Map<String, bool>>> adminResult =
            await roleRepository.getAdminPermissions(roleId);

        if (adminResult.isRight()) {
          // A missing or empty admin document — the usual case for a DRAFT —
          // simply contributes nothing here; the backfill supplies defaults.
          loaded.addAll(adminResult.getOrElse(() => {}));
        }
      } else {
        Either<FirebaseFailure, Map<String, Map<String, dynamic>>> result =
            await roleRepository.getAllRolePermissions(
          roleId: roleId,
          selectedModules: modulesToLoad,
        );

        if (result.isRight()) {
          Map<String, Map<String, dynamic>> allPermissions = result.getOrElse(
            () => {},
          );

          for (String moduleName in modulesToLoad) {
            if (!allPermissions.containsKey(moduleName)) continue;

            Map<String, dynamic> moduleData = allPermissions[moduleName]!;
            Map<String, bool> stored = <String, bool>{};

            moduleData.forEach((key, value) {
              if (key == 'Role_Id' || key == 'timestamps') return;
              if (!isPermissionAllowedByAdmin(moduleName, key)) return;

              if (value is List && value.isNotEmpty) {
                var lastValue = value.last;
                bool boolValue = false;

                if (lastValue is bool) {
                  boolValue = lastValue;
                } else if (lastValue == true ||
                    lastValue == 'true' ||
                    lastValue == 1) {
                  boolValue = true;
                }

                stored[key] = boolValue;
              } else if (value is bool) {
                stored[key] = value;
              }
            });

            // An empty result is dropped rather than stored: a bucket that
            // exists but holds nothing hides the module's switches, so it is
            // left for the backfill to fill with defaults.
            if (stored.isNotEmpty) {
              loaded[moduleName] = stored;
            }
          }
        }
      }
    }

    // ── THE GUARANTEE ───────────────────────────────────────────────────
    // Whatever happened above — admin or not, document found, missing, empty
    // or refused — every selected module ends with a real set of switches,
    // the same defaults the create flow uses.
    for (String moduleName in modulesToLoad) {
      final Map<String, bool>? existing = loaded[moduleName];
      if (existing == null || existing.isEmpty) {
        loaded[moduleName] = await _getDefaultPermissionsForModule(moduleName);
      } else {
        // ADDED 26/9/2026 (form bug report #28): a role saved BEFORE a
        // permission was added to the template (e.g. Form Builder's
        // "Create Group Permissions") never has that key in its stored
        // document, so ModuleSwitchesBuilder had nothing to bind a switch to
        // and the row vanished. Backfill every key the admin template allows
        // but the role is missing, defaulted to `false` — this grants nothing,
        // it only makes the switch appear so the admin can turn it on.
        final Map<String, bool> defaults =
            await _getDefaultPermissionsForModule(moduleName);
        defaults.forEach((key, _) {
          existing.putIfAbsent(key, () => false);
        });
      }
    }

    modulePermissions = loaded;
    emitSafely(RolePermissionLoaded());
  }

  Future<void> fixQiyasPermissions(String roleId) async {
    var result = await roleRepository.fixCorruptedQiyasDocument(roleId);

    result.fold(
      (failure) {
        emitSafely(RoleError(failure.errMessage));
      },
      (success) {
        getUnDeletedRoles();
        if (selectedRole != null) {
          var updatedRole = roles.firstWhere((r) => r.roleId == roleId);
          selectRole(updatedRole);
        }
        emitSafely(RolePermissionUpdated());
      },
    );
  }

  /// Function Name: [pruneRetiredPermissions]
  ///
  /// Purpose: Force every permission key the admin template does not know about
  ///          to `false`, so a save cannot be blocked by a key no switch shows.
  ///
  /// WHY: a module's permission set changes over time. A role saved under the
  /// old set keeps those keys in its permission document, and
  /// [loadAllModulePermissions] reads them straight back into
  /// [modulePermissions] — still `true`. The editor renders the NEW set, so
  /// those stale keys are invisible, yet the violation scan below sees them as
  /// `true` and not allowed, and reports them as "restricted by administrator".
  /// The user then cannot clear the error: every switch they can reach belongs
  /// to a different key. GRC hit exactly this when its 4 placeholder keys were
  /// replaced by the real 32.
  ///
  /// A key ABSENT from the template is retired, not restricted — drop it. A key
  /// PRESENT and `false` is a real restriction and still blocks the save.
  ///
  /// Only prunes modules whose template actually loaded and is non-empty;
  /// otherwise a failed read would silently wipe every permission.
  ///
  /// Returns: [List<String>] the "module.key" pairs that were dropped.
  List<String> pruneRetiredPermissions() {
    if (!_adminRestrictionsLoaded) return const <String>[];

    final List<String> dropped = <String>[];

    for (final String moduleName in selectedModules) {
      final Map<String, bool>? perms = modulePermissions[moduleName];
      if (perms == null) continue;

      final Map<String, bool>? template =
          _adminRestrictions[RoleCubit.canonicalModuleName(moduleName)] ??
              _adminRestrictions[moduleName];
      if (template == null || template.isEmpty) continue;

      for (final String permKey in perms.keys.toList()) {
        if (!template.containsKey(permKey) && perms[permKey] == true) {
          perms[permKey] = false;
          dropped.add('$moduleName.$permKey');
        }
      }
    }

    if (dropped.isNotEmpty) {}

    return dropped;
  }

  Future<void> addNewRole() async {
    // Retired keys first: they are invisible in the editor, so letting them
    // reach the scan below produces an error the user cannot clear.
    pruneRetiredPermissions();

    bool hasViolations = false;
    List<String> violations = [];

    for (String moduleName in selectedModules) {
      if (modulePermissions.containsKey(moduleName)) {
        Map<String, bool> modulePerms = modulePermissions[moduleName]!;

        modulePerms.forEach((permKey, permValue) {
          if (permValue == true &&
              !isPermissionAllowedByAdmin(moduleName, permKey)) {
            hasViolations = true;
            violations.add("$moduleName.$permKey");
          }
        });
      }
    }

    if (hasViolations) {

      emitSafely(
        RoleError(
          "Cannot create role: The following permissions are restricted by administrator:\n${violations.join('\n')}",
        ),
      );
      return;
    }

    Either<Failure, dynamic> result = await roleRepository.addNewRole(
      selectedModules: selectedModules,
      roleName: roleNameController.text,
      roleNameAr: roleNameControllerAr.text,
      status: isActive ? RoleStatus.active : RoleStatus.inactive,
      roleDescription: roleDescriptionController.text,
      roleDescriptionAr: roleDescriptionControllerAr.text,
      createdBy: AppControllers.employee.employeeEntity!.email!,
      roleImage: roleImage?.path,
      modulePermissions: modulePermissions,
      restrictedCountryCodes: restrictedCountryCodes,
    );

    if (result.isRight()) {
      // CLEAR SEARCH TEXT HERE
      searchController.clear();

      await initAddingRoleController();
      await getUnDeletedRoles();
      emitSafely(RoleAdded());
    } else {
      emitSafely(
        RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')),
      );
    }
  }

  Future<void> selectModule(String moduleName) async {
    if (moduleName == 'settings') {
      if (!selectedModules.contains(moduleName)) {
        selectedModules.add(moduleName);
        modulePermissions[moduleName] = await _getDefaultPermissionsForModule(
          moduleName,
        );
        emitSafely(RoleModuleSelected());
      } else {}
      return;
    }

    if (selectedModules.contains(moduleName)) {
      selectedModules.remove(moduleName);
      modulePermissions.remove(moduleName);
    } else {
      selectedModules.add(moduleName);

      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(
        moduleName,
      );

      if (modulePermissions[moduleName] != null &&
          modulePermissions[moduleName]!.isNotEmpty) {}
    }

    await ensureSettingsSelected();

    emitSafely(RoleModuleSelected());
  }

  void updateModulePermission(
    String moduleName,
    String permission,
    bool value,
  ) {
    if (!modulePermissions.containsKey(moduleName)) {
      return;
    }

    if (value == true && !isPermissionAllowedByAdmin(moduleName, permission)) {
      emitSafely(
        RoleError(
          "Cannot enable '$permission' in module '$moduleName': This permission is restricted by the administrator.",
        ),
      );
      return;
    }

    modulePermissions[moduleName]![permission] = value;
    emitSafely(RolePermissionUpdated());
  }
}
