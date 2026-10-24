/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: service_employee_data.dart
/// Purpose: The fields of an employee as the services module stores it.
///          Split out of service_employee_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/academic_history_entity.dart';
import 'package:knowticed_plus/features/services/data/models/services_mobile_phone_entity.dart';

/// Class Name: [ServiceEmployeeData]
///
/// Purpose: The stored fields; ServiceEmployeeModel adds the behaviour.
abstract class ServiceEmployeeData {
  final String? id;

  final String? state;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? firstNameInArabic;
  final String? middleNameInArabic;
  final String? lastNameInArabic;
  final String? nationalId;
  final String? nationalIdExpirationDate;
  final String? nationality;
  final String? passport;
  final String? passportExpirationDate;
  final String? email;
  final ServicesMobilePhoneEntity? mobilePhone;
  final String? officePhone;
  final String? homePhone;
  final String? extension;
  final String? birthDay;
  final String? gender;
  final String? country;
  final String? imageUrl;
  final String? province;
  final String? city;
  final String? postalCode;
  final String? street;
  final String? maritalStatus;
  final String? language;
  final String? departmentId;
  final String? supervisor;
  final String? role;
  final String? title;
  final String? titleInArabic;
  final String? workLocation;
  final String? drivingLicenseId;
  final List<String?>? carPlates;
  final AcademicHistoryEntity? academicHistory;
  final String? bio;
  final String? photo;
  final List<String?>? skills;
  final List<String?>? hobbies;
  final String? status;
  final String? firstLogin;
  final String? lastLogin;
  final String? deactivationDate;
  final String? activationDate;

  ServiceEmployeeData({
    this.id,
    this.state,
    this.firstName,
    this.middleName,
    this.lastName,
    this.firstNameInArabic,
    this.middleNameInArabic,
    this.lastNameInArabic,
    this.nationalId,
    this.nationalIdExpirationDate,
    this.nationality,
    this.passport,
    this.passportExpirationDate,
    this.email,
    this.mobilePhone,
    this.officePhone,
    this.homePhone,
    this.extension,
    this.birthDay,
    this.gender,
    this.country,
    this.imageUrl,
    this.province,
    this.city,
    this.postalCode,
    this.street,
    this.maritalStatus,
    this.language,
    this.departmentId,
    this.supervisor,
    this.role,
    this.title,
    this.titleInArabic,
    this.workLocation,
    this.drivingLicenseId,
    this.carPlates,
    this.academicHistory,
    this.bio,
    this.photo,
    this.skills,
    this.hobbies,
    this.status,
    this.firstLogin,
    this.lastLogin,
    this.deactivationDate,
    this.activationDate,
  });
}
