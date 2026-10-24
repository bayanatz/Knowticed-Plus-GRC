/// Module: roles/r1_role_management
///
///*************************** FILE INFO ****************************///
/// File Name: modules_cubit_methods.dart
/// Description: Methods of `ModulesCubit` — split out of `modules_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../modules_cubit.dart';

// Split from modules_cubit.dart to keep every file under 700 lines.

extension ModulesCubitMethods on ModulesCubit {
  Modules _getModuleEnum(String moduleName) {
    // Canonical first, so a stored `form_builder` resolves like `services_app`
    // instead of falling through to the `employees` default (23/8/2026).
    switch (ModuleNameAliases.canonical(moduleName)) {
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
      case 'time_tracker': // ADDED 8/10/2026 — Time Tracker
        return Modules.timeTracker;
      default:
        return Modules.employees;
    }
  }

  Future<Map<String, bool>> getFilteredDefaultPermissionsForModule(
    String moduleName,
  ) async {
    Map<String, bool> allPermissions = getDefaultPermissionsForModule(
      moduleName,
    );

    try {
      String companyId = _getCompanyId();

      if (companyId.isEmpty) {
        return {};
      }

      DocumentSnapshot demoPermDoc = await roleRepository.firestore
          .collection(FirebaseCollections.demoPermissions)
          .doc(companyId)
          .get();

      if (!demoPermDoc.exists) {
        return {};
      }

      Map<String, dynamic> demoPermissions =
          demoPermDoc.data() as Map<String, dynamic>;

      // Try every spelling this module is stored under (23/8/2026). The form
      // builder's template is keyed `form_builder` in `Demo_Permissions`, while
      // the rest of the code calls the module `services_app` — asking for one
      // name only meant the module read as having no template at all and came
      // back with no permissions. See [ModuleNameAliases].
      String? storedKey;
      for (final String spelling in ModuleNameAliases.spellingsOf(moduleName)) {
        if (demoPermissions[spelling] is Map) {
          storedKey = spelling;
          break;
        }
      }

      if (storedKey == null) {
        return {};
      }

      Map<String, dynamic> modulePermissions = Map<String, dynamic>.from(
        demoPermissions[storedKey],
      );

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

  /// Function Name: [_permissionsFromEnums]
  ///
  /// Purpose: Every permission key a module declares through its section enums,
  ///          each defaulted to `false`.
  ///
  /// EXTRACTED 2/9/2026 — this was written twice inside the `services` case,
  /// once per column, and adding a second enum-backed module would have made it
  /// four copies. Behaviour is unchanged: both columns are walked in the same
  /// order and each section contributes its own key before its children's.
  ///
  /// A column with no sections contributes nothing, which is what
  /// `Modules.notification` relies on — its design has one column and
  /// `moduleLastColumnPermissions` is deliberately empty.
  ///
  /// Parameters:
  /// - [module]: The module whose enum columns to read.
  ///
  /// Returns: [Map<String, bool>] section and permission keys, all `false`.
  Map<String, bool> _permissionsFromEnums(Modules module) {
    final Map<String, bool> permissions = <String, bool>{};

    for (final Enum section in <Enum>[
      ...module.moduleFirstColumnPermissions,
      ...module.moduleLastColumnPermissions,
    ]) {
      // `section` is declared as `Enum`, and these interfaces are not subtypes
      // of `Enum`, so `is` cannot promote it — cast explicitly.
      if (section is! ModulePermissionsSections ||
          section is! ModulePermissionsSectionsPermission) {
        continue;
      }

      final ModulePermissionsSections sectionInterface =
          section as ModulePermissionsSections;
      final ModulePermissionsSectionsPermission permissionInterface =
          section as ModulePermissionsSectionsPermission;

      permissions[_convertToDbFormat(permissionInterface.getDataBaseName)] =
          false;

      for (final Enum permission in sectionInterface.sectionPermissions) {
        final ModulePermissionsSectionsPermission perm =
            permission as ModulePermissionsSectionsPermission;
        permissions[_convertToDbFormat(perm.getDataBaseName)] = false;
      }
    }

    return permissions;
  }

  @Deprecated('Use new architecture with selectedModules instead')
  Map<Modules, ModulePermissionModel?> mapEachSelectedModuleToItsModel(
    RoleModel role,
  ) {
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
}
