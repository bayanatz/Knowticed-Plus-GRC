/// Module: roles/r1_role_management
///
///*************************** FILE INFO ****************************///
/// File Name: role_history_model_statics.dart
/// Description: `_RoleHistoryModelStatics` data model — split out of `role_model.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../role_model.dart';

// Split from role_model.dart to keep every file under 700 lines.

abstract final class _RoleHistoryModelStatics {
  static RoleHistoryModel factoryFromMap(Map<String, dynamic> map) {
    try {
      final List<int> sharedTimestamps =
          (map[RoleHistoryModel.kTimestampsKey] as List<dynamic>?)
                  ?.map((e) => e is int ? e : (e as num).toInt())
                  .toList() ??
              [DateTime.now().millisecondsSinceEpoch];

      // Parse role name with multiple fallbacks
      var roleNameData = map[RoleHistoryModel.kAccessNameKey] ??
          map[RoleHistoryModel.kAccessNameKeyAlt] ??
          map[RoleHistoryModel.kAccessNameKeyAlt2] ??
          map['roleName'];

      if (roleNameData == null ||
          (roleNameData is List && roleNameData.isEmpty) ||
          (roleNameData is String && roleNameData.isEmpty)) {
        String? docId = map['_documentId'];
        if (docId != null && docId.isNotEmpty) {
          roleNameData = [docId];
        }
      }

      var roleNameArData = map[RoleHistoryModel.kAccessNameArKey] ??
          map[RoleHistoryModel.kAccessNameArKeyAlt] ??
          map[RoleHistoryModel.kAccessNameArKeyAlt2];
      var roleDescData = map[RoleHistoryModel.kRoleDescriptionKey] ??
          map[RoleHistoryModel.kRoleDescriptionKeyAlt];
      var roleDescArData = map[RoleHistoryModel.kRoleDescriptionArKey] ??
          map[RoleHistoryModel.kRoleDescriptionArKeyAlt];
      var roleImageData = map[RoleHistoryModel.kAccessImageKey] ??
          map[RoleHistoryModel.kAccessImageKeyAlt] ??
          map[RoleHistoryModel.kAccessImageKeyAlt2];

      // ✅ CRITICAL FIX: Handle Selected_Modules OR selectedModules (both naming conventions)

      // ✅ CHECK BOTH: Selected_Modules (Roles) AND selectedModules (Subscription_Admin)
      var selectedModulesData = map[RoleHistoryModel.kSelectedModulesKey] ??
          map[RoleHistoryModel.kSelectedModulesKeyAlt];

      List<List<String>> parsedSelectedModules;

      if (selectedModulesData == null) {
        List<String> modulesFromOldStructure =
            RoleHistoryModel._extractModulesFromOldStructure(map);
        parsedSelectedModules = [modulesFromOldStructure];
      } else {
        if (selectedModulesData is List) {
          if ((selectedModulesData).isNotEmpty) {}
        }

        parsedSelectedModules =
            RoleHistoryModel._parseSelectedModulesList(selectedModulesData);

        if (parsedSelectedModules.isNotEmpty) {}
      }

      var parsedRoleName = RoleHistoryModel._parseListSafely(roleNameData);

      return RoleHistoryModel(
        roleId: map[RoleHistoryModel.kRoleIdKey] ?? map['_documentId'] ?? '',
        timestamps: sharedTimestamps,
        roleName: parsedRoleName,
        roleNameAr: RoleHistoryModel._parseListSafely(roleNameArData),
        roleDescription: RoleHistoryModel._parseListSafely(roleDescData),
        roleDescriptionAr: RoleHistoryModel._parseListSafely(roleDescArData),
        roleImage: RoleHistoryModel._parseListSafely(roleImageData),
        createdAt: RoleHistoryModel._parseTimestampList(
            map[RoleHistoryModel.kCreatedAtKey]),
        createdBy: RoleHistoryModel._parseListSafely(
            map[RoleHistoryModel.kCreatedByKey]),
        status:
            RoleHistoryModel._parseListSafely(map[RoleHistoryModel.kStatusKey]),
        selectedModules: parsedSelectedModules,
        editBy:
            RoleHistoryModel._parseEditByList(map[RoleHistoryModel.kEditByKey]),
      );
    } catch (e) {
      rethrow;
    }
  }

  static List<String> _extractModulesFromOldStructure(
      Map<String, dynamic> map) {
    List<String> modules = [];

    // Map of old field names to new module names
    Map<String, String> oldToNewModuleMap = {
      'Service_Module': 'services',
      'Employee_Module': 'employees',
      'Task_Module': 'tasks',
      'Todo_Module': 'todo',
      'Event_Module': 'events',
      'Note_Module': 'notes',
      'Request_Module': 'requests',
      'Reqest_Module': 'requests', // Typo in old structure
      'Knowledge_Hub_Module': 'knowledge_hub',
      'Data_GRC_Module': 'qiyas', // Keep this for backward compatibility
      'Grc_Module': 'grc', // ✅ ADD THIS - New GRC module
      'Time_Tracking_Module': 'tracking', // ✅ This should work now
      'Inventory_Module': 'inventory',
      'Message_Module': 'messages',
      'Database_Builder_Module': 'database_builder',
      'services_app_Module': 'services_app',
      'Role_Module': 'roles',
      'HR_Module': 'hr',
      'CRM_Module': 'crm',
      'Notification_Module': 'notification',
    };

    // Check each old field and add if it exists and is granted
    oldToNewModuleMap.forEach((oldKey, newModuleName) {
      if (map.containsKey(oldKey)) {
        var moduleData = map[oldKey];

        // Check if module is granted (exists and has granted: true)
        bool isGranted = false;

        if (moduleData is Map) {
          isGranted =
              moduleData['granted'] == true || moduleData['Granted'] == true;
        } else if (moduleData != null) {
          // If it exists and is not null, consider it granted
          isGranted = true;
        }

        if (isGranted) {
          modules.add(newModuleName);
        }
      }
    });

    // Always include settings
    if (!modules.contains('settings')) {
      modules.add('settings');
    }

    return modules;
  }

  static List<List<String>> _parseSelectedModulesList(dynamic value) {
    if (value == null) {
      return [[]];
    }

    if (value is List) {
      if (value.isEmpty) {
        return [[]];
      }

      // ✅ Case 1: Nested array (Roles collection - history format)
      if (value.first is List) {
        List<List<String>> result = value.map((e) {
          if (e is List) {
            return List<String>.from(e);
          }
          return <String>[];
        }).toList();

        return result;
      }

      // ✅ Case 2: Flat array of strings (Subscription_Admin format)
      if (value.first is String) {
        List<String> modules = List<String>.from(value);

        // ✅ CRITICAL: Wrap in array for history tracking
        List<List<String>> result = [modules];
        return result;
      }

      // // ✅ Fallback for unexpected types
      return [[]];
    }

    // Not a list at all
    return [[]];
  }

  static String _convertToJsonString(dynamic value) {
    if (value == null) return '{}';

    if (value is String) {
      if (value.trim().startsWith('{') && value.trim().endsWith('}')) {
        return value;
      }
      return '{}';
    }

    if (value is Map<String, dynamic>) {
      try {
        return jsonEncode(RoleHistoryModel._sanitizeMapForFirebase(value));
      } catch (e) {
        return '{}';
      }
    }

    return '{}';
  }

  static Map<String, dynamic> _sanitizeMapForFirebase(
      Map<String, dynamic> map) {
    Map<String, dynamic> result = {};

    map.forEach((key, value) {
      if (value is Timestamp) {
        result[key] = value.millisecondsSinceEpoch;
      } else if (value is List) {
        result[key] = value.map((item) {
          if (item is Timestamp) return item.millisecondsSinceEpoch;
          if (item is Map<String, dynamic>) {
            return RoleHistoryModel._sanitizeMapForFirebase(item);
          }
          return item;
        }).toList();
      } else if (value is Map<String, dynamic>) {
        result[key] = RoleHistoryModel._sanitizeMapForFirebase(value);
      } else {
        result[key] = value;
      }
    });

    return result;
  }

  static RoleHistoryModel factoryCreateNew({
    required String roleId,
    String roleName = '',
    String roleNameAr = '',
    String roleDescription = '',
    String roleDescriptionAr = '',
    String roleImage = '',
    Timestamp? createdAt,
    String createdBy = '',
    RoleStatus status = RoleStatus.active,
    List<String> selectedModules = const [],
    EditBy? editBy,
  }) {
    return RoleHistoryModel(
      roleId: roleId,
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      roleName: [roleName],
      roleNameAr: [roleNameAr],
      roleDescription: [roleDescription],
      roleDescriptionAr: [roleDescriptionAr],
      roleImage: [roleImage],
      createdAt: [createdAt ?? Timestamp.now()],
      createdBy: [createdBy],
      status: [status.name],
      selectedModules: [selectedModules],
      editBy: [
        editBy != null
            ? RoleHistoryModel._editByToJsonString(editBy)
            : jsonEncode({'Editor_Email': [], 'Timestamp': []})
      ],
    );
  }
}
