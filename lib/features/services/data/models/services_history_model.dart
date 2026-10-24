/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: services_history_model.dart
/// Purpose: DTO for a service history record (providers, approval cycle, SLA).
///          Rule "Max 200 lines per model": the fields, readers, writers and
///          builders live in the services_history_*.dart files; this class
///          puts them together, so every caller keeps using one type.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
/// Updated: 22/10/2026 by Amr Mesbah — split into the files below.
library;

import 'package:knowticed_plus/features/services/data/models/services_history_copy.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_create_json.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_current.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_data.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_json.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_writes.dart';

export 'package:knowticed_plus/features/services/data/models/services_history_factory.dart';
export 'package:knowticed_plus/features/services/data/models/services_history_keys.dart';

/// Class Name: [ServicesHistoryModel]
///
/// Purpose: One service or request record. Field names are in
/// [ServicesHistoryKeys]; new records come from [ServicesHistoryFactory].
class ServicesHistoryModel extends ServicesHistoryData
    with
        ServicesHistoryCurrent,
        ServicesHistoryWrites,
        ServicesHistoryCreateJson,
        ServicesHistoryCopy {
  ServicesHistoryModel({
    super.isDeleted,
    required super.timestamps,
    required super.id,
    required super.state,
    required super.status,
    required super.parentServiceId,
    required super.firstNameRequester,
    required super.lastNameRequester,
    required super.departmentRequester,
    required super.jobTitleRequester,
    required super.emailRequester,
    required super.phoneRequester,
    required super.genderRequester,
    required super.assignedProviderEmail,
    required super.firstNameRequesterArabic,
    required super.lastNameRequesterArabic,
    required super.jobTitleRequesterArabic,
    required super.departmentRequesterArabic,
    required super.serviceNameEnglish,
    required super.serviceNameArabic,
    required super.serviceDescriptionEnglish,
    required super.serviceDescriptionArabic,
    required super.durationOfServices,
    required super.selectedDurationUnit,
    required super.durationOfServicesTimestamp,
    required super.imageUrl,
    required super.providerServices,
    required super.limitAvailability,
    required super.requireApproval,
    required super.selectDepartment,
    required super.approvalCycle,
    required super.slaOneControllerEnglish,
    required super.slaTwoControllerEnglish,
    required super.notifyRequesterChecked,
    required super.notifyProviderChecked,
    required super.notifyManagerChecked,
    required super.notifyRequesterSwitch0,
    required super.notifyManagerSwitch1,
  });

  /// Reads a record from a Firestore map. Pure data mapping — the
  /// repository catches and reports malformed data.
  factory ServicesHistoryModel.fromJson(
    Map<String, dynamic> json, [
    String? docId,
  ]) =>
      servicesHistoryFromJson(json, docId);

  /// Canonical name for [ServicesHistoryModel.fromJson] (§10).
  factory ServicesHistoryModel.fromMap(
    Map<String, dynamic> map, [
    String? docId,
  ]) =>
      ServicesHistoryModel.fromJson(map, docId);
}
