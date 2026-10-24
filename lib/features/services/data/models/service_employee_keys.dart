/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: service_employee_keys.dart
/// Purpose: Field names of an employee map.
///          Split out of service_employee_model.dart (rule "Max 200 lines
///          per model").
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

/// Class Name: [ServiceEmployeeKeys]
///
/// Purpose: One constant per employee field.
abstract final class ServiceEmployeeKeys {
  // ---- Firestore field keys (in-class, SCREAMING_SNAKE_CASE) ----
  static const String kId = 'id';
  static const String kState = 'state';
  static const String kFirstName = 'firstName';
  static const String kMiddleName = 'middleName';
  static const String kLastName = 'lastName';
  static const String kFirstNameInArabic = 'firstNameInArabic';
  static const String kMiddleNameInArabic = 'middleNameInArabic';
  static const String kLastNameInArabic = 'lastNameInArabic';
  static const String kNationalId = 'nationalId';
  static const String kNationalIdExpirationDate = 'nationalIdExpirationDate';
  static const String kNationality = 'nationality';
  static const String kPassport = 'passport';
  static const String kPassportExpirationDate = 'passportExpirationDate';
  static const String kEmail = 'email';
  static const String kMobilePhone = 'mobilePhone';
  static const String kOfficePhone = 'officePhone';
  static const String kHomePhone = 'homePhone';
  static const String kExtension = 'extension';
  static const String kBirthDay = 'birthDay';
  static const String kGender = 'gender';
  static const String kCountry = 'country';
  static const String kImageUrl = 'imageUrl';
  static const String kProvince = 'province';
  static const String kCity = 'city';
  static const String kPostalCode = 'postalCode';
  static const String kStreet = 'street';
  static const String kMaritalStatus = 'maritalStatus';
  static const String kLanguage = 'language';
  static const String kDepartmentId = 'departmentId';
  static const String kSupervisor = 'supervisor';
  static const String kRole = 'role';
  static const String kTitle = 'title';
  static const String kTitleInArabic = 'titleInArabic';
  static const String kWorkLocation = 'workLocation';
  static const String kDrivingLicenseId = 'drivingLicenseId';
  static const String kCarPlates = 'carPlates';
  static const String kAcademicHistory = 'academicHistory';
  static const String kBio = 'bio';
  static const String kPhoto = 'photo';
  static const String kSkills = 'skills';
  static const String kHobbies = 'hobbies';
  static const String kStatus = 'status';
  static const String kFirstLogin = 'firstLogin';
  static const String kLastLogin = 'lastLogin';
  static const String kDeactivationDate = 'deactivationDate';
  static const String kActivationDate = 'activationDate';
}
