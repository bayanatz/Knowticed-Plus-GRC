  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
  import 'package:get/get.dart';
  import 'package:intl/intl.dart';
  import 'package:demo_app/features/roles/role_management/data/models/role_model.dart';
  import 'package:demo_app/features/roles/role_management/data/repository/role_repository.dart';
  import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
  import 'package:demo_app/features/roles/role_management/domain/interfaces/module_permissions_sections.dart';
  import 'package:demo_app/features/roles/role_management/domain/interfaces/module_permissions_sections_permissions.dart';

  import 'package:demo_app/core/network/get_base_url.dart';
  
  import 'package:demo_app/features/settings/presentation/controller/settings_controller.dart';
  import 'package:demo_app/features/roles/role_management/data/models/module_permission_model.dart';
  import 'package:demo_app/features/roles/role_management/domain/entity/access_data.dart';
  import 'package:demo_app/features/roles/role_management/domain/entity/module_item.dart';
  import 'package:demo_app/features/roles/role_management/utils/constants.dart';
  import 'package:demo_app/features/roles/role_management/ui/pages/role_responsive_page.dart';

  class ModulesController extends GetxController {
    RoleRepository roleRepository = RoleRepository();

    List<ModuleItem> modules = [];
    List<bool> modulesEdit = [];
    List<AccessData> accesses = [];
    List<bool> accessesEdit = [];

    List<String> currentSelectedRoleActiveModules = [];
    List<String> currentSelectedRoleInactiveModules = [];

    final List<String> allAvailableModules = [
      'services',
      'form_builder',
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
      'hr',           // ✅ ADDED
      'notification', // ✅ ADDED
    ];

    getRoleModulesState(RoleHistoryModel role) {
      currentSelectedRoleActiveModules = getRoleActiveModules(role);
      _getRoleInactiveModules();
    }

    List<String> getRoleActiveModules(RoleHistoryModel role) {
      List<String> activeModules = List<String>.from(role.currentSelectedModules);

      if (role.currentRoleName == 'super admin') {
        activeModules = List<String>.from(allAvailableModules);
      }

      removeAllDemoNotAllowedModules(role, activeModules);

      return activeModules;
    }

    void removeAllDemoNotAllowedModules(RoleHistoryModel role, List<String> activeModules) {
      if (role.currentRoleName != "super admin") {
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

    _getRoleInactiveModules() {
      currentSelectedRoleInactiveModules = [];
      List<String> demoActiveModules = getDemoActiveModules();

      for (String module in allAvailableModules) {
        if (!currentSelectedRoleActiveModules.contains(module) &&
            demoActiveModules.contains(module)) {
          currentSelectedRoleInactiveModules.add(module);
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

    void getModules() {
      modules = [];
      modulesEdit = [];
      accesses = [];
      accessesEdit = [];
      _getInactiveModules();
      _getAccessModules();
    }

    void _getInactiveModules() {
      for (int i = 0; i < currentSelectedRoleInactiveModules.length; i++) {
        String moduleName = currentSelectedRoleInactiveModules[i];
        Modules moduleEnum = _getModuleEnum(moduleName);

        modules.add(
          ModuleItem(
            imageUrl: moduleEnum.iconPath,
            isSelected: false,
            text: moduleEnum.getModuleName,
          ),
        );
        modulesEdit.add(false);
      }
    }

    void _getAccessModules() async {
      if (roleCubit.selectedRole == null) return;

      RoleHistoryModel role = roleCubit.selectedRole!;
      EmployeeController addEmployeeController = Get.find<EmployeeController>();

      for (int i = 0; i < currentSelectedRoleActiveModules.length; i++) {
        String moduleName = currentSelectedRoleActiveModules[i];
        Modules moduleEnum = _getModuleEnum(moduleName);

        var permissionData = await _getModulePermissionData(role.currentRoleName, moduleName);

        accesses.add(
          AccessData(
            text: moduleEnum.getModuleName,
            accessIcon: moduleEnum.iconPath,
            grantedBy: permissionData['grantedBy'] ?? 'System',
            grantedDate: permissionData['grantedDate'] ?? 'Unknown',
            isRemoved: true,
          ),
        );
        accessesEdit.add(true);
      }
    }

    Future<Map<String, String>> _getModulePermissionData(String roleId, String moduleName) async {
      try {
        var result = await roleRepository.getRolePermissions(roleId: roleId, module: moduleName);

        if (result.isRight()) {
          Map<String, dynamic>? permissions = result.getOrElse(() => null);
          if (permissions != null && permissions.containsKey('timestamps')) {
            List<int> timestamps = List<int>.from(permissions['timestamps'] ?? []);
            if (timestamps.isNotEmpty) {
              DateTime grantedDate = DateTime.fromMillisecondsSinceEpoch(timestamps.last);
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

    // ✅ UPDATED: Added HR and Notification cases
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
        case 'form_builder':
          return Modules.formBuilder;
        case 'roles':
          return Modules.roles;
        case 'settings':
          return Modules.settings;
        case 'hr':  // ✅ ADDED
          return Modules.hr;
        case 'notification':  // ✅ ADDED
          return Modules.notification;
        default:
          return Modules.employees;
      }
    }

    // ✅ UPDATED: Added HR and Notification cases
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
          return 'form_builder';
        case Modules.roles:
          return 'roles';
        case Modules.settings:
          return 'settings';
        case Modules.hr:  // ✅ ADDED
          return 'hr';
        case Modules.notification:  // ✅ ADDED
          return 'notification';
        default:
          return 'employees';
      }
    }

    updateRoleModules() async {
      if (roleCubit.selectedRole == null) return;

      List<String> newSelectedModules = [];

      for (int i = 0; i < modules.length; i++) {
        if (modules[i].isSelected) {
          newSelectedModules.add(currentSelectedRoleInactiveModules[i]);
        }
      }

      for (int i = 0; i < accesses.length; i++) {
        if (accesses[i].isRemoved) {
          newSelectedModules.add(currentSelectedRoleActiveModules[i]);
        }
      }

      RoleHistoryModel updatedRole = roleCubit.selectedRole!.copyWith(
        selectedModules: newSelectedModules,
      );

      roleCubit.selectedRole = updatedRole;
    }

    Future<void> addModulesToRole({
      required RoleHistoryModel role,
      required List<String> moduleNames,
      required String email,
      Map<String, Map<String, bool>>? modulePermissions,
    }) async {
      try {
        List<String> updatedModules = List<String>.from(role.currentSelectedModules);

        for (String moduleName in moduleNames) {
          if (!updatedModules.contains(moduleName)) {
            updatedModules.add(moduleName);
          }
        }

        RoleHistoryModel updatedRole = role.copyWith(selectedModules: updatedModules);

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
      } catch (e) {
        // Silently handle error
      }
    }

    Future<void> removeModulesFromRole({
      required RoleHistoryModel role,
      required List<String> moduleNames,
    }) async {
      try {
        List<String> updatedModules = List<String>.from(role.currentSelectedModules);

        for (String moduleName in moduleNames) {
          updatedModules.remove(moduleName);
        }

        RoleHistoryModel updatedRole = role.copyWith(selectedModules: updatedModules);
        roleCubit.selectedRole = updatedRole;
      } catch (e) {
        // Silently handle error
      }
    }

    List<String> getDemoActiveModules() {
      try {
        RoleHistoryModel superAdminRole = roleCubit.roles
            .firstWhere((element) => element.currentRoleName == "Super admin");

        return getRoleActiveModules(superAdminRole);
      } catch (e) {
        return [
          'services',
          'form_builder',
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
          'hr',           // ✅ ADDED
          'notification', // ✅ ADDED
        ];
      }
    }

    Future<Map<String, bool>> getFilteredDefaultPermissionsForModule(String moduleName) async {

      Map<String, bool> allPermissions = getDefaultPermissionsForModule(moduleName);


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

        Map<String, dynamic> demoPermissions = demoPermDoc.data() as Map<String, dynamic>;


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
        int allowedCount = 0;

        modulePermissions.forEach((key, value) {
          if (key != 'Role_Id' && key != 'timestamps') {
            if (allPermissions.containsKey(key) && value == true) {
              filteredPermissions[key] = true;
              allowedCount++;
            }
          }
        });

        return filteredPermissions;

      } catch (e, stackTrace) {
        return {};
      }
    }

    String _getCompanyId() {
      try {
        String baseUrl = getBaseUrl('');

        String companyId = baseUrl
            .replaceAll('Demo/', '')
            .replaceAll('/', '')
            .trim();


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
            if (section is ModulePermissionsSections && section is ModulePermissionsSectionsPermission) {
              ModulePermissionsSections sectionInterface = section as ModulePermissionsSections;
              ModulePermissionsSectionsPermission permissionInterface = section as ModulePermissionsSectionsPermission;
              String sectionDbName = _convertToDbFormat(permissionInterface.getDataBaseName);
              permissions[sectionDbName] = false;
              for (Enum permission in sectionInterface.sectionPermissions) {
                ModulePermissionsSectionsPermission perm = permission as ModulePermissionsSectionsPermission;
                String dbName = _convertToDbFormat(perm.getDataBaseName);
                permissions[dbName] = false;
              }
            }
          }
          for (Enum section in module.moduleLastColumnPermissions) {
            if (section is ModulePermissionsSections && section is ModulePermissionsSectionsPermission) {
              ModulePermissionsSections sectionInterface = section as ModulePermissionsSections;
              ModulePermissionsSectionsPermission permissionInterface = section as ModulePermissionsSectionsPermission;
              String sectionDbName = _convertToDbFormat(permissionInterface.getDataBaseName);
              permissions[sectionDbName] = false;
              for (Enum permission in sectionInterface.sectionPermissions) {
                ModulePermissionsSectionsPermission perm = permission as ModulePermissionsSectionsPermission;
                String dbName = _convertToDbFormat(perm.getDataBaseName);
                permissions[dbName] = false;
              }
            }
          }
          return permissions;

      // ✅ ADD HR CASE
        case 'hr':
        // Return empty map - will use RAW Demo_Permissions data
          return {};

      // ✅ ADD NOTIFICATION CASE
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
        // Silently handle error
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
              if (key != 'Role_Id' && key != 'timestamps' && value is List && value.isNotEmpty) {
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
        'form_builder',
        'messages',
        'inventory',
        'settings',
        'qiyas',
        'knowledge_hub',
        'roles',
        'hr',           // ✅ ADDED
        'notification', // ✅ ADDED
      ];
    }

    List<String> validateModulesForRole(RoleHistoryModel role, List<String> requestedModules) {
      List<String> availableModules = getDemoActiveModules();
      List<String> validModules = [];

      for (String module in requestedModules) {
        if (availableModules.contains(module) || role.currentRoleName == 'super admin') {
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
    Map<Modules, ModulePermissionModel?> mapEachSelectedModuleToItsModel(RoleModel role) {
      Map<Modules, ModulePermissionModel?> modulesMap = {};
      if (role.employeeModule?.granted == true) modulesMap[Modules.employees] = role.employeeModule;
      if (role.serviceModule?.granted == true) modulesMap[Modules.services] = role.serviceModule;
      if (role.taskModule?.granted == true) modulesMap[Modules.tasks] = role.taskModule;
      if (role.messageModule?.granted == true) modulesMap[Modules.messages] = role.messageModule;
      if (role.noteModule?.granted == true) modulesMap[Modules.notes] = role.noteModule;
      if (role.reqestModule?.granted == true) modulesMap[Modules.requests] = role.reqestModule;
      if (role.knowledgeHubModule?.granted == true) modulesMap[Modules.knowledgeHub] = role.knowledgeHubModule;
      if (role.dataGRCModule?.granted == true) modulesMap[Modules.qiyas] = role.dataGRCModule;
      if (role.trackingModule?.granted == true) modulesMap[Modules.tracking] = role.trackingModule;
      if (role.inventoryModule?.granted == true) modulesMap[Modules.inventory] = role.inventoryModule;
      if (role.databaseBuilderModule?.granted == true) modulesMap[Modules.database] = role.databaseBuilderModule;
      if (role.formBuilderModule?.granted == true) modulesMap[Modules.formBuilder] = role.formBuilderModule;
      if (role.eventModule?.granted == true) modulesMap[Modules.events] = role.eventModule;
      if (role.todoModule?.granted == true) modulesMap[Modules.todo] = role.todoModule;
      if (role.roleModule?.granted == true) modulesMap[Modules.roles] = role.roleModule;
      if (role.hrModule?.granted == true) modulesMap[Modules.hr] = role.hrModule;  // ✅ ADDED
      if (role.notificationModule?.granted == true) modulesMap[Modules.notification] = role.notificationModule;  // ✅ ADDED
      return modulesMap;
    }

    List<String> getRoleActiveModulesNew(RoleHistoryModel role) {
      return List<String>.from(role.currentSelectedModules);
    }

    bool isModuleActive(RoleHistoryModel role, String moduleName) {
      return role.currentSelectedModules.contains(moduleName);
    }
  }