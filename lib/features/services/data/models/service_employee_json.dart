/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: service_employee_json.dart
/// Purpose: Reading an employee from a map / entity, and writing it back.
///          Split out of service_employee_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/academic_history_entity.dart';
import 'package:knowticed_plus/features/services/data/models/services_mobile_phone_entity.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_data.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_keys.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

/// Function Name: [serviceEmployeeFromEntity]
///
/// Purpose: The body of ServiceEmployeeModel.fromEntity.
ServiceEmployeeModel serviceEmployeeFromEntity(dynamic entity) {
  if (entity is ServiceEmployeeModel) return entity;

  return ServiceEmployeeModel(
    id: entity.id,
    state: entity.state,
    firstName: entity.firstName,
    middleName: entity.middleName,
    lastName: entity.lastName,
    firstNameInArabic: entity.firstNameInArabic,
    middleNameInArabic: entity.middleNameInArabic,
    lastNameInArabic: entity.lastNameInArabic,
    nationalId: entity.nationalId,
    nationalIdExpirationDate: entity.nationalIdExpirationDate,
    nationality: entity.nationality,
    passport: entity.passport,
    passportExpirationDate: entity.passportExpirationDate,
    email: entity.email,
    mobilePhone: entity.mobilePhone,
    officePhone: entity.officePhone,
    homePhone: entity.homePhone,
    extension: entity.extension,
    birthDay: entity.birthDay,
    gender: entity.gender,
    country: entity.country,
    imageUrl: entity.imageUrl,
    province: entity.province,
    city: entity.city,
    postalCode: entity.postalCode,
    street: entity.street,
    maritalStatus: entity.maritalStatus,
    language: entity.language,
    departmentId: entity.departmentId,
    supervisor: entity.supervisor,
    role: entity.role,
    title: entity.title,
    titleInArabic: entity.titleInArabic,
    workLocation: entity.workLocation,
    drivingLicenseId: entity.drivingLicenseId,
    carPlates: entity.carPlates,
    academicHistory: entity.academicHistory,
    bio: entity.bio,
    photo: entity.photo,
    skills: entity.skills,
    hobbies: entity.hobbies,
    status: entity.status,
    firstLogin: entity.firstLogin,
    lastLogin: entity.lastLogin,
    deactivationDate: entity.deactivationDate,
    activationDate: entity.activationDate,
  );
}

/// Function Name: [serviceEmployeeFromJson]
///
/// Purpose: The body of ServiceEmployeeModel.fromJson.
ServiceEmployeeModel serviceEmployeeFromJson(Map<String, dynamic> json) {
  return ServiceEmployeeModel(
    id: json[ServiceEmployeeKeys.kId],
    state: json[ServiceEmployeeKeys.kState],
    firstName: json[ServiceEmployeeKeys.kFirstName],
    middleName: json[ServiceEmployeeKeys.kMiddleName],
    lastName: json[ServiceEmployeeKeys.kLastName],
    firstNameInArabic: json[ServiceEmployeeKeys.kFirstNameInArabic],
    middleNameInArabic: json[ServiceEmployeeKeys.kMiddleNameInArabic],
    lastNameInArabic: json[ServiceEmployeeKeys.kLastNameInArabic],
    nationalId: json[ServiceEmployeeKeys.kNationalId],
    nationalIdExpirationDate:
        json[ServiceEmployeeKeys.kNationalIdExpirationDate],
    nationality: json[ServiceEmployeeKeys.kNationality],
    passport: json[ServiceEmployeeKeys.kPassport],
    passportExpirationDate: json[ServiceEmployeeKeys.kPassportExpirationDate],
    email: json[ServiceEmployeeKeys.kEmail],
    mobilePhone: json[ServiceEmployeeKeys.kMobilePhone] != null
        ? ServicesMobilePhoneEntity.fromJson(
            json[ServiceEmployeeKeys.kMobilePhone],
          )
        : null,
    officePhone: json[ServiceEmployeeKeys.kOfficePhone],
    homePhone: json[ServiceEmployeeKeys.kHomePhone],
    extension: json[ServiceEmployeeKeys.kExtension],
    birthDay: json[ServiceEmployeeKeys.kBirthDay],
    gender: json[ServiceEmployeeKeys.kGender],
    country: json[ServiceEmployeeKeys.kCountry],
    imageUrl: json[ServiceEmployeeKeys.kImageUrl],
    province: json[ServiceEmployeeKeys.kProvince],
    city: json[ServiceEmployeeKeys.kCity],
    postalCode: json[ServiceEmployeeKeys.kPostalCode],
    street: json[ServiceEmployeeKeys.kStreet],
    maritalStatus: json[ServiceEmployeeKeys.kMaritalStatus],
    language: json[ServiceEmployeeKeys.kLanguage],
    departmentId: json[ServiceEmployeeKeys.kDepartmentId],
    supervisor: json[ServiceEmployeeKeys.kSupervisor],
    role: json[ServiceEmployeeKeys.kRole],
    title: json[ServiceEmployeeKeys.kTitle],
    titleInArabic: json[ServiceEmployeeKeys.kTitleInArabic],
    workLocation: json[ServiceEmployeeKeys.kWorkLocation],
    drivingLicenseId: json[ServiceEmployeeKeys.kDrivingLicenseId],
    carPlates: (json[ServiceEmployeeKeys.kCarPlates] as List?)?.cast<String?>(),
    academicHistory: json[ServiceEmployeeKeys.kAcademicHistory] != null
        ? AcademicHistoryEntity.fromJson(
            json[ServiceEmployeeKeys.kAcademicHistory],
          )
        : null,
    bio: json[ServiceEmployeeKeys.kBio],
    photo: json[ServiceEmployeeKeys.kPhoto],
    skills: (json[ServiceEmployeeKeys.kSkills] as List?)?.cast<String?>(),
    hobbies: (json[ServiceEmployeeKeys.kHobbies] as List?)?.cast<String?>(),
    status: json[ServiceEmployeeKeys.kStatus],
    firstLogin: json[ServiceEmployeeKeys.kFirstLogin],
    lastLogin: json[ServiceEmployeeKeys.kLastLogin],
    deactivationDate: json[ServiceEmployeeKeys.kDeactivationDate],
    activationDate: json[ServiceEmployeeKeys.kActivationDate],
  );
}

/// Mixin Name: [ServiceEmployeeWrites]
///
/// Purpose: toJson / toMap.
mixin ServiceEmployeeWrites on ServiceEmployeeData {
  // Canonical map serialization (§10) — delegates to toJson()/fromJson().
  Map<String, dynamic> toMap() => toJson();

  Map<String, dynamic> toJson() {
    return {
      ServiceEmployeeKeys.kId: id,
      ServiceEmployeeKeys.kState: state,
      ServiceEmployeeKeys.kFirstName: firstName,
      ServiceEmployeeKeys.kMiddleName: middleName,
      ServiceEmployeeKeys.kLastName: lastName,
      ServiceEmployeeKeys.kFirstNameInArabic: firstNameInArabic,
      ServiceEmployeeKeys.kMiddleNameInArabic: middleNameInArabic,
      ServiceEmployeeKeys.kLastNameInArabic: lastNameInArabic,
      ServiceEmployeeKeys.kNationalId: nationalId,
      ServiceEmployeeKeys.kNationalIdExpirationDate: nationalIdExpirationDate,
      ServiceEmployeeKeys.kNationality: nationality,
      ServiceEmployeeKeys.kPassport: passport,
      ServiceEmployeeKeys.kPassportExpirationDate: passportExpirationDate,
      ServiceEmployeeKeys.kEmail: email,
      ServiceEmployeeKeys.kMobilePhone: mobilePhone?.toJson(),
      ServiceEmployeeKeys.kOfficePhone: officePhone,
      ServiceEmployeeKeys.kHomePhone: homePhone,
      ServiceEmployeeKeys.kExtension: extension,
      ServiceEmployeeKeys.kBirthDay: birthDay,
      ServiceEmployeeKeys.kGender: gender,
      ServiceEmployeeKeys.kCountry: country,
      ServiceEmployeeKeys.kImageUrl: imageUrl,
      ServiceEmployeeKeys.kProvince: province,
      ServiceEmployeeKeys.kCity: city,
      ServiceEmployeeKeys.kPostalCode: postalCode,
      ServiceEmployeeKeys.kStreet: street,
      ServiceEmployeeKeys.kMaritalStatus: maritalStatus,
      ServiceEmployeeKeys.kLanguage: language,
      ServiceEmployeeKeys.kDepartmentId: departmentId,
      ServiceEmployeeKeys.kSupervisor: supervisor,
      ServiceEmployeeKeys.kRole: role,
      ServiceEmployeeKeys.kTitle: title,
      ServiceEmployeeKeys.kTitleInArabic: titleInArabic,
      ServiceEmployeeKeys.kWorkLocation: workLocation,
      ServiceEmployeeKeys.kDrivingLicenseId: drivingLicenseId,
      ServiceEmployeeKeys.kCarPlates: carPlates,
      ServiceEmployeeKeys.kAcademicHistory: academicHistory?.toJson(),
      ServiceEmployeeKeys.kBio: bio,
      ServiceEmployeeKeys.kPhoto: photo,
      ServiceEmployeeKeys.kSkills: skills,
      ServiceEmployeeKeys.kHobbies: hobbies,
      ServiceEmployeeKeys.kStatus: status,
      ServiceEmployeeKeys.kFirstLogin: firstLogin,
      ServiceEmployeeKeys.kLastLogin: lastLogin,
      ServiceEmployeeKeys.kDeactivationDate: deactivationDate,
      ServiceEmployeeKeys.kActivationDate: activationDate,
    };
  }
}
