/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: services_history_factory.dart
/// Purpose: Builds a new service record and a minimal request record.
///          Split out of services_history_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

/// Class Name: [ServicesHistoryFactory]
///
/// Purpose: The two ways a record is created (they were factories on the
/// model).
abstract final class ServicesHistoryFactory {
  // Factory: Create new service
  static ServicesHistoryModel createNew({
    String id = '',
    String state = '',
    String status = 'draft',
    String parentServiceId = '',
    String firstNameRequester = '',
    String lastNameRequester = '',
    String departmentRequester = '',
    String jobTitleRequester = '',
    String emailRequester = '',
    String phoneRequester = '',
    String genderRequester = '',
    String assignedProviderEmail = '',
    String firstNameRequesterArabic = '',
    String lastNameRequesterArabic = '',
    String jobTitleRequesterArabic = '',
    String departmentRequesterArabic = '',
    String serviceNameEnglish = '',
    String serviceNameArabic = '',
    String serviceDescriptionEnglish = '',
    String serviceDescriptionArabic = '',
    String durationOfServices = '',
    String selectedDurationUnit = '',
    Timestamp? durationOfServicesTimestamp,
    String imageUrl = '',
    List<ServiceEmployeeModel> providerServices = const [],
    bool limitAvailability = false,
    bool requireApproval = false,
    List<dynamic> selectDepartment = const [],
    List<ServiceEmployeeModel> approvalCycle = const [],
    String slaOneControllerEnglish = '',
    String slaTwoControllerEnglish = '',
    bool notifyRequesterChecked = false,
    bool notifyProviderChecked = false,
    bool notifyManagerChecked = false,
    bool notifyRequesterSwitch0 = false,
    bool notifyManagerSwitch1 = false,
  }) {
    return ServicesHistoryModel(
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      id: [id],
      state: [state],
      status: [status],
      parentServiceId: [parentServiceId],
      firstNameRequester: [firstNameRequester],
      lastNameRequester: [lastNameRequester],
      departmentRequester: [departmentRequester],
      jobTitleRequester: [jobTitleRequester],
      emailRequester: [emailRequester],
      phoneRequester: [phoneRequester],
      genderRequester: [genderRequester],
      assignedProviderEmail: [assignedProviderEmail],
      firstNameRequesterArabic: [firstNameRequesterArabic],
      lastNameRequesterArabic: [lastNameRequesterArabic],
      jobTitleRequesterArabic: [jobTitleRequesterArabic],
      departmentRequesterArabic: [departmentRequesterArabic],
      serviceNameEnglish: [serviceNameEnglish],
      serviceNameArabic: [serviceNameArabic],
      serviceDescriptionEnglish: [serviceDescriptionEnglish],
      serviceDescriptionArabic: [serviceDescriptionArabic],
      durationOfServices: [durationOfServices],
      selectedDurationUnit: [selectedDurationUnit],
      durationOfServicesTimestamp: [
        durationOfServicesTimestamp ?? Timestamp.now(),
      ],
      imageUrl: [imageUrl],
      providerServices: [
        jsonEncode(providerServices.map((e) => e.toJson()).toList()),
      ],
      limitAvailability: [limitAvailability],
      requireApproval: [requireApproval],
      selectDepartment: [jsonEncode(selectDepartment)],
      approvalCycle: [
        jsonEncode(approvalCycle.map((e) => e.toJson()).toList()),
      ],
      slaOneControllerEnglish: [slaOneControllerEnglish],
      slaTwoControllerEnglish: [slaTwoControllerEnglish],
      notifyRequesterChecked: [notifyRequesterChecked],
      notifyProviderChecked: [notifyProviderChecked],
      notifyManagerChecked: [notifyManagerChecked],
      notifyRequesterSwitch0: [notifyRequesterSwitch0],
      notifyManagerSwitch1: [notifyManagerSwitch1],
    );
  }

  // ✅ NEW: Creates a MINIMAL request with ONLY the required fields
  /// All other fields will remain as EMPTY LISTS (not included in toJsonMinimal)
  static ServicesHistoryModel createMinimalRequest({
    required String parentServiceId,
    required String id,
    required List<ServiceEmployeeModel> providerServices,
    required List<ServiceEmployeeModel> approvalCycle,
    required String state,
    required String status,
    required String emailRequester, // ✅ ADDED
  }) {
    return ServicesHistoryModel(
      // ✅ Required fields ONLY
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      parentServiceId: [parentServiceId],
      id: [id],
      providerServices: [
        jsonEncode(providerServices.map((e) => e.toJson()).toList()),
      ],
      selectDepartment: [], // ✅ Empty - will not be uploaded
      emailRequester: [emailRequester], // ✅ ADDED - will be uploaded
      approvalCycle: [
        jsonEncode(approvalCycle.map((e) => e.toJson()).toList()),
      ],
      state: [state],
      status: [status],

      // ✅ ALL other fields are EMPTY LISTS (won't be uploaded when using toJsonMinimal)
      firstNameRequester: [],
      lastNameRequester: [],
      departmentRequester: [],
      jobTitleRequester: [],
      phoneRequester: [],
      genderRequester: [],
      assignedProviderEmail: [],
      firstNameRequesterArabic: [],
      lastNameRequesterArabic: [],
      jobTitleRequesterArabic: [],
      departmentRequesterArabic: [],
      serviceNameEnglish: [],
      serviceNameArabic: [],
      serviceDescriptionEnglish: [],
      serviceDescriptionArabic: [],
      durationOfServices: [],
      selectedDurationUnit: [],
      durationOfServicesTimestamp: [],
      imageUrl: [],
      limitAvailability: [],
      requireApproval: [],
      slaOneControllerEnglish: [],
      slaTwoControllerEnglish: [],
      notifyRequesterChecked: [],
      notifyProviderChecked: [],
      notifyManagerChecked: [],
      notifyRequesterSwitch0: [],
      notifyManagerSwitch1: [],
    );
  }
}
