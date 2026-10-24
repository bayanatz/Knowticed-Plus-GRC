/// Module: knowledge_hub/data/models
/// ************************* FILE INFO *************************** ///
/// File Name: employee_data_json.dart
/// Description: Reading an Employees record into `EmployeeData`.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';

/// Firestore field names of an Employees record.
class EmployeeKeys {
  const EmployeeKeys._();
  static const String timestamps = 'timestamps';
  static const String timestamp = 'Timestamp';
  static const String firstName = 'First_Name';
  static const String lastName = 'Last_Name';
  static const String firstNameArabic = 'First_Name_Arabic';
  static const String lastNameArabic = 'Last_Name_Arabic';
  static const String jobTitle = 'Job_Title';
  static const String jobTitleArabic = 'Job_Title_Arabic';
  static const String id = 'Id';
  static const String employeeId = 'employeeId';
  static const String email = 'Email';
  static const String photo = 'Photo';
  static const String departmentId = 'Department_Id';
  static const String role = 'Role';
  static const String supervisor = 'Supervisor';
  static const String mobilePhone = 'Mobile_Phone';
  static const String phone = 'Phone';
  static const String countryCode = 'Country_Code';
  static const String countryApp = 'Country_App';
}

typedef _K = EmployeeKeys;

class EmployeeDataJson {
  const EmployeeDataJson._();

  static EmployeeData fromJson(Map<String, dynamic> json) {
    final List<String> names = _combine(
      _list(json[_K.firstName]),
      _list(json[_K.lastName]),
    );
    final List<String> namesArabic = _combine(
      _list(json[_K.firstNameArabic]),
      _list(json[_K.lastNameArabic]),
    );
    final List<String> jobTitle = _list(json[_K.jobTitle]);
    final List<String> jobTitleArabic = _list(json[_K.jobTitleArabic]);
    final List<String> ids = _list(json[_K.id]);
    return EmployeeData(
      timestamps: _timestamps(json[_K.timestamps]),
      employeeName: names,
      employeeNameArabic: namesArabic.isNotEmpty ? namesArabic : names,
      employeeId: ids.isNotEmpty ? ids : _list(json[_K.employeeId]),
      employeeEmail: _list(json[_K.email]),
      employeePhoto: _list(json[_K.photo]),
      employeeDepartment: _list(json[_K.departmentId]),
      employeeRole: jobTitle.isNotEmpty ? jobTitle : _list(json[_K.role]),
      employeeRoleArabic: jobTitleArabic.isNotEmpty ? jobTitleArabic : jobTitle,
      employeePhone: _phones(json[_K.mobilePhone]),
      employeeJobTitle: jobTitle,
      employeeSupervisor: _list(json[_K.supervisor]),
    );
  }

  static Map<String, dynamic> toJson(EmployeeData e) => {
    'timestamps': e.timestamps,
    'employeeName': e.employeeName,
    'employeeNameArabic': e.employeeNameArabic,
    'employeeId': e.employeeId,
    'jobTitle': e.employeeJobTitle,
    'employeeEmail': e.employeeEmail,
    'employeePhoto': e.employeePhoto,
    'employeeDepartment': e.employeeDepartment,
    'employeeRole': e.employeeRole,
    'employeeRoleArabic': e.employeeRoleArabic,
    'employeePhone': e.employeePhone,
    'employeeSupervisor': e.employeeSupervisor,
  };

  static List<int> _timestamps(dynamic value) {
    if (value is! List) return [DateTime.now().millisecondsSinceEpoch];
    return value
        .map(
          (e) => e is num ? e.toInt() : DateTime.now().millisecondsSinceEpoch,
        )
        .toList();
  }

  /// A history list stored as plain values or as `{Field: value,
  /// Timestamp: ...}` entries.
  static List<String> _list(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map(_entry).toList();
    if (value is Map) {
      final String entry = _entry(value);
      return entry.isEmpty ? [] : [entry];
    }
    return [value.toString()];
  }

  static String _entry(dynamic item) {
    if (item == null) return '';
    if (item is! Map) return item.toString();
    for (final MapEntry<dynamic, dynamic> entry in item.entries) {
      if (entry.key == _K.timestamp || entry.value == null) continue;
      final dynamic v = entry.value;
      if (v is List) return v.isEmpty ? '' : (v.first?.toString() ?? '');
      return v.toString();
    }
    return '';
  }

  static List<String> _combine(List<String> first, List<String> last) {
    final int n = first.length > last.length ? first.length : last.length;
    return [
      for (int i = 0; i < n; i++)
        '${i < first.length ? first[i] : ''} ${i < last.length ? last[i] : ''}'
            .trim(),
    ];
  }

  static List<String> _phones(dynamic value) {
    final List<dynamic> items = value is List
        ? value
        : (value is Map ? [value] : const []);
    return items
        .whereType<Map>()
        .map(_phoneOf)
        .whereType<String>()
        .where((p) => p.isNotEmpty)
        .toList();
  }

  static final RegExp _digits = RegExp(r'^[0-9]{7,15}$');

  static String? _phoneOf(Map<dynamic, dynamic> phone) {
    if (phone[_K.phone] != null) return phone[_K.phone].toString();
    if (phone['phone'] != null) return phone['phone'].toString();
    for (final MapEntry<dynamic, dynamic> entry in phone.entries) {
      if (entry.key == _K.timestamp ||
          entry.key == _K.countryCode ||
          entry.key == _K.countryApp ||
          entry.value == null) {
        continue;
      }
      final String text = entry.value.toString();
      if (_digits.hasMatch(text)) return text;
    }
    return null;
  }
}
