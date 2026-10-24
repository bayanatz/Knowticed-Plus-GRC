/// Module: roles / r1_role_management / data / models
///
///********************** FILE INFO ********************///
/// File_Name: role_access_model.dart
/// Purpose: holds user permissions data model.
/// Author: Amr Mesbah
/// Created at: 20/1/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/helper/single_value_model.dart';

class UserPermissionModel {
  SingleValueModel<String> role;
  SingleValueModel<String> fromDate;
  SingleValueModel<String> toDate;
  SingleValueModel<String> editBy;
  String employeeId;
  UserPermissionModel({
    required this.employeeId,
    required this.role,
    required this.fromDate,
    required this.toDate,
    required this.editBy,
  }) {
    _updateEditBy();
  }

  static const String kEmployeeId = "Employee_Id";
  static const String kRole = "Role";
  static const String kCreatedBy = "Created_By";
  static const String kFromDate = "From_Date";
  static const String kToDate = "To_Date";
  static const String kEditBy = "Edit_By";
  static const String kTimestamp = "Timestamp";

  Map<String, dynamic> toMap() {
    return {
      kEmployeeId: employeeId,
      kRole: role.toMap(),
      kFromDate: fromDate.toMap(),
      kToDate: toDate.toMap(),
      kEditBy: editBy.toMap(),
    };
  }

  factory UserPermissionModel.fromMap(Map<String, dynamic> map) {
    return UserPermissionModel(
      employeeId: map[kEmployeeId],
      role: SingleValueModel<String>.fromMap(map[kRole]),
      fromDate: SingleValueModel<String>.fromMap(map[kFromDate]),
      toDate: SingleValueModel<String>.fromMap(map[kToDate]),
      editBy: SingleValueModel<String>.fromMap(map[kEditBy]),
    );
  }

  void _updateEditBy() {
    if (editBy.values.lastOrNull == 'admin@bayanatz.com' ||
        editBy.values.lastOrNull == 'admin@baynatz.com' ||
        editBy.values.isEmpty) {
      editBy.values.add('ibrahim_saeed_1702@bayanatz.com');
      editBy.timestamps.add(Timestamp.now());
    }
  }
}
