/// Module: knowledge_hub/data/models
/// ************************* FILE INFO *************************** ///
/// File Name: employee_data.dart
/// Description: `EmployeeData` — the employee shown next to a comment, a view
///              or a download. Every field is a history list.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data_json.dart';

class EmployeeData {
  EmployeeData({
    required this.timestamps,
    required this.employeeName,
    required this.employeeNameArabic,
    required this.employeeId,
    required this.employeeEmail,
    required this.employeeJobTitle,
    this.employeePhoto,
    required this.employeeDepartment,
    required this.employeeRole,
    required this.employeeRoleArabic,
    this.employeePhone,
    required this.employeeSupervisor,
  });

  /// Reads an Employees record; malformed fields become empty entries.
  factory EmployeeData.fromJson(Map<String, dynamic> json) =>
      EmployeeDataJson.fromJson(json);

  factory EmployeeData.createNew({
    required String employeeName,
    String? employeeNameArabic,
    required String employeeId,
    required String employeeEmail,
    required String employeeJobTitle,
    required String employeeDepartment,
    String? employeePhoto,
    required String employeeRole,
    String? employeeRoleArabic,
    String? employeePhone,
    required String employeeSupervisor,
  }) => EmployeeData(
    timestamps: [DateTime.now().millisecondsSinceEpoch],
    employeeName: [employeeName],
    employeeNameArabic: [employeeNameArabic ?? employeeName],
    employeeEmail: [employeeEmail],
    employeeId: [employeeId],
    employeeDepartment: [employeeDepartment],
    employeeRole: [employeeRole],
    employeeRoleArabic: [employeeRoleArabic ?? employeeRole],
    employeeJobTitle: [employeeJobTitle],
    employeePhoto: employeePhoto != null ? [employeePhoto] : null,
    employeePhone: employeePhone != null ? [employeePhone] : null,
    employeeSupervisor: [employeeSupervisor],
  );

  final List<int> timestamps;
  final List<String> employeeName;
  final List<String> employeeNameArabic;
  final List<String> employeeId;
  final List<String> employeeEmail;
  final List<String>? employeePhoto;
  final List<String> employeeDepartment;
  final List<String> employeeRole;
  final List<String> employeeRoleArabic;
  final List<String> employeeJobTitle;
  final List<String>? employeePhone;
  final List<String> employeeSupervisor;

  static String _last(List<String>? values) =>
      (values == null || values.isEmpty) ? '' : values.last;

  String get currentemployeeName => _last(employeeName);
  String get currentemployeeNameArabic => employeeNameArabic.isNotEmpty
      ? employeeNameArabic.last
      : currentemployeeName;
  String get currentemployeeId => _last(employeeId);
  String get currentemployeeEmail => _last(employeeEmail);
  String get currentemployeePhoto => _last(employeePhoto);
  String get currentemployeeDepartment => _last(employeeDepartment);
  String get currentemployeeRole => _last(employeeRole);
  String get currentemployeeRoleAr => employeeRoleArabic.isNotEmpty
      ? employeeRoleArabic.last
      : currentemployeeRole;
  String get currentemployeePhone => _last(employeePhone);
  String get currentemployeeSupervisor => _last(employeeSupervisor);
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;
  int? getTimestampAt(int index) =>
      index >= 0 && index < timestamps.length ? timestamps[index] : null;

  Map<String, dynamic> toJson() => EmployeeDataJson.toJson(this);
}
