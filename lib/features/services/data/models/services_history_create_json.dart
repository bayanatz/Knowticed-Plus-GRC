/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: services_history_create_json.dart
/// Purpose: The map written when a service is created or updated, and the
///          empty-selection fields drafts need.
///          Split out of services_history_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/services_history_data.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_keys.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_writes.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_current.dart';
import 'package:knowticed_plus/features/services/data/utils/service_visibility.dart';

/// Mixin Name: [ServicesHistoryCreateJson]
///
/// Purpose: toJsonForCreate and emptyableSelectionJson.
mixin ServicesHistoryCreateJson
    on ServicesHistoryData, ServicesHistoryCurrent, ServicesHistoryWrites {
  // ✅ NEW: For CREATING/UPDATING services - includes ALL service data, NO personal requester info
  Map<String, dynamic> toJsonForCreate() {
    final Map<String, dynamic> json = {};

    // ✅ Always include timestamps
    json['timestamps'] = timestamps;

    // ✅ Core identifiers
    if (id.isNotEmpty) json['id'] = id;
    if (state.isNotEmpty) json['state'] = state;
    if (status.isNotEmpty) json['status'] = status;
    if (parentServiceId.isNotEmpty) json['Parent_Service_Id'] = parentServiceId;

    // ✅ Email Requester (ADDED)
    if (emailRequester.isNotEmpty && emailRequester.last.isNotEmpty) {
      json['Email_Requester'] = emailRequester;
    }

    // ✅ Service details (INCLUDE ALL)
    if (serviceNameEnglish.isNotEmpty) {
      json['Service_Name_English'] = serviceNameEnglish;
    }
    if (serviceNameArabic.isNotEmpty) {
      json['Service_Name_Arabic'] = serviceNameArabic;
    }
    if (serviceDescriptionEnglish.isNotEmpty) {
      json['Service_Description_English'] = serviceDescriptionEnglish;
    }
    if (serviceDescriptionArabic.isNotEmpty) {
      json['Service_Description_Arabic'] = serviceDescriptionArabic;
    }
    if (durationOfServices.isNotEmpty) {
      json['Duration_Of_Services'] = durationOfServices;
    }
    if (selectedDurationUnit.isNotEmpty) {
      json['Selected_Duration_Unit'] = selectedDurationUnit;
    }
    if (durationOfServicesTimestamp.isNotEmpty) {
      json['Duration_Of_Services_Timestamp'] = durationOfServicesTimestamp
          .map((v) => v.millisecondsSinceEpoch)
          .toList();
    }

    // ✅ Image URL (only if not empty)
    if (imageUrl.isNotEmpty && imageUrl.last.isNotEmpty) {
      json['Image_Url'] = imageUrl;
    }

    // ✅ Provider and approval data
    if (providerServices.isNotEmpty &&
        providerServices.last.isNotEmpty &&
        providerServices.last != '[]') {
      json['Provider_Services'] = providerServices;
    }
    if (approvalCycle.isNotEmpty &&
        approvalCycle.last.isNotEmpty &&
        approvalCycle.last != '[]') {
      json['Approval_Cycle'] = approvalCycle;
    }
    if (selectDepartment.isNotEmpty &&
        selectDepartment.last.isNotEmpty &&
        selectDepartment.last != '[]') {
      json['Select_Department'] = selectDepartment;
    }

    // ✅ Boolean flags
    if (limitAvailability.isNotEmpty) {
      json['Limit_Availability'] = limitAvailability;
    }
    if (requireApproval.isNotEmpty) json['Require_Approval'] = requireApproval;

    // ✅ SLA fields
    if (slaOneControllerEnglish.isNotEmpty &&
        slaOneControllerEnglish.last.isNotEmpty) {
      json['Sla_One_Controller_English'] = slaOneControllerEnglish;
    }
    if (slaTwoControllerEnglish.isNotEmpty &&
        slaTwoControllerEnglish.last.isNotEmpty) {
      json['Sla_Two_Controller_English'] = slaTwoControllerEnglish;
    }

    // ✅ Notification settings
    if (notifyRequesterChecked.isNotEmpty) {
      json['Notify_Requester_Checked'] = notifyRequesterChecked;
    }
    if (notifyProviderChecked.isNotEmpty) {
      json['Notify_Provider_Checked'] = notifyProviderChecked;
    }
    if (notifyManagerChecked.isNotEmpty) {
      json['Notify_Manager_Checked'] = notifyManagerChecked;
    }
    if (notifyRequesterSwitch0.isNotEmpty) {
      json['Notify_Requester_Switch0'] = notifyRequesterSwitch0;
    }
    if (notifyManagerSwitch1.isNotEmpty) {
      json['Notify_Manager_Switch1'] = notifyManagerSwitch1;
    }

    // ✅ Assigned provider email (for requests)
    if (assignedProviderEmail.isNotEmpty &&
        assignedProviderEmail.last.isNotEmpty) {
      json['Assigned_Provider_Email'] = assignedProviderEmail;
    }

    // SVC-HOME-01: flat copy of who may see the service, for queries.
    json[ServiceVisibility.field] = visibleTo;

    // ❌ EXCLUDE OTHER requester personal fields:
    // - First_Name_Requester
    // - Last_Name_Requester
    // - Department_Requester
    // - Job_Title_Requester
    // - Phone_Requester
    // - Gender_Requester
    // - First_Name_Requester_Arabic
    // - Last_Name_Requester_Arabic
    // - Job_Title_Requester_Arabic
    // - Department_Requester_Arabic

    return json;
  }

  /// The selection fields that [toJson] / [toJsonForCreate] deliberately omit
  /// when they are empty, re-expressed so an empty selection can be written.
  ///
  /// Those encoders skip `Provider_Services`, `Approval_Cycle` and
  /// `Select_Department` when the newest revision is empty or `'[]'`. That is
  /// correct for a partial write, but drafts are persisted with
  /// `update()` / `set(merge: true)`, where a missing key means "keep whatever
  /// is already stored". The result was that clearing a selection could not be
  /// saved: the previously chosen provider/approver/department came back the
  /// next time the draft was opened, looking like a default the user never
  /// picked.
  ///
  /// Callers that own the whole document (the draft repository) spread this on
  /// top of the encoded json so "nothing selected" round-trips as `['[]']`.
  Map<String, dynamic> get emptyableSelectionJson {
    List<String> revisions(List<String> raw) =>
        raw.isEmpty ? <String>['[]'] : raw;

    return {
      ServicesHistoryKeys.kProviderServices: revisions(providerServices),
      ServicesHistoryKeys.kApprovalCycle: revisions(approvalCycle),
      ServicesHistoryKeys.kSelectDepartment: revisions(selectDepartment),
    };
  }
}
