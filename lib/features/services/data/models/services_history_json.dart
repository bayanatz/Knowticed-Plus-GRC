/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: services_history_json.dart
/// Purpose: Reads a ServicesHistoryModel from a Firestore map (all legacy shapes).
///          Split out of services_history_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_keys.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

/// Function Name: [servicesHistoryFromJson]
///
/// Purpose: The body of ServicesHistoryModel.fromJson.
// Factory: Create from JSON.
// NOTE: Pure data mapping only — no try/catch (§11.2/§10). Any parsing guards
// belong at the repository call site, which is responsible for catching and
// translating malformed-data errors into an error state.
ServicesHistoryModel servicesHistoryFromJson(
  Map<String, dynamic> json, [
  String? docId,
]) {
  // ✅ Parse shared timestamps first
  // B6 FIX: was `(e) => e as int`, which threw TypeError on legacy/cross-platform
  // docs where a timestamp is stored as a Timestamp or double. Coerce the known
  // shapes (int / num / Firestore Timestamp) instead of a hard cast.
  final List<int> sharedTimestamps =
      (json[ServicesHistoryKeys.kTimestamps] as List<dynamic>?)
              ?.map(_coerceEpochMs)
              .toList() ??
          [DateTime.now().millisecondsSinceEpoch];

  return ServicesHistoryModel(
    isDeleted: json[ServicesHistoryKeys.kIsDeleted] == true,
    timestamps: sharedTimestamps,
    id: _parseList<String>(
      docId ?? json[ServicesHistoryKeys.kId],
      (v) => v as String? ?? '',
    ),
    state: _parseList<String>(
      json[ServicesHistoryKeys.kState],
      (v) => v as String? ?? '',
    ),
    status: _parseList<String>(
      json[ServicesHistoryKeys.kStatus],
      (v) => v as String? ?? '',
    ),
    parentServiceId: _parseList<String>(
      json[ServicesHistoryKeys.kParentServiceId],
      (v) => v as String? ?? '',
    ),
    firstNameRequester: _parseList<String>(
      json[ServicesHistoryKeys.kFirstNameRequester],
      (v) => v as String? ?? '',
    ),
    lastNameRequester: _parseList<String>(
      json[ServicesHistoryKeys.kLastNameRequester],
      (v) => v as String? ?? '',
    ),
    departmentRequester: _parseList<String>(
      json[ServicesHistoryKeys.kDepartmentRequester],
      (v) => v as String? ?? '',
    ),
    jobTitleRequester: _parseList<String>(
      json[ServicesHistoryKeys.kJobTitleRequester],
      (v) => v as String? ?? '',
    ),
    emailRequester: _parseList<String>(
      json[ServicesHistoryKeys.kEmailRequester],
      (v) => v as String? ?? '',
    ),
    phoneRequester: _parseList<String>(
      json[ServicesHistoryKeys.kPhoneRequester],
      (v) => v as String? ?? '',
    ),
    genderRequester: _parseList<String>(
      json[ServicesHistoryKeys.kGenderRequester],
      (v) => v as String? ?? '',
    ),
    assignedProviderEmail: _parseList<String>(
      json[ServicesHistoryKeys.kAssignedProviderEmail],
      (v) => v as String? ?? '',
    ),
    firstNameRequesterArabic: _parseList<String>(
      json[ServicesHistoryKeys.kFirstNameRequesterArabic],
      (v) => v as String? ?? '',
    ),
    lastNameRequesterArabic: _parseList<String>(
      json[ServicesHistoryKeys.kLastNameRequesterArabic],
      (v) => v as String? ?? '',
    ),
    jobTitleRequesterArabic: _parseList<String>(
      json[ServicesHistoryKeys.kJobTitleRequesterArabic],
      (v) => v as String? ?? '',
    ),
    departmentRequesterArabic: _parseList<String>(
      json[ServicesHistoryKeys.kDepartmentRequesterArabic],
      (v) => v as String? ?? '',
    ),
    serviceNameEnglish: _parseList<String>(
      json[ServicesHistoryKeys.kServiceNameEnglish],
      (v) => v as String? ?? '',
    ),
    serviceNameArabic: _parseList<String>(
      json[ServicesHistoryKeys.kServiceNameArabic],
      (v) => v as String? ?? '',
    ),
    serviceDescriptionEnglish: _parseList<String>(
      json[ServicesHistoryKeys.kServiceDescriptionEnglish],
      (v) => v as String? ?? '',
    ),
    serviceDescriptionArabic: _parseList<String>(
      json[ServicesHistoryKeys.kServiceDescriptionArabic],
      (v) => v as String? ?? '',
    ),
    durationOfServices: _parseList<String>(
      json[ServicesHistoryKeys.kDurationOfServices],
      (v) => v as String? ?? '',
    ),
    selectedDurationUnit: _parseList<String>(
      json[ServicesHistoryKeys.kSelectedDurationUnit],
      (v) => v as String? ?? '',
    ),
    durationOfServicesTimestamp: _parseList<Timestamp>(
      json[ServicesHistoryKeys.kDurationOfServicesTimestamp],
      (v) {
        if (v is Timestamp) return v;
        if (v is int) return Timestamp.fromMillisecondsSinceEpoch(v);
        return Timestamp.now();
      },
    ),
    imageUrl: _parseList<String>(
      json[ServicesHistoryKeys.kImageUrl],
      (v) => v as String? ?? '',
    ),
    providerServices: _parseList<String>(
      json[ServicesHistoryKeys.kProviderServices],
      (v) => _parseEmployeeListToJson(v),
    ),
    selectDepartment: _parseList<String>(
      json[ServicesHistoryKeys.kSelectDepartment],
      (v) => _parseJsonArray(v),
    ),
    approvalCycle: _parseList<String>(
      json[ServicesHistoryKeys.kApprovalCycle],
      (v) => _parseEmployeeListToJson(v),
    ),
    limitAvailability: _parseList<bool>(
      json[ServicesHistoryKeys.kLimitAvailability],
      (v) => v as bool? ?? false,
    ),
    requireApproval: _parseList<bool>(
      json[ServicesHistoryKeys.kRequireApproval],
      (v) => v as bool? ?? false,
    ),
    slaOneControllerEnglish: _parseList<String>(
      json[ServicesHistoryKeys.kSlaOneControllerEnglish],
      (v) => v as String? ?? '',
    ),
    slaTwoControllerEnglish: _parseList<String>(
      json[ServicesHistoryKeys.kSlaTwoControllerEnglish],
      (v) => v as String? ?? '',
    ),
    notifyRequesterChecked: _parseList<bool>(
      json[ServicesHistoryKeys.kNotifyRequesterChecked],
      (v) => v as bool? ?? false,
    ),
    notifyProviderChecked: _parseList<bool>(
      json[ServicesHistoryKeys.kNotifyProviderChecked],
      (v) => v as bool? ?? false,
    ),
    notifyManagerChecked: _parseList<bool>(
      json[ServicesHistoryKeys.kNotifyManagerChecked],
      (v) => v as bool? ?? false,
    ),
    notifyRequesterSwitch0: _parseList<bool>(
      json[ServicesHistoryKeys.kNotifyRequesterSwitch0],
      (v) => v as bool? ?? false,
    ),
    notifyManagerSwitch1: _parseList<bool>(
      json[ServicesHistoryKeys.kNotifyManagerSwitch1],
      (v) => v as bool? ?? false,
    ),
  );
}

// Helper: Parse list (handles multiple legacy formats)
// B6 FIX helper: coerce a timestamp entry that may arrive as an int (epoch ms),
// a num (double epoch), or a Firestore Timestamp into epoch milliseconds.
int _coerceEpochMs(dynamic e) {
  if (e is int) return e;
  if (e is Timestamp) return e.millisecondsSinceEpoch;
  if (e is num) return e.toInt();
  return DateTime.now().millisecondsSinceEpoch;
}

List<T> _parseList<T>(dynamic value, T Function(dynamic) deserializer) {
  // If it's already a list
  if (value is List) {
    return value.map((e) => deserializer(e)).toList();
  }

  // Legacy format with FieldHistory: {timestamps: [...], values: [...]}
  if (value is Map<String, dynamic> && value.containsKey('values')) {
    final values = value['values'];
    if (values is List) {
      return values.map((e) => deserializer(e)).toList();
    }
  }

  // Legacy format: {value: ..., timestamp: ...}
  if (value is Map<String, dynamic> && value.containsKey('value')) {
    return [deserializer(value['value'])];
  }

  // Simple value
  return [deserializer(value)];
}

// Helper: Convert arrays to JSON string
String _parseJsonArray(dynamic value) {
  if (value == null) return '[]';
  if (value is String) return value;
  if (value is List) return jsonEncode(value);
  return '[]';
}

// Helper: Convert employee list to JSON string
String _parseEmployeeListToJson(dynamic value) {
  if (value == null) return '[]';
  if (value is String) return value;
  if (value is List) {
    final employees = value
        .map((e) {
          if (e is Map<String, dynamic>) {
            return e;
          } else if (e is Map) {
            return Map<String, dynamic>.from(e);
          }
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .toList();
    return jsonEncode(employees);
  }
  return '[]';
}
