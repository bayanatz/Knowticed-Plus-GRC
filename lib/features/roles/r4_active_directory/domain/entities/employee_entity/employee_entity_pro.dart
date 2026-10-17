/// Module: roles/r4_active_directory
///
///*************************** FILE INFO ****************************///
/// File Name: employee_entity_pro.dart
/// Description: `EmployeeEntityPro` — split out of `employee_entity.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../employee_entity.dart';

// Split from employee_entity.dart to keep every file under 700 lines.

class EmployeeEntityPro {
  final String? id;
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
  final PhoneNumber? mobilePhone;
  final String? officePhone;
  final String? homePhone;
  final PhoneNumber? officePhoneNumber;
  final PhoneNumber? homePhoneNumber;
  final PhoneNumber? firstEmergencyPhone;
  final PhoneNumber? secondEmergencyPhone;
  final String? extension;
  final String? birthDay;
  final String? gender;
  final String? country;
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
  final String? personalEmail;
  final String? homeCountryCode;
  final String? officeCountryCode;
  final String? jobType;
  final String? workArrangement;
  final String? remoteStatus;
  final String? employeeGrade;
  final String? startDate;
  final String? startTime;
  final String? endTime;
  final String? daysOff;
  final String? salary;
  final String? currency;
  final String? institutionName;
  final String? degree;
  final String? fieldOfStudy;
  final String? certificationStartDate;
  final String? certificationEndDate;
  final String? gradeOrScore;
  final String? certificateId;
  final String? issuingAuthority;
  final String? certificationDocumentUrl;
  final String? certificationNotes;
  final String? insuranceName;
  final String? insurancePolicyNumber;
  final String? insuranceProviderContact;
  final String? firstContactFirstName;
  final String? firstContactLastName;
  final String? firstContactRelationship;
  final String? firstContactEmail;
  final String? firstContactPhone;
  final String? firstContactLanguage;
  final String? firstContactCountry;
  final String? firstContactProvince;
  final String? firstContactCity;
  final String? firstContactStreet;
  final String? firstContactFirstNameArabic;
  final String? firstContactMiddleName;
  final String? firstContactMiddleNameArabic;
  final String? firstContactLastNameArabic;
  final String? secondContactFirstName;
  final String? secondContactLastName;
  final String? secondContactRelationship;
  final String? secondContactEmail;
  final String? secondContactPhone;
  final String? secondContactLanguage;
  final String? secondContactCountry;
  final String? secondContactProvince;
  final String? secondContactCity;
  final String? secondContactStreet;
  final String? secondContactFirstNameArabic;
  final String? secondContactMiddleName;
  final String? secondContactMiddleNameArabic;
  final String? secondContactLastNameArabic;
  final String? passportDocumentUrl;
  final String? nationalIdFrontUrl;
  final String? nationalIdBackUrl;
  final String? drivingLicenseDocumentUrl;
  final String? password;
  final String? defaultPassword;
  final String? firstLogin;
  final String? lastLogin;
  final String? deactivationDate;
  final String? activationDate;

  EmployeeEntityPro({
    this.id,
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
    this.officePhoneNumber,
    this.homePhoneNumber,
    this.firstEmergencyPhone,
    this.secondEmergencyPhone,
    this.extension,
    this.birthDay,
    this.gender,
    this.country,
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
    this.personalEmail,
    this.homeCountryCode,
    this.officeCountryCode,
    this.jobType,
    this.workArrangement,
    this.remoteStatus,
    this.employeeGrade,
    this.startDate,
    this.startTime,
    this.endTime,
    this.daysOff,
    this.salary,
    this.currency,
    this.institutionName,
    this.degree,
    this.fieldOfStudy,
    this.certificationStartDate,
    this.certificationEndDate,
    this.gradeOrScore,
    this.certificateId,
    this.issuingAuthority,
    this.certificationDocumentUrl,
    this.certificationNotes,
    this.insuranceName,
    this.insurancePolicyNumber,
    this.insuranceProviderContact,
    this.firstContactFirstName,
    this.firstContactLastName,
    this.firstContactRelationship,
    this.firstContactEmail,
    this.firstContactPhone,
    this.firstContactLanguage,
    this.firstContactCountry,
    this.firstContactProvince,
    this.firstContactCity,
    this.firstContactStreet,
    this.firstContactFirstNameArabic,
    this.firstContactMiddleName,
    this.firstContactMiddleNameArabic,
    this.firstContactLastNameArabic,
    this.secondContactFirstName,
    this.secondContactLastName,
    this.secondContactRelationship,
    this.secondContactEmail,
    this.secondContactPhone,
    this.secondContactLanguage,
    this.secondContactCountry,
    this.secondContactProvince,
    this.secondContactCity,
    this.secondContactStreet,
    this.secondContactFirstNameArabic,
    this.secondContactMiddleName,
    this.secondContactMiddleNameArabic,
    this.secondContactLastNameArabic,
    this.passportDocumentUrl,
    this.nationalIdFrontUrl,
    this.nationalIdBackUrl,
    this.drivingLicenseDocumentUrl,
    this.password,
    this.defaultPassword,
    this.firstLogin,
    this.lastLogin,
    this.deactivationDate,
    this.activationDate,
  });

  /// Checks if the employee is a manager
  bool isManager() {
    return title?.toLowerCase().contains('manager') ?? false;
  }

  /// Gets full name in English
  String getFullName() {
    return '${firstName ?? ''} ${middleName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// Gets full name in Arabic
  String getFullNameArabic() {
    return '${firstNameInArabic ?? ''} ${middleNameInArabic ?? ''} ${lastNameInArabic ?? ''}'
        .trim();
  }

  /// Checks if employee is active
  bool isActive() {
    return status?.toLowerCase() == 'active';
  }

  /// Checks if employee is deactivated
  bool isDeactivated() {
    return status?.toLowerCase() == 'deactivated';
  }
}
