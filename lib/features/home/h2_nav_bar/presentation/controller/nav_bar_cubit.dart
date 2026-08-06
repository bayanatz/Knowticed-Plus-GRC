import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/home/h2_nav_bar/utils/nav_bar_constant_modules.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';

import '../../../../../core/network/api_constants.dart';
import '../../../../../generated/l10n.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';

part './nav_bar_state.dart';

class NavBarCubit extends Cubit<NavBarState> {
  /// Kicks off [_init] immediately, mirroring the GetxController onInit()
  /// behaviour the rest of the app relies on.
  NavBarCubit() : super(const NavBarInitial()) {
    _init();
  }

  /// Re-runs the module load. Replaces call sites that used to invoke the
  /// GetxController's `onInit()` by hand to force a refresh.
  Future<void> reload() => _init();

  RoleCubit roleController = roleCubit;
  RoleHistoryModel? roleHistory;
  List<Modules> _allAllowedModules = [];
  List<Modules> moreListModules = [];
  List<Modules> navBarModules = [];

  // ✅ ADD: Company license data (same as AppDrawerCubit)
  Map<String, bool> _companyLicensedModules = {};
  bool isLoadingModules = true;

  List<Widget> get navBarItems =>
      navBarModules.map((module) => module.widget).toList();
  List<String> get navBarTitles =>
      navBarModules.map((module) => module.getModuleName).toList();
  List<String> get navBarIcons =>
      navBarModules.map((module) => module.iconPath).toList();
  bool get isAppBarEventAllowed =>
      _allAllowedModules.contains(Modules.events) &&
          !navBarModules.contains(Modules.events);


  Future<void> _init() async {


    isLoadingModules = true;

    // ✅ CRITICAL: Initialize with minimum viable navbar IMMEDIATELY
    // This prevents UI crashes while Firebase loads
    navBarModules = [Modules.home, Modules.more];
    _publish();

    final currentEmployee = Get.find<MainCoreEmployeeController>().employeeEntity;

    if (currentEmployee == null) {
      print('❌ NavBar: Current employee not found');
      _allAllowedModules = [];
      _getNavBarModules();
      isLoadingModules = false;
      _publish();
      return;
    }

    // ✅ ADD: Extract company ID and load licensed modules
    String? companyId = _getCompanyId(currentEmployee);

    if (companyId != null && companyId.isNotEmpty) {
      await _loadCompanyLicensedModules(companyId);
    } else {
      print('⚠️ NavBar: No company ID, setting default licenses');
      _companyLicensedModules = {
        'services': true,
        'tasks': true,
        'tracking': true,
        'inventory': true,
        'messages': true,
        'roles': true,
        'knowledge_hub': true,
        'knowledgehub': true,
        'qiyas': true,
        'grc': true,
        'services_app': true,
        'formbuilder': true,
        'todo': true,
        'employees': true,
        'events': true,
        'notes': true,
        'requests': true,
        'database': true,
        'database_builder': true,
      };
    }

    String? employeeRoleName = _getEmployeeRoleName(currentEmployee);

    if (employeeRoleName == null || employeeRoleName.isEmpty) {
      print('❌ NavBar: Employee has no role assigned');
      _allAllowedModules = [];
      _getNavBarModules();
      isLoadingModules = false;
      _publish();
      return;
    }

    print('🔍 NavBar: Loading employee role: $employeeRoleName');

    try {
      roleHistory = roleController.roles.firstWhereOrNull(
            (element) => element.currentRoleName.toLowerCase() == employeeRoleName.toLowerCase(),
      );

      if (roleHistory == null) {
        print('❌ NavBar: Role not found in database: $employeeRoleName');

        if (_isAdminRole(employeeRoleName)) {
          print('⚠️ NavBar: Admin role not found in database, granting all modules');
          _allAllowedModules = Modules.values.where((m) => m != Modules.more).toList();
        } else {
          _allAllowedModules = [];
        }
        _getNavBarModules();
        isLoadingModules = false;
        _publish();
        return;
      }

      print('✅ NavBar: Role found: ${roleHistory!.currentRoleName}');

      List<String> activeModuleNames = roleHistory!.currentSelectedModules;
      print('📦 NavBar: Role has ${activeModuleNames.length} modules: $activeModuleNames');

      _allAllowedModules = _convertModuleNamesToEnums(activeModuleNames);
      print('✅ NavBar: Converted to ${_allAllowedModules.length} module enums');

      _getNavBarModules();

      print("✅ NavBar: Modules initialized: ${navBarModules.map((m) => m.getModuleName).join(', ')}");

      isLoadingModules = false;
      _publish();

    } catch (e, stackTrace) {
      print('❌ NavBar: Error initializing: $e');
      print('Stack trace: $stackTrace');
      _allAllowedModules = [];
      _getNavBarModules();
      isLoadingModules = false;
      _publish();
    }
  }

  // ✅ ADD: Extract company ID (same as AppDrawerCubit)
  String? _getCompanyId(dynamic currentEmployee) {
    print('🔍 NavBar: Attempting to extract company ID');
    print('🔍 NavBar: ApiConstants.baseUri = "${ApiConstants.baseUri}"');

    if (ApiConstants.baseUri.isNotEmpty) {
      print('✅ NavBar: baseUri is not empty');

      if (ApiConstants.baseUri.contains('/')) {
        print('✅ NavBar: baseUri contains "/"');

        List<String> parts = ApiConstants.baseUri.split('/');
        print('🔍 NavBar: Split into ${parts.length} parts: $parts');

        if (parts.length >= 2) {
          String companyId = parts[1];
          print('✅✅✅ NavBar: Successfully extracted company ID: $companyId');
          return companyId;
        }
      }
    }

    print('❌ NavBar: Extraction failed, returning null');
    return null;
  }

  // ✅ ADD: Load company licensed modules from Firebase (same as AppDrawerCubit)
  Future<void> _loadCompanyLicensedModules(String companyId) async {
    try {
      print('🔄 NavBar: Loading company licensed modules for company: $companyId');
      print('🔄 NavBar: Firebase path: Demo Requests/$companyId');

      final docRef = FirebaseFirestore.instance
          .collection('Demo_Requests')
          .doc(companyId);

      print('🔄 NavBar: Attempting to fetch from Firebase...');
      final snapshot = await docRef.get();
      print('🔄 NavBar: Firebase fetch completed. Exists: ${snapshot.exists}');

      if (!snapshot.exists) {
        print('❌ NavBar: Demo Requests document not found for company: $companyId');
        print('❌ NavBar: NO LICENSE DATA - Blocking all non-system modules');
        _companyLicensedModules = {};
        return;
      }

      final data = snapshot.data();
      if (data == null) {
        print('⚠️ NavBar: Document exists but has no data');
        _companyLicensedModules = {};
        return;
      }

      Map? modulesData;

      // Try Demo_Details/Modules first
      if (data['Demo_Details'] != null && data['Demo_Details'] is Map) {
        final demoDetails = data['Demo_Details'] as Map;
        if (demoDetails['Modules'] != null && demoDetails['Modules'] is Map) {
          modulesData = demoDetails['Modules'] as Map;
          print('✅ NavBar: Found Modules in Demo_Details/Modules');
        }
      }

      // Try Modules directly
      if (modulesData == null && data['Modules'] != null && data['Modules'] is Map) {
        modulesData = data['Modules'] as Map;
        print('✅ NavBar: Found Modules directly in document');
      }

      if (modulesData == null) {
        print('⚠️ NavBar: Modules not found in document');
        _companyLicensedModules = {};
        return;
      }

      print('✅ NavBar: Found Modules with ${modulesData.keys.length} entries');

      _companyLicensedModules = {};

      for (var entry in modulesData.entries) {
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

        _companyLicensedModules[moduleName] = isLicensed;
        print('✅ NavBar: Module "$moduleName" license: $isLicensed');
      }

      print('✅ NavBar: Total licensed modules loaded: ${_companyLicensedModules.length}');

    } catch (e, stackTrace) {
      print('❌ NavBar: Error loading company modules: $e');
      print('❌ NavBar: Stack trace: $stackTrace');
      _companyLicensedModules = {};
    }
  }

  // ✅ ADD: Check if module is licensed (same as AppDrawerCubit)
  bool _isModuleLicensed(Modules module) {
    // ✅ FIX: System modules are always allowed (including roles_module for admin/HR)
    if (module == Modules.home ||
        module == Modules.settings ||
        module == Modules.roles) {  // ✅ Roles is also a system module
      return true;
    }

    // ✅ CRITICAL: "More" is special - it's always allowed for navbar but NOT checked for license
    if (module == Modules.more) {
      return true;
    }

    // If no license data, BLOCK
    if (_companyLicensedModules.isEmpty) {
      print('❌ NavBar: No license data loaded, blocking ${module.name}');
      return false;
    }

    String moduleName = module.name.toLowerCase();

    // Map grc/qiyas correctly
    if (module == Modules.grc) {
      moduleName = 'grc';
    }
    if (module == Modules.qiyas) {
      moduleName = _companyLicensedModules.containsKey('qiyas') ? 'qiyas' : 'grc';
    }

    final isLicensed = _companyLicensedModules[moduleName] ?? false;

    if (isLicensed) {
      print('✅ NavBar: Module ${module.name} IS licensed');
    } else {
      print('❌ NavBar: Module ${module.name} NOT licensed by company');
    }

    return isLicensed;
  }

  bool _isAdminRole(String roleName) {
    String lowerRoleName = roleName.toLowerCase().trim();
    return lowerRoleName == 'super admin' ||
        lowerRoleName == 'admin_role' ||
        lowerRoleName == 'admin' ||
        lowerRoleName == 'administrator';
  }

  String? _getEmployeeRoleName(dynamic currentEmployee) {
    try {
      dynamic role = currentEmployee.role;

      if (role == null) return null;
      if (role is String) return role;

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
      print('⚠️ NavBar: Error extracting role name: $e');
      return null;
    }
  }

  List<Modules> _convertModuleNamesToEnums(List<String> moduleNames) {
    List<Modules> moduleEnums = [];

    for (String moduleName in moduleNames) {
      Modules? moduleEnum = _getModuleEnum(moduleName);
      if (moduleEnum != null) {
        moduleEnums.add(moduleEnum);
        print('  ✓ NavBar: Added module: $moduleName -> ${moduleEnum.getModuleName}');
      } else {
        print('  ✗ NavBar: Unknown module: $moduleName');
      }
    }

    return moduleEnums;
  }

  Modules? _getModuleEnum(String moduleName) {
    String normalizedName = moduleName.toLowerCase().trim();

    switch (normalizedName) {
      case 'employees':
      case 'الموظفين':
        return Modules.employees;
      case 'services':
      case 'الخدمات':
        return Modules.services;
      case 'tasks':
      case 'المهام':
        return Modules.tasks;
      case 'todo':
      case 'قائمة المهام':
        return Modules.todo;
      case 'events':
      case 'الأحداث':
        return Modules.events;
      case 'notes':
      case 'الملاحظات':
        return Modules.notes;
      case 'requests':
      case 'الطلبات':
        return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':
      case 'مركز المعرفة':
        return Modules.knowledgeHub;
      case 'qiyas':
      case 'قياس':
        return Modules.qiyas;
      case 'grc':
      case 'كامل':
        return Modules.grc;
      case 'tracking':
      case 'التتبع':
        return Modules.tracking;
      case 'inventory':
      case 'المخزون':
        return Modules.inventory;
      case 'messages':
      case 'الرسائل':
        return Modules.messages;
      case 'database_builder':
      case 'database':
      case 'منشئ قاعدة البيانات':
      case 'قاعدة البيانات':
        return Modules.database;
      case 'services_app':
      case 'formbuilder':
      case 'منشئ النماذج':
        return Modules.formBuilder;
      case 'roles':
      case 'الأدوار':
        return Modules.roles;
      case 'settings':
      case 'الإعدادات':
        return Modules.settings;
      case 'home':
      case 'الرئيسية':
        return Modules.home;
      default:
        print('⚠️ NavBar: Unknown module name: $moduleName');
        return null;
    }
  }

  void _getNavBarModules() {
    final currentEmployee = Get.find<MainCoreEmployeeController>().employeeEntity;

    if (currentEmployee == null) {
      print('❌ NavBar: Current employee not found in _getNavBarModules');
      return;
    }

    String? employeeRoleName = _getEmployeeRoleName(currentEmployee);

    if (employeeRoleName == null) {
      print('❌ NavBar: Employee role not found in _getNavBarModules');
      return;
    }

    // AppDrawerCubit.isOwner = _isAdminRole(employeeRoleName);
    // AppDrawerCubit.isHr = employeeRoleName.toLowerCase() == 'hr';
    //
    // print('🔧 NavBar: Role: $employeeRoleName');
    // print('🔧 NavBar: AppDrawerCubit.isOwner: ${AppDrawerCubit.isOwner}, AppDrawerCubit.isHr: ${AppDrawerCubit.isHr}');

    // Always add home
    if (!_allAllowedModules.contains(Modules.home)) {
      _allAllowedModules.add(Modules.home);
    }

    // ✅ CRITICAL FIX: Clear navBarModules to remove the initial [home, more]
    navBarModules.clear();
    print('🧹 NavBar: Cleared navBarModules');

    if (AppDrawerCubit.isOwner) {
      print('👑 NavBar: Loading admin modules');
      _getNavBarModulesFromReference(
          referenceModulesList: NavBarConstantModules.defaultAdminNavBarModules);
    } else if (AppDrawerCubit.isHr) {
      print('👔 NavBar: Loading HR modules');
      if (!_allAllowedModules.contains(Modules.roles)) {
        _allAllowedModules.add(Modules.roles);
      }
      _getNavBarModulesFromReference(
          referenceModulesList: NavBarConstantModules.defaultHRNavBarModules);
    } else {
      print('👤 NavBar: Loading user modules');
      _getNavBarModulesFromReference(
          referenceModulesList: NavBarConstantModules.defaultUserNavBarModules);
    }

    _addSecondaryModulesIfNeeded();

    // ✅ Only add More once, here at the end
    if (!navBarModules.contains(Modules.more)) {
      navBarModules.add(Modules.more);
      print('  ✅ Added "More" button (total now: ${navBarModules.length})');
    }

    _getMoreListModules();

    print('📱 NavBar: Final modules (${navBarModules.length}): ${navBarModules.map((m) => m.getModuleName).join(', ')}');
    print('📱 NavBar: Final allAllowedModules: ${_allAllowedModules.map((m) => m.getModuleName).join(', ')}');
  }

  // ✅ MODIFIED: Add license check
  void _getNavBarModulesFromReference({
    required List<Modules> referenceModulesList,
  }) {
    print('🔍 NavBar: Checking reference modules: ${referenceModulesList.map((m) => m.getModuleName).join(', ')}');

    for (Modules module in referenceModulesList) {
      bool isAllowed = _allAllowedModules.contains(module);
      bool notInNavBar = !navBarModules.contains(module);
      bool isLicensed = _isModuleLicensed(module); // ✅ ADD LICENSE CHECK

      print('  Module ${module.getModuleName}: allowed=$isAllowed, notInNavBar=$notInNavBar, isLicensed=$isLicensed');

      // ✅ MODIFIED: Only add if licensed
      if (isAllowed && notInNavBar && isLicensed) {
        navBarModules.add(module);
        print('  ✅ Added ${module.getModuleName} to navbar (role + license)');
      } else if (!isLicensed && isAllowed) {
        print('  ❌ Blocked ${module.getModuleName} (not licensed by company)');
      }
    }
  }

  void _addSecondaryModulesIfNeeded() {
    print('🔍 NavBar: Adding secondary modules if needed (current count: ${navBarModules.length})');

    for (int i = 0;
    i < NavBarConstantModules.secondaryNavBarItems.length &&
        navBarModules.length < 4;
    i++) {
      Modules module = NavBarConstantModules.secondaryNavBarItems[i];

      // ✅ ADD: Check license before adding
      if (_allAllowedModules.contains(module) &&
          !navBarModules.contains(module) &&
          _isModuleLicensed(module)) {
        navBarModules.add(module);
        print('  ✅ Added secondary module: ${module.getModuleName}');
      }
    }

    navBarModules.remove(Modules.events);
    print('  Removed events module from navbar');
  }

  // ✅ MODIFIED: Updated to include ALL allowed modules
  void _getMoreListModules() {
    print('🔍 NavBar: Building more list modules');

    // First add modules from secondaryNavBarItems (maintains order)
    for (Modules module in NavBarConstantModules.secondaryNavBarItems) {
      if (!navBarModules.contains(module) &&
          _allAllowedModules.contains(module) &&
          _isModuleLicensed(module)) { // ✅ ADD LICENSE CHECK
        moreListModules.add(module);
        print('  ✅ Added to more list: ${module.getModuleName}');
      }
    }

    // ✅ ADD: Then add any remaining allowed AND licensed modules
    for (Modules module in _allAllowedModules) {
      if (!navBarModules.contains(module) &&
          !moreListModules.contains(module) &&
          module != Modules.more &&
          module != Modules.home &&
          _isModuleLicensed(module)) { // ✅ ADD LICENSE CHECK
        moreListModules.add(module);
        print('  ✅ Added additional module to more list: ${module.getModuleName}');
      }
    }

    print('📋 NavBar: More list modules: ${moreListModules.map((m) => m.getModuleName).join(', ')}');
  }

  /// Emits the current field snapshot so BlocBuilder rebuilds. Replaces the
  /// GetxController `update()` call the original used.
  void _publish() {
    if (isClosed) return;
    emit(NavBarLoaded(
      navBarModules: List.unmodifiable(navBarModules),
      moreListModules: List.unmodifiable(moreListModules),
      isLoadingModules: isLoadingModules,
    ));
  }
}
