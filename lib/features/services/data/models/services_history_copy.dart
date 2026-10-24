/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: services_history_copy.dart
/// Purpose: copyWith and the in-place update helpers (each appends a revision).
///          Split out of services_history_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_data.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

/// Mixin Name: [ServicesHistoryCopy]
///
/// Purpose: New revisions of a record.
mixin ServicesHistoryCopy on ServicesHistoryData {
  /// copyWith APPENDS a revision to each field that is passed (history
  /// lists: the current value is the last entry).
  ///
  /// [bumpTimestamp]: whether this copy counts as a real edit and appends
  /// "now" to [timestamps]. Pass false for cosmetic / derived changes (the
  /// read-time repairs of a missing name), so "Last Update" is not re-dated
  /// on every list load.
  ServicesHistoryModel copyWith({
    String? id,
    String? state,
    String? status,
    String? parentServiceId,
    String? firstNameRequester,
    String? lastNameRequester,
    String? departmentRequester,
    String? jobTitleRequester,
    String? emailRequester,
    String? phoneRequester,
    String? genderRequester,
    String? assignedProviderEmail,
    String? firstNameRequesterArabic,
    String? lastNameRequesterArabic,
    String? jobTitleRequesterArabic,
    String? departmentRequesterArabic,
    String? serviceNameEnglish,
    String? serviceNameArabic,
    String? serviceDescriptionEnglish,
    String? serviceDescriptionArabic,
    String? durationOfServices,
    String? selectedDurationUnit,
    Timestamp? durationOfServicesTimestamp,
    String? imageUrl,
    List<ServiceEmployeeModel>? providerServices,
    bool? limitAvailability,
    bool? requireApproval,
    List<dynamic>? selectDepartment,
    List<ServiceEmployeeModel>? approvalCycle,
    String? slaOneControllerEnglish,
    String? slaTwoControllerEnglish,
    bool? notifyRequesterChecked,
    bool? notifyProviderChecked,
    bool? notifyManagerChecked,
    bool? notifyRequesterSwitch0,
    bool? notifyManagerSwitch1,
    bool bumpTimestamp = true,
  }) {
    String? employees(List<ServiceEmployeeModel>? list) =>
        list == null ? null : jsonEncode(list.map((e) => e.toJson()).toList());

    return ServicesHistoryModel(
      isDeleted: isDeleted,
      timestamps: bumpTimestamp
          ? (List<int>.from(timestamps)
            ..add(DateTime.now().millisecondsSinceEpoch))
          : List<int>.from(timestamps),
      id: _append(this.id, id),
      state: _append(this.state, state),
      status: _append(this.status, status),
      parentServiceId: _append(this.parentServiceId, parentServiceId),
      firstNameRequester: _append(this.firstNameRequester, firstNameRequester),
      lastNameRequester: _append(this.lastNameRequester, lastNameRequester),
      departmentRequester: _append(
        this.departmentRequester,
        departmentRequester,
      ),
      jobTitleRequester: _append(this.jobTitleRequester, jobTitleRequester),
      emailRequester: _append(this.emailRequester, emailRequester),
      phoneRequester: _append(this.phoneRequester, phoneRequester),
      genderRequester: _append(this.genderRequester, genderRequester),
      assignedProviderEmail: _append(
        this.assignedProviderEmail,
        assignedProviderEmail,
      ),
      firstNameRequesterArabic: _append(
        this.firstNameRequesterArabic,
        firstNameRequesterArabic,
      ),
      lastNameRequesterArabic: _append(
        this.lastNameRequesterArabic,
        lastNameRequesterArabic,
      ),
      jobTitleRequesterArabic: _append(
        this.jobTitleRequesterArabic,
        jobTitleRequesterArabic,
      ),
      departmentRequesterArabic: _append(
        this.departmentRequesterArabic,
        departmentRequesterArabic,
      ),
      serviceNameEnglish: _append(this.serviceNameEnglish, serviceNameEnglish),
      serviceNameArabic: _append(this.serviceNameArabic, serviceNameArabic),
      serviceDescriptionEnglish: _append(
        this.serviceDescriptionEnglish,
        serviceDescriptionEnglish,
      ),
      serviceDescriptionArabic: _append(
        this.serviceDescriptionArabic,
        serviceDescriptionArabic,
      ),
      durationOfServices: _append(this.durationOfServices, durationOfServices),
      selectedDurationUnit: _append(
        this.selectedDurationUnit,
        selectedDurationUnit,
      ),
      durationOfServicesTimestamp: _append(
        this.durationOfServicesTimestamp,
        durationOfServicesTimestamp,
      ),
      imageUrl: _append(this.imageUrl, imageUrl),
      providerServices: _append(
        this.providerServices,
        employees(providerServices),
      ),
      limitAvailability: _append(this.limitAvailability, limitAvailability),
      requireApproval: _append(this.requireApproval, requireApproval),
      selectDepartment: _append(
        this.selectDepartment,
        selectDepartment == null ? null : jsonEncode(selectDepartment),
      ),
      approvalCycle: _append(this.approvalCycle, employees(approvalCycle)),
      slaOneControllerEnglish: _append(
        this.slaOneControllerEnglish,
        slaOneControllerEnglish,
      ),
      slaTwoControllerEnglish: _append(
        this.slaTwoControllerEnglish,
        slaTwoControllerEnglish,
      ),
      notifyRequesterChecked: _append(
        this.notifyRequesterChecked,
        notifyRequesterChecked,
      ),
      notifyProviderChecked: _append(
        this.notifyProviderChecked,
        notifyProviderChecked,
      ),
      notifyManagerChecked: _append(
        this.notifyManagerChecked,
        notifyManagerChecked,
      ),
      notifyRequesterSwitch0: _append(
        this.notifyRequesterSwitch0,
        notifyRequesterSwitch0,
      ),
      notifyManagerSwitch1: _append(
        this.notifyManagerSwitch1,
        notifyManagerSwitch1,
      ),
    );
  }

  /// A copy of [history] with [value] added at the end, or [history] itself
  /// when [value] is null.
  List<T> _append<T>(List<T> history, T? value) =>
      value == null ? history : (List<T>.from(history)..add(value));

  // Update methods - add new values to lists
  void updateServiceName(String englishName, String arabicName) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    serviceNameEnglish.add(englishName);
    serviceNameArabic.add(arabicName);
  }

  void updateServiceDescription(String englishDesc, String arabicDesc) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    serviceDescriptionEnglish.add(englishDesc);
    serviceDescriptionArabic.add(arabicDesc);
  }

  void updateStatus(String newStatus) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    status.add(newStatus);
  }

  void updateProviderServices(List<ServiceEmployeeModel> providers) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    providerServices.add(jsonEncode(providers.map((e) => e.toJson()).toList()));
  }

  void updateApprovalCycle(List<ServiceEmployeeModel> approvers) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    approvalCycle.add(jsonEncode(approvers.map((e) => e.toJson()).toList()));
  }

  void updateSelectDepartment(List<String> departments) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    selectDepartment.add(jsonEncode(departments));
  }

  void updateDurationTimestamp(Timestamp timestamp) {
    timestamps.add(DateTime.now().millisecondsSinceEpoch);
    durationOfServicesTimestamp.add(timestamp);
  }
}
