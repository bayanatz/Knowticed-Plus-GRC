/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: service_employee_copy.dart
/// Purpose: copyWith for an employee.
///          Split out of service_employee_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/academic_history_entity.dart';
import 'package:knowticed_plus/features/services/data/models/services_mobile_phone_entity.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_data.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

/// Mixin Name: [ServiceEmployeeCopy]
///
/// Purpose: A copy with some fields replaced.
mixin ServiceEmployeeCopy on ServiceEmployeeData {
  ServiceEmployeeModel copyWith({
    String? id,
    String? state,
    String? firstName,
    String? middleName,
    String? lastName,
    String? firstNameInArabic,
    String? middleNameInArabic,
    String? lastNameInArabic,
    String? nationalId,
    String? nationalIdExpirationDate,
    String? nationality,
    String? passport,
    String? passportExpirationDate,
    String? email,
    ServicesMobilePhoneEntity? mobilePhone,
    String? officePhone,
    String? homePhone,
    String? extension,
    String? birthDay,
    String? gender,
    String? country,
    String? imageUrl,
    String? province,
    String? city,
    String? postalCode,
    String? street,
    String? maritalStatus,
    String? language,
    String? departmentId,
    String? supervisor,
    String? role,
    String? title,
    String? titleInArabic,
    String? workLocation,
    String? drivingLicenseId,
    List<String?>? carPlates,
    AcademicHistoryEntity? academicHistory,
    String? bio,
    String? photo,
    List<String?>? skills,
    List<String?>? hobbies,
    String? status,
    String? firstLogin,
    String? lastLogin,
    String? deactivationDate,
    String? activationDate,
  }) {
    return ServiceEmployeeModel(
      id: id ?? this.id,
      state: state ?? this.state,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      firstNameInArabic: firstNameInArabic ?? this.firstNameInArabic,
      middleNameInArabic: middleNameInArabic ?? this.middleNameInArabic,
      lastNameInArabic: lastNameInArabic ?? this.lastNameInArabic,
      nationalId: nationalId ?? this.nationalId,
      nationalIdExpirationDate:
          nationalIdExpirationDate ?? this.nationalIdExpirationDate,
      nationality: nationality ?? this.nationality,
      passport: passport ?? this.passport,
      passportExpirationDate:
          passportExpirationDate ?? this.passportExpirationDate,
      email: email ?? this.email,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      officePhone: officePhone ?? this.officePhone,
      homePhone: homePhone ?? this.homePhone,
      extension: extension ?? this.extension,
      birthDay: birthDay ?? this.birthDay,
      imageUrl: imageUrl ?? this.imageUrl,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      province: province ?? this.province,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      street: street ?? this.street,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      language: language ?? this.language,
      departmentId: departmentId ?? this.departmentId,
      supervisor: supervisor ?? this.supervisor,
      role: role ?? this.role,
      title: title ?? this.title,
      titleInArabic: titleInArabic ?? this.titleInArabic,
      workLocation: workLocation ?? this.workLocation,
      drivingLicenseId: drivingLicenseId ?? this.drivingLicenseId,
      carPlates: carPlates ?? this.carPlates,
      academicHistory: academicHistory ?? this.academicHistory,
      bio: bio ?? this.bio,
      photo: photo ?? this.photo,
      skills: skills ?? this.skills,
      hobbies: hobbies ?? this.hobbies,
      status: status ?? this.status,
      firstLogin: firstLogin ?? this.firstLogin,
      lastLogin: lastLogin ?? this.lastLogin,
      deactivationDate: deactivationDate ?? this.deactivationDate,
      activationDate: activationDate ?? this.activationDate,
    );
  }
}
