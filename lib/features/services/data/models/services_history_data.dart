/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: services_history_data.dart
/// Purpose: The fields of a service / request record (every field is a history
///          list whose LAST entry is the current value).
///          Split out of services_history_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Class Name: [ServicesHistoryData]
///
/// Purpose: The stored fields; ServicesHistoryModel adds the behaviour.
abstract class ServicesHistoryData {
  // ✅ SHARED timestamps for ALL fields
  final List<int> timestamps;

  // Core fields - Direct lists!
  final List<String> id;
  final List<String> state;
  final List<String> status;
  final List<String> parentServiceId;

  // Requester information
  final List<String> firstNameRequester;
  final List<String> lastNameRequester;
  final List<String> departmentRequester;
  final List<String> jobTitleRequester;
  final List<String> emailRequester;
  final List<String> phoneRequester;
  final List<String> genderRequester;
  final List<String> assignedProviderEmail;

  // Arabic fields
  final List<String> firstNameRequesterArabic;
  final List<String> lastNameRequesterArabic;
  final List<String> jobTitleRequesterArabic;
  final List<String> departmentRequesterArabic;

  // Service details
  final List<String> serviceNameEnglish;
  final List<String> serviceNameArabic;
  final List<String> serviceDescriptionEnglish;
  final List<String> serviceDescriptionArabic;
  final List<String> durationOfServices;
  final List<String> selectedDurationUnit;
  final List<Timestamp> durationOfServicesTimestamp;
  final List<String> imageUrl;

  // Provider services (stored as JSON string)
  final List<String> providerServices;

  // Boolean fields
  final List<bool> limitAvailability;
  final List<bool> requireApproval;

  // Department selection (stored as JSON string)
  final List<String> selectDepartment;

  // Approval cycle (stored as JSON string)
  final List<String> approvalCycle;

  // SLA fields
  final List<String> slaOneControllerEnglish;
  final List<String> slaTwoControllerEnglish;

  // Notification fields
  final List<bool> notifyRequesterChecked;
  final List<bool> notifyProviderChecked;
  final List<bool> notifyManagerChecked;
  final List<bool> notifyRequesterSwitch0;
  final List<bool> notifyManagerSwitch1;

  /// See [ServicesHistoryKeys.kIsDeleted]. Read-only here — written by `deleteService`.
  final bool isDeleted;

  ServicesHistoryData({
    this.isDeleted = false,
    required this.timestamps,
    required this.id,
    required this.state,
    required this.status,
    required this.parentServiceId,
    required this.firstNameRequester,
    required this.lastNameRequester,
    required this.departmentRequester,
    required this.jobTitleRequester,
    required this.emailRequester,
    required this.phoneRequester,
    required this.genderRequester,
    required this.assignedProviderEmail,
    required this.firstNameRequesterArabic,
    required this.lastNameRequesterArabic,
    required this.jobTitleRequesterArabic,
    required this.departmentRequesterArabic,
    required this.serviceNameEnglish,
    required this.serviceNameArabic,
    required this.serviceDescriptionEnglish,
    required this.serviceDescriptionArabic,
    required this.durationOfServices,
    required this.selectedDurationUnit,
    required this.durationOfServicesTimestamp,
    required this.imageUrl,
    required this.providerServices,
    required this.limitAvailability,
    required this.requireApproval,
    required this.selectDepartment,
    required this.approvalCycle,
    required this.slaOneControllerEnglish,
    required this.slaTwoControllerEnglish,
    required this.notifyRequesterChecked,
    required this.notifyProviderChecked,
    required this.notifyManagerChecked,
    required this.notifyRequesterSwitch0,
    required this.notifyManagerSwitch1,
  });
}
