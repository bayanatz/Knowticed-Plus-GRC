/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: services_history_current.dart
/// Purpose: The current (latest) value of every history field.
///          Split out of services_history_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_data.dart';

/// Mixin Name: [ServicesHistoryCurrent]
///
/// Purpose: Read-only getters for the current values.
mixin ServicesHistoryCurrent on ServicesHistoryData {
  // ✅ Helper getters for current (latest) values
  String get currentId => id.isNotEmpty ? id.last : '';
  String get currentState => state.isNotEmpty ? state.last : '';

  /// SVC-CREATE-12: true for an unfinished draft (state "draft" or a local
  /// draft id), which must never be matched as an existing service.
  bool get isDraftState =>
      currentState.trim().toLowerCase() == 'draft' ||
      currentId.startsWith('draft_');
  String get currentStatus => status.isNotEmpty ? status.last : '';
  String get currentParentServiceId =>
      parentServiceId.isNotEmpty ? parentServiceId.last : '';
  String get currentFirstNameRequester =>
      firstNameRequester.isNotEmpty ? firstNameRequester.last : '';
  String get currentLastNameRequester =>
      lastNameRequester.isNotEmpty ? lastNameRequester.last : '';
  String get currentDepartmentRequester =>
      departmentRequester.isNotEmpty ? departmentRequester.last : '';
  String get currentJobTitleRequester =>
      jobTitleRequester.isNotEmpty ? jobTitleRequester.last : '';
  String get currentEmailRequester =>
      emailRequester.isNotEmpty ? emailRequester.last : '';
  String get currentPhoneRequester =>
      phoneRequester.isNotEmpty ? phoneRequester.last : '';
  String get currentGenderRequester =>
      genderRequester.isNotEmpty ? genderRequester.last : '';
  String get currentAssignedProviderEmail =>
      assignedProviderEmail.isNotEmpty ? assignedProviderEmail.last : '';
  String get currentFirstNameRequesterArabic =>
      firstNameRequesterArabic.isNotEmpty ? firstNameRequesterArabic.last : '';
  String get currentLastNameRequesterArabic =>
      lastNameRequesterArabic.isNotEmpty ? lastNameRequesterArabic.last : '';
  String get currentJobTitleRequesterArabic =>
      jobTitleRequesterArabic.isNotEmpty ? jobTitleRequesterArabic.last : '';
  String get currentDepartmentRequesterArabic =>
      departmentRequesterArabic.isNotEmpty
          ? departmentRequesterArabic.last
          : '';
  String get currentServiceNameEnglish =>
      serviceNameEnglish.isNotEmpty ? serviceNameEnglish.last : '';
  String get currentServiceNameArabic =>
      serviceNameArabic.isNotEmpty ? serviceNameArabic.last : '';
  String get currentServiceDescriptionEnglish =>
      serviceDescriptionEnglish.isNotEmpty
          ? serviceDescriptionEnglish.last
          : '';
  String get currentServiceDescriptionArabic =>
      serviceDescriptionArabic.isNotEmpty ? serviceDescriptionArabic.last : '';
  String get currentDurationOfServices =>
      durationOfServices.isNotEmpty ? durationOfServices.last : '';
  String get currentSelectedDurationUnit =>
      selectedDurationUnit.isNotEmpty ? selectedDurationUnit.last : '';
  Timestamp get currentDurationOfServicesTimestamp =>
      durationOfServicesTimestamp.isNotEmpty
          ? durationOfServicesTimestamp.last
          : Timestamp.now();
  String get currentImageUrl => imageUrl.isNotEmpty ? imageUrl.last : '';
  bool get currentLimitAvailability =>
      limitAvailability.isNotEmpty ? limitAvailability.last : false;
  bool get currentRequireApproval =>
      requireApproval.isNotEmpty ? requireApproval.last : false;
  String get currentSlaOneControllerEnglish =>
      slaOneControllerEnglish.isNotEmpty ? slaOneControllerEnglish.last : '';
  String get currentSlaTwoControllerEnglish =>
      slaTwoControllerEnglish.isNotEmpty ? slaTwoControllerEnglish.last : '';
  bool get currentNotifyRequesterChecked =>
      notifyRequesterChecked.isNotEmpty ? notifyRequesterChecked.last : false;
  bool get currentNotifyProviderChecked =>
      notifyProviderChecked.isNotEmpty ? notifyProviderChecked.last : false;
  bool get currentNotifyManagerChecked =>
      notifyManagerChecked.isNotEmpty ? notifyManagerChecked.last : false;
  bool get currentNotifyRequesterSwitch0 =>
      notifyRequesterSwitch0.isNotEmpty ? notifyRequesterSwitch0.last : false;
  bool get currentNotifyManagerSwitch1 =>
      notifyManagerSwitch1.isNotEmpty ? notifyManagerSwitch1.last : false;

  // ✅ Get timestamp at specific index
  int? getTimestampAt(int index) =>
      index < timestamps.length ? timestamps[index] : null;

  // ✅ Get current (latest) timestamp
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  // NOTE: No try/catch in the model (§11.2). These read back JSON strings that
  // were produced by this same model's encoders, guarded by empty/`[]` checks.
  List<ServiceEmployeeModel> get currentProviderServices {
    if (providerServices.isEmpty) return [];

    final jsonStr = providerServices.last;
    if (jsonStr.isEmpty || jsonStr == '[]' || jsonStr == '""') return [];

    final List<dynamic> list = jsonDecode(jsonStr);
    if (list.isEmpty) return [];

    return list.map((e) => ServiceEmployeeModel.fromJson(e)).toList();
  }

  List<ServiceEmployeeModel> get currentApprovalCycle {
    if (approvalCycle.isEmpty) return [];

    final jsonStr = approvalCycle.last;
    if (jsonStr.isEmpty || jsonStr == '[]' || jsonStr == '""') return [];

    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => ServiceEmployeeModel.fromJson(e)).toList();
  }

  List<String> get currentSelectDepartment {
    if (selectDepartment.isEmpty) return [];

    final jsonStr = selectDepartment.last;
    if (jsonStr.isEmpty || jsonStr == '[]' || jsonStr == '""') return [];

    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => e.toString()).toList();
  }
}
