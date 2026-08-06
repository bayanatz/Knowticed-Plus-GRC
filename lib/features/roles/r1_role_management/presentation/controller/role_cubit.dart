import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';

import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
import 'dart:ui' as ui;
part './role_state.dart';

/// App-wide shared RoleCubit instance.
///
/// Moved here from role_responsive_page.dart so the many non-UI callers
/// (login, drawer, nav bar, active directory, system logs, user management…)
/// depend on the controller library instead of a UI page. Top-level variables
/// are lazily initialised in Dart, so this is only constructed on first use.
RoleCubit roleCubit = RoleCubit();

class RoleCubit extends Cubit<RoleState> {
  RoleCubit() : super(RoleInitial()) {
    //print("RoleCubit initialized");
  }

  Map<String, Map<String, bool>> modulePermissions = {};
  bool isActive = true;
  /// Cache for role permissions to avoid reloading
  final Map<String, Map<String, List<String>>> _rolePermissionsCache = {};

  void toggleActiveStatus(bool value) {
    isActive = value;
    emit(RoleModuleSelected());
  }

  RoleRepository roleRepository = RoleRepository();
  File? roleImage;
  TextEditingController roleNameController = TextEditingController();
  TextEditingController roleNameControllerAr = TextEditingController();
  TextEditingController roleDescriptionController = TextEditingController();
  TextEditingController roleDescriptionControllerAr = TextEditingController();

  List<String> selectedModules = [];

  RoleStatus selectedRoleStatus = RoleStatus.all;
  List<RoleHistoryModel> roles = [];
  List<RoleHistoryModel> filteredRoles = [];
  RoleHistoryModel? selectedRole;
  TextEditingController searchController = TextEditingController();
  ModulesCubit modulesCubit = ModulesCubit();
  bool isEditing = false;

  final List<String> availableModules = [
    'services',
    'services_app',
    'messages',
    'inventory',
    'settings',
    'qiyas',
    'knowledge_hub',
    'employees',
    'tasks',
    'events',
    'notes',
    'requests',
    'tracking',
    'database_builder',
    'roles',
    'hr',           // ✅ ADDED
    'crm',          // ✅ ADDED
    'notification', // ✅ ADDED
  ];

  Map<String, Map<String, bool>> _adminRestrictions = {};

  String _getCompanyId() {
    try {
      String baseUrl = getBaseUrl('');
      String companyId = baseUrl
          .replaceAll('Demo/', '')
          .replaceAll('/', '')
          .trim();

      //print("🔍 _getCompanyId() extracted: '$companyId' from baseUrl: '$baseUrl'");

      return companyId.isNotEmpty ? companyId : '';
    } catch (e) {
      //print("❌ Error getting company ID: $e");
      return '';
    }
  }

  Future<void> getUnDeletedRoles() async {
    emit(RoleLoading()); // Show loading state

    Either<FirebaseFailure, dynamic> result =
    await roleRepository.getUnDeletedRoles();

    if (result.isLeft()) {
      emit(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
      return;
    }

    roles = result.getOrElse(() => []);
    searchController.clear();
    filterRoles(); // This filters but doesn't emit yet

    await _loadAdminRestrictions();

    // ✅ Preload ALL permissions before showing roles
    await preloadAllRolePermissions();

    // ✅ NOW emit fetched after everything is ready
    emit(RoleFetched());
  }

  /// Preload permissions for all filtered roles
  Future<void> preloadAllRolePermissions() async {
    if (filteredRoles.isEmpty) {
      //print("⚠️ No roles to preload");
      return;
    }

    //print("\n=== Preloading permissions for ${filteredRoles.length} roles ===");

    await Future.wait(
        filteredRoles.map((role) => _preloadRolePermissions(role))
    );

    //print("✓ All role permissions preloaded (${_rolePermissionsCache.length} cached)\n");
  }

  Future<void> _preloadRolePermissions(RoleHistoryModel role) async {
    if (_rolePermissionsCache.containsKey(role.roleId)) {
      return;
    }

    final activeModuleStrings = modulesCubit.getRoleActiveModules(role);

    if (activeModuleStrings.isEmpty) {
      _rolePermissionsCache[role.roleId] = {};
      return;
    }

    try {
      var result = await roleRepository.getAllRolePermissions(
        roleId: role.roleId,
        selectedModules: activeModuleStrings,
      );

      if (result.isRight()) {
        Map<String, Map<String, dynamic>> allPermissions = result.getOrElse(() => {});
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
                  isActive = (lastValue == true || lastValue == 1 || lastValue == '1');
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
        //print("✓ Cached ${rolePermissions.length} modules for: ${role.currentRoleName}");
      } else {
        _rolePermissionsCache[role.roleId] = {};
      }
    } catch (e) {
      //print("❌ Exception loading role ${role.roleId}: $e");
      _rolePermissionsCache[role.roleId] = {};
    }
  }

  Map<String, List<String>>? getRolePermissions(String roleId) {
    return _rolePermissionsCache[roleId];
  }

  void clearPermissionsCache() {
    if (_rolePermissionsCache.isNotEmpty) {
      //print("🗑️ Clearing permissions cache (${_rolePermissionsCache.length} entries)");
      _rolePermissionsCache.clear();
    }
  }

  String _formatPermissionNameForDisplay(String permissionKey) {
    return permissionKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  Future<void> _loadAdminRestrictions() async {
    //print("\n🔒 Loading admin restrictions from Demo_Permissions...");

    try {
      String companyId = _getCompanyId();
      //print("   Company ID: $companyId");

      for (String moduleName in availableModules) {
        //print("   Loading restrictions for: $moduleName");

        Either<FirebaseFailure, Map<String, bool>> result =
        await roleRepository.getAdminRestrictionsForModule(
          companyId: companyId,
          moduleName: moduleName,
        );

        if (result.isRight()) {
          Map<String, bool> restrictions = result.getOrElse(() => {});

          if (restrictions.isNotEmpty) {
            _adminRestrictions[moduleName] = restrictions;
            //print("   ✅ Loaded restrictions for $moduleName: ${restrictions.length} permissions");
          }
        } else {
          //print("   ⚠️ Failed to load restrictions for $moduleName: ${result.fold((l) => l.errMessage, (r) => '')}");
        }
      }

      //print("✅ Admin restrictions loaded for ${_adminRestrictions.length} modules");
    } catch (e) {
      //print("❌ Error loading admin restrictions: $e");
    }
  }

  bool isPermissionAllowedByAdmin(String moduleName, String permissionKey) {
    if (!_adminRestrictions.containsKey(moduleName)) {
      return true;
    }

    Map<String, bool> moduleRestrictions = _adminRestrictions[moduleName]!;

    if (!moduleRestrictions.containsKey(permissionKey)) {
      return true;
    }

    return moduleRestrictions[permissionKey] == true;
  }

  List<String> getBlockedPermissionsForModule(String moduleName) {
    if (!_adminRestrictions.containsKey(moduleName)) {
      return [];
    }

    Map<String, bool> moduleRestrictions = _adminRestrictions[moduleName]!;

    return moduleRestrictions.entries
        .where((entry) => entry.value == false)
        .map((entry) => entry.key)
        .toList();
  }

  Future<void> _loadAllModulePermissions(RoleHistoryModel role) async {
    modulePermissions.clear();

    String roleId = role.roleId;
    List<String> modulesToLoad = role.currentSelectedModules;

    //print("\n🔍 ════════════════════════════════════════");
    //print("🔍 _loadAllModulePermissions called");
    //print("🔍 ════════════════════════════════════════");
    //print("   Role ID: $roleId");
    //print("   Role name: ${role.currentRoleName}");
    //print("   Modules to load: $modulesToLoad");

    String? currentUserEmail;
    try {
      currentUserEmail = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    } catch (e) {
      //print("   ❌ ERROR: Could not get MainCoreEmployeeController: $e");
    }

    if (currentUserEmail == null || currentUserEmail.isEmpty) {
      //print("   ❌ ERROR: Current user email not found!");
      //print("   Loading default permissions for all modules...");

      for (String moduleName in modulesToLoad) {
        modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
      }
      //print("🔍 ════════════════════════════════════════\n");
      return;
    }

    //print("   📧 Current User Email: $currentUserEmail");

    bool isCurrentUserAdmin = roleRepository.isCompanyAdminByEmail(currentUserEmail);

    //print("   ════════════════════════════════════════");
    if (isCurrentUserAdmin) {
      //print("   🎯 ADMIN STATUS: ✅ IS ADMIN");
      //print("   📁 Loading from: Subscription_Permission_Admin");
      //print("   📍 Path: Demo/{companyId}/Subscription_Permission_Admin/$roleId");
    } else {
      //print("   🎯 ADMIN STATUS: ❌ NOT ADMIN (Regular Employee)");
      //print("   📁 Loading from: Module Permission Collections");
      //print("   📍 Path: Demo/{companyId}/roles_module_permissions/$roleId");
      //print("   📍 Path: Demo/{companyId}/services_module_permissions/$roleId");
    }
    //print("   ════════════════════════════════════════");

    if (isCurrentUserAdmin) {
      Either<FirebaseFailure, Map<String, Map<String, bool>>> adminResult =
      await roleRepository.getAdminPermissions(roleId);

      if (adminResult.isRight()) {
        Map<String, Map<String, bool>> adminPermissions =
        adminResult.getOrElse(() => {});

        //print("   ✅ Found admin permissions for ${adminPermissions.length} modules");

        modulePermissions = adminPermissions;

        modulePermissions.forEach((module, perms) {
          int enabledCount = perms.values.where((v) => v == true).length;
          int totalCount = perms.length;
          //print("   ✅ Module '$module': $enabledCount/$totalCount enabled");
        });
      } else {
        //print("   ❌ Error loading admin permissions");
        //print("   Creating default permissions as fallback...");

        for (String moduleName in modulesToLoad) {
          modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
        }
      }
    } else {
      Either<FirebaseFailure, Map<String, Map<String, dynamic>>> result =
      await roleRepository.getAllRolePermissions(
        roleId: roleId,
        selectedModules: modulesToLoad,
      );

      if (result.isRight()) {
        Map<String, Map<String, dynamic>> allPermissions = result.getOrElse(() => {});

        //print("   ✅ Found permissions for ${allPermissions.length} modules in Firestore");

        for (String moduleName in modulesToLoad) {
          //print("\n   === Processing module: $moduleName ===");

          if (allPermissions.containsKey(moduleName)) {
            Map<String, dynamic> moduleData = allPermissions[moduleName]!;

            //print("      Loading allowed switches from admin restrictions...");
            Map<String, bool> allowedSwitches = await _getDefaultPermissionsForModule(moduleName);
            //print("      Allowed switches count: ${allowedSwitches.length}");

            modulePermissions[moduleName] = {};

            int allowedCount = 0;
            int blockedCount = 0;

            moduleData.forEach((key, value) {
              if (key != 'Role_Id' && key != 'timestamps') {
                if (isPermissionAllowedByAdmin(moduleName, key)) {
                  if (value is List && value.isNotEmpty) {
                    var lastValue = value.last;
                    bool boolValue = false;

                    if (lastValue is bool) {
                      boolValue = lastValue;
                    } else if (lastValue == true || lastValue == 'true' || lastValue == 1) {
                      boolValue = true;
                    }

                    modulePermissions[moduleName]![key] = boolValue;
                    allowedCount++;
                  } else if (value is bool) {
                    modulePermissions[moduleName]![key] = value;
                    allowedCount++;
                  }
                } else {
                  blockedCount++;
                  //print("      ⚠️ Skipping $key (blocked by admin)");
                }
              }
            });

            //print("      ✅ Loaded $allowedCount allowed permissions");
            //print("      ❌ Blocked $blockedCount permissions (by admin)");
            //print("      Total stored: ${modulePermissions[moduleName]!.length}");
          } else {
            //print("      ⚠️ Module not found in Firestore");
            //print("      Creating filtered default permissions...");
            modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
            //print("      Created ${modulePermissions[moduleName]?.length ?? 0} default permissions");
          }
        }
      } else {
        //print("   ❌ Error loading permissions: ${result.fold((l) => l.errMessage, (r) => '')}");
        //print("   Creating filtered default permissions for all modules...");

        for (String moduleName in modulesToLoad) {
          modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
          //print("      Created ${modulePermissions[moduleName]?.length ?? 0} permissions for $moduleName");
        }
      }
    }

    //print("\n   ✅ Total permissions loaded for ${modulePermissions.length} modules");
    //print("🔍 ════════════════════════════════════════\n");
  }

  Future<void> ensureSettingsSelected() async {
    //print("\n🔍 ensureSettingsSelected called");
    if (!selectedModules.contains('settings')) {
      //print("   Settings not in selectedModules, adding it...");
      selectedModules.add('settings');
      if (!modulePermissions.containsKey('settings')) {
        //print("   Loading filtered permissions for settings...");
        modulePermissions['settings'] = await _getDefaultPermissionsForModule('settings');
        //print("   Loaded ${modulePermissions['settings']?.length ?? 0} permissions for settings");
      }
      //print('✅ Auto-added Settings module to selectedModules');
      emit(RoleModuleSelected());
    } else {
      //print("   Settings already in selectedModules");
    }
  }

  Future<void> fixQiyasPermissions(String roleId) async {
    //print("\n🔧 Fixing qiyas permissions for role: $roleId");

    var result = await roleRepository.fixCorruptedQiyasDocument(roleId);

    result.fold(
          (failure) {
        //print("❌ Failed to fix qiyas document: ${failure.errMessage}");
        emit(RoleError(failure.errMessage));
      },
          (success) {
        //print("✅ $success");
        //print("✅ Reloading role...");
        getUnDeletedRoles();
        if (selectedRole != null) {
          var updatedRole = roles.firstWhere((r) => r.roleId == roleId);
          selectRole(updatedRole);
        }
        emit(RolePermissionUpdated());
      },
    );
  }

  Future<void> initAddingRoleController() async {
    //print("\n🔍 initAddingRoleController called");
    isEditing = false;
    isActive = true;
    roleImage = null;
    roleNameController.clear();
    roleNameControllerAr.clear();

    roleDescriptionController.clear();
    roleDescriptionControllerAr.clear();
    selectedModules = [];
    modulePermissions = {};

    //print("   Calling ensureSettingsSelected...");
    await ensureSettingsSelected();
    //print("   initAddingRoleController complete\n");
  }

  Future<void> addNewRole() async {
    //print("\n🔍 ========================================");
    //print("🔍 addNewRole() DEBUG");
    //print("🔍 ========================================");
    //print("   isEditing: $isEditing");
    //print("   selectedRole: ${selectedRole?.currentRoleName ?? 'null'}");
    //print("   selectedRole ID: ${selectedRole?.roleId ?? 'null'}");
    //print("   Role name: ${roleNameController.text}");
    //print("   Selected modules: $selectedModules");
    //print("🔍 ========================================\n");

    //print("\n🔍 addNewRole called");
    //print("   Selected modules: $selectedModules");
    //print("   Module permissions keys: ${modulePermissions.keys.toList()}");

    //print("\n🔒 Validating permissions against admin restrictions...");
    bool hasViolations = false;
    List<String> violations = [];

    for (String moduleName in selectedModules) {
      if (modulePermissions.containsKey(moduleName)) {
        Map<String, bool> modulePerms = modulePermissions[moduleName]!;

        modulePerms.forEach((permKey, permValue) {
          if (permValue == true && !isPermissionAllowedByAdmin(moduleName, permKey)) {
            hasViolations = true;
            violations.add("$moduleName.$permKey");
          }
        });
      }
    }

    if (hasViolations) {
      //print("❌ Permission violations detected:");
      for (String violation in violations) {
        //print("   - $violation is blocked by administrator");
      }

      emit(RoleError(
          "Cannot create role: The following permissions are restricted by administrator:\n${violations.join('\n')}"
      ));
      return;
    }

    //print("✅ No permission violations");

    Either<Failure, dynamic> result = await roleRepository.addNewRole(
      selectedModules: selectedModules,
      roleName: roleNameController.text,
      roleNameAr: roleNameControllerAr.text,
      status: isActive ? RoleStatus.active : RoleStatus.inactive,
      roleDescription: roleDescriptionController.text,
      roleDescriptionAr: roleDescriptionControllerAr.text,
      createdBy: Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
      roleImage: roleImage?.path,
      modulePermissions: modulePermissions,
    );

    if (result.isRight()) {
      //print("✅ Role added successfully");

      // CLEAR SEARCH TEXT HERE
      searchController.clear();

      await initAddingRoleController();
      await getUnDeletedRoles();
      emit(RoleAdded());
    } else {
      //print("❌ Failed to add role: ${result.fold((l) => l.errMessage, (r) => 'Unknown error')}");
      emit(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
    }
  }

  Future<Map<String, bool>> _getDefaultPermissionsForModule(String moduleName) async {
    //print("\n🔍 _getDefaultPermissionsForModule called for: $moduleName");

    Map<String, bool> permissions = await modulesCubit.getFilteredDefaultPermissionsForModule(moduleName);

    //print("✅ Got ${permissions.length} FILTERED permissions for $moduleName");
    //print("   Permission keys: ${permissions.keys.toList()}\n");

    return permissions;
  }

  Future<void> selectModule(String moduleName) async {
    //print("\n🔍 ========================================");
    //print("🔍 selectModule called for: $moduleName");
    //print("🔍 ========================================");

    if (moduleName == 'settings') {
      //print("   Module is settings");
      if (!selectedModules.contains(moduleName)) {
        //print("   Settings not selected, adding it...");
        selectedModules.add(moduleName);
        //print("   Loading filtered permissions for settings...");
        modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
        //print("   Loaded ${modulePermissions[moduleName]?.length ?? 0} permissions");
        emit(RoleModuleSelected());
      } else {
        //print("   Settings already selected - no action needed");
      }
      return;
    }

    if (selectedModules.contains(moduleName)) {
      //print("   Module is currently selected - REMOVING");
      //print("   Before: selectedModules = $selectedModules");
      selectedModules.remove(moduleName);
      modulePermissions.remove(moduleName);
      //print("   After: selectedModules = $selectedModules");
      //print("   Removed permissions for $moduleName");
    } else {
      //print("   Module is NOT selected - ADDING");
      //print("   Before: selectedModules = $selectedModules");
      selectedModules.add(moduleName);
      //print("   After: selectedModules = $selectedModules");
      //print("   Loading filtered permissions for $moduleName...");

      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);

      //print("   ✅ Loaded ${modulePermissions[moduleName]?.length ?? 0} permissions");
      if (modulePermissions[moduleName] != null && modulePermissions[moduleName]!.isNotEmpty) {
        //print("   📋 First 5 permission keys: ${modulePermissions[moduleName]!.keys.take(5).toList()}");
      }
    }

    //print("   Calling ensureSettingsSelected...");
    await ensureSettingsSelected();

    //print("   Final selectedModules: $selectedModules");
    //print("   Final modulePermissions keys: ${modulePermissions.keys.toList()}");
    //print("🔍 ======================================== \n");

    emit(RoleModuleSelected());
  }

  void updateModulePermission(String moduleName, String permission, bool value) {
    //print("\n🔧 updateModulePermission called");
    //print("   Module: $moduleName");
    //print("   Permission: $permission");
    //print("   Requested value: $value");

    if (!modulePermissions.containsKey(moduleName)) {
      //print("   ❌ Module not found in permissions");
      return;
    }

    if (value == true && !isPermissionAllowedByAdmin(moduleName, permission)) {
      //print("   ❌ Permission blocked by administrator");
      emit(RoleError(
          "Cannot enable '$permission' in module '$moduleName': This permission is restricted by the administrator."
      ));
      return;
    }

    modulePermissions[moduleName]![permission] = value;
    //print("   ✅ Permission updated");
    emit(RolePermissionUpdated());
  }



// Add this at the top of your RoleCubit class

  pickRoleImage({required bool camera}) async {
    try {

      final ImagePicker picker = ImagePicker();

      final result = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );


      if (result == null) {
        return;
      }


      // Check file size
      try {
        final bytes = await result.readAsBytes();

        // Check file extension
        final extension = result.path.split('.').last.toLowerCase();

        // Validate image format
        final validFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'];
        if (!validFormats.contains(extension)) {
          emit(RoleError("Invalid format. Please use JPG, PNG, or WEBP"));
          return;
        }

        // Create File object
        final file = File(result.path);

        // Check if file exists
        final exists = await file.exists();

        if (!exists) {
          emit(RoleError("Image file not found"));
          return;
        }

        // Try to decode image to verify it's valid
        try {
          final ui.Codec codec = await ui.instantiateImageCodec(bytes);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ui.Image decodedImage = frameInfo.image;


          decodedImage.dispose();
          codec.dispose();
        } catch (decodeError, decodeStack) {
          emit(RoleError("Invalid or corrupted image file"));
          return;
        }

        // File size check (optional: limit to 10MB)
        if (bytes.length > 10 * 1024 * 1024) {
          emit(RoleError("Image too large. Please use an image under 10MB"));
          return;
        }

        // Update the role image
        roleImage = file;

        emit(RoleImagePicked());

      } catch (readError, readStack) {
        emit(RoleError("Failed to read image data"));
        return;
      }

    } catch (e, stackTrace) {

      emit(RoleError("Failed to load image: $e"));
    }
  }

  updateSelectedRoleStatus(RoleStatus roleStatus) {
    selectedRoleStatus = roleStatus;
    filterRoles();
  }

  void filterRoles() {
    // REMOVE emit(RoleLoading()) from here if roles are already loaded

    filteredRoles = [];
    String searchText = searchController.text.toLowerCase().trim();

    for (var role in roles) {
      bool matchesStatus = (role.currentStatus == selectedRoleStatus ||
          selectedRoleStatus == RoleStatus.all);

      bool matchesSearch = searchText.isEmpty ||
          role.currentRoleName.toLowerCase().contains(searchText) ||
          role.currentRoleNameAr.contains(searchController.text.trim());

      if (matchesStatus && matchesSearch) {
        filteredRoles.add(role);
      }
    }

    emit(RoleFiltered());
  }

  void clearFilters() {
    //print('🗑️ Clearing all filters');
    searchController.clear();
    selectedRoleStatus = RoleStatus.all;
    filterRoles();
  }

  Future<void> selectRole(RoleHistoryModel role) async {
    selectedRole = role;

    selectedModules = List<String>.from(role.currentSelectedModules);

    roleNameController.text = role.currentRoleName;
    roleNameControllerAr.text = role.currentRoleNameAr;
    roleDescriptionController.text = role.currentRoleDescription;
    roleDescriptionControllerAr.text = role.currentRoleDescriptionAr;

    roleImage = null;

    isEditing = (role.currentStatus != RoleStatus.draft);
    isActive = role.currentStatus == RoleStatus.active;

    await ensureSettingsSelected();

    await _loadAllModulePermissions(role);

    emit(RoleSelected());
  }

  String moduleEnumToString(Modules module) {
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
      case Modules.settings:
        return 'settings';
      case Modules.hr:  // ✅ ADDED
        return 'hr';
      case Modules.crm:  // ✅ ADDED
        return 'crm';
      case Modules.notification:  // ✅ ADDED
        return 'notification';
      default:
        return 'employees';
    }
  }

  String _moduleEnumToString(Modules module) {
    return moduleEnumToString(module);
  }

  // ───────────────────────────────────────────────────────────────────────
  // ROLE CREATION LOGIC
  //
  // Moved here from adding_new_role_methods1.dart so the "Add new role" page
  // only builds widgets. Covers text-direction detection, company licence
  // lookup (Firestore) and the module name <-> enum mapping used while
  // picking modules for a new role.
  // ───────────────────────────────────────────────────────────────────────

  /// True when [text] contains any Arabic character.
  bool containsArabic(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  /// True when [text] contains any Latin character.
  bool containsEnglish(String text) => RegExp(r'[a-zA-Z]').hasMatch(text);

  /// Company id parsed out of [ApiConstants.baseUri] (format: "Demo/<id>").
  String? extractCompanyId() {
    if (ApiConstants.baseUri.isEmpty) return null;
    if (ApiConstants.baseUri.contains('/')) {
      final List<String> parts = ApiConstants.baseUri.split('/');
      if (parts.length >= 2) return parts[1];
    }
    return null;
  }

  /// Modules the current company is licensed for, keyed by lowercase name.
  ///
  /// Falls back to "everything enabled" when no company id is resolvable, which
  /// preserves the previous behaviour for local/demo sessions.
  Future<Map<String, bool>> loadCompanyLicensedModules() async {
    try {
      final String? companyId = extractCompanyId();

      if (companyId == null || companyId.isEmpty) {
        return {
          'services': true, 'tasks': true, 'tracking': true,
          'inventory': true, 'messages': true, 'roles': true,
          'knowledge_hub': true, 'knowledgehub': true, 'qiyas': true,
          'grc': true, 'services_app': true, 'formbuilder': true,
          'todo': true, 'employees': true, 'events': true,
          'notes': true, 'requests': true, 'database': true,
          'notification': true, 'hr': true, 'crm': true, 'database_builder': true,
        };
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('Demo_Requests')
          .doc(companyId)
          .get();

      if (!snapshot.exists) return {};

      final data = snapshot.data();
      if (data == null) return {};

      Map? modulesData;
      if (data['Demo_Details'] is Map &&
          (data['Demo_Details'] as Map)['Modules'] is Map) {
        modulesData = (data['Demo_Details'] as Map)['Modules'] as Map;
      } else if (data['Modules'] is Map) {
        modulesData = data['Modules'] as Map;
      }

      if (modulesData == null) return {};

      final Map<String, bool> licensedModules = {};
      for (final entry in modulesData.entries) {
        final moduleName = entry.key.toString().toLowerCase();
        final moduleData = entry.value;
        bool isLicensed = false;

        if (moduleData is Map) {
          final values = moduleData['Values'];
          if (values is List && values.isNotEmpty) {
            isLicensed = values.last == true;
          }
        } else if (moduleData is bool) {
          isLicensed = moduleData;
        } else if (moduleData is List && moduleData.isNotEmpty) {
          isLicensed = moduleData.last == true;
        }

        licensedModules[moduleName] = isLicensed;
      }

      return licensedModules;
    } catch (e) {
      return {};
    }
  }

  /// Module names selectable when creating a role.
  Future<List<String>> getAllowedModulesForRoleCreation() async {
    try {
      final ModulesCubit modulesCubit = Get.find<ModulesCubit>();
      final List<String> masterAdminModules =
          modulesCubit.getDemoActiveModules();
      masterAdminModules.removeWhere((m) => m == 'home' || m == 'settings');

      final Map<String, bool> companyLicensedModules =
          await loadCompanyLicensedModules();

      final List<String> allowedModules = [];
      for (final entry in companyLicensedModules.entries) {
        if (entry.value) allowedModules.add(entry.key);
      }
      return allowedModules;
    } catch (e) {
      return [];
    }
  }

  /// Maps a stored module name to its [Modules] enum.
  ///
  /// Throws for unknown names so callers can skip modules they don't render.
  /// Paired with [moduleEnumToSelectionString] — use the two together so the
  /// name -> enum -> name round trip stays consistent. Note this is
  /// deliberately NOT the inverse of [moduleEnumToString], which serialises
  /// `database` as `database_builder` for the permissions payload.
  Modules stringToModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'services': return Modules.services;
      case 'employees': return Modules.employees;
      case 'tasks': return Modules.tasks;
      case 'todo': return Modules.todo;
      case 'notes': return Modules.notes;
      case 'events': return Modules.events;
      case 'requests': return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub': return Modules.knowledgeHub;
      case 'qiyas': return Modules.qiyas;
      case 'inventory': return Modules.inventory;
      case 'tracking': return Modules.tracking;
      case 'grc': return Modules.grc;
      case 'database': return Modules.database;
      case 'messages': return Modules.messages;
      case 'services_app':
      case 'formbuilder': return Modules.formBuilder;
      case 'roles': return Modules.roles;
      case 'settings': return Modules.settings;
      case 'notification': return Modules.notification;
      case 'crm': return Modules.crm;
      case 'hr': return Modules.hr;  // ✅ ADDED — was missing, so 'hr' threw and
      // the module grid in adding_new_role.dart silently skipped it.
      default: throw Exception("Unknown module: $moduleName");
    }
  }

  /// Inverse of [stringToModuleEnum], used to test membership of
  /// [selectedModules] while the user picks modules for a new role.
  String moduleEnumToSelectionString(Modules module) {
    switch (module) {
      case Modules.services: return 'services';
      case Modules.employees: return 'employees';
      case Modules.tasks: return 'tasks';
      case Modules.todo: return 'todo';
      case Modules.notes: return 'notes';
      case Modules.events: return 'events';
      case Modules.requests: return 'requests';
      case Modules.knowledgeHub: return 'knowledge_hub';
      case Modules.qiyas: return 'qiyas';
      case Modules.inventory: return 'inventory';
      case Modules.messages: return 'messages';
      case Modules.database: return 'database';
      case Modules.formBuilder: return 'services_app';
      case Modules.grc: return 'grc';
      case Modules.tracking: return 'tracking';
      case Modules.notification: return 'notification';
      case Modules.hr: return 'hr';
      case Modules.crm: return 'crm';
      case Modules.roles: return 'roles';
      case Modules.settings: return 'settings';
      default: return 'settings';
    }
  }

  updateRole() async {
    if (selectedRole == null) return;

    bool hasViolations = false;
    List<String> violations = [];

    for (String moduleName in selectedModules) {
      if (modulePermissions.containsKey(moduleName)) {
        Map<String, bool> modulePerms = modulePermissions[moduleName]!;

        modulePerms.forEach((permKey, permValue) {
          if (permValue == true && !isPermissionAllowedByAdmin(moduleName, permKey)) {
            hasViolations = true;
            violations.add("$moduleName.$permKey");
          }
        });
      }
    }

    if (hasViolations) {
      emit(RoleError(
          "Cannot update role: The following permissions are restricted by administrator:\n${violations.join('\n')}"
      ));
      return;
    }

    Either<Failure, dynamic> result = await roleRepository.updateRole(
      role: selectedRole!,
      status: isActive ? RoleStatus.active : RoleStatus.inactive,
      currentUserEmail: Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
      roleDescription: roleDescriptionController.text,
      roleDescriptionAr: roleDescriptionControllerAr.text,
      roleNameAr: roleNameControllerAr.text,
      roleImage: roleImage?.path,

      selectedModules: selectedModules,
      modulePermissions: modulePermissions,
    );

    if (result.isRight()) {
      searchController.clear();

      // ✅ FIX: Invalidate this role's cache so preload fetches fresh data
      _rolePermissionsCache.remove(selectedRole!.roleId);

      await getUnDeletedRoles();
      emit(RoleUpdated());
    } else {
      emit(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
    }
  }

  deleteRole() async {
    if (selectedRole == null) {
      emit(RoleError('No role selected'));
      return;
    }

    //print("\n🔍 === Deleting Role ===");
    //print("   Role ID: ${selectedRole!.roleId}");
    //print("   Role Name: ${selectedRole!.currentRoleName}");

    Either<FirebaseFailure, dynamic> result = await roleRepository.deleteRole(
      role: selectedRole!,
      currentUserEmail: Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
    );

    if (result.isRight()) {
      //print("✅ Role deleted successfully\n");

      // CLEAR SEARCH TEXT HERE
      searchController.clear();
      _rolePermissionsCache.remove(selectedRole!.roleId);
      await getUnDeletedRoles();
      emit(RoleDeleted());
    } else {
      String errorMessage = result.fold((l) => l.errMessage, (r) => 'Unknown error');
      //print("❌ Error deleting role: $errorMessage\n");
      emit(RoleError(errorMessage));
    }
  }

  Future<void> saveDraft() async {
    //print("\n🔍 Saving role as draft");

    if (selectedRole != null && selectedRole!.currentStatus == RoleStatus.draft) {
      //print("   Updating existing draft: ${selectedRole!.roleId}");

      Either<Failure, dynamic> result = await roleRepository.updateRole(
        role: selectedRole!,
        currentUserEmail: Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
        roleDescription: roleDescriptionController.text,
        roleDescriptionAr: roleDescriptionControllerAr.text,
        roleNameAr: roleNameControllerAr.text,
        roleImage: roleImage?.path,
        selectedModules: selectedModules,
        modulePermissions: modulePermissions,
      );

      if (result.isRight()) {
        //print("✅ Draft updated successfully\n");

        // CLEAR SEARCH TEXT HERE
        searchController.clear();

        await getUnDeletedRoles();
        emit(RoleDraftSaved());
      } else {
        //print("❌ Error updating draft: ${result.fold((l) => l.errMessage, (r) => 'Unknown error')}\n");
        emit(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
      }
    } else {
      //print("   Creating new draft");

      Either<Failure, dynamic> result = await roleRepository.addNewRole(
        selectedModules: selectedModules,
        roleName: roleNameController.text,
        roleNameAr: roleNameControllerAr.text,
        roleDescription: roleDescriptionController.text,
        roleDescriptionAr: roleDescriptionControllerAr.text,
        createdBy: Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
        roleImage: roleImage?.path,
        modulePermissions: modulePermissions,
        status: RoleStatus.draft,
      );

      if (result.isRight()) {
        //print("✅ New draft created successfully\n");

        // CLEAR SEARCH TEXT HERE
        searchController.clear();

        await initAddingRoleController();
        await getUnDeletedRoles();
        emit(RoleDraftSaved());
      } else {
        //print("❌ Error creating draft: ${result.fold((l) => l.errMessage, (r) => 'Unknown error')}\n");
        emit(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
      }
    }
  }

  bool isAdminAccessActive(Modules module) {
    return adminAccessModules.contains(module);
  }

  void toggleAdminAccess({required Modules module}) {
    if (adminAccessModules.contains(module)) {
      adminAccessModules.remove(module);
    } else {
      adminAccessModules.add(module);
    }
    emit(RoleSwitchToggled());
  }

  bool isSectionActive(Modules module, ModulePermissionsSections section) {
    String moduleName = moduleEnumToString(module);

    if (!modulePermissions.containsKey(moduleName)) {
      return false;
    }

    if (section is ModulePermissionsSectionsPermission) {
      String sectionKey = _convertToDbFormat((section as ModulePermissionsSectionsPermission).getDataBaseName);
      return modulePermissions[moduleName]?[sectionKey] ?? false;
    }

    return false;
  }

  void toggleSectionPermissionState({
    required Modules module,
    required ModulePermissionsSections section,
  }) async {
    String moduleName = moduleEnumToString(module);
    bool currentState = isSectionActive(module, section);
    bool newState = !currentState;

    if (!modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
    }

    if (section is ModulePermissionsSectionsPermission) {
      String sectionKey = _convertToDbFormat((section as ModulePermissionsSectionsPermission).getDataBaseName);

      if (newState == true && !isPermissionAllowedByAdmin(moduleName, sectionKey)) {
        emit(RoleError(
            "Cannot enable this section: It is restricted by the administrator."
        ));
        return;
      }

      modulePermissions[moduleName]![sectionKey] = newState;
    }

    for (var permission in section.sectionPermissions) {
      String permissionKey = _convertToDbFormat((permission as ModulePermissionsSectionsPermission).getDataBaseName);

      if (newState == true && !isPermissionAllowedByAdmin(moduleName, permissionKey)) {
        continue;
      }

      modulePermissions[moduleName]![permissionKey] = newState;
    }

    emit(RoleSwitchToggled());
  }

  bool isSwitchActive(
      Modules module,
      ModulePermissionsSections section,
      ModulePermissionsSectionsPermission permission,
      ) {
    String moduleName = moduleEnumToString(module);
    String permissionKey = _convertToDbFormat(permission.getDataBaseName);

    return modulePermissions[moduleName]?[permissionKey] ?? false;
  }

  void toggleSwitchState({
    required Modules module,
    required ModulePermissionsSections section,
    required ModulePermissionsSectionsPermission permission,
  }) async {
    String moduleName = moduleEnumToString(module);
    String permissionKey = _convertToDbFormat(permission.getDataBaseName);

    if (!modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
    }

    bool currentValue = modulePermissions[moduleName]![permissionKey] ?? false;
    bool newValue = !currentValue;

    if (newValue == true && !isPermissionAllowedByAdmin(moduleName, permissionKey)) {
      emit(RoleError(
          "Cannot enable '${permission.getDataBaseName}': This permission is restricted by the administrator."
      ));
      return;
    }

    modulePermissions[moduleName]![permissionKey] = newValue;

    emit(RoleSwitchToggled());
  }

  String _convertToDbFormat(String displayName) {
    return displayName.trim().replaceAll(RegExp(r'\s+'), '_');
  }

  Future<void> activateDraftRole() async {
    //print("\n🔍 Activating draft role");

    if (selectedRole == null) {
      throw Exception("No role selected");
    }

    RoleHistoryModel updatedRole = selectedRole!.copyWith(
      status: RoleStatus.active.name,
      selectedModules: selectedModules,
    );

    Either<Failure, dynamic> result = await roleRepository.updateRole(
      role: updatedRole,
      currentUserEmail: Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
      roleDescription: roleDescriptionController.text,
      roleDescriptionAr: roleDescriptionControllerAr.text,
      roleNameAr: roleNameControllerAr.text,
      roleImage: roleImage?.path,
      selectedModules: selectedModules,
      modulePermissions: modulePermissions,
    );

    if (result.isRight()) {
      //print("✅ Draft activated successfully\n");

      // CLEAR SEARCH TEXT HERE
      searchController.clear();

      await initAddingRoleController();
      await getUnDeletedRoles();
      emit(RoleActivated());
    } else {
      //print("❌ Failed to activate draft: ${result.fold((l) => l.errMessage, (r) => 'Unknown error')}\n");
      emit(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
    }
  }

  List<Map<String, dynamic>> getRoleHistory(RoleHistoryModel role) {
    List<Map<String, dynamic>> history = [];

    for (int i = 0; i < role.timestamps.length; i++) {
      Map<String, dynamic> historyEntry = {
        'timestamp': DateTime.fromMillisecondsSinceEpoch(role.timestamps[i]),
        'roleName': i < role.roleName.length ? role.roleName[i] : '',
        'roleNameAr': i < role.roleNameAr.length ? role.roleNameAr[i] : '',
        'roleDescription': i < role.roleDescription.length ? role.roleDescription[i] : '',
        'roleDescriptionAr': i < role.roleDescriptionAr.length ? role.roleDescriptionAr[i] : '',
        'status': i < role.status.length ? role.status[i] : '',
        'roleImage': i < role.roleImage.length ? role.roleImage[i] : '',
        'selectedModules': i < role.selectedModules.length ? role.selectedModules[i] : [],
      };
      history.add(historyEntry);
    }

    return history;
  }

  List<Map<String, dynamic>> getRoleChangesByDateRange(
      RoleHistoryModel role, DateTime startDate, DateTime endDate) {
    List<Map<String, dynamic>> changes = [];

    for (int i = 0; i < role.timestamps.length; i++) {
      DateTime changeDate = DateTime.fromMillisecondsSinceEpoch(role.timestamps[i]);
      if (changeDate.isAfter(startDate) && changeDate.isBefore(endDate)) {
        Map<String, dynamic> change = {
          'timestamp': changeDate,
          'roleName': i < role.roleName.length ? role.roleName[i] : '',
          'roleNameAr': i < role.roleNameAr.length ? role.roleNameAr[i] : '',
          'roleDescription': i < role.roleDescription.length ? role.roleDescription[i] : '',
          'roleDescriptionAr': i < role.roleDescriptionAr.length ? role.roleDescriptionAr[i] : '',
          'status': i < role.status.length ? role.status[i] : '',
          'roleImage': i < role.roleImage.length ? role.roleImage[i] : '',
          'selectedModules': i < role.selectedModules.length ? role.selectedModules[i] : [],
        };
        changes.add(change);
      }
    }

    return changes;
  }

  bool isModuleSelected(String moduleName) {
    return selectedModules.contains(moduleName);
  }

  Map<String, bool> getModulePermissions(String moduleName) {
    return Map<String, bool>.from(modulePermissions[moduleName] ?? {});
  }

  bool getPermissionValue(String moduleName, String permission) {
    return modulePermissions[moduleName]?[permission] ?? false;
  }

  void addModule(String moduleName) async {
    if (!selectedModules.contains(moduleName)) {
      selectedModules.add(moduleName);
      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(moduleName);
      emit(RoleModuleSelected());
    }
  }

  void removeModule(String moduleName) {
    if (moduleName == 'settings') {
      //print('⚠️ Cannot remove Settings module - it is required');
      return;
    }

    selectedModules.remove(moduleName);
    modulePermissions.remove(moduleName);
    emit(RoleModuleSelected());
  }

  void updateModulePermissions(String moduleName, Map<String, bool> permissions) {
    if (modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName]!.addAll(permissions);
      emit(RolePermissionUpdated());
    }
  }

  Future<void> loadModulePermissions(String moduleName) async {
    if (selectedRole == null) return;

    String roleId = selectedRole!.currentRoleName;
    Either<FirebaseFailure, Map<String, dynamic>?> result =
    await roleRepository.getRolePermissions(roleId: roleId, module: moduleName);

    if (result.isRight()) {
      Map<String, dynamic>? permissions = result.getOrElse(() => null);
      if (permissions != null) {
        modulePermissions[moduleName] = {};
        permissions.forEach((key, value) {
          if (key != 'Role_Id' && key != 'timestamps' && value is List && value.isNotEmpty) {
            modulePermissions[moduleName]![key] = value.last == true;
          }
        });
        emit(RolePermissionLoaded());
      }
    }
  }

  Future<void> saveModulePermissions(String moduleName) async {
    if (selectedRole == null || !modulePermissions.containsKey(moduleName)) return;

    String roleId = selectedRole!.currentRoleName;
    Either<FirebaseFailure, String> result = await roleRepository.updateModulePermissions(
      roleId: roleId,
      module: moduleName,
      permissions: modulePermissions[moduleName]!,
    );

    if (result.isRight()) {
      emit(RolePermissionSaved());
    } else {
      emit(RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')));
    }
  }

  bool validateSelectedModules() {
    if (selectedModules.isEmpty) return false;

    for (String module in selectedModules) {
      if (!availableModules.contains(module)) {
        return false;
      }
    }

    return true;
  }

  List<String> getAvailableModules() {
    return availableModules.where((module) => !selectedModules.contains(module)).toList();
  }

  List<String> getDemoActiveModules() {
    return modulesCubit.getDemoActiveModules();
  }

  void clearAllPermissions() async {
    modulePermissions.clear();
    selectedModules.clear();
    await ensureSettingsSelected();
    emit(RolePermissionsCleared());
  }

  Map<String, dynamic> exportRoleConfiguration() {
    return {
      'roleName': roleNameController.text,
      'roleNameAr': roleNameControllerAr.text,
      'roleDescription': roleDescriptionController.text,
      'roleDescriptionAr': roleDescriptionControllerAr.text,
      'selectedModules': selectedModules,
      'modulePermissions': modulePermissions,
      'createdAt': DateTime.now().toIso8601String(),
    };
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

    emit(RoleConfigurationImported());
  }

  Map<String, dynamic> getRoleStatistics() {
    return {
      'totalRoles': roles.length,
      'activeRoles': roles.where((r) => r.currentStatus == RoleStatus.active).length,
      'draftRoles': roles.where((r) => r.currentStatus == RoleStatus.draft).length,
      'selectedModulesCount': selectedModules.length,
      'totalPermissionsCount': modulePermissions.values
          .map((perms) => perms.length)
          .fold(0, (sum, count) => sum + count),
    };
  }

  @Deprecated('Use new architecture methods instead')
  Map<Modules, Map<ModulePermissionsSections, Set<ModulePermissionsSectionsPermission>>>
  activeSwitches = {};

  @Deprecated('Use new architecture methods instead')
  Set<Modules> adminAccessModules = {};

  @Deprecated('Use new architecture methods instead')
  Map<Modules, Set<ModulePermissionsSections>> moduleSectionsHasFullAccess = {};

  @Deprecated('Use selectModule(String) instead')
  void selectModuleEnum(Modules module) {
    String moduleName = _moduleEnumToString(module);
    selectModule(moduleName);
  }

  String? get roleName => selectedRole?.currentRoleName;
}