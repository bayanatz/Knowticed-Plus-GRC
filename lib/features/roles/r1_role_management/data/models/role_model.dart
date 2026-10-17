// ignore_for_file: prefer_null_aware_operators

/// Module: roles / r1_role_management / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: role_model.dart
/// Description: Declares `RoleModel`, `RoleHistoryModel`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header; removed
///          the Firestore query (generateNextRoleId -> RoleRemoteDataSource)
///          and the 349 commented-out debug prints.
///
/// KNOWN DEBT (from the r1 code review, not yet closed):
/// - This file is ~1,000 LOC against a 200-LOC cap for models (§10). Splitting
///   it needs new files, which the current change set is not allowed to add.
/// - Four `try/catch` blocks remain (`currentEditBy`, `RoleHistoryModel.fromMap`,
///   `_sanitizeValue`, `_editByToJsonString`). §11.2 forbids try/catch in
///   `data/models/`; each wraps a `jsonEncode`/`jsonDecode` whose failure mode
///   is load-bearing, so they must move to the data source together with the
///   parsing they guard rather than simply be deleted.
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/edit_by_model.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

import 'package:grc_module/features/roles/r1_role_management/domain/enums/form_builder/form_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/module_permission_model.dart';

part 'role_model/role_history_model_methods.dart';
part 'role_model/role_history_model_statics.dart';

class RoleModel {
  String? roleName;
  String? roleNameAr;
  String? roleDescription;
  String? roleDescriptionAr;
  String? roleImage;
  Timestamp? createdAt;
  String? createdBy;
  RoleStatus? status;
  EditBy? editBy;
  Map<ModulePermissionsSections, List<ModulePermissionsSectionsPermission>>?
      settingsPermissions;
  ModulePermissionModel? messageModule;
  ModulePermissionModel? taskModule;
  ModulePermissionModel? employeeModule;
  ModulePermissionModel? reqestModule;
  ModulePermissionModel? serviceModule;
  ModulePermissionModel? eventModule;
  ModulePermissionModel? noteModule;
  ModulePermissionModel? grcModule;
  ModulePermissionModel? formBuilderModule;
  ModulePermissionModel? databaseBuilderModule;
  ModulePermissionModel? dataGRCModule;
  ModulePermissionModel? knowledgeHubModule;
  ModulePermissionModel? trackingModule;
  ModulePermissionModel? inventoryModule;
  ModulePermissionModel? todoModule;
  ModulePermissionModel? roleModule;
  ModulePermissionModel? hrModule;
  ModulePermissionModel? notificationModule;
  ModulePermissionModel? crmModule; // ✅ ADDED

  RoleModel({
    this.roleName,
    this.roleNameAr,
    this.roleImage,
    this.createdAt,
    this.createdBy,
    this.roleDescription,
    this.roleDescriptionAr,
    this.status,
    this.editBy,
    this.taskModule,
    this.employeeModule,
    this.messageModule,
    this.grcModule,
    this.reqestModule,
    this.serviceModule,
    this.eventModule,
    this.noteModule,
    this.formBuilderModule,
    this.databaseBuilderModule,
    this.dataGRCModule,
    this.knowledgeHubModule,
    this.inventoryModule,
    this.trackingModule,
    this.settingsPermissions,
    this.roleModule,
    this.todoModule,
    this.hrModule,
    this.notificationModule,
    this.crmModule, // ✅ ADDED
  });

  static const String kAccessNameKey = 'Access_Name';
  static const String kAccessNameArKey = 'Access_Name_Ar';
  static const String kRoleDescriptionKey = 'Role_Description';
  static const String kRoleDescriptionArKey = 'Role_Description_Ar';
  static const String kAccessImageKey = 'Access_Image';
  static const String kCreatedAtKey = 'Created_At';
  static const String kCreatedByKey = 'Created_By';
  static const String kEditMessageKey = 'Edit_Message';
  static const String kDeleteMessageKey = 'Delete_Message';
  static const String kReactionsKey = 'Reactions';
  static const String kCreateMessageGroupsKey = 'Create_Message_Groups';
  static const String kExportChatAsExcelKey = 'Export_Chat_As_Excel';
  static const String kTakeScreenshotKey = 'Take_Screenshot';
  static const String kKnowWhosOnlineKey = 'Know_Whos_Online';
  static const String kKnowLastSeenActiveKey = 'Know_Last_Seen_Active';
  static const String kBiometricsForLoginKey = 'Biometrics_For_Login';
  static const String kRestrictedLocation = 'Restricted_Location';

  static const String kCompanyInformationKey = 'Company_Information';
  static const String kAnimation = 'Animation';

  static const String kLockOutOfGeographicalBoundariesKey =
      'Lock_Out_Of_Geographical_Boundaries';
  static const String kShareEmailsAndSocialDataKey =
      'Share_Emails_And_Social_Data';
  static const String kShareCellphonesKey = 'Share_Cellphones';
  static const String kShareSocialInformationKey = 'Share_Social_Information';
  static const String kBioKey = 'Bio';
  static const String kAcademicHistoryKey = 'Academic_History';
  static const String kCertificatesKey = 'Certificates';
  static const String kSkillsKey = 'Skills';
  static const String kHobbiesKey = 'Hobbies';
  static const String kAddEmployeesKey = 'Add_Employees';
  static const String kOneByOneKey = 'One_By_One';
  static const String kBulkUploadViaExcelSheetKey =
      'Bulk_Upload_Via_Excel_Sheet';
  static const String kViewAndSearchEmployeeRecordsKey =
      'View_And_Search_Employee_Records';
  static const String kStatusKey = 'Status';
  static const String kEditByKey = 'Edit_By';
  static const String kTaskModuleKey = 'Task_Module';
  static const String kEmployeeModuleKey = 'Employee_Module';
  static const String kMessageModuleKey = 'Message_Module';
  static const String kGrcModuleKey = 'Grc_Module';
  static const String kRequestModuleKey = 'Reqest_Module';
  static const String kServiceModuleKey = 'Service_Module';
  static const String kEventModuleKey = 'Event_Module';
  static const String kNoteModuleKey = 'Note_Module';
  static const String kServicesAppModuleKey = 'services_app_Module';
  static const String kDatabaseBuilderModuleKey = 'Database_Builder_Module';
  static const String kDataGrcModuleKey = 'Data_GRC_Module';
  static const String kKnowledgeHubModuleKey = 'Knowledge_Hub_Module';
  static const String kTrackingModuleKey = 'Time_Tracking_Module';
  static const String kInventoryModuleKey = 'Inventory_Module';
  static const String kTodoModuleKey = 'Todo_Module';
  static const String kRoleModuleKey = 'Role_Module';
  static const String kHrModuleKey = 'HR_Module';
  static const String kNotificationModuleKey = 'Notification_Module';
  static const String kCrmModuleKey = 'CRM_Module'; // ✅ ADDED

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      kAccessNameKey: roleName,
      kAccessNameArKey: roleNameAr,
      kAccessImageKey: roleImage,
      kRoleDescriptionKey: roleDescription,
      kRoleDescriptionArKey: roleDescriptionAr,
      kCreatedAtKey: createdAt,
      kCreatedByKey: createdBy,
      kStatusKey: status?.name,
      kEditByKey: editBy != null ? editBy!.toMap() : null,
      kTaskModuleKey: taskModule != null ? taskModule!.toMap() : null,
      kEmployeeModuleKey:
          employeeModule != null ? employeeModule!.toMap() : null,
      kMessageModuleKey: messageModule != null ? messageModule!.toMap() : null,
      kRequestModuleKey: reqestModule != null ? reqestModule!.toMap() : null,
      kServiceModuleKey: serviceModule != null ? serviceModule!.toMap() : null,
      kEventModuleKey: eventModule != null ? eventModule!.toMap() : null,
      kNoteModuleKey: noteModule != null ? noteModule!.toMap() : null,
      kServicesAppModuleKey:
          formBuilderModule != null ? formBuilderModule!.toMap() : null,
      kDatabaseBuilderModuleKey:
          databaseBuilderModule != null ? databaseBuilderModule!.toMap() : null,

      kDataGrcModuleKey:
          dataGRCModule != null ? dataGRCModule!.toMap() : null,
      kKnowledgeHubModuleKey:
          knowledgeHubModule != null ? knowledgeHubModule!.toMap() : null,
      kTrackingModuleKey:
          trackingModule != null ? trackingModule!.toMap() : null,
      kInventoryModuleKey:
          inventoryModule != null ? inventoryModule!.toMap() : null,
      kTodoModuleKey: todoModule != null ? todoModule!.toMap() : null,
      kRoleModuleKey: roleModule != null ? roleModule!.toMap() : null,
      kGrcModuleKey: grcModule != null ? grcModule!.toMap() : null,
      kHrModuleKey: hrModule != null ? hrModule!.toMap() : null,
      kNotificationModuleKey:
          notificationModule != null ? notificationModule!.toMap() : null,
      kCrmModuleKey: crmModule != null ? crmModule!.toMap() : null, // ✅ ADDED
    };
    // "setting permissions: ${settingsPermissions?.map((key, value) => MapEntry(key.getName, value.map((e) => e.getDataBaseName).toList()))}");
    map.addAll(settingsPermissions?.map((key, value) => MapEntry(
            key.getName, value.map((e) => e.getDataBaseName).toList())) ??
        {});
    return map;
  }

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      roleName: map[kAccessNameKey],
      roleNameAr: map[kAccessNameArKey],
      roleImage: map[kAccessImageKey],
      createdAt: _getCreatedAt(map[kCreatedAtKey]),
      createdBy: map[kCreatedByKey],
      status: RoleStatus.values.firstWhere(
        (e) => e.name == map[kStatusKey],
        orElse: () => RoleStatus.active,
      ),
      roleDescription: map[kRoleDescriptionKey],
      roleDescriptionAr: map[kRoleDescriptionArKey],
      editBy:
          map[kEditByKey] != null ? EditBy.fromMap(map[kEditByKey]) : null,
      roleModule: map[kRoleModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kRoleModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kRoleModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kRoleModuleKey], []),
            )
          : null,
      taskModule: map[kTaskModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kTaskModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kTaskModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kTaskModuleKey], []),
            )
          : null,
      employeeModule: map[kEmployeeModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kEmployeeModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kEmployeeModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kEmployeeModuleKey], []),
            )
          : null,
      messageModule: map[kMessageModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kMessageModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kMessageModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kMessageModuleKey], []),
            )
          : null,
      reqestModule: map[kRequestModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kRequestModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kRequestModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kRequestModuleKey], []),
            )
          : null,
      serviceModule: map[kServiceModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kServiceModuleKey],
              constructedAdminSections: _getAdminSections(
                  map[kServiceModuleKey], ServicePermissionsSections.values),
              constructedSectionsPermissions: _getSectionsPermissions(
                  map[kServiceModuleKey], ServicePermissionsSections.values),
            )
          : null,
      eventModule: map[kEventModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kEventModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kEventModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kEventModuleKey], []),
            )
          : null,
      noteModule: map[kNoteModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kNoteModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kNoteModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kNoteModuleKey], []),
            )
          : null,
      formBuilderModule: map[kServicesAppModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kServicesAppModuleKey],
              constructedAdminSections: _getAdminSections(
                  map[kServicesAppModuleKey], FormPermissionsSections.values),
              constructedSectionsPermissions: _getSectionsPermissions(
                  map[kServicesAppModuleKey], FormPermissionsSections.values),
            )
          : null,
      databaseBuilderModule: map[kDatabaseBuilderModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kDatabaseBuilderModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kDatabaseBuilderModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kDatabaseBuilderModuleKey], []),
            )
          : null,
      dataGRCModule: map[kDataGrcModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kDataGrcModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kDataGrcModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kDataGrcModuleKey], []),
            )
          : null,
      knowledgeHubModule: map[kKnowledgeHubModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kKnowledgeHubModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kKnowledgeHubModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kKnowledgeHubModuleKey], []),
            )
          : null,
      trackingModule: map[kTrackingModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kTrackingModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kTrackingModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kTrackingModuleKey], []),
            )
          : null,
      inventoryModule: map[kInventoryModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kInventoryModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kInventoryModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kInventoryModuleKey], []),
            )
          : null,
      hrModule: map[kHrModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kHrModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kHrModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kHrModuleKey], []),
            )
          : null,
      crmModule: map[kCrmModuleKey] != null // ✅ ADDED
          ? ModulePermissionModel.fromMap(
              map[kCrmModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kCrmModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kCrmModuleKey], []),
            )
          : null,
      notificationModule: map[kNotificationModuleKey] != null
          ? ModulePermissionModel.fromMap(
              map[kNotificationModuleKey],
              constructedAdminSections:
                  _getAdminSections(map[kNotificationModuleKey], []),
              constructedSectionsPermissions:
                  _getSectionsPermissions(map[kNotificationModuleKey], []),
            )
          : null,
      settingsPermissions: getSettingsPermissions(map),
    );
  }

  String toJson() => json.encode(toMap());

  factory RoleModel.fromJson(String source) =>
      RoleModel.fromMap(json.decode(source));

  /// Reads `Created_At`, which is a [Timestamp] on new documents and a
  /// `"Jan 29, 2025"` string on legacy ones.
  ///
  /// Was a `try { … as Timestamp } catch { … parse(…) }` — a type test does the
  /// same job without try/catch, which §11.2 forbids in `data/models/`.
  static Timestamp _getCreatedAt(dynamic createdAt) {
    if (createdAt is Timestamp) return createdAt;

    /// string format jan 29, 2025
    return Timestamp.fromDate(DateFormat('MMM d, yyyy').parse(createdAt));
  }

  static List<ModulePermissionsSections> _getAdminSections(
      Map<String, dynamic> map, List<ModulePermissionsSections> sections) {
    List<ModulePermissionsSections> adminSections = [];
    for (var element in sections) {
      if (map[ModulePermissionModel.adminSectionsKey] != null &&
          map[ModulePermissionModel.adminSectionsKey]
              .contains(element.getName)) {
        adminSections.add(element);
      }
    }
    return adminSections;
  }

  static Map<ModulePermissionsSections, List<ModulePermissionsSectionsPermission>> _getSectionsPermissions(
      Map<String, dynamic> map, List<ModulePermissionsSections> sections) {
    Map<ModulePermissionsSections, List<ModulePermissionsSectionsPermission>>
        allowedSections = {};
    for (ModulePermissionsSections section in sections) {
      if (map.containsKey(section.getName)) {
        allowedSections[section] = [];
        for (Enum subSection in section.sectionPermissions) {
          if (map[section.getName] != null &&
              map[section.getName].contains(
                  (subSection as ModulePermissionsSectionsPermission)
                      .getDataBaseName)) {
            allowedSections[section]!
                .add((subSection as ModulePermissionsSectionsPermission));
          }
        }
      }
    }
    return allowedSections;
  }

  static Map<SettingsPermissionsSections,
          List<ModulePermissionsSectionsPermission>>
      getSettingsPermissions(Map<String, dynamic> map) {
    Map<SettingsPermissionsSections, List<ModulePermissionsSectionsPermission>>
        allowedSections = {};
    for (SettingsPermissionsSections section
        in SettingsPermissionsSections.values) {
      if (map.containsKey(section.getName)) {
        allowedSections[section] = [];
        for (Enum permission in section.sectionPermissions) {
          if (map[section.getName] != null &&
              map[section.getName].contains(
                  (permission as ModulePermissionsSectionsPermission)
                      .getDataBaseName)) {
            allowedSections[section]!
                .add(((permission as ModulePermissionsSectionsPermission)));
          }
        }
      }
    }
    return allowedSections;
  }
}

class RoleHistoryModel {
  final String roleId;
  final List<int> timestamps;
  final List<String> roleName;
  final List<String> roleNameAr;
  final List<String> roleDescription;
  final List<String> roleDescriptionAr;
  final List<String> roleImage;
  final List<Timestamp> createdAt;
  final List<String> createdBy;
  final List<String> status;
  final List<List<String>> selectedModules;
  final List<String> editBy;

  RoleHistoryModel({
    required this.roleId,
    required this.timestamps,
    required this.roleName,
    required this.roleNameAr,
    required this.roleDescription,
    required this.roleDescriptionAr,
    required this.roleImage,
    required this.createdAt,
    required this.createdBy,
    required this.status,
    required this.selectedModules,
    required this.editBy,
  });

  // Constants for database keys
  static const String kRoleIdKey = 'Role_Id';
  static const String kAccessNameKey = 'Role_Name';
  static const String kAccessNameKeyAlt = 'Name';
  static const String kAccessNameKeyAlt2 = 'Access_Name';
  static const String kAccessNameArKey = 'Role_Name_Ar';
  static const String kAccessNameArKeyAlt = 'Name_Ar';
  static const String kAccessNameArKeyAlt2 = 'Access_Name_Ar';
  static const String kRoleDescriptionKey = 'Role_Description';
  static const String kRoleDescriptionKeyAlt = 'Description';
  static const String kRoleDescriptionArKey = 'Role_Description_Ar';
  static const String kRoleDescriptionArKeyAlt = 'Description_Ar';
  static const String kAccessImageKey = 'Role_Image';
  static const String kAccessImageKeyAlt = 'Image_Url';
  static const String kAccessImageKeyAlt2 = 'Access_Image';
  static const String kCreatedAtKey = 'Created_At';
  static const String kCreatedByKey = 'Created_By';
  static const String kStatusKey = 'Status';
  static const String kSelectedModulesKey = 'Selected_Modules';
  static const String kSelectedModulesKeyAlt =
      'selectedModules'; // ← ADD THIS
  static const String kEditByKey = 'Edit_By';
  static const String kTimestampsKey = 'timestamps';

  RoleStatus get currentStatus => status.isNotEmpty
      ? RoleStatus.values.firstWhere((e) => e.name == status.last,
          orElse: () => RoleStatus.active)
      : RoleStatus.active;

  // CRITICAL: Updated fromMap to read old module structure
  factory RoleHistoryModel.fromMap(Map<String, dynamic> map) =>
      _RoleHistoryModelStatics.factoryFromMap(map);

  // NEW: Extract modules from old structure
  static List<String> _extractModulesFromOldStructure(
          Map<String, dynamic> map) =>
      _RoleHistoryModelStatics._extractModulesFromOldStructure(map);

  static List<String> _parseListSafely(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e?.toString() ?? '').toList();
    return [value.toString()];
  }

  static List<Timestamp> _parseTimestampList(dynamic value) {
    if (value == null) return [Timestamp.now()];
    if (value is List) {
      return value.map((e) {
        if (e is Timestamp) return e;
        if (e is int) return Timestamp.fromMillisecondsSinceEpoch(e);
        if (e is Map && e.containsKey('_seconds')) {
          return Timestamp(e['_seconds'], e['_nanoseconds'] ?? 0);
        }
        return Timestamp.now();
      }).toList();
    }
    if (value is int) return [Timestamp.fromMillisecondsSinceEpoch(value)];
    return [Timestamp.now()];
  }

  static List<String> _parseEditByList(dynamic value) {
    if (value == null) {
      return [
        jsonEncode({'editorEmail': [], 'timestamps': []})
      ];
    }
    if (value is List) {
      return value.map((e) => _convertToJsonString(e)).toList();
    }
    return [_convertToJsonString(value)];
  }

  // static List<List<String>> _parseSelectedModulesList(dynamic value) {
  //   if (value == null) return [[]];
  //
  //   // CRITICAL FIX: Handle both nested and flat arrays
  //   if (value is List) {
  //     if (value.isEmpty) return [[]];
  //
  //     // Check if it's already a nested array
  //     if (value.first is List) {
  //       return value.map((e) => List<String>.from(e)).toList();
  //     }
  //
  //     // If it's a flat array, wrap it in another array for history tracking
  //     return [List<String>.from(value)];
  //   }
  //
  //   return [[]];
  // }

  static List<List<String>> _parseSelectedModulesList(dynamic value) =>
      _RoleHistoryModelStatics._parseSelectedModulesList(value);

  static String _convertToJsonString(dynamic value) =>
      _RoleHistoryModelStatics._convertToJsonString(value);

  static Map<String, dynamic> _sanitizeMapForFirebase(
          Map<String, dynamic> map) =>
      _RoleHistoryModelStatics._sanitizeMapForFirebase(map);

  // ✅ FIXED: toMap now uses primary keys (Name, Name_Ar, Image_Url)
  Map<String, dynamic> toMap() => _toMapImpl();

  String toJson() => json.encode(toMap());

  factory RoleHistoryModel.fromJson(String source) =>
      RoleHistoryModel.fromMap(json.decode(source));

  // ✅✅✅ FIXED: copyWith method that ALWAYS synchronizes ALL fields
  RoleHistoryModel copyWith({
    String? roleName,
    String? roleNameAr,
    String? roleDescription,
    String? roleDescriptionAr,
    String? roleImage,
    Timestamp? createdAt,
    String? createdBy,
    String? status,
    List<String>? selectedModules,
    EditBy? editBy,
  }) =>
      _copyWithImpl(
        roleName: roleName,
        roleNameAr: roleNameAr,
        roleDescription: roleDescription,
        roleDescriptionAr: roleDescriptionAr,
        roleImage: roleImage,
        createdAt: createdAt,
        createdBy: createdBy,
        status: status,
        selectedModules: selectedModules,
        editBy: editBy,
      );

  static String _editByToJsonString(EditBy editBy) {
    try {
      // Convert the EditBy map to a Firebase-safe format
      Map<String, dynamic> editByMap = editBy.toMap();
      Map<String, dynamic> safeMap = _sanitizeMapForFirebase(editByMap);
      return jsonEncode(safeMap);
    } catch (e) {
      return jsonEncode({'Editor_Email': [], 'Timestamp': []});
    }
  }

  factory RoleHistoryModel.createNew({
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
  }) =>
      _RoleHistoryModelStatics.factoryCreateNew(
        roleId: roleId,
        roleName: roleName,
        roleNameAr: roleNameAr,
        roleDescription: roleDescription,
        roleDescriptionAr: roleDescriptionAr,
        roleImage: roleImage,
        createdAt: createdAt,
        createdBy: createdBy,
        status: status,
        selectedModules: selectedModules,
        editBy: editBy,
      );

  // MOVED 12/8/2026 -> RoleRemoteDataSource.generateNextRoleId.
  // This ran a Firestore query (and two try/catch blocks) from inside a
  // data model. Models are pure data (§10/§11.2); network access belongs to
  // the data source. Callers: RoleRepository.addNewRole and
  // ActiveDirectoryRepository._createAccessType.
}
