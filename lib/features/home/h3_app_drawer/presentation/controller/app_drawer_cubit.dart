import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/main.dart';

import 'package:grc_module/core/helper/main_helper/biometric_controller.dart';
import '../../../../../core/network/api_constants.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import '../utils/app_drawer_constant_modules.dart';
import '../utils/app_drawer_update_ids.dart';

part './app_drawer_state.dart';

class AppDrawerCubit extends Cubit<AppDrawerState> {
  /// Kicks off [_init] immediately, mirroring the GetxController onInit()
  /// behaviour the rest of the app relies on.
  AppDrawerCubit() : super(const AppDrawerInitial()) {
    _init();
  }

  /// Re-runs the module load. Replaces call sites that used to invoke the
  /// GetxController's `onInit()` by hand to force a refresh.
  Future<void> reload() => _init();

  /// Role flags, formerly `Mode.owner` / `Mode.hr`.
  /// Static so they survive `Get.delete<AppDrawerCubit>()` on mobile
  /// layouts, where widgets read them without the controller registered.
  static bool isOwner = false;
  static bool isHr = false;

  RoleCubit roleController = roleCubit;
  RoleHistoryModel? roleHistory;
  List<Modules> _allDrawerModules = [];
  List<Modules> allowedDrawerModules = [];

  // Company license data
  Map<String, bool> _companyLicensedModules = {};

  List<Widget> get drawerItems =>
      allowedDrawerModules.map((module) => module.widget).toList();
  List<String> get drawerTitles =>
      allowedDrawerModules.map((module) => module.getModuleName).toList();
  List<String> get drawerIcons =>
      allowedDrawerModules.map((module) => module.iconPath).toList();

  int selectedIndex = 0;

  // Storage key for custom order
  static const String _orderStorageKey = 'drawer_custom_order';

  bool isLoadingModules = true;






  // ✅ UPDATE onInit() in app_drawer_controller.dart

  Future<void> _init() async {

    isLoadingModules = true;
    _publish();

    // ✅ FIX: employeeEntity may not be ready yet (MainCoreEmployeeController
    // loads it asynchronously during login). Previously we bailed out
    // immediately, leaving the drawer with only Home + Settings forever.
    // Now we wait up to ~10 seconds for it to become available.
    final mainCoreController = Get.find<MainCoreEmployeeController>();
    var currentEmployee = mainCoreController.employeeEntity;

    int retries = 0;
    while (currentEmployee == null && retries < 20) {
      if (retries == 0) {
        print("⏳ Drawer: employeeEntity is null, waiting for it to load...");
      }
      await Future.delayed(const Duration(milliseconds: 500));
      currentEmployee = mainCoreController.employeeEntity;
      retries++;
    }
    if (currentEmployee != null && retries > 0) {
      print("✅ Drawer: employeeEntity became available after ${retries * 500}ms");
    }

    if (currentEmployee == null) {
      print("❌ Drawer: employeeEntity still null after waiting — showing system modules only");
      _allDrawerModules = [];
      _getAllowedDrawerModules();
      isLoadingModules = false;
      _publish();
      return;
    }

    // ✅ CHECK: Is user company admin?
    bool isAdmin = (currentEmployee.id == '1');
    print("🔍 Drawer: Is company admin: $isAdmin");

    String? companyId = _getCompanyId(currentEmployee);

    if (companyId != null && companyId.isNotEmpty) {
      await _loadCompanyLicensedModules(companyId);
    }

    String? employeeRoleName = _getEmployeeRoleName(currentEmployee);

    if (employeeRoleName == null || employeeRoleName.isEmpty) {
      _allDrawerModules = [];
      _getAllowedDrawerModules();
      isLoadingModules = false;
      _publish();
      return;
    }

    AppDrawerCubit.isOwner = _isAdminRole(employeeRoleName);
    AppDrawerCubit.isHr = employeeRoleName.toLowerCase() == 'hr';

    selectedIndex = 0;
    allowedDrawerModules = [];

    try {
      // ✅ UPDATED: Load role from appropriate collection
      if (isAdmin) {
        print("🔍 Drawer: Loading role from Subscription_Admin (admin user)");

        // Load from Subscription_Admin
        roleHistory = roleController.roles.firstWhereOrNull(
              (element) => element.currentRoleName.toLowerCase() == employeeRoleName.toLowerCase(),
        );

        if (roleHistory == null) {
          print("⚠️ Drawer: Admin role not found, using all modules");
          _allDrawerModules = Modules.values.where((m) => m != Modules.more).toList();
        } else {
          print("✅ Drawer: Admin role loaded from Subscription_Admin");
          // Admin/master roles get every module, NOT just the ones stored in
          // Current_Selected_Modules. That stored array is a snapshot from when
          // the role was created, so modules added to the platform later (hr,
          // crm, ...) are missing from it and would never reach the drawer.
          // The company-license filter in _getDrawerModulesFromReference still
          // applies, so this widens the role gate only — not the license gate.
          _allDrawerModules =
              Modules.values.where((m) => m != Modules.more).toList();
        }
      } else {
        print("🔍 Drawer: Loading role from Roles (regular employee)");

        // Load from Roles (existing code)
        roleHistory = roleController.roles.firstWhereOrNull(
              (element) => element.currentRoleName.toLowerCase() == employeeRoleName.toLowerCase(),
        );

        if (roleHistory == null) {
          if (_isAdminRole(employeeRoleName)) {
            _allDrawerModules = Modules.values.where((m) => m != Modules.more).toList();
          } else {
            _allDrawerModules = [];
          }
        } else if (_isAdminRole(employeeRoleName)) {
          // Same reasoning as the admin branch above: an admin role's stored
          // Current_Selected_Modules predates newer modules, so widen to all.
          _allDrawerModules =
              Modules.values.where((m) => m != Modules.more).toList();
        } else {
          List<String> activeModuleNames = roleHistory!.currentSelectedModules;
          _allDrawerModules = _convertModuleNamesToEnums(activeModuleNames);
        }
      }

      _getAllowedDrawerModules();
      isLoadingModules = false;
      _publish();

    } catch (e, stackTrace) {
      print('❌ Drawer: Error initializing: $e');
      _allDrawerModules = [];
      _getAllowedDrawerModules();
      isLoadingModules = false;
      _publish();
    }
  }


  /// Extract company ID from ApiConstants.baseUri
  String? _getCompanyId(dynamic currentEmployee) {
    // print('🔍 Drawer: Attempting to extract company ID');
    // print('🔍 Drawer: ApiConstants.baseUri = "${ApiConstants.baseUri}"');

    // Method 1: Extract from ApiConstants.baseUri (PRIMARY - MOST RELIABLE)
    if (ApiConstants.baseUri.isNotEmpty) {
      // print('✅ Drawer: baseUri is not empty');

      if (ApiConstants.baseUri.contains('/')) {
        // print('✅ Drawer: baseUri contains "/"');

        List<String> parts = ApiConstants.baseUri.split('/');
        // print('🔍 Drawer: Split into ${parts.length} parts: $parts');

        if (parts.length >= 2) {
          String companyId = parts[1];
          // print('✅✅✅ Drawer: Successfully extracted company ID: $companyId');
          return companyId;
        } else {
          // print('❌ Drawer: Not enough parts (need 2+, got ${parts.length})');
        }
      } else {
        // print('❌ Drawer: baseUri does NOT contain "/"');
      }
    } else {
      // print('❌ Drawer: baseUri is EMPTY');
    }

    // print('❌ Drawer: Extraction failed, returning null');
    return null;
  }

  /// Load company licensed modules from Firebase
  Future<void> _loadCompanyLicensedModules(String companyId) async {
    try {
      // print('🔄 Drawer: Loading company licensed modules for company: $companyId');
      // print('🔄 Drawer: Firebase path: Demo Requests/$companyId');  // ✅ Changed

      final docRef = FirebaseFirestore.instance
          .collection('Demo_Requests')  // ✅ Changed from 'Demo_Requests' to 'Demo Requests'
          .doc(companyId);

    //  // print('🔄 Drawer: Attempting to fetch from Firebase...');
      final snapshot = await docRef.get();
      // // print('🔄 Drawer: Firebase fetch completed. Exists: ${snapshot.exists}');
      // // print('🔄 Drawer: Document data: ${snapshot.data()}');  // ✅ Added debug

      if (!snapshot.exists) {
        // print('❌ Drawer: Demo Requests document not found for company: $companyId');
        // print('❌ Drawer: NO LICENSE DATA - Blocking all non-system modules');
        _companyLicensedModules = {};
        return;
      }

      final data = snapshot.data();
      if (data == null) {
        // print('⚠️ Drawer: Document exists but has no data');
        _companyLicensedModules = {};
        return;
      }

      // ✅ Check for Modules directly in the document (not in Demo_Details)
      Map? modulesData;

      // Try Demo_Details/Modules first (for older structure)
      if (data['Demo_Details'] != null && data['Demo_Details'] is Map) {
        final demoDetails = data['Demo_Details'] as Map;
        if (demoDetails['Modules'] != null && demoDetails['Modules'] is Map) {
          modulesData = demoDetails['Modules'] as Map;
          // print('✅ Drawer: Found Modules in Demo_Details/Modules');
        }
      }

      // If not found, try Modules directly (for new structure)
      if (modulesData == null && data['Modules'] != null && data['Modules'] is Map) {
        modulesData = data['Modules'] as Map;
      //  // print('✅ Drawer: Found Modules directly in document');
      }

      if (modulesData == null) {
     //   // print('⚠️ Drawer: Modules not found in document');
     //   // print('⚠️ Drawer: Available keys: ${data.keys.toList()}');
        _companyLicensedModules = {};
        return;
      }

      // print('✅ Drawer: Found Modules with ${modulesData.keys.length} entries');

      _companyLicensedModules = {};

      for (var entry in modulesData.entries) {
        final moduleName = entry.key.toString().toLowerCase();
        final moduleData = entry.value;

        // print('🔍 Drawer: Processing module: $moduleName, data type: ${moduleData.runtimeType}');

        bool isLicensed = false;

        if (moduleData is Map) {
          final values = moduleData['Values'];
          if (values is List && values.isNotEmpty) {
            isLicensed = values.last == true;
           // // print('  📦 Drawer: Module "$moduleName" from Values array: $isLicensed');
          }
        } else if (moduleData is bool) {
          isLicensed = moduleData;
        //  // print('  📦 Drawer: Module "$moduleName" from direct bool: $isLicensed');
        } else if (moduleData is List && moduleData.isNotEmpty) {
          isLicensed = moduleData.last == true;
          // // print('  📦 Drawer: Module "$moduleName" from array: $isLicensed');
        }

        _companyLicensedModules[moduleName] = isLicensed;
        // print('✅ Drawer: Module "$moduleName" license: $isLicensed');
      }

      // print('✅ Drawer: Loaded company licensed modules: $_companyLicensedModules');
      // print('✅ Drawer: Total licensed modules loaded: ${_companyLicensedModules.length}');

    } catch (e, stackTrace) {
      // print('❌ Drawer: Error loading company modules: $e');
      // print('❌ Drawer: Stack trace: $stackTrace');

      _companyLicensedModules = {};
      // print('❌ Drawer: Error occurred - Blocking all non-system modules');
    }
  }

  /// Check if a module is licensed by the company
  /// Check if a module is licensed by the company
  bool _isModuleLicensed(Modules module) {
    // System modules (home, settings) are always allowed
    if (module == Modules.home || module == Modules.settings) {
      return true;
    }

    // If no license data, BLOCK (fail-closed security)
    if (_companyLicensedModules.isEmpty) {
      // print('❌ Drawer: No license data loaded, blocking ${module.name}');
      return false;
    }

    String moduleName = module.name.toLowerCase();

    // ✅ FIX: Map grc enum back to "grc" Firebase key
    if (module == Modules.grc) {
      moduleName = 'grc';
    }

    // ✅ FIX: If qiyas module exists separately, map it too
    if (module == Modules.qiyas) {
      // Check if you have a separate qiyas key in Firebase
      // If not, use grc key
      moduleName = _companyLicensedModules.containsKey('qiyas') ? 'qiyas' : 'grc';
    }

    final isLicensed = _companyLicensedModules[moduleName] ?? false;

    if (isLicensed) {
      // print('✅ Drawer: Module ${module.name} IS licensed');
    } else {
      // print('❌ Drawer: Module ${module.name} NOT licensed by company');
    }

    return isLicensed;
  }

  /// Save custom drawer order
  void saveCustomOrder(List<Modules> newOrder) {
    try {
      List<String> orderStrings = newOrder.map((m) => m.getModuleName).toList();
      storage.write(_orderStorageKey, orderStrings);

      allowedDrawerModules = newOrder;
      _publish();

      // print('✅ Drawer: Custom order saved: ${orderStrings.join(', ')}');
    } catch (e) {
      // print('❌ Drawer: Error saving custom order: $e');
    }
  }

  /// Load custom drawer order
  List<Modules>? _loadCustomOrder() {
    try {
      List<dynamic>? orderStrings = storage.read(_orderStorageKey);
      if (orderStrings == null || orderStrings.isEmpty) {
        return null;
      }

      List<Modules> customOrder = [];
      Set<Modules> addedModules = {};

      for (var moduleName in orderStrings) {
        Modules? module = _getModuleFromDisplayName(moduleName.toString());
        if (module != null && _allDrawerModules.contains(module)) {
          if (!addedModules.contains(module)) {
            customOrder.add(module);
            addedModules.add(module);
          } else {
            // print('⚠️ Drawer: Skipped duplicate module in custom order: ${module.getModuleName}');
          }
        }
      }

      for (var module in allowedDrawerModules) {
        if (!addedModules.contains(module)) {
          customOrder.add(module);
          addedModules.add(module);
        }
      }

      // print('✅ Drawer: Loaded custom order: ${customOrder.map((m) => m.getModuleName).join(', ')}');
      return customOrder;
    } catch (e) {
      // print('❌ Drawer: Error loading custom order: $e');
      return null;
    }
  }

  /// Get module from display name
  Modules? _getModuleFromDisplayName(String displayName) {
    for (var module in Modules.values) {
      if (module.getModuleName.toLowerCase() == displayName.toLowerCase()) {
        return module;
      }
    }

    return _getModuleEnum(displayName);
  }

  /// Reset to default order
  void resetToDefaultOrder() {
    try {
      storage.remove(_orderStorageKey);
      allowedDrawerModules.clear();
      _getAllowedDrawerModules();
      _publish();
      // print('✅ Drawer: Reset to default order');
    } catch (e) {
      // print('❌ Drawer: Error resetting order: $e');
    }
  }

  bool _isAdminRole(String roleName) {
    String lowerRoleName = roleName.toLowerCase().trim();
    return lowerRoleName == 'super admin' ||
        lowerRoleName == 'master admin' ||
        lowerRoleName == 'admin_role' ||
        lowerRoleName == 'admin' ||
        lowerRoleName == 'administrator';
  }

  String? _getEmployeeRoleName(dynamic currentEmployee) {
    try {
      dynamic role = currentEmployee.role;

      if (role == null) {
        return null;
      }

      if (role is String) {
        return role;
      }

      if (role.role != null) {
        if (role.role is List && (role.role as List).isNotEmpty) {
          return (role.role as List).last?.toString();
        }
        if (role.role is String) {
          return role.role as String;
        }
      }

      return role.toString();
    } catch (e) {
      // print('⚠️ Drawer: Error extracting role name: $e');
      return null;
    }
  }

  List<Modules> _convertModuleNamesToEnums(List<String> moduleNames) {
    List<Modules> moduleEnums = [];

    for (String moduleName in moduleNames) {
      Modules? moduleEnum = _getModuleEnum(moduleName);
      if (moduleEnum != null) {
        moduleEnums.add(moduleEnum);
     //   // print('  ✓ Drawer: Added module: $moduleName -> ${moduleEnum.getModuleName}');
      } else {
        // print('  ✗ Drawer: Unknown module: $moduleName');
      }
    }

    return moduleEnums;
  }

  Modules? _getModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase().trim()) {
      case 'employees':
        return Modules.employees;
      case 'services':
        return Modules.services;
      case 'tasks':
        return Modules.tasks;
      case 'todo':
        return Modules.todo;
      case 'events':
        return Modules.events;
      case 'notes':
        return Modules.notes;
      case 'requests':
        return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':
        return Modules.knowledgeHub;
      case 'qiyas':
        return Modules.qiyas;
      case 'grc':
        return Modules.grc;
      case 'tracking':
        return Modules.tracking;
      case 'inventory':
        return Modules.inventory;
      case 'messages':
        return Modules.messages;
      case 'database_builder':
      case 'database':
        return Modules.database;
      case 'services_app':
      case 'formbuilder':
        return Modules.formBuilder;
      case 'roles':
        return Modules.roles;
      case 'settings':
        return Modules.settings;
      case 'home':
        return Modules.home;
      case 'hr':  // ✅ Add this
        return Modules.hr;
      case 'crm':  // ✅ Add this
        return Modules.crm;
      case 'notification':  // ✅ Add this
        return Modules.notification;
      default:
        // print('⚠️ Drawer: Unknown module name: $moduleName');
        return null;
    }
  }

  void _getAllowedDrawerModules() {
    // print('🔍 Drawer: Building allowed modules list');
    // print('🔍 Drawer: _allDrawerModules (from role): ${_allDrawerModules.map((m) => m.getModuleName).join(', ')}');
    // print('🔍 Drawer: _companyLicensedModules: $_companyLicensedModules');

    if (!_allDrawerModules.contains(Modules.home)) {
      _allDrawerModules.add(Modules.home);
      // print('  ✓ Drawer: Added home module to _allDrawerModules');
    }
    if (!_allDrawerModules.contains(Modules.settings)) {
      _allDrawerModules.add(Modules.settings);
      // print('  ✓ Drawer: Added settings module to _allDrawerModules');
    }

    if (!allowedDrawerModules.contains(Modules.home)) {
      allowedDrawerModules.add(Modules.home);
      // print('  ✅ Drawer: Added home to allowedDrawerModules (system module)');
    }
    if (!allowedDrawerModules.contains(Modules.settings)) {
      allowedDrawerModules.add(Modules.settings);
      // print('  ✅ Drawer: Added settings to allowedDrawerModules (system module)');
    }

    // print("🔧 Drawer: AppDrawerCubit.isOwner: ${AppDrawerCubit.isOwner}, AppDrawerCubit.isHr: ${AppDrawerCubit.isHr}");

    if (AppDrawerCubit.isOwner || AppDrawerCubit.isHr) {
      if (!_allDrawerModules.contains(Modules.roles)) {
        _allDrawerModules.add(Modules.roles);
        // print('  ✓ Drawer: Added roles_module module to _allDrawerModules (admin/HR)');
      }
      if (!allowedDrawerModules.contains(Modules.roles)) {
        allowedDrawerModules.add(Modules.roles);
        // print('  ✅ Drawer: Added roles_module to allowedDrawerModules (admin/HR)');
      }
    }

    // print('🔍 Drawer: Filtering modules by company license...');
    _getDrawerModulesFromReference(
        referenceModulesList: AppDrawerConstantModules.drawerModules
    );

    // print('🔍 Drawer: After reference filtering, allowed modules: ${allowedDrawerModules.map((m) => m.getModuleName).join(', ')}');

    List<Modules>? customOrder = _loadCustomOrder();
    if (customOrder != null && customOrder.isNotEmpty) {
      // print('🔄 Drawer: Custom order found, but checking if it has all modules...');

      List<Modules> missingFromCustomOrder = [];
      for (var module in allowedDrawerModules) {
        if (!customOrder.contains(module)) {
          missingFromCustomOrder.add(module);
          // print('  ⚠️ Drawer: Custom order missing: ${module.getModuleName}');
        }
      }

      if (missingFromCustomOrder.isEmpty) {
        allowedDrawerModules = customOrder;
        // print('✅ Drawer: Applied custom order (complete)');
      } else {
        // print('❌ Drawer: Custom order incomplete (missing ${missingFromCustomOrder.length} modules), ignoring it');
        // print('❌ Drawer: Clearing corrupted custom order storage');
        storage.remove(_orderStorageKey);
      }
    }

    // print('📱 Drawer: Final allowed modules (${allowedDrawerModules.length}): ${allowedDrawerModules.map((m) => m.getModuleName).join(', ')}');
  }

  void _getDrawerModulesFromReference({
    required List<Modules> referenceModulesList,
  }) {
    // print('🔍 Drawer: Checking reference modules: ${referenceModulesList.map((m) => m.getModuleName).join(', ')}');

    for (Modules module in referenceModulesList) {
      if (module == Modules.home || module == Modules.settings) {
        // print('  ℹ️ Drawer: ${module.name} is system module (already added)');
        continue;
      }

      bool isInRole = _allDrawerModules.contains(module);
      bool notInAllowed = !allowedDrawerModules.contains(module);
      bool isLicensed = _isModuleLicensed(module);

      // print('  🔎 Module ${module.getModuleName}: inRole=$isInRole, notInAllowed=$notInAllowed, isLicensed=$isLicensed');

      if (isInRole && notInAllowed && isLicensed) {
        allowedDrawerModules.add(module);
        // print('  ✅ Drawer: Added ${module.getModuleName} (in role + licensed + not duplicate)');
      } else {
        if (!isInRole) {
          // print('  ❌ Drawer: Skipped ${module.getModuleName} (not in role)');
        } else if (!notInAllowed) {
          // print('  ⚠️ Drawer: Skipped ${module.getModuleName} (already in allowed)');
        } else if (!isLicensed) {
          // print('  ❌ Drawer: Skipped ${module.getModuleName} (not licensed by company)');
        }
      }
    }
  }

  updateSelectedIndex(int index, {bool isOnlyDrawer = false}) {
    selectedIndex = index;
    if (isOnlyDrawer) {
      _publish();
    } else {
      _publish();
    }
  }

  /// Emits the current field snapshot so BlocBuilder rebuilds. Replaces the
  /// GetxController `update()` / `update([id])` calls the original used —
  /// Bloc has no per-id rebuilds, so every listener rebuilds.
  void _publish() {
    if (isClosed) return;
    emit(AppDrawerLoaded(
      allowedDrawerModules: List.unmodifiable(allowedDrawerModules),
      selectedIndex: selectedIndex,
      isLoadingModules: isLoadingModules,
    ));
  }
}
