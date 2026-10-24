/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: services_history_writes.dart
/// Purpose: toJson / toMap / toJsonMinimal and the Visible_To value.
///          Split out of services_history_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/services_history_current.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_data.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_keys.dart';
import 'package:knowticed_plus/features/services/data/utils/service_visibility.dart';

/// Mixin Name: [ServicesHistoryWrites]
///
/// Purpose: Full and minimal maps for Firestore writes.
mixin ServicesHistoryWrites on ServicesHistoryData, ServicesHistoryCurrent {
  // ---- Canonical map serialization (§10) ----
  // toMap()/fromMap() are the standard names. They delegate to the existing
  // toJson()/fromJson() so the 100+ call sites keep working during migration.
  Map<String, dynamic> toMap() => toJson();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      ServicesHistoryKeys.kTimestamps: timestamps,
      ServicesHistoryKeys.kId: id,
      ServicesHistoryKeys.kState: state,
      ServicesHistoryKeys.kStatus: status,
      ServicesHistoryKeys.kParentServiceId: parentServiceId,
      ServicesHistoryKeys.kFirstNameRequester: firstNameRequester,
      ServicesHistoryKeys.kLastNameRequester: lastNameRequester,
      ServicesHistoryKeys.kDepartmentRequester: departmentRequester,
      ServicesHistoryKeys.kJobTitleRequester: jobTitleRequester,
      ServicesHistoryKeys.kEmailRequester: emailRequester,
      ServicesHistoryKeys.kPhoneRequester: phoneRequester,
      ServicesHistoryKeys.kGenderRequester: genderRequester,
      ServicesHistoryKeys.kAssignedProviderEmail: assignedProviderEmail,
      ServicesHistoryKeys.kFirstNameRequesterArabic: firstNameRequesterArabic,
      ServicesHistoryKeys.kLastNameRequesterArabic: lastNameRequesterArabic,
      ServicesHistoryKeys.kJobTitleRequesterArabic: jobTitleRequesterArabic,
      ServicesHistoryKeys.kDepartmentRequesterArabic: departmentRequesterArabic,
      ServicesHistoryKeys.kServiceNameEnglish: serviceNameEnglish,
      ServicesHistoryKeys.kServiceNameArabic: serviceNameArabic,
      ServicesHistoryKeys.kServiceDescriptionEnglish: serviceDescriptionEnglish,
      ServicesHistoryKeys.kServiceDescriptionArabic: serviceDescriptionArabic,
      ServicesHistoryKeys.kDurationOfServices: durationOfServices,
      ServicesHistoryKeys.kSelectedDurationUnit: selectedDurationUnit,
      ServicesHistoryKeys.kDurationOfServicesTimestamp:
          durationOfServicesTimestamp
              .map((v) => v.millisecondsSinceEpoch)
              .toList(),
      ServicesHistoryKeys.kImageUrl: imageUrl,
      ServicesHistoryKeys.kProviderServices: providerServices,
      ServicesHistoryKeys.kLimitAvailability: limitAvailability,
      ServicesHistoryKeys.kRequireApproval: requireApproval,
      ServicesHistoryKeys.kSelectDepartment: selectDepartment,
      ServicesHistoryKeys.kApprovalCycle: approvalCycle,
      ServicesHistoryKeys.kSlaOneControllerEnglish: slaOneControllerEnglish,
      ServicesHistoryKeys.kSlaTwoControllerEnglish: slaTwoControllerEnglish,
      ServicesHistoryKeys.kNotifyRequesterChecked: notifyRequesterChecked,
      ServicesHistoryKeys.kNotifyProviderChecked: notifyProviderChecked,
      ServicesHistoryKeys.kNotifyManagerChecked: notifyManagerChecked,
      ServicesHistoryKeys.kNotifyRequesterSwitch0: notifyRequesterSwitch0,
      ServicesHistoryKeys.kNotifyManagerSwitch1: notifyManagerSwitch1,
      // SVC-HOME-01: flat copy of who may see the service, for queries.
      ServiceVisibility.field: visibleTo,
    };
  }

  /// SVC-HOME-01: the `Visible_To` value written with every save. A draft is
  /// visible to nobody but its creator (found through Email_Requester).
  List<String> get visibleTo => isDraftState
      ? const <String>[]
      : ServiceVisibility.keysFor(
          limitAvailability: limitAvailability,
          selectDepartment: selectDepartment,
        );

  // ✅ NEW: Convert to JSON, ONLY including fields that have values
  // ✅ UPDATED: Convert to JSON, ONLY including fields that have values
  Map<String, dynamic> toJsonMinimal() {
    final Map<String, dynamic> json = {};

    // ✅ Always include timestamps
    json['timestamps'] = timestamps;

    // ✅ Only add fields if they are NOT EMPTY AND have non-empty values
    if (parentServiceId.isNotEmpty && parentServiceId.last.isNotEmpty) {
      json['Parent_Service_Id'] = parentServiceId;
    }
    if (id.isNotEmpty && id.last.isNotEmpty) {
      json['id'] = id;
    }
    if (providerServices.isNotEmpty && providerServices.last.isNotEmpty) {
      json['Provider_Services'] = providerServices;
    }
    if (approvalCycle.isNotEmpty && approvalCycle.last.isNotEmpty) {
      json['Approval_Cycle'] = approvalCycle;
    }
    if (state.isNotEmpty && state.last.isNotEmpty) {
      json['state'] = state;
    }
    if (status.isNotEmpty && status.last.isNotEmpty) {
      json['status'] = status;
    }
    if (emailRequester.isNotEmpty && emailRequester.last.isNotEmpty) {
      // ✅ ADDED CHECK
      json['Email_Requester'] = emailRequester;
    }
    if (assignedProviderEmail.isNotEmpty &&
        assignedProviderEmail.last.isNotEmpty) {
      json['Assigned_Provider_Email'] = assignedProviderEmail;
    }

    // ✅ Don't include selectDepartment or any other empty fields
    return json;
  }
}
