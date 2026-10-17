/// Module: roles/r1_role_management
///
///*************************** FILE INFO ****************************///
/// File Name: role_history_model_methods.dart
/// Description: Methods of `RoleHistoryModel` — split out of `role_model.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../role_model.dart';

// Split from role_model.dart to keep every file under 700 lines.

extension RoleHistoryModelMethods on RoleHistoryModel {
  // Helper getters for current (latest) values
  String get currentRoleName => roleName.isNotEmpty ? roleName.last : '';

  String get currentRoleNameAr => roleNameAr.isNotEmpty ? roleNameAr.last : '';

  String get currentRoleDescription =>
      roleDescription.isNotEmpty ? roleDescription.last : '';

  String get currentRoleDescriptionAr =>
      roleDescriptionAr.isNotEmpty ? roleDescriptionAr.last : '';

  String get currentRoleImage => roleImage.isNotEmpty ? roleImage.last : '';

  Timestamp get currentCreatedAt =>
      createdAt.isNotEmpty ? createdAt.last : Timestamp.now();

  String get currentCreatedBy => createdBy.isNotEmpty ? createdBy.last : '';

  List<String> get currentSelectedModules =>
      selectedModules.isNotEmpty ? selectedModules.last : [];

  EditBy? get currentEditBy {
    if (editBy.isEmpty) return null;
    try {
      String editByString = editBy.last;
      Map<String, dynamic> data;

      if (editByString.startsWith('{') && editByString.endsWith('}')) {
        data = jsonDecode(editByString);
      } else {
        return null;
      }

      return EditBy.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  int? getTimestampAt(int index) =>
      index < timestamps.length ? timestamps[index] : null;

  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  RoleModel toLegacyRoleModel() {
    return RoleModel(
      roleName: currentRoleName.isNotEmpty ? currentRoleName : null,
      roleNameAr: currentRoleNameAr.isNotEmpty ? currentRoleNameAr : null,
      roleDescription:
          currentRoleDescription.isNotEmpty ? currentRoleDescription : null,
      roleDescriptionAr:
          currentRoleDescriptionAr.isNotEmpty ? currentRoleDescriptionAr : null,
      roleImage: currentRoleImage.isNotEmpty ? currentRoleImage : null,
      createdAt: currentCreatedAt,
      createdBy: currentCreatedBy.isNotEmpty ? currentCreatedBy : null,
      status: currentStatus,
      editBy: currentEditBy,
    );
  }

  // ✅ FIXED: toMap now uses primary keys (Name, Name_Ar, Image_Url)
  Map<String, dynamic> _toMapImpl() {
    Map<String, dynamic> map = {
      RoleHistoryModel.kRoleIdKey: roleId,
      RoleHistoryModel.kTimestampsKey: timestamps,

      // ✅ CHANGED: Use ACCESS_NAME_KEY_ALT instead of ACCESS_NAME_KEY_ALT2
      // This maps to 'Name' instead of 'Access_Name'
      RoleHistoryModel.kAccessNameKeyAlt: roleName,

      // ✅ CHANGED: Use ACCESS_NAME_AR_KEY_ALT instead of ACCESS_NAME_AR_KEY_ALT2
      // This maps to 'Name_Ar' instead of 'Access_Name_Ar'
      RoleHistoryModel.kAccessNameArKeyAlt: roleNameAr,

      RoleHistoryModel.kRoleDescriptionKey: roleDescription,
      RoleHistoryModel.kRoleDescriptionArKey: roleDescriptionAr,

      // ✅ CHANGED: Use ACCESS_IMAGE_KEY_ALT instead of ACCESS_IMAGE_KEY_ALT2
      // This maps to 'Image_Url' instead of 'Access_Image'
      RoleHistoryModel.kAccessImageKeyAlt: roleImage,

      RoleHistoryModel.kCreatedAtKey:
          createdAt.map((t) => t.millisecondsSinceEpoch).toList(),
      RoleHistoryModel.kCreatedByKey: createdBy,
      RoleHistoryModel.kStatusKey: status,
      // ✅ FIX: Use only the current (last) value to avoid nested arrays
      RoleHistoryModel.kSelectedModulesKey:
          selectedModules.isNotEmpty ? selectedModules.last : [],
      RoleHistoryModel.kEditByKey: editBy,
    };

    return map;
  }

  // ✅✅✅ FIXED: copyWith method that ALWAYS synchronizes ALL fields
  RoleHistoryModel _copyWithImpl({
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
  }) {
    // Add new timestamp for this update
    final newTimestamps = List<int>.from(timestamps)
      ..add(DateTime.now().millisecondsSinceEpoch);

    // ✅ CRITICAL: ALL fields get updated - edited values OR current values repeated
    final result = RoleHistoryModel(
      roleId: roleId,
      timestamps: newTimestamps,

      // ✅ Role Name: append provided value OR repeat current value
      roleName: List<String>.from(this.roleName)
        ..add(roleName ?? currentRoleName),

      // ✅ Role Name Ar: append provided value OR repeat current value
      roleNameAr: List<String>.from(this.roleNameAr)
        ..add(roleNameAr ?? currentRoleNameAr),

      // ✅ Role Description: append provided value OR repeat current value
      roleDescription: List<String>.from(this.roleDescription)
        ..add(roleDescription ?? currentRoleDescription),

      // ✅ Role Description Ar: append provided value OR repeat current value
      roleDescriptionAr: List<String>.from(this.roleDescriptionAr)
        ..add(roleDescriptionAr ?? currentRoleDescriptionAr),

      // ✅ Role Image: append provided value OR repeat current value
      roleImage: List<String>.from(this.roleImage)
        ..add(roleImage ?? currentRoleImage),

      // ✅ Created At: append provided value OR repeat current value
      createdAt: List<Timestamp>.from(this.createdAt)
        ..add(createdAt ?? currentCreatedAt),

      // ✅ Created By: append provided value OR repeat current value
      createdBy: List<String>.from(this.createdBy)
        ..add(createdBy ?? currentCreatedBy),

      // ✅ Status: append provided value OR repeat current value
      status: List<String>.from(this.status)..add(status ?? currentStatus.name),

      // ✅ Selected Modules: append provided value OR repeat current value
      selectedModules: List<List<String>>.from(this.selectedModules)
        ..add(selectedModules ?? currentSelectedModules),

      // ✅ Edit By: append provided value OR repeat current value
      editBy: List<String>.from(this.editBy)
        ..add(editBy != null
            ? RoleHistoryModel._editByToJsonString(editBy)
            : (this.editBy.isNotEmpty
                ? this.editBy.last
                : jsonEncode({'Editor_Email': [], 'Timestamp': []}))),
    );

    return result;
  }
}
