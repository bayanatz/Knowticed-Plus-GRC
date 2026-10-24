// ******************* FILE INFO *******************
// File Name: model_employee
// Description: Employee DTO used by the services module (serialisation to/from Firestore).
// Module: services_management_module / data / models
// *************************************************

import 'package:knowticed_plus/core/helper/phone_number.dart';

class ServicesMobilePhoneEntity {
  // ---- Firestore field keys (in-class, SCREAMING_SNAKE_CASE) ----
  static const String kPhone = 'phone';
  static const String kCountryCode = 'countryCode';
  static const String kCountryApp = 'countryApp';

  final String? phone;
  final String? countryCode;
  final String? countryApp;

  ServicesMobilePhoneEntity({
    this.phone,
    this.countryCode,
    this.countryApp,
  });
  factory ServicesMobilePhoneEntity.fromMobilePhoneEntity(PhoneNumber entity) {
    return ServicesMobilePhoneEntity(
      phone: entity.phone,
      countryCode: entity.countryCode,
      countryApp: entity.countryApp,
    );
  }
  factory ServicesMobilePhoneEntity.fromJson(Map<String, dynamic> json) {
    return ServicesMobilePhoneEntity(
      phone: json[kPhone],
      countryCode: json[kCountryCode],
      countryApp: json[kCountryApp],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kPhone: phone,
      kCountryCode: countryCode,
      kCountryApp: countryApp,
    };
  }
}

class AcademicHistoryEntity {
  // ---- Firestore field keys (in-class, SCREAMING_SNAKE_CASE) ----
  static const String kGpa = 'gpa';
  static const String kGraduateFrom = 'graduateFrom';
  static const String kUniversity = 'university';
  static const String kYearOfGraduation = 'yearOfGraduation';
  static const String kGraduateFromStatus = 'graduateFromStatus';
  static const String kUniversityStatus = 'universityStatus';
  static const String kYearOfGraduationStatus = 'yearOfGraduationStatus';
  static const String kGpaStatus = 'gpaStatus';

  final String? gpa;
  final String? graduateFrom;
  final String? university;
  final String? yearOfGraduation;
  final String? graduateFromStatus;
  final String? universityStatus;
  final String? yearOfGraduationStatus;
  final String? gpaStatus;

  AcademicHistoryEntity({
    this.gpa,
    this.graduateFrom,
    this.university,
    this.yearOfGraduation,
    this.graduateFromStatus,
    this.universityStatus,
    this.yearOfGraduationStatus,
    this.gpaStatus,
  });

  factory AcademicHistoryEntity.fromJson(Map<String, dynamic> json) {
    return AcademicHistoryEntity(
      gpa: json[kGpa],
      graduateFrom: json[kGraduateFrom],
      university: json[kUniversity],
      yearOfGraduation: json[kYearOfGraduation],
      graduateFromStatus: json[kGraduateFromStatus],
      universityStatus: json[kUniversityStatus],
      yearOfGraduationStatus: json[kYearOfGraduationStatus],
      gpaStatus: json[kGpaStatus],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      kGpa: gpa,
      kGraduateFrom: graduateFrom,
      kUniversity: university,
      kYearOfGraduation: yearOfGraduation,
      kGraduateFromStatus: graduateFromStatus,
      kUniversityStatus: universityStatus,
      kYearOfGraduationStatus: yearOfGraduationStatus,
      kGpaStatus: gpaStatus,
    };
  }
}

class EmployeeEntityModell {
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

  EmployeeEntityModell({
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

  EmployeeEntityModell copyWith({
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
    return EmployeeEntityModell(
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

  factory EmployeeEntityModell.fromEntity(dynamic entity) {
    if (entity is EmployeeEntityModell) return entity;

    return EmployeeEntityModell(
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

  factory EmployeeEntityModell.fromJson(Map<String, dynamic> json) {
    return EmployeeEntityModell(
      id: json[kId],
      state: json[kState],
      firstName: json[kFirstName],
      middleName: json[kMiddleName],
      lastName: json[kLastName],
      firstNameInArabic: json[kFirstNameInArabic],
      middleNameInArabic: json[kMiddleNameInArabic],
      lastNameInArabic: json[kLastNameInArabic],
      nationalId: json[kNationalId],
      nationalIdExpirationDate: json[kNationalIdExpirationDate],
      nationality: json[kNationality],
      passport: json[kPassport],
      passportExpirationDate: json[kPassportExpirationDate],
      email: json[kEmail],
      mobilePhone: json[kMobilePhone] != null
          ? ServicesMobilePhoneEntity.fromJson(json[kMobilePhone])
          : null,
      officePhone: json[kOfficePhone],
      homePhone: json[kHomePhone],
      extension: json[kExtension],
      birthDay: json[kBirthDay],
      gender: json[kGender],
      country: json[kCountry],
      imageUrl: json[kImageUrl],
      province: json[kProvince],
      city: json[kCity],
      postalCode: json[kPostalCode],
      street: json[kStreet],
      maritalStatus: json[kMaritalStatus],
      language: json[kLanguage],
      departmentId: json[kDepartmentId],
      supervisor: json[kSupervisor],
      role: json[kRole],
      title: json[kTitle],
      titleInArabic: json[kTitleInArabic],
      workLocation: json[kWorkLocation],
      drivingLicenseId: json[kDrivingLicenseId],
      carPlates: (json[kCarPlates] as List?)?.cast<String?>(),
      academicHistory: json[kAcademicHistory] != null
          ? AcademicHistoryEntity.fromJson(json[kAcademicHistory])
          : null,
      bio: json[kBio],
      photo: json[kPhoto],
      skills: (json[kSkills] as List?)?.cast<String?>(),
      hobbies: (json[kHobbies] as List?)?.cast<String?>(),
      status: json[kStatus],
      firstLogin: json[kFirstLogin],
      lastLogin: json[kLastLogin],
      deactivationDate: json[kDeactivationDate],
      activationDate: json[kActivationDate],
    );
  }

  // Canonical map serialization (§10) — delegates to toJson()/fromJson().
  Map<String, dynamic> toMap() => toJson();

  factory EmployeeEntityModell.fromMap(Map<String, dynamic> map) =>
      EmployeeEntityModell.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      kId: id,
      kState: state,
      kFirstName: firstName,
      kMiddleName: middleName,
      kLastName: lastName,
      kFirstNameInArabic: firstNameInArabic,
      kMiddleNameInArabic: middleNameInArabic,
      kLastNameInArabic: lastNameInArabic,
      kNationalId: nationalId,
      kNationalIdExpirationDate: nationalIdExpirationDate,
      kNationality: nationality,
      kPassport: passport,
      kPassportExpirationDate: passportExpirationDate,
      kEmail: email,
      kMobilePhone: mobilePhone?.toJson(),
      kOfficePhone: officePhone,
      kHomePhone: homePhone,
      kExtension: extension,
      kBirthDay: birthDay,
      kGender: gender,
      kCountry: country,
      kImageUrl: imageUrl,
      kProvince: province,
      kCity: city,
      kPostalCode: postalCode,
      kStreet: street,
      kMaritalStatus: maritalStatus,
      kLanguage: language,
      kDepartmentId: departmentId,
      kSupervisor: supervisor,
      kRole: role,
      kTitle: title,
      kTitleInArabic: titleInArabic,
      kWorkLocation: workLocation,
      kDrivingLicenseId: drivingLicenseId,
      kCarPlates: carPlates,
      kAcademicHistory: academicHistory?.toJson(),
      kBio: bio,
      kPhoto: photo,
      kSkills: skills,
      kHobbies: hobbies,
      kStatus: status,
      kFirstLogin: firstLogin,
      kLastLogin: lastLogin,
      kDeactivationDate: deactivationDate,
      kActivationDate: activationDate,
    };
  }
}
