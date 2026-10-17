/// Module: core/helper
///
///*************************** FILE INFO ****************************///
/// File Name: main_core_employee_controller_methods.dart
/// Description: Methods of `MainCoreEmployeeController` — split out of `main_core_employee_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../main_core_employee_controller.dart';

// Split from main_core_employee_controller.dart to keep every file under 700 lines.

extension MainCoreEmployeeControllerMethods on MainCoreEmployeeController {
  /// Fetches all employees from a specific Firestore collection and filters them by 'active' status.
  /// Returns a list of [EmployeeEntityPro] for all employees if successful, or an empty list if an error occurs.
  Future<List<EmployeeEntityPro>?> getAllNewEmployees() async {
    try {
      Either<Failure, List<NewEmployeeModelHistory>> result =
          await employeeRepository.getEmployees();

      if (result.isRight()) {
        allNewEmployees = result.getOrElse(() => []);
        EmployeeEntityController employeeEntityController =
            EmployeeEntityController();

        // Convert NewEmployeeModelHistory to EmployeeEntity
        allEmployeesEntities = employeeEntityController.fromHistoryModelList(
          allNewEmployees ?? [],
        );

        // ✅ CRITICAL FIX: Get the current logged-in employee from EmployeeController.
        // Guard against it not being registered yet: onInit() runs at app
        // startup, before LoginController registers EmployeeController.
        if (!Get.isRegistered<EmployeeController>()) {
          return allEmployeesEntities;
        }
        final employeeController = Get.find<EmployeeController>();

        // ✅ Check if employee field is initialized
        if (employeeController.employee == null) {
          return allEmployeesEntities;
        }

        String? currentEmployeeEmail =
            employeeController.employee!.email.lastOrNull;

        if (currentEmployeeEmail == null || currentEmployeeEmail.isEmpty) {
          return allEmployeesEntities;
        }

        // Populate map and find current employee.
        // ✅ FIX: one bad record (null email, missing role, …) used to throw
        // and abort the WHOLE loop, so employeeEntity was never set and the
        // drawer showed only Home + Settings. Each employee is now isolated.
        for (EmployeeEntityPro employee in allEmployeesEntities!) {
          try {
            if (employee.email == null || employee.email!.isEmpty) continue;

            mapOfEmployeesWithEmailKey[employee.email!] = employee;

            if (employee.email == currentEmployeeEmail) {
              employeeEntity = employee;

              // ✅ FIX: keep global constants in sync so features that read
              // Constant.emailUser (e.g. home calendar) get a real value.
              Constant.emailUser = employee.email ?? '';
              Constant.departmentId = employee.departmentId ?? '';
              Constant.roleName = employee.role ?? '';
              Constant.idUser = employee.id ?? '';

              // ✅ FIX: the services data layer queries Firestore with
              // CurrentUserContext.email. It was never assigned, so every
              // "Email_Requester arrayContains ''" query returned 0 docs
              // (My Requests looked empty while the chips showed counts).
              CurrentUserContext.email = employee.email;

              // Load role and initialize messaging — must not kill the loop.
              try {
                await loadEmployeeRole();
              } catch (e) {
                debugPrint('Ignored error: $e');
              }

              if (Get.context != null) {
                login(Get.context!, employee.email!);
              }
            }
          } catch (e) {
            continue;
          }
        }

        if (employeeEntity == null) {}
      } else {}

      return allEmployeesEntities;
    } catch (e) {
      return [];
    }
  }

  /// Loads permissions for all modules from separate collections
  Future<void> _loadModulePermissions() async {
    if (currentEmployeeRole == null) return;

    // ✅ Use the ACTUAL role document ID, not the role name!
    String roleId = currentEmployeeRole!.roleId;
    List<String> selectedModules = currentEmployeeRole!.currentSelectedModules;

    // ⚠️ Do NOT clear the cache here.
    //
    // This method is invoked several times during startup (initData step 4,
    // step 5, and again from the roles/permissions listeners). Clearing before
    // the await left the cache EMPTY for the whole duration of the Firestore
    // round-trip. Any screen that built during that window saw zero
    // permissions and silently rendered its no-permission fallback — and
    // because nothing rebuilds it afterwards, it stayed that way forever.
    // (This is what made the services page always show the "request" view.)
    //
    // Instead we build a fresh map locally and swap it in atomically once the
    // data is actually in hand, so readers always see either the previous
    // permissions or the new ones — never nothing.

    // Load permissions from each module collection
    Either<FirebaseFailure, Map<String, Map<String, dynamic>>> result =
        await roleRepository.getAllRolePermissions(
      roleId: roleId,
      selectedModules: selectedModules,
    );

    if (result.isRight()) {
      Map<String, Map<String, dynamic>> allPermissions = result.getOrElse(
        () => {},
      );

      // Built locally, then swapped in atomically below.
      final Map<String, Map<String, bool>> freshCache = {};

      // Process and cache permissions
      for (String module in selectedModules) {
        if (allPermissions.containsKey(module)) {
          Map<String, dynamic> moduleData = allPermissions[module]!;
          // Cache under the normalised key so lookups via _getModuleName()
          // (always lower-case) match regardless of how the module name was
          // capitalised in Firestore.
          // Canonical (9/10/2026): `tracking` and `time_tracker` share one
          // cache entry, matching the lookups in [_moduleKey].
          final String cacheKey = ModuleNameAliases.canonical(module);
          freshCache[cacheKey] = {};

          // // print("\n--- Processing module: $module ---");
          // // print("Raw module data keys: ${moduleData.keys.toList()}");

          // Extract current permissions (last value in arrays)
          moduleData.forEach((key, value) {
            if (key == 'Role_Id' || key == 'timestamps') {
              //    // print("  Skipping metadata: $key");
              return;
            }

            // Handle array values properly
            bool permissionValue = false;

            if (value is List && value.isNotEmpty) {
              var lastValue = value.last;
              permissionValue = lastValue == true || lastValue == 'true';
              //   // print("  $key: $permissionValue (from array: $value)");
            } else if (value is bool) {
              permissionValue = value;
              //   // print("  $key: $permissionValue (direct boolean)");
            } else {}

            freshCache[cacheKey]![key] = permissionValue;
          });
        } else {}
      }

      // Atomic swap — readers never observe a half-built or empty cache.
      _modulePermissionsCache = freshCache;

      // Screens that already built while permissions were still loading show
      // their no-permission fallback. Without this they would never re-run
      // their permission checks. update() rebuilds GetBuilder/Obx listeners.
      update();

      // ADDED 28/9/2026 — apply the role's Restricted Location policy (the
      // switch and country list set on the role editor's third page). Not
      // awaited: the location lookup must not hold up the rest of startup;
      // the block screen appears as soon as it has an answer.
      RestrictedLocationGuard.instance.evaluate(
        roleId: roleId,
        enabled: freshCache['settings']?['Restricted_Location'] ?? false,
      );

      _modulePermissionsCache.forEach((module, perms) {
        perms.values.where((v) => v == true).length;
      });
    } else {}
  }

  void getActiveSwitches() {
    activeSwitches[Modules.services] = {};
    moduleSectionsHasFullAccess[Modules.services] = {};
    for (int sectionIndex = 0;
        sectionIndex < ServicePermissionsSections.values.length;
        sectionIndex++) {
      moduleSectionsHasFullAccess[Modules.services]!.add(
        ServicePermissionsSections.values[sectionIndex],
      );
      for (int permissionIndex = 0;
          permissionIndex <
              ServicePermissionsSections
                  .values[sectionIndex].sectionPermissions.length;
          permissionIndex++) {
        activeSwitches[Modules.services]!.putIfAbsent(
          ServicePermissionsSections.values[sectionIndex],
          () => {},
        );
        activeSwitches[Modules.services]![
                ServicePermissionsSections.values[sectionIndex]]!
            .add(
          ServicePermissionsSections
                  .values[sectionIndex].sectionPermissions[permissionIndex]
              as ModulePermissionsSectionsPermission,
        );
      }
    }

    // activeSwitches[Modules.services]![ServicePermissionsSections.requestedServices]!
    //   .remove(ServicePermissions.viewRequesters);

    //activeSwitches[Modules.services]!.remove(ServicePermissionsSections.servicesPermissions);

    // moduleSectionsHasFullAccess[Modules.services]!
    //     .remove(ServicePermissionsSections.servicesPermissions);
    // moduleSectionsHasFullAccess[Modules.services]!
    //     .remove(ServicePermissionsSections.requestedServices);
    // moduleSectionsHasFullAccess[Modules.services]!
    //     .remove(ServicePermissionsSections.requestServicePermissions);
    // moduleSectionsHasFullAccess[Modules.services]!
    //     .remove(ServicePermissionsSections.dashboardPermissions);
    // moduleSectionsHasFullAccess[Modules.services]!
    //     .remove(ServicePermissionsSections.approvalPermissions);

    /*  activeSwitches[Modules.grc]![QiyasPermissionsSections.champions]!
        .remove(Champions.removeChampion);*/
    /*    moduleSectionsHasFullAccess[Modules.grc]!
        .remove(QiyasPermissionsSections.approvals);
    moduleSectionsHasFullAccess[Modules.grc]!
        .remove(QiyasPermissionsSections.dashboard);
    activeSwitches[Modules.grc]![QiyasPermissionsSections.qiyasPermissions]!
        .remove(QiyasPermissions.bulkUpload);
    activeSwitches[Modules.grc]![QiyasPermissionsSections.qiyasPermissions]!
        .remove(QiyasPermissions.exportTable);
    activeSwitches[Modules.grc]![QiyasPermissionsSections.qiyasPermissions]!
        .remove(QiyasPermissions.assignChampion);
    activeSwitches[Modules.grc]![QiyasPermissionsSections.champions]!
        .remove(Champions.reassignChampion);

    activeSwitches[Modules.grc]![QiyasPermissionsSections.champions]!
        .remove(Champions.editEvidence);

        */
    /* moduleSectionsHasFullAccess[Modules.grc]!
        .remove(QiyasPermissionsSections.assignedEvidence);*/
  }
}
