/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: service_employee_model.dart
/// Purpose: The employee model used by the services module (renamed from
///          EmployeeEntityModell, H35). Rule "Max 200 lines per model": the
///          fields, copyWith and the map conversion live in the
///          service_employee_*.dart files.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
/// Updated: 22/10/2026 by Amr Mesbah — split into the files below.
library;

import 'package:knowticed_plus/features/services/data/models/service_employee_copy.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_data.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_json.dart';

export 'package:knowticed_plus/features/services/data/models/academic_history_entity.dart';
export 'package:knowticed_plus/features/services/data/models/service_employee_keys.dart';
export 'package:knowticed_plus/features/services/data/models/services_mobile_phone_entity.dart';

/// Class Name: [ServiceEmployeeModel]
///
/// Purpose: One employee (provider or approver) saved on a service.
class ServiceEmployeeModel extends ServiceEmployeeData
    with ServiceEmployeeCopy, ServiceEmployeeWrites {
  ServiceEmployeeModel({
    super.id,
    super.state,
    super.firstName,
    super.middleName,
    super.lastName,
    super.firstNameInArabic,
    super.middleNameInArabic,
    super.lastNameInArabic,
    super.nationalId,
    super.nationalIdExpirationDate,
    super.nationality,
    super.passport,
    super.passportExpirationDate,
    super.email,
    super.mobilePhone,
    super.officePhone,
    super.homePhone,
    super.extension,
    super.birthDay,
    super.gender,
    super.country,
    super.imageUrl,
    super.province,
    super.city,
    super.postalCode,
    super.street,
    super.maritalStatus,
    super.language,
    super.departmentId,
    super.supervisor,
    super.role,
    super.title,
    super.titleInArabic,
    super.workLocation,
    super.drivingLicenseId,
    super.carPlates,
    super.academicHistory,
    super.bio,
    super.photo,
    super.skills,
    super.hobbies,
    super.status,
    super.firstLogin,
    super.lastLogin,
    super.deactivationDate,
    super.activationDate,
  });

  factory ServiceEmployeeModel.fromEntity(dynamic entity) =>
      serviceEmployeeFromEntity(entity);

  factory ServiceEmployeeModel.fromJson(Map<String, dynamic> json) =>
      serviceEmployeeFromJson(json);

  /// Canonical name for [ServiceEmployeeModel.fromJson] (§10).
  factory ServiceEmployeeModel.fromMap(Map<String, dynamic> map) =>
      ServiceEmployeeModel.fromJson(map);
}
