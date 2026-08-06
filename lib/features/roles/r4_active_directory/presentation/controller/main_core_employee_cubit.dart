/// ***************************** FILE INFO ***************************** ///
/// File Name: main_core_employee_cubit.dart
/// Purpose: Signed-in employee, the employee directory, and role/permission
///          lookups. Converted from MainCoreEmployeeController (GetxController).
/// Notes:   - onInit() auto-load now runs from the constructor.
///          - update() calls are emits of [MainCoreEmployeeReady].
///          - Collaborators are constructor-injected; no service locator.
/// ********************************************************************* ///

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
// NOTE: the settings EmployeeController is injected, which also removes the
// old ambiguity with the identically-named organization_chart_module class
// that used to break Get.find<EmployeeController>().
// Full import: `Get.locale` is an extension member on GetInterface, so a
// `show Get` clause does not bring it into scope.
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/network/failure_model.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/core/helper/main_helper/current_user_context.dart';
import './main_core_department_cubit.dart';
import '../../data/models/emplyees_model/new_employee_model.dart';
import '../../data/repository/main_core_employee_repository.dart';
import '../../domain/entities/employee_entity.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';

part './main_core_employee_state.dart';

class MainCoreEmployeeCubit extends Cubit<MainCoreEmployeeState> {
  /// [departmentCubit] and [settingsEmployeeController] are injected rather
  /// than located, so this cubit has no dependency on a service locator.
  /// Construction kicks off the employee load, mirroring the old `onInit`.
  MainCoreEmployeeCubit({
    required this.departmentCubit,
    required this.settingsEmployeeController,
    bool autoLoad = true,
  }) : super(const MainCoreEmployeeInitial()) {
    if (autoLoad) {
      getAllNewEmployees();
    }
  }

  /// Controller for handling department-related functionalities.
  final MainCoreDepartmentCubit departmentCubit;

  /// The settings-module EmployeeController that owns the signed-in user.
  final EmployeeController settingsEmployeeController;

  MainCoreEmployeeRepository employeeRepository = MainCoreEmployeeRepository();
  RoleRepository roleRepository = RoleRepository();





  Future<void> setCurrentEmployeeByEmail(String email) async {
    // print("🔍 Setting current employee by email: $email");

    employeeEntity = mapOfEmployeesWithEmailKey[email];
    if (employeeEntity != null) {
      // print("✅ Current employee set: ${employeeEntity!.firstName} ${employeeEntity!.lastName}");
      // print("📧 Email: ${employeeEntity!.email}");
      // print("🆔 ID: ${employeeEntity!.id}");

      // Update your constants
      Constant.emailUser = employeeEntity!.email!;
      Constant.departmentId = employeeEntity!.departmentId!;
      Constant.roleName = employeeEntity!.role!;
      Constant.idUser = employeeEntity!.id!;

      // Keep the services data layer's user context in sync (see loadData).
      CurrentUserContext.email = employeeEntity!.email;

      // ✅ CRITICAL FIX: Notify GetBuilder to update
      _publish();
      // print("✅ Notified GetBuilder of employee data update");
    } else {
      // print("⚠️ Employee not found for email: $email");
      // print("📊 Available employees in map: ${mapOfEmployeesWithEmailKey.length}");
    }
  }

  Map<String, EmployeeEntityPro> mapOfEmployeesWithEmailKey = {};

  // Cached permissions for performance
  Map<String, Map<String, bool>> _modulePermissionsCache = {};

  /// List of all new employees fetched from Firestore (using NewEmployeeModelHistory)
  List<NewEmployeeModelHistory>? allNewEmployees;
  List<EmployeeEntityPro>? allEmployeesEntities = [];

  /// Currently focused employee, used for detailed interactions.
  NewEmployeeModelHistory? currentEmployee;
  EmployeeEntityPro? employeeEntity;

  /// Current role history model for the logged-in employee
  RoleHistoryModel? currentEmployeeRole;





  Future<void> refreshEmployeeData() async {
    await getAllNewEmployees();
    _publish();
  }


  /// Fetches all employees from a specific Firestore collection and filters them by 'active' status.
  /// Returns a list of [EmployeeEntityPro] for all employees if successful, or an empty list if an error occurs.
  Future<List<EmployeeEntityPro>?> getAllNewEmployees() async {
    // print("🔵 MainCore: Starting getAllNewEmployees...");

    try {
      Either<Failure, List<NewEmployeeModelHistory>> result =
      await employeeRepository.getEmployees();

      if (result.isRight()) {
        allNewEmployees = result.getOrElse(() => []);
        EmployeeEntityController employeeEntityController =
        EmployeeEntityController();

        // print("✓ All employees list count: ${allNewEmployees!.length}");

        // Convert NewEmployeeModelHistory to EmployeeEntity
        allEmployeesEntities =
            employeeEntityController.fromHistoryModelList(allNewEmployees ?? []);

        // ✅ CRITICAL FIX: the signed-in employee comes from the injected
        // settings EmployeeController.
        final employeeController = settingsEmployeeController;

        // ✅ Check if employee field is initialized
        if (employeeController.employee == null) {
          print("⚠️ MainCore: EmployeeController.employee is null, cannot initialize employeeEntity");
          return allEmployeesEntities;
        }

        String? currentEmployeeEmail = employeeController.employee!.email?.lastOrNull;

        if (currentEmployeeEmail == null || currentEmployeeEmail.isEmpty) {
          print("⚠️ MainCore: Current employee email is null or empty");
          return allEmployeesEntities;
        }

        print("🔍 MainCore: Looking for employee with email: $currentEmployeeEmail "
            "among ${allEmployeesEntities?.length ?? 0} entities");

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
              print("✓ MainCore: Found current employeeEntity: ${employee.email}");

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
                print("⚠️ MainCore: loadEmployeeRole failed (non-fatal): $e");
              }

              await login(employee.email!);
            }
          } catch (e) {
            print("⚠️ MainCore: skipped bad employee record: $e");
            continue;
          }
        }

        if (employeeEntity == null) {
          print("⚠️ MainCore: employeeEntity NOT found for email: $currentEmployeeEmail");
        }
      } else {
        print("❌ MainCore: Error loading employees: ${result.fold((l) => l.errMessage, (r) => '')}");
      }

      return allEmployeesEntities;
    } catch (e, stackTrace) {
      print("❌ MainCore.getAllNewEmployees error: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
  }


  void _publish() {
    emit(MainCoreEmployeeReady(
      employeeEntity: employeeEntity,
      allEmployees: List.unmodifiable(allEmployeesEntities ?? const []),
      currentEmployeeRole: currentEmployeeRole,
    ));
  }

  /// Retrieves either the first or last name of an employee based on the provided email and a boolean flag.
  String getEmployeeNameFirstOrLast(String email, bool isFirst) {
    EmployeeEntityPro? employee = mapOfEmployeesWithEmailKey[email];
    if (employee == null) return '';

    return Get.locale.toString().contains('en')
        ? isFirst
        ? employee.firstName ?? ''
        : employee.lastName ?? ''
        : isFirst
        ? employee.firstNameInArabic ?? ''
        : employee.lastNameInArabic ?? '';
  }

  /// Constructs the full name of an employee based on their email.
  String getEmployeeName(String email) {
    EmployeeEntityPro? employee = mapOfEmployeesWithEmailKey[email];
    if (employee == null) return "no name";

    return Get.locale.toString().contains('en')
        ? "${employee.firstName ?? ''} ${employee.lastName ?? ''}"
        : "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}";
  }

  /// Fetches the full name of an employee in either English or Arabic based on the provided flag.
  String getEmployeeNameEnglishArabic(String email, bool isEnglish) {
    EmployeeEntityPro? employee = mapOfEmployeesWithEmailKey[email];
    if (employee == null) return '';

    return isEnglish
        ? "${employee.firstName ?? ''} ${employee.lastName ?? ''}"
        : "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}";
  }

  /// Retrieves a list of employees who are designated as 'super admins'.
  List<EmployeeEntityPro> getSuperAdmin() {
    return allEmployeesEntities
        ?.where((element) => element.role == 'super admin')
        .toList() ??
        [];
  }

  /// Retrieves the job title of an employee based on their email.
  String getEmployeeJobTitle(String email) {
    EmployeeEntityPro? employee = mapOfEmployeesWithEmailKey[email];
    if (employee == null) return "no job";

    return Get.locale.toString().contains('en')
        ? employee.title ?? 'no job'
        : employee.titleInArabic ?? 'no job';
  }

  /// Retrieves the photo URL or default avatar based on the gender of the employee.
  String getEmployeePhoto(String email) {
    EmployeeEntityPro? employee = mapOfEmployeesWithEmailKey[email];
    if (employee == null) return "assets/icons_assets/main_icons_assets/male_avatar.png";

    return employee.photo == null
        ? employee.gender == 'female'
        ? "assets/icons_assets/main_icons_assets/female_avatar.png"
        : "assets/icons_assets/main_icons_assets/male_avatar.png"
        : employee.photo!;
  }

  /// Returns the employee entity for the given email.
  EmployeeEntityPro? getLocaleEmployee(String email) {
    return mapOfEmployeesWithEmailKey[email];
  }

  /// Fetches a new employee by their email and updates the local data.
  Future<EmployeeEntityPro?> getNewEmployee(String email) async {
    // print("Checking if employee exists: ${mapOfEmployeesWithEmailKey[email].toString()}");
    return mapOfEmployeesWithEmailKey[email];
  }

  /// Retrieves the department name of an employee based on their email.
  String getEmployeeDepartmentName(String email) {
    // Manual lookup instead of firstWhereOrNull: that helper lives in
    // package:collection, which is only a transitive dependency here.
    EmployeeEntityPro? employee;
    final entities = allEmployeesEntities;
    if (entities != null) {
      for (final element in entities) {
        if (email == element.email) {
          employee = element;
          break;
        }
      }
    }
    if (employee == null) {
      return "no department";
    } else {
      return departmentCubit.getDepartmentName(
          employee.departmentId!, Get.locale.toString().contains('en'));
    }
  }

  /// Login method for setting user preferences
  Future<void> login(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();

    if (employeeEntity == null) return;

    // Save to SharedPreferences
    await prefs.setString("emailRequester", employeeEntity!.email ?? '');
    await prefs.setString(
        "firstNameRequester", employeeEntity!.firstName ?? '');
    await prefs.setString("lastNameRequester", employeeEntity!.lastName ?? '');
    await prefs.setString("genderRequester", employeeEntity!.gender ?? '');
    await prefs.setString(
        "phoneRequester", employeeEntity!.mobilePhone?.phone ?? '');

    // Arabic localization
    await prefs.setString("firstNameRequesterArabic",
        employeeEntity!.firstNameInArabic ?? '');
    await prefs.setString(
        "lastNameRequesterArabic", employeeEntity!.lastNameInArabic ?? '');
    await prefs.setString(
        "jobTitleRequesterArabic", employeeEntity!.titleInArabic ?? '');

    await prefs.setString("jobTitleRequester", employeeEntity!.title ?? '');
    await prefs.setString(
        "departmentRequester", employeeEntity!.departmentId ?? '');

    // print("✓ Saved to SharedPreferences!");
    Constant.emailUser = normalizedEmail;
  }





  /// Loads the current employee's role and permissions from the new multi-collection structure
  Future<void> loadEmployeeRole() async {
    if (employeeEntity?.role == null) {
      // print("⚠️ Employee role is null, cannot load role");
      return;
    }

    // print("Loading employee role: ${employeeEntity!.role}");

    try {
      // Find role using RoleHistoryModel
      currentEmployeeRole = roleCubit.roles.firstWhere(
            (element) => element.currentRoleName == employeeEntity!.role,
        orElse: () => throw Exception('Role not found: ${employeeEntity!.role}'),
      );

      // print("✓ Found role: ${currentEmployeeRole!.currentRoleName}");
      // print("✓ Selected modules: ${currentEmployeeRole!.currentSelectedModules}");

      // Load permissions for all selected modules
      await _loadModulePermissions();
    } catch (e) {
      // Role lookup failed — usually because roleCubit.roles is momentarily
      // empty (the roles listener fires with 0 documents before refilling).
      //
      // Previously this wiped currentEmployeeRole AND the permission cache,
      // permanently downgrading the user to "no permissions" until the next
      // full restart. A transient lookup miss must not destroy known-good
      // permissions, so we keep whatever we already had.
      print("⚠️ loadEmployeeRole failed, keeping previous permissions: $e");
      if (currentEmployeeRole == null) {
        _modulePermissionsCache.clear();
      }
    }
  }

  /// Loads permissions for all modules from separate collections
  Future<void> _loadModulePermissions() async {
    if (currentEmployeeRole == null) return;

    // ✅ Use the ACTUAL role document ID, not the role name!
    String roleId = currentEmployeeRole!.roleId;
    List<String> selectedModules = currentEmployeeRole!.currentSelectedModules;

    // print("\n=== Loading Module Permissions ===");
    // print("Role Name: ${currentEmployeeRole!.currentRoleName}");
    // print("Role ID (Document ID): $roleId");
    // print("Selected Modules: $selectedModules");

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

    // TEMP DIAGNOSTIC
    print('PERMLOAD ===== _loadModulePermissions =====');
    print('PERMLOAD roleId          : $roleId');
    print('PERMLOAD selectedModules : $selectedModules');
    print('PERMLOAD baseUri         : "${ApiConstants.baseUri}"');
    print('PERMLOAD result.isRight  : ${result.isRight()}');
    result.fold(
      (l) => print('PERMLOAD FAILURE: ${l.errMessage}'),
      (r) => print('PERMLOAD modules returned: ${r.keys.toList()}'),
    );

    if (result.isRight()) {
      Map<String, Map<String, dynamic>> allPermissions =
      result.getOrElse(() => {});

      print('PERMLOAD services doc present: '
          '${allPermissions.containsKey('services')}');
      print('PERMLOAD services raw keys   : '
          '${allPermissions['services']?.keys.toList()}');

      // print("✓ Loaded permissions for ${allPermissions.length} modules");

      // Built locally, then swapped in atomically below.
      final Map<String, Map<String, bool>> freshCache = {};

      // Process and cache permissions
      for (String module in selectedModules) {
        if (allPermissions.containsKey(module)) {
          Map<String, dynamic> moduleData = allPermissions[module]!;
          // Cache under the normalised key so lookups via _getModuleName()
          // (always lower-case) match regardless of how the module name was
          // capitalised in Firestore.
          final String cacheKey = module.toLowerCase().trim();
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
            } else {
              // print("  ⚠️ $key: Unexpected type ${value.runtimeType}: $value");
            }

            freshCache[cacheKey]![key] = permissionValue;
          });

          // print("✓ Cached ${freshCache[cacheKey]!.length} permissions for $module");
        } else {
          // print("⚠️ No permissions found for module: $module");
        }
      }

      // Atomic swap — readers never observe a half-built or empty cache.
      _modulePermissionsCache = freshCache;

      // Screens that already built while permissions were still loading show
      // their no-permission fallback. Without this they would never re-run
      // their permission checks. Emitting rebuilds BlocBuilder listeners.
      _publish();

      // print("\n=== Permission Loading Complete ===");
      // print("Total modules cached: ${_modulePermissionsCache.length}");
      _modulePermissionsCache.forEach((module, perms) {
        int trueCount = perms.values.where((v) => v == true).length;
        // print("  $module: $trueCount/${perms.length} permissions enabled");
      });
    } else {
      // print("❌ Error loading module permissions: ${result.fold((l) => l.errMessage, (r) => '')}");
    }
  }

  /// Checks if the current employee has access to a specific module
  /// Uses the new selectedModules approach instead of individual module fields
  bool hasModuleAccess(Modules module) {
    if (currentEmployeeRole == null) return false;

    // Check if module is in the role's selected modules list.
    //
    // The stored value is whatever the roles UI wrote to Firestore, which is
    // not guaranteed to be lower-case ('Services' vs 'services'). A raw
    // contains() therefore returned false for roles that clearly had the
    // module enabled — the nav bar showed the icon (it normalises with
    // toLowerCase(), see NavBarCubit._getModuleEnum) while every
    // permission check silently failed. Normalise on both sides.
    String moduleName = _getModuleName(module).toLowerCase().trim();
    bool hasAccess = currentEmployeeRole!.currentSelectedModules
        .any((m) => m.toLowerCase().trim() == moduleName);

   // // print("Checking module access for ${module.name} ($moduleName): $hasAccess");
    return hasAccess;
  }

  /// Helper method to convert Modules enum to string for database lookup
  String _getModuleName(Modules module) {
    switch (module) {
      case Modules.employees:
        return 'employees';
      case Modules.services:
        return 'services';
      case Modules.tasks:
        return 'tasks';
      case Modules.todo:
        return 'todo';
      case Modules.events:
        return 'events';
      case Modules.notes:
        return 'notes';
      case Modules.requests:
        return 'requests';
      case Modules.knowledgeHub:
        return 'knowledge_hub';
      case Modules.qiyas:
        return 'qiyas';
      case Modules.tracking:
        return 'tracking';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.database:
        return 'database_builder';
      case Modules.formBuilder:
        return 'services_app';
      case Modules.roles:
        return 'roles';
      case Modules.notification:  // ← ADD THIS LINE
        return 'notification';    // ← ADD THIS LINE
      case Modules.hr:  // ← ADD THIS LINE
        return 'hr';    // ← ADD THIS LINE
      case Modules.crm:  // ← ADD THIS LINE
        return 'crm';    // ← ADD THIS LINE
      case Modules.settings:
        return 'settings';
      default:
        return '';
    }
  }

  /// Checks if the current employee has a specific permission within a module
  bool hasSpecificPermission(Modules module, String permission) {
    if (!hasModuleAccess(module)) return false;

    String moduleName = _getModuleName(module).toLowerCase().trim();
    bool hasPermission = _modulePermissionsCache[moduleName]?[permission] ?? false;

   // // print("Checking permission $permission in module $moduleName: $hasPermission");
    return hasPermission;
  }

  /// Gets all permissions for a specific module
  Map<String, bool> getModulePermissions(Modules module) {
    String moduleName = _getModuleName(module).toLowerCase().trim();
    return Map<String, bool>.from(_modulePermissionsCache[moduleName] ?? {});
  }

  /// Async method to reload permissions for a specific module
  Future<bool> hasSpecificPermissionAsync(Modules module, String permission) async {
    if (!hasModuleAccess(module)) {
      // print("⚠️ Module ${module.name} not accessible");
      return false;
    }

    String roleId = currentEmployeeRole!.roleId;
    String moduleName = _getModuleName(module);

    // print("\n--- Checking Async Permission ---");
    // print("Module: $moduleName");
    // print("Permission: $permission");
    // print("Role ID: $roleId");

    // Check cache first
    if (_modulePermissionsCache.containsKey(moduleName)) {
      bool cachedValue = _modulePermissionsCache[moduleName]![permission] ?? false;
      // print("✓ Found in cache: $cachedValue");
      return cachedValue;
    }

    // print("Not in cache, loading from database...");

    // Load from database if not cached
    Either<FirebaseFailure, Map<String, dynamic>?> result =
    await roleRepository.getRolePermissions(
      roleId: roleId,
      module: moduleName,
    );

    if (result.isRight()) {
      Map<String, dynamic>? permissions = result.getOrElse(() => null);

      if (permissions != null) {
        // print("Loaded permissions: ${permissions.keys.toList()}");

        if (permissions.containsKey(permission)) {
          bool hasPermission = false;
          var value = permissions[permission];

          if (value is List && value.isNotEmpty) {
            hasPermission = value.last == true;
            // print("Permission value from array: ${value.last}");
          } else if (value is bool) {
            hasPermission = value;
            // print("Permission value direct: $value");
          }

          // Update cache
          _modulePermissionsCache[moduleName] ??= {};
          _modulePermissionsCache[moduleName]![permission] = hasPermission;

          // print("✓ Result: $hasPermission");
          return hasPermission;
        } else {
          // print("⚠️ Permission '$permission' not found in document");
        }
      } else {
        // print("⚠️ No permission data returned");
      }
    } else {
      // print("❌ Error loading permissions: ${result.fold((l) => l.errMessage, (r) => '')}");
    }

    return false;
  }

  /// UPDATED: Legacy method for backward compatibility - now uses new architecture
  /// This method is kept for existing code that still uses the old permission checking system
  bool isHasPermission({
    required Modules? module,
    required ModulePermissionsSectionsPermission? permission,
    required ModulePermissionsSections? section,
  }) {
    // // print("Legacy permission check - module: ${module?.name}, section: ${section?.getName}, permission: ${permission?.getDataBaseName}");
    //
    // // print("check Data grc - module: ${module?.name}, section: ${section?.getName}, permission: ${permission?.getDataBaseName}");
    if (module == null || section == null) return false;

    // For backward compatibility, we'll map the old permission system to the new one
    if (!hasModuleAccess(module)) return false;

    if (permission == null) {
      // When checking section-level permission (permission is null),
      // we need to check the section permission value in Firebase
      if (section is ModulePermissionsSectionsPermission) {
        ModulePermissionsSectionsPermission permissionInterface =
        section as ModulePermissionsSectionsPermission;

        String sectionPermissionName = permissionInterface.getDataBaseName;
       // // print("Checking section-level permission: $sectionPermissionName");

        bool hasSectionPermission = hasSpecificPermission(module, sectionPermissionName);
      //  // print("Section permission result: $hasSectionPermission");

        return hasSectionPermission;
      } else {
        // Fallback: section doesn't have permission data, just check module access
        // print("⚠️ Section doesn't implement ModulePermissionsSectionsPermission, returning true");
        return true;
      }
    }

    // Map the old permission to new permission name
    String permissionName = permission.getDataBaseName;
    return hasSpecificPermission(module, permissionName);
  }

  /// Checks if the current employee has admin access to a specific module
  bool hasAdminAccess(Modules module) {
    // In the new system, check for specific admin permissions
    return hasSpecificPermission(module, 'Admin_Access') || isSuperAdmin();
  }

  /// Gets the current role name for the logged-in employee
  String? getCurrentRoleName() {
    return currentEmployeeRole?.currentRoleName;
  }

  /// Gets the current role description for the logged-in employee
  String? getCurrentRoleDescription({bool isArabic = false}) {
    if (currentEmployeeRole == null) return null;

    return isArabic
        ? currentEmployeeRole!.currentRoleDescriptionAr
        : currentEmployeeRole!.currentRoleDescription;
  }

  /// Refreshes the employee's role permissions
  Future<void> refreshRolePermissions() async {
    await loadEmployeeRole();
    _publish();
  }

  /// Checks if current employee is super admin
  bool isSuperAdmin() {
    return employeeEntity?.role == 'super admin';
  }

  /// Gets all available modules for the current employee
  List<Modules> getAvailableModules() {
    List<Modules> availableModules = [];

    for (Modules module in Modules.values) {
      if (hasModuleAccess(module)) {
        availableModules.add(module);
      }
    }

    return availableModules;
  }

  /// Gets the list of selected module names for the current employee
  List<String> getSelectedModuleNames() {
    return currentEmployeeRole?.currentSelectedModules ?? [];
  }

  /// Checks if a specific module name is selected for the current employee
  bool isModuleSelected(String moduleName) {
    return currentEmployeeRole?.currentSelectedModules.contains(moduleName) ?? false;
  }

  /// Clears the permission cache (useful when role changes)
  void clearPermissionCache() {
    _modulePermissionsCache.clear();
  }

  /// Gets cached permissions count for debugging
  Map<String, int> getPermissionCacheStatus() {
    Map<String, int> status = {};
    _modulePermissionsCache.forEach((module, permissions) {
      status[module] = permissions.length;
    });
    return status;
  }

  /// Force reload all permissions from database
  Future<void> forceReloadPermissions() async {
    clearPermissionCache();
    await loadEmployeeRole();
    _publish();
  }

  /// Batch check multiple permissions for better performance
  Future<Map<String, bool>> checkMultiplePermissions(
      Modules module,
      List<String> permissions,
      ) async
  {
    Map<String, bool> results = {};

    if (!hasModuleAccess(module)) {
      // print("⚠️ Module ${module.name} not accessible");
      for (String permission in permissions) {
        results[permission] = false;
      }
      return results;
    }

    String roleId = currentEmployeeRole!.roleId;
    String moduleName = _getModuleName(module);

    // print("\n=== Batch Permission Check ===");
    // print("Module: $moduleName");
    // print("Permissions: $permissions");
    // print("Role ID: $roleId");

    // Check if permissions are cached
    if (_modulePermissionsCache.containsKey(moduleName)) {
      // print("Using cached permissions");
      for (String permission in permissions) {
        results[permission] = _modulePermissionsCache[moduleName]![permission] ?? false;
      }
      // print("Results: $results");
      return results;
    }

    // print("Loading from database...");

    // Load from database if not cached
    Either<FirebaseFailure, Map<String, dynamic>?> result =
    await roleRepository.getRolePermissions(
      roleId: roleId,
      module: moduleName,
    );

    if (result.isRight()) {
      Map<String, dynamic>? modulePermissions = result.getOrElse(() => null);

      if (modulePermissions != null) {
        // print("Loaded module permissions");

        // Update cache
        _modulePermissionsCache[moduleName] = {};

        for (String permission in permissions) {
          if (modulePermissions.containsKey(permission)) {
            bool hasPermission = false;
            var value = modulePermissions[permission];

            if (value is List && value.isNotEmpty) {
              hasPermission = value.last == true;
            } else if (value is bool) {
              hasPermission = value;
            }

            results[permission] = hasPermission;
            _modulePermissionsCache[moduleName]![permission] = hasPermission;
            // print("  $permission: $hasPermission");
          } else {
            results[permission] = false;
            // print("  $permission: false (not found)");
          }
        }
      }
    } else {
      // print("❌ Error loading permissions");
    }

    return results;
  }


  Map<Modules,Map<ModulePermissionsSections, Set<ModulePermissionsSectionsPermission>> >  activeSwitches = {};

  Set<Modules> adminAccessModules = {};
  Map<Modules, Set<ModulePermissionsSections>> moduleSectionsHasFullAccess = {};
  void getActiveSwitches() {
    activeSwitches[Modules.services] = {};
    moduleSectionsHasFullAccess[Modules.services] = {};
    for (
    int sectionIndex = 0;
    sectionIndex < ServicePermissionsSections.values.length;
    sectionIndex++
    ) {
      moduleSectionsHasFullAccess[Modules.services]!.add(
        ServicePermissionsSections.values[sectionIndex],
      );
      for (
      int permissionIndex = 0;
      permissionIndex <
          ServicePermissionsSections
              .values[sectionIndex]
              .sectionPermissions
              .length;
      permissionIndex++
      ) {
        activeSwitches[Modules.services]!.putIfAbsent(
          ServicePermissionsSections.values[sectionIndex],
              () => {},
        );
        activeSwitches[Modules.services]![ServicePermissionsSections
            .values[sectionIndex]]!
            .add(
          ServicePermissionsSections
              .values[sectionIndex]
              .sectionPermissions[permissionIndex]
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

abstract class Constant {
  static String? emailUser;
  static String? departmentId;
  static String? roleName;
  static String? idUser;
}
