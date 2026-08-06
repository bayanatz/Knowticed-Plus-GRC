// ******************* FILE INFO *******************
// File Name: modules_cubit.dart
// Description: Builds the module / access lists shown for a selected role, and
//              owns the module<->permission helper logic. Converted from the
//              former ModulesController (GetxController).
// Module: roles / role_management / presentation / controller
// *************************************************

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/module_permission_model.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/entity/access_data.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/entity/module_item.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

part './modules_state.dart';

class ModulesCubit extends Cubit<ModulesState> {
  ModulesCubit() : super(const ModulesInitial());

  RoleRepository roleRepository = RoleRepository();

  // ── Working copies ────────────────────────────────────────────────────────
  // The build steps below are imperative and multi-pass, so they mutate these
  // and publish a snapshot via [_publish] once each step settles.
  final List<ModuleItem> _modules = [];
  final List<bool> _modulesEdit = [];
  final List<AccessData> _accesses = [];
  final List<bool> _accessesEdit = [];
  List<String> _activeModules = [];
  List<String> _inactiveModules = [];

  static const List<String> allAvailableModules = [
    'services',
    'services_app',
    'messages',
    'inventory',
    'settings',
    'qiyas',
    'knowledge_hub',
    'employees',
    'tasks',
    'grc',
    'database',
    'events',
    'notes',
    'requests',
    'tracking',
    'database_builder',
    'roles',
    'hr',
    'crm',
    'notification',
  ];

  void _publish() {
    emit(ModulesReady(
      modules: List.unmodifiable(_modules),
      modulesEdit: List.unmodifiable(_modulesEdit),
      accesses: List.unmodifiable(_accesses),
      accessesEdit: List.unmodifiable(_accessesEdit),
      activeModules: List.unmodifiable(_activeModules),
      inactiveModules: List.unmodifiable(_inactiveModules),
    ));
  }

  // ── Role module state ─────────────────────────────────────────────────────

  void getRoleModulesState(RoleHistoryModel role) {
    _activeModules = getRoleActiveModules(role);
    _computeInactiveModules();
    _publish();
  }

  /// True for the platform-wide admin roles, which are entitled to every module
  /// rather than only the ones frozen into their Current_Selected_Modules array.
  ///
  /// Case-insensitive on purpose: getDemoActiveModules() looks the role up as
  /// "Super admin", so a `== 'super admin'` comparison never matched and admins
  /// silently fell back to their stored (stale) module list — which is why
  /// modules added later, like hr and crm, never showed up.
  static bool isPlatformAdminRole(String roleName) {
    final String name = roleName.toLowerCase().trim();
    return name == 'super admin' ||
        name == 'master admin' ||
        name == 'admin' ||
        name == 'administrator';
  }

  List<String> getRoleActiveModules(RoleHistoryModel role) {
    List<String> activeModules =
        List<String>.from(role.currentSelectedModules);

    if (isPlatformAdminRole(role.currentRoleName)) {
      activeModules = List<String>.from(allAvailableModules);
    }

    removeAllDemoNotAllowedModules(role, activeModules);

    return activeModules;
  }

  void removeAllDemoNotAllowedModules(
      RoleHistoryModel role, List<String> activeModules) {
    // Must use the same case-insensitive check as getRoleActiveModules: this
    // guard is what stops the admin role from recursing back into
    // getDemoActiveModules() -> getRoleActiveModules() -> here.
    if (!isPlatformAdminRole(role.currentRoleName)) {
      List<String> demoActiveModules = getDemoActiveModules();
      List<String> needsToBeRemoved = [];

      for (String module in activeModules) {
        if (!demoActiveModules.contains(module)) {
          needsToBeRemoved.add(module);
        }
      }

      for (String module in needsToBeRemoved) {
        activeModules.remove(module);
      }
    }
  }

  void _computeInactiveModules() {
    _inactiveModules = [];
    List<String> demoActiveModules = getDemoActiveModules();

    for (String module in allAvailableModules) {
      if (!_activeModules.contains(module) &&
          demoActiveModules.contains(module)) {
        _inactiveModules.add(module);
      }
    }
  }

  List<Modules> getDemoActiveModulesAsEnums() {
    List<String> activeModuleStrings = getDemoActiveModules();
    List<Modules> activeModuleEnums = [];

    for (String moduleName in activeModuleStrings) {
      activeModuleEnums.add(_getModuleEnum(moduleName));
    }

    return activeModuleEnums;
  }

  // ── Module / access list building ─────────────────────────────────────────

  Future<void> getModules() async {
    emit(const ModulesLoading());
    _modules.clear();
    _modulesEdit.clear();
    _accesses.clear();
    _accessesEdit.clear();
    _buildInactiveModules();
    await _buildAccessModules();
    _publish();
  }

  void _buildInactiveModules() {
    for (int i = 0; i < _inactiveModules.length; i++) {
      String moduleName = _inactiveModules[i];
      Modules moduleEnum = _getModuleEnum(moduleName);

      _modules.add(
        ModuleItem(
          imageUrl: moduleEnum.iconPath,
          isSelected: false,
          text: moduleEnum.getModuleName,
        ),
      );
      _modulesEdit.add(false);
    }
  }

  Future<void> _buildAccessModules() async {
    if (roleCubit.selectedRole == null) return;

    RoleHistoryModel role = roleCubit.selectedRole!;

    for (int i = 0; i < _activeModules.length; i++) {
      String moduleName = _activeModules[i];
      Modules moduleEnum = _getModuleEnum(moduleName);

      var permissionData =
          await _getModulePermissionData(role.currentRoleName, moduleName);

      _accesses.add(
        AccessData(
          text: moduleEnum.getModuleName,
          accessIcon: moduleEnum.iconPath,
          grantedBy: permissionData['grantedBy'] ?? 'System',
          grantedDate: permissionData['grantedDate'] ?? 'Unknown',
          isRemoved: true,
        ),
      );
      _accessesEdit.add(true);
    }
  }

  Future<Map<String, String>> _getModulePermissionData(
      String roleId, String moduleName) async {
    try {
      var result = await roleRepository.getRolePermissions(
          roleId: roleId, module: moduleName);

      if (result.isRight()) {
        Map<String, dynamic>? permissions = result.getOrElse(() => null);
        if (permissions != null && permissions.containsKey('timestamps')) {
          List<int> timestamps =
              List<int>.from(permissions['timestamps'] ?? []);
          if (timestamps.isNotEmpty) {
            DateTime grantedDate =
                DateTime.fromMillisecondsSinceEpoch(timestamps.last);
            return {
              'grantedBy': 'System',
              'grantedDate': DateFormat('MMM dd, yyyy').format(grantedDate),
            };
          }
        }
      }
    } catch (e) {
      // Silently handle error
    }

    return {
      'grantedBy': 'System',
      'grantedDate': DateFormat('MMM dd, yyyy').format(DateTime.now()),
    };
  }

  Modules _getModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase()) {
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
        return Modules.knowledgeHub;
      case 'grc':
        return Modules.grc;
      case 'qiyas':
        return Modules.qiyas;
      case 'tracking':
        return Modules.tracking;
      case 'inventory':
        return Modules.inventory;
      case 'messages':
        return Modules.messages;
      case 'database_builder':
        return Modules.database;
      case 'database':
        return Modules.database;
      case 'services_app':
        return Modules.formBuilder;
      case 'roles':
        return Modules.roles;
      case 'settings':
        return Modules.settings;
      case 'hr':
        return Modules.hr;
      case 'crm':
        return Modules.crm;
      case 'notification':
        return Modules.notification;
      default:
        return Modules.employees;
    }
  }

  String _getModuleString(Modules module) {
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
      case Modules.grc:
        return 'grc';
      case Modules.database:
        return 'database';
      case Modules.tracking:
        return 'tracking';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.formBuilder:
        return 'services_app';
      case Modules.roles:
        return 'roles';
      case Modules.settings:
        return 'settings';
      case Modules.hr:
        return 'hr';
      case Modules.crm:
        return 'crm';
      case Modules.notification:
        return 'notification';
      default:
        return 'employees';
    }
  }

  // ── Role mutations ────────────────────────────────────────────────────────

  Future<void> updateRoleModules() async {
    if (roleCubit.selectedRole == null) return;

    List<String> newSelectedModules = [];

    for (int i = 0; i < _modules.length; i++) {
      if (_modules[i].isSelected) {
        newSelectedModules.add(_inactiveModules[i]);
      }
    }

    for (int i = 0; i < _accesses.length; i++) {
      if (_accesses[i].isRemoved) {
        newSelectedModules.add(_activeModules[i]);
      }
    }

    RoleHistoryModel updatedRole = roleCubit.selectedRole!.copyWith(
      selectedModules: newSelectedModules,
    );

    roleCubit.selectedRole = updatedRole;
    _publish();
  }

  Future<void> addModulesToRole({
    required RoleHistoryModel role,
    required List<String> moduleNames,
    required String email,
    Map<String, Map<String, bool>>? modulePermissions,
  }) async {
    try {
      List<String> updatedModules =
          List<String>.from(role.currentSelectedModules);

      for (String moduleName in moduleNames) {
        if (!updatedModules.contains(moduleName)) {
          updatedModules.add(moduleName);
        }
      }

      RoleHistoryModel updatedRole =
          role.copyWith(selectedModules: updatedModules);

      if (modulePermissions != null) {
        for (String moduleName in moduleNames) {
          if (modulePermissions.containsKey(moduleName)) {
            await roleRepository.updateModulePermissions(
              roleId: role.currentRoleName,
              module: moduleName,
              permissions: modulePermissions[moduleName]!,
            );
          }
        }
      }

      roleCubit.selectedRole = updatedRole;
      _publish();
    } catch (e) {
      emit(ModulesError(e.toString()));
    }
  }

  Future<void> removeModulesFromRole({
    required RoleHistoryModel role,
    required List<String> moduleNames,
  }) async {
    try {
      List<String> updatedModules =
          List<String>.from(role.currentSelectedModules);

      for (String moduleName in moduleNames) {
        updatedModules.remove(moduleName);
      }

      RoleHistoryModel updatedRole =
          role.copyWith(selectedModules: updatedModules);
      roleCubit.selectedRole = updatedRole;
      _publish();
    } catch (e) {
      emit(ModulesError(e.toString()));
    }
  }

  // ── Queries (pure; do not emit) ───────────────────────────────────────────

  List<String> getDemoActiveModules() {
    try {
      // Case-insensitive, and accepts any platform admin role name ("Super
      // admin", "Master Admin", ...) — the exact-string lookup missed the demo
      // company's "Master Admin" role and silently fell through to the
      // hardcoded fallback list below.
      RoleHistoryModel superAdminRole = roleCubit.roles
          .firstWhere((element) => isPlatformAdminRole(element.currentRoleName));

      return getRoleActiveModules(superAdminRole);
    } catch (e) {
      return [
        'services',
        'services_app',
        'messages',
        'employees',
        'inventory',
        'grc',
        'knowledgeHub',
        'events',
        'qiyas',
        'database',
        'settings',
        'tasks',
        'tracking',
        'roles',
        'hr',
        'crm',
        'notification',
      ];
    }
  }

  Future<Map<String, bool>> getFilteredDefaultPermissionsForModule(
      String moduleName) async {
    Map<String, bool> allPermissions =
        getDefaultPermissionsForModule(moduleName);

    try {
      String companyId = _getCompanyId();

      if (companyId.isEmpty) {
        return {};
      }

      DocumentSnapshot demoPermDoc = await roleRepository.firestore
          .collection('Demo_Permissions')
          .doc(companyId)
          .get();

      if (!demoPermDoc.exists) {
        return {};
      }

      Map<String, dynamic> demoPermissions =
          demoPermDoc.data() as Map<String, dynamic>;

      if (!demoPermissions.containsKey(moduleName)) {
        return {};
      }

      if (demoPermissions[moduleName] is! Map) {
        return {};
      }

      Map<String, dynamic> modulePermissions =
          Map<String, dynamic>.from(demoPermissions[moduleName]);

      if (allPermissions.isEmpty) {
        Map<String, bool> rawPermissions = {};

        modulePermissions.forEach((key, value) {
          if (key != 'Role_Id' && key != 'timestamps') {
            if (value == true) {
              rawPermissions[key] = true;
            }
          }
        });

        return rawPermissions;
      }

      Map<String, bool> filteredPermissions = {};

      modulePermissions.forEach((key, value) {
        if (key != 'Role_Id' && key != 'timestamps') {
          if (allPermissions.containsKey(key) && value == true) {
            filteredPermissions[key] = true;
          }
        }
      });

      return filteredPermissions;
    } catch (e) {
      return {};
    }
  }

  String _getCompanyId() {
    try {
      String baseUrl = getBaseUrl('');

      String companyId =
          baseUrl.replaceAll('Demo/', '').replaceAll('/', '').trim();

      if (companyId.isNotEmpty && companyId != 'Demo') {
        return companyId;
      }

      List<String> parts = baseUrl.split('/');

      if (parts.length >= 2) {
        companyId = parts[1].trim();
        if (companyId.isNotEmpty) {
          return companyId;
        }
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  Map<String, bool> getDefaultPermissionsForModule(String moduleName) {
    Map<String, bool> permissions = {};

    switch (moduleName.toLowerCase()) {
      case 'services':
        Modules module = Modules.services;
        for (Enum section in module.moduleFirstColumnPermissions) {
          if (section is ModulePermissionsSections &&
              section is ModulePermissionsSectionsPermission) {
            // `section` is declared as `Enum`, and these interfaces are not
            // subtypes of `Enum`, so `is` cannot promote it — cast explicitly.
            ModulePermissionsSections sectionInterface =
                section as ModulePermissionsSections;
            ModulePermissionsSectionsPermission permissionInterface =
                section as ModulePermissionsSectionsPermission;
            String sectionDbName =
                _convertToDbFormat(permissionInterface.getDataBaseName);
            permissions[sectionDbName] = false;
            for (Enum permission in sectionInterface.sectionPermissions) {
              ModulePermissionsSectionsPermission perm =
                  permission as ModulePermissionsSectionsPermission;
              String dbName = _convertToDbFormat(perm.getDataBaseName);
              permissions[dbName] = false;
            }
          }
        }
        for (Enum section in module.moduleLastColumnPermissions) {
          if (section is ModulePermissionsSections &&
              section is ModulePermissionsSectionsPermission) {
            // `section` is declared as `Enum`, and these interfaces are not
            // subtypes of `Enum`, so `is` cannot promote it — cast explicitly.
            ModulePermissionsSections sectionInterface =
                section as ModulePermissionsSections;
            ModulePermissionsSectionsPermission permissionInterface =
                section as ModulePermissionsSectionsPermission;
            String sectionDbName =
                _convertToDbFormat(permissionInterface.getDataBaseName);
            permissions[sectionDbName] = false;
            for (Enum permission in sectionInterface.sectionPermissions) {
              ModulePermissionsSectionsPermission perm =
                  permission as ModulePermissionsSectionsPermission;
              String dbName = _convertToDbFormat(perm.getDataBaseName);
              permissions[dbName] = false;
            }
          }
        }
        return permissions;

      case 'hr':
        // Return empty map - will use RAW Demo_Permissions data
        return {};

      case 'crm':
        // Return empty map - will use RAW Demo_Permissions data
        return {};

      case 'notification':
        // Return empty map - will use RAW Demo_Permissions data
        return {};

      default:
        return {};
    }
  }

  String _convertToDbFormat(String displayName) {
    return displayName.trim().replaceAll(RegExp(r'\s+'), '_');
  }

  Future<void> updateModulePermissions({
    required String roleId,
    required String moduleName,
    required Map<String, bool> permissions,
  }) async {
    try {
      await roleRepository.updateModulePermissions(
        roleId: roleId,
        module: moduleName,
        permissions: permissions,
      );
    } catch (e) {
      emit(ModulesError(e.toString()));
    }
  }

  Future<Map<String, bool>> loadModulePermissions({
    required String roleId,
    required String moduleName,
  }) async {
    try {
      var result = await roleRepository.getRolePermissions(
        roleId: roleId,
        module: moduleName,
      );

      if (result.isRight()) {
        Map<String, dynamic>? permissions = result.getOrElse(() => null);
        if (permissions != null) {
          Map<String, bool> modulePermissions = {};

          permissions.forEach((key, value) {
            if (key != 'Role_Id' &&
                key != 'timestamps' &&
                value is List &&
                value.isNotEmpty) {
              modulePermissions[key] = value.last == true;
            }
          });

          return modulePermissions;
        }
      }
    } catch (e) {
      // Silently handle error
    }

    return getDefaultPermissionsForModule(moduleName);
  }

  List<String> getModulesNeedingPermissions() {
    return [
      'services',
      'services_app',
      'messages',
      'inventory',
      'settings',
      'qiyas',
      'knowledge_hub',
      'roles',
      'hr',
      'crm',
      'notification',
    ];
  }

  List<String> validateModulesForRole(
      RoleHistoryModel role, List<String> requestedModules) {
    List<String> availableModules = getDemoActiveModules();
    List<String> validModules = [];

    for (String module in requestedModules) {
      if (availableModules.contains(module) ||
          isPlatformAdminRole(role.currentRoleName)) {
        validModules.add(module);
      }
    }

    return validModules;
  }

  Map<String, dynamic> getModuleStatistics() {
    Map<String, int> moduleUsage = {};

    for (RoleHistoryModel role in roleCubit.roles) {
      for (String module in role.currentSelectedModules) {
        moduleUsage[module] = (moduleUsage[module] ?? 0) + 1;
      }
    }

    return {
      'totalRoles': roleCubit.roles.length,
      'moduleUsage': moduleUsage,
      'mostUsedModule': moduleUsage.isNotEmpty
          ? moduleUsage.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : 'none',
      'totalUniqueModules': moduleUsage.keys.length,
    };
  }

  @Deprecated('Use new architecture with selectedModules instead')
  Map<Modules, ModulePermissionModel?> mapEachSelectedModuleToItsModel(
      RoleModel role) {
    Map<Modules, ModulePermissionModel?> modulesMap = {};
    if (role.employeeModule?.granted == true) {
      modulesMap[Modules.employees] = role.employeeModule;
    }
    if (role.serviceModule?.granted == true) {
      modulesMap[Modules.services] = role.serviceModule;
    }
    if (role.taskModule?.granted == true) {
      modulesMap[Modules.tasks] = role.taskModule;
    }
    if (role.messageModule?.granted == true) {
      modulesMap[Modules.messages] = role.messageModule;
    }
    if (role.noteModule?.granted == true) {
      modulesMap[Modules.notes] = role.noteModule;
    }
    if (role.reqestModule?.granted == true) {
      modulesMap[Modules.requests] = role.reqestModule;
    }
    if (role.knowledgeHubModule?.granted == true) {
      modulesMap[Modules.knowledgeHub] = role.knowledgeHubModule;
    }
    if (role.dataGRCModule?.granted == true) {
      modulesMap[Modules.qiyas] = role.dataGRCModule;
    }
    if (role.trackingModule?.granted == true) {
      modulesMap[Modules.tracking] = role.trackingModule;
    }
    if (role.inventoryModule?.granted == true) {
      modulesMap[Modules.inventory] = role.inventoryModule;
    }
    if (role.databaseBuilderModule?.granted == true) {
      modulesMap[Modules.database] = role.databaseBuilderModule;
    }
    if (role.formBuilderModule?.granted == true) {
      modulesMap[Modules.formBuilder] = role.formBuilderModule;
    }
    if (role.eventModule?.granted == true) {
      modulesMap[Modules.events] = role.eventModule;
    }
    if (role.todoModule?.granted == true) {
      modulesMap[Modules.todo] = role.todoModule;
    }
    if (role.roleModule?.granted == true) {
      modulesMap[Modules.roles] = role.roleModule;
    }
    if (role.hrModule?.granted == true) {
      modulesMap[Modules.hr] = role.hrModule;
    }
    if (role.crmModule?.granted == true) {
      modulesMap[Modules.crm] = role.crmModule;
    }
    if (role.notificationModule?.granted == true) {
      modulesMap[Modules.notification] = role.notificationModule;
    }
    return modulesMap;
  }

  List<String> getRoleActiveModulesNew(RoleHistoryModel role) {
    return List<String>.from(role.currentSelectedModules);
  }

  bool isModuleActive(RoleHistoryModel role, String moduleName) {
    return role.currentSelectedModules.contains(moduleName);
  }
}
