// ignore_for_file: prefer_null_aware_operators

/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: new_employee_model.dart
/// Description: Declares `NewEmployeeModel`, `NewEmployeeModelHistory`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header; removed
///          the no-op `try/catch { rethrow }` around `fromMap`, the dead nested
///          `_createFieldMap`, and the GetX dependency; the two remaining empty
///          catches now log instead of swallowing.
///
/// KNOWN DEBT (from the r4 code review, not yet closed):
/// - ~1,590 LOC against a 200-LOC cap for models, and it declares two model
///   classes (`NewEmployeeModel`, `NewEmployeeModelHistory`). Splitting needs
///   new files, which the current change set is not allowed to add.
/// - Fields are mutable and there are no `static const` key constants; `toMap`
///   types its Firestore keys inline. Making the fields final requires a
///   const/final constructor plus updating every mutation site across the CSV
///   import path — a change that must be compiler-verified, not hand-checked.
/// - Two `try/catch` blocks remain in `_parseMobilePhoneList`. §11.2 forbids
///   try/catch under `data/models/`; they belong in a `data/utils/` parser
///   alongside the rest of the `_parse*` helpers.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/city_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/country_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/province_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/academic_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/department_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/first_name_arabic_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/first_name_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/job_location_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/last_name_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/middle_name_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/bio_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/bio_in_arabic_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/birthday_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/email_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/gender_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/hobbies_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/language_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/last_name_arabic_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/marital_status_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/middle_name_arabic_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/national_id_date_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/national_id_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/nationality_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/passport_date_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/passport_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/postal_code_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/role_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/skills_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/status_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/title_arabic_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/title_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/car_plates_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/driving_license_id.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/employee_photo_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/extension_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/home_phone_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/supervisor_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/office_phone_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/street_model.dart';

part 'new_employee_model/new_employee_model_history_methods.dart';
part 'new_employee_model/new_employee_model_history_methods_2.dart';
part 'new_employee_model/new_employee_model_history_statics.dart';
part 'new_employee_model/new_employee_model_methods.dart';
part 'new_employee_model/new_employee_model_statics.dart';

class NewEmployeeModel {
  String? id;
  FirstName? firstName;
  MiddleName? middleName;
  LastName? lastName;
  FirstNameInArabic? firstNameInArabic;
  MiddleNameInArabic? middleNameInArabic;
  LastNameInArabic? lastNameInArabic;
  NationalId? nationalId;
  NationalIdExpirationDate? nationalIdExpirationDate;
  Nationality? nationality;
  Passport? passport;
  PassportExpirationDate? passportExpirationDate;
  Email? email;
  MobilePhone? mobilePhone;
  OfficePhone? officePhone;
  HomePhone? homePhone;
  Extension? extension;
  BirthDay? birthDay;
  Gender? gender;
  Country? country;
  Province? province;
  City? city;
  PostalCode? postalCode;
  Street? street;
  MaritalStatus? maritalStatus;
  Language? language;
  DepartmentId? departmentid;
  Supervisor? supervisor;
  Role? role;
  TitleModel? title;
  TitleInArabic? titleInArabic;
  WorkLocation? workLocation;
  DrivingLicenseId? drivingLicenseId;
  CarPlates? carPlates;
  AcademicHistory? academicHistory;
  Bio? bio;
  BioInArabic? bioInArabic;
  Photo? photo;
  Skills? skills;
  Hobbies? hobbies;
  Status? status;
  String? password;
  String? defaultPassword;
  String? firstLogin;
  String? lastLogin;
  String? deactivationDate;
  String? activationDate;

  NewEmployeeModel({
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
    this.departmentid,
    this.supervisor,
    this.role,
    this.title,
    this.titleInArabic,
    this.workLocation,
    this.drivingLicenseId,
    this.carPlates,
    this.academicHistory,
    this.bio,
    this.bioInArabic,
    this.photo,
    this.skills,
    this.hobbies,
    this.status,
    this.password,
    this.defaultPassword,
    this.firstLogin,
    this.lastLogin,
    this.deactivationDate,
    this.activationDate,
  });

  factory NewEmployeeModel.fromMap(Map? data) =>
      _NewEmployeeModelStatics.factoryFromMap(data);

  Map<String, dynamic> toMap() => _toMapImpl();

  String toJson() => json.encode(toMap());
  Map<String, dynamic> fromJson(String jsonString) => json.decode(jsonString);
}

class NewEmployeeModelHistory {
  String? id;
  List<int> timestamps;
  List<String> firstName;
  List<String> middleName;
  List<String> lastName;
  List<String> firstNameInArabic;
  List<String> middleNameInArabic;
  List<String> lastNameInArabic;
  List<String> nationalId;
  List<String> nationalIdExpirationDate;
  List<String> nationality;
  List<String> passport;
  List<String> passportExpirationDate;
  List<String> email;
  List<MobilePhone> mobilePhone;
  List<String> officePhone;
  List<String> homePhone;
  List<String> extension;
  List<String> birthDay;
  List<String> gender;
  List<String> country;
  List<String> province;
  List<String> city;
  List<String> postalCode;
  List<String> street;
  List<String> maritalStatus;
  List<String> language;
  List<String> departmentId;
  List<String> supervisor;
  List<String> role;
  List<String> title;
  List<String> titleInArabic;
  List<String> workLocation;
  List<String> drivingLicenseId;
  List<List<String>> carPlates;
  List<Map<String, dynamic>> academicHistory;
  List<String> bio;
  List<String> bioInArabic;
  List<String> photo;
  List<List<String>> skills;
  List<List<String>> hobbies;
  List<String> status;

  List<String?> personalEmail;
  List<String?> homeCountryCode;
  List<String?> officeCountryCode;
  List<HomePhone> homePhoneDetails;
  List<OfficePhone> officePhoneDetails;
  List<String?> jobType;
  List<String?> workArrangement;
  List<String?> remoteStatus;
  List<String?> employeeGrade;
  List<String?> startDate;
  List<String?> startTime;
  List<String?> endTime;
  List<String?> daysOff;
  List<String?> salary;
  List<String?> currency;
  List<String?> institutionName;
  List<String?> degree;
  List<String?> fieldOfStudy;
  List<String?> certificationStartDate;
  List<String?> certificationEndDate;
  List<String?> gradeOrScore;
  List<String?> certificateId;
  List<String?> issuingAuthority;
  List<String?> certificationDocumentUrl;
  List<String?> certificationNotes;

  // Health Insurance Fields
  List<String> insuranceName;
  List<String> insurancePolicyNumber;
  List<String?> insuranceProviderContact;

  // 1st Emergency Contact Fields
  List<String> firstContactFirstName;
  List<String> firstContactLastName;
  List<String> firstContactRelationship;
  List<String> firstContactEmail;
  List<String> firstContactPhone;
  List<String> firstContactLanguage;
  List<String> firstContactCountry;
  List<String> firstContactProvince;
  List<String> firstContactCity;
  List<String> firstContactStreet;
  List<String?> firstContactFirstNameArabic;
  List<String?> firstContactMiddleName;
  List<String?> firstContactMiddleNameArabic;
  List<String?> firstContactLastNameArabic;
  List<MobilePhone> firstContactPhoneDetails;

  // 2nd Emergency Contact Fields
  List<String> secondContactFirstName;
  List<String> secondContactLastName;
  List<String> secondContactRelationship;
  List<String> secondContactEmail;
  List<String> secondContactPhone;
  List<String> secondContactLanguage;
  List<String> secondContactCountry;
  List<String> secondContactProvince;
  List<String> secondContactCity;
  List<String> secondContactStreet;
  List<String?> secondContactFirstNameArabic;
  List<String?> secondContactMiddleName;
  List<String?> secondContactMiddleNameArabic;
  List<String?> secondContactLastNameArabic;
  List<MobilePhone> secondContactPhoneDetails;
  List<String?> passportDocumentUrl;
  List<String?> nationalIdFrontUrl;
  List<String?> nationalIdBackUrl;
  List<String?> drivingLicenseDocumentUrl;

  String? password;
  String? passwordExpirationTime;
  String? passwordExpirationUnit;
  String? defaultPassword;
  String? firstLogin;
  String? lastLogin;
  String? deactivationDate;
  String? activationDate;

  NewEmployeeModelHistory({
    this.id,
    List<int>? timestamps,
    List<String>? firstName,
    List<String>? middleName,
    List<String>? lastName,
    List<String>? firstNameInArabic,
    List<String>? middleNameInArabic,
    List<String>? lastNameInArabic,
    List<String>? nationalId,
    List<String>? nationalIdExpirationDate,
    List<String>? nationality,
    List<String>? passport,
    List<String>? passportExpirationDate,
    List<String>? email,
    List<MobilePhone>? mobilePhone,
    List<String>? officePhone,
    List<String>? homePhone,
    List<String>? extension,
    List<String>? birthDay,
    List<String>? gender,
    List<String>? country,
    List<String>? province,
    List<String>? city,
    List<String>? postalCode,
    List<String>? street,
    List<String>? maritalStatus,
    List<String>? language,
    List<String>? departmentId,
    List<String>? supervisor,
    List<String>? role,
    List<String>? title,
    List<String>? titleInArabic,
    List<String>? workLocation,
    List<String>? drivingLicenseId,
    List<List<String>>? carPlates,
    List<Map<String, dynamic>>? academicHistory,
    List<String>? bio,
    List<String>? bioInArabic,
    List<String>? photo,
    List<List<String>>? skills,
    List<List<String>>? hobbies,
    List<String>? status,
    List<String?>? personalEmail,
    List<String?>? homeCountryCode,
    List<String?>? officeCountryCode,
    List<HomePhone>? homePhoneDetails,
    List<OfficePhone>? officePhoneDetails,
    List<String?>? jobType,
    List<String?>? workArrangement,
    List<String?>? remoteStatus,
    List<String?>? employeeGrade,
    List<String?>? startDate,
    List<String?>? startTime,
    List<String?>? endTime,
    List<String?>? daysOff,
    List<String?>? salary,
    List<String?>? currency,
    List<String?>? institutionName,
    List<String?>? degree,
    List<String?>? fieldOfStudy,
    List<String?>? certificationStartDate,
    List<String?>? certificationEndDate,
    List<String?>? gradeOrScore,
    List<String?>? certificateId,
    List<String?>? issuingAuthority,
    List<String?>? certificationDocumentUrl,
    List<String?>? certificationNotes,
    // Health Insurance Parameters
    List<String>? insuranceName,
    List<String>? insurancePolicyNumber,
    List<String?>? insuranceProviderContact,
    // 1st Emergency Contact Parameters
    List<String>? firstContactFirstName,
    List<String>? firstContactLastName,
    List<String>? firstContactRelationship,
    List<String>? firstContactEmail,
    List<String>? firstContactPhone,
    List<String>? firstContactLanguage,
    List<String>? firstContactCountry,
    List<String>? firstContactProvince,
    List<String>? firstContactCity,
    List<String>? firstContactStreet,
    List<String?>? firstContactFirstNameArabic,
    List<String?>? firstContactMiddleName,
    List<String?>? firstContactMiddleNameArabic,
    List<String?>? firstContactLastNameArabic,
    List<MobilePhone>? firstContactPhoneDetails,
    // 2nd Emergency Contact Parameters
    List<String>? secondContactFirstName,
    List<String>? secondContactLastName,
    List<String>? secondContactRelationship,
    List<String>? secondContactEmail,
    List<String>? secondContactPhone,
    List<String>? secondContactLanguage,
    List<String>? secondContactCountry,
    List<String>? secondContactProvince,
    List<String>? secondContactCity,
    List<String>? secondContactStreet,
    List<String?>? secondContactFirstNameArabic,
    List<String?>? secondContactMiddleName,
    List<String?>? secondContactMiddleNameArabic,
    List<String?>? secondContactLastNameArabic,
    List<MobilePhone>? secondContactPhoneDetails,
    List<String?>? passportDocumentUrl,
    List<String?>? nationalIdFrontUrl,
    List<String?>? nationalIdBackUrl,
    List<String?>? drivingLicenseDocumentUrl,
    this.password,
    this.defaultPassword,
    this.passwordExpirationTime,
    this.passwordExpirationUnit,
    this.firstLogin,
    this.lastLogin,
    this.deactivationDate,
    this.activationDate,
  })  : timestamps = timestamps ?? [DateTime.now().millisecondsSinceEpoch],
        firstName = firstName ?? [],
        middleName = middleName ?? [],
        lastName = lastName ?? [],
        firstNameInArabic = firstNameInArabic ?? [],
        middleNameInArabic = middleNameInArabic ?? [],
        lastNameInArabic = lastNameInArabic ?? [],
        nationalId = nationalId ?? [],
        nationalIdExpirationDate = nationalIdExpirationDate ?? [],
        nationality = nationality ?? [],
        passport = passport ?? [],
        passportExpirationDate = passportExpirationDate ?? [],
        email = email ?? [],
        mobilePhone = mobilePhone ?? [],
        officePhone = officePhone ?? [],
        homePhone = homePhone ?? [],
        extension = extension ?? [],
        birthDay = birthDay ?? [],
        gender = gender ?? [],
        country = country ?? [],
        province = province ?? [],
        city = city ?? [],
        postalCode = postalCode ?? [],
        street = street ?? [],
        maritalStatus = maritalStatus ?? [],
        language = language ?? [],
        departmentId = departmentId ?? [],
        supervisor = supervisor ?? [],
        role = role ?? [],
        title = title ?? [],
        titleInArabic = titleInArabic ?? [],
        workLocation = workLocation ?? [],
        drivingLicenseId = drivingLicenseId ?? [],
        carPlates = carPlates ?? [],
        academicHistory = academicHistory ?? [],
        bio = bio ?? [],
        bioInArabic = bioInArabic ?? [],
        photo = photo ?? [],
        skills = skills ?? [],
        hobbies = hobbies ?? [],
        status = status ?? [],
        personalEmail = personalEmail ?? [null],
        homeCountryCode = homeCountryCode ?? [null],
        officeCountryCode = officeCountryCode ?? [null],
        homePhoneDetails = homePhoneDetails ?? [],
        officePhoneDetails = officePhoneDetails ?? [],
        jobType = jobType ?? [null],
        workArrangement = workArrangement ?? [null],
        remoteStatus = remoteStatus ?? [null],
        employeeGrade = employeeGrade ?? [null],
        startDate = startDate ?? [null],
        startTime = startTime ?? [null],
        endTime = endTime ?? [null],
        daysOff = daysOff ?? [null],
        salary = salary ?? [null],
        currency = currency ?? [null],
        institutionName = institutionName ?? [null],
        degree = degree ?? [null],
        fieldOfStudy = fieldOfStudy ?? [null],
        certificationStartDate = certificationStartDate ?? [null],
        certificationEndDate = certificationEndDate ?? [null],
        gradeOrScore = gradeOrScore ?? [null],
        certificateId = certificateId ?? [null],
        issuingAuthority = issuingAuthority ?? [null],
        certificationDocumentUrl = certificationDocumentUrl ?? [null],
        certificationNotes = certificationNotes ?? [null],
        // Health Insurance Initialization
        insuranceName = insuranceName ?? [],
        insurancePolicyNumber = insurancePolicyNumber ?? [],
        insuranceProviderContact = insuranceProviderContact ?? [null],
        // 1st Emergency Contact Initialization
        firstContactFirstName = firstContactFirstName ?? [],
        firstContactLastName = firstContactLastName ?? [],
        firstContactRelationship = firstContactRelationship ?? [],
        firstContactEmail = firstContactEmail ?? [],
        firstContactPhone = firstContactPhone ?? [],
        firstContactLanguage = firstContactLanguage ?? [],
        firstContactCountry = firstContactCountry ?? [],
        firstContactProvince = firstContactProvince ?? [],
        firstContactCity = firstContactCity ?? [],
        firstContactStreet = firstContactStreet ?? [],
        firstContactFirstNameArabic = firstContactFirstNameArabic ?? [null],
        firstContactMiddleName = firstContactMiddleName ?? [null],
        firstContactMiddleNameArabic = firstContactMiddleNameArabic ?? [null],
        firstContactLastNameArabic = firstContactLastNameArabic ?? [null],
        firstContactPhoneDetails = firstContactPhoneDetails ?? [],
        // 2nd Emergency Contact Initialization
        secondContactFirstName = secondContactFirstName ?? [],
        secondContactLastName = secondContactLastName ?? [],
        secondContactRelationship = secondContactRelationship ?? [],
        secondContactEmail = secondContactEmail ?? [],
        secondContactPhone = secondContactPhone ?? [],
        secondContactLanguage = secondContactLanguage ?? [],
        secondContactCountry = secondContactCountry ?? [],
        secondContactProvince = secondContactProvince ?? [],
        secondContactCity = secondContactCity ?? [],
        secondContactStreet = secondContactStreet ?? [],
        secondContactFirstNameArabic = secondContactFirstNameArabic ?? [null],
        secondContactMiddleName = secondContactMiddleName ?? [null],
        secondContactMiddleNameArabic = secondContactMiddleNameArabic ?? [null],
        secondContactLastNameArabic = secondContactLastNameArabic ?? [null],
        secondContactPhoneDetails = secondContactPhoneDetails ?? [],
        passportDocumentUrl = passportDocumentUrl ?? [null],
        nationalIdFrontUrl = nationalIdFrontUrl ?? [null],
        nationalIdBackUrl = nationalIdBackUrl ?? [null],
        drivingLicenseDocumentUrl = drivingLicenseDocumentUrl ?? [null];

  factory NewEmployeeModelHistory.fromMap(Map? data) =>
      _NewEmployeeModelHistoryStatics.factoryFromMap(data);

  Map<String, dynamic> toMap() => _toMapImpl();

  static List<String?> _parseNullableListSafely(dynamic value) {
    if (value == null) return [null];
    if (value is List) {
      if (value.isEmpty) return [null];
      return value.map((item) => item?.toString()).toList();
    }
    return [value.toString()];
  }

  static List<HomePhone> _parseHomePhoneList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => HomePhone.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<OfficePhone> _parseOfficePhoneList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => OfficePhone.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<String> _parseListSafely(dynamic value) =>
      _NewEmployeeModelHistoryStatics._parseListSafely(value);

  static List<List<String>> _parseNestedListSafely(dynamic value) =>
      _NewEmployeeModelHistoryStatics._parseNestedListSafely(value);

  static List<MobilePhone> _parseMobilePhoneList(dynamic value) =>
      _NewEmployeeModelHistoryStatics._parseMobilePhoneList(value);

  static List<Map<String, dynamic>> _parseAcademicHistoryList(dynamic value) =>
      _NewEmployeeModelHistoryStatics._parseAcademicHistoryList(value);

  /// Helper function to synchronize a field list with the target length
  ///
  /// FIXED 9/10/2026 — the gap was filled with `''`, so for an UNCHANGED
  /// field the "repeat the last value" step below repeated that blank instead
  /// of the real value: one approved health/emergency change wiped every
  /// other insurance / contact field whose list was shorter than `timestamps`
  /// (e.g. after an HR bulk upload that appended `timestamps` only). The gap
  /// now carries the last known value forward — the missing revisions are the
  /// ones in which this field did not change — so the current value survives
  /// and the list ends up exactly as long as `timestamps`.
  static List<String> _synchronizeFieldList(
    List<String> currentList,
    int targetLength,
    String? newValue,
  ) =>
      _NewEmployeeModelHistoryStatics._synchronizeFieldList(
        currentList,
        targetLength,
        newValue,
      );

  /// Helper function to synchronize a MobilePhone list with the target length
  ///
  /// FIXED 9/10/2026 — same defect as [_synchronizeFieldList]: the gap was
  /// filled with an empty `MobilePhone()`, so any synchronized write on a
  /// document whose `Mobile_Phone` list was shorter than `timestamps` replaced
  /// the employee's current phone with a blank one. The gap now carries the
  /// last phone forward.
  static List<MobilePhone> _synchronizeMobilePhoneList(
    List<MobilePhone> currentList,
    int targetLength,
    MobilePhone? newValue,
  ) =>
      _NewEmployeeModelHistoryStatics._synchronizeMobilePhoneList(
        currentList,
        targetLength,
        newValue,
      );

  NewEmployeeModelHistory copyWithUpdateSynchronized({
    String? id,
    int? addTimestamp,
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
    MobilePhone? mobilePhone,
    String? officePhone,
    String? homePhone,
    String? extension,
    String? birthDay,
    String? gender,
    String? country,
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
    List<String>? carPlates,
    Map<String, dynamic>? academicHistory,
    String? bio,
    String? bioInArabic,
    String? photo,
    List<String>? skills,
    List<String>? hobbies,
    String? status,
    // Health Insurance Parameters
    String? insuranceName,
    String? insurancePolicyNumber,
    // 1st Emergency Contact Parameters
    String? firstContactFirstName,
    String? firstContactLastName,
    String? firstContactRelationship,
    String? firstContactEmail,
    String? firstContactPhone,
    String? firstContactLanguage,
    String? firstContactCountry,
    String? firstContactProvince,
    String? firstContactCity,
    String? firstContactStreet,
    // 2nd Emergency Contact Parameters
    String? secondContactFirstName,
    String? secondContactLastName,
    String? secondContactRelationship,
    String? secondContactEmail,
    String? secondContactPhone,
    String? secondContactLanguage,
    String? secondContactCountry,
    String? secondContactProvince,
    String? secondContactCity,
    String? secondContactStreet,
    String? password,
    String? defaultPassword,
    String? passwordExpirationTime,
    String? passwordExpirationUnit,
    String? firstLogin,
    String? lastLogin,
    String? deactivationDate,
    String? activationDate,
  }) =>
      _copyWithUpdateSynchronizedImpl(
        id: id,
        addTimestamp: addTimestamp,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        firstNameInArabic: firstNameInArabic,
        middleNameInArabic: middleNameInArabic,
        lastNameInArabic: lastNameInArabic,
        nationalId: nationalId,
        nationalIdExpirationDate: nationalIdExpirationDate,
        nationality: nationality,
        passport: passport,
        passportExpirationDate: passportExpirationDate,
        email: email,
        mobilePhone: mobilePhone,
        officePhone: officePhone,
        homePhone: homePhone,
        extension: extension,
        birthDay: birthDay,
        gender: gender,
        country: country,
        province: province,
        city: city,
        postalCode: postalCode,
        street: street,
        maritalStatus: maritalStatus,
        language: language,
        departmentId: departmentId,
        supervisor: supervisor,
        role: role,
        title: title,
        titleInArabic: titleInArabic,
        workLocation: workLocation,
        drivingLicenseId: drivingLicenseId,
        carPlates: carPlates,
        academicHistory: academicHistory,
        bio: bio,
        bioInArabic: bioInArabic,
        photo: photo,
        skills: skills,
        hobbies: hobbies,
        status: status,
        insuranceName: insuranceName,
        insurancePolicyNumber: insurancePolicyNumber,
        firstContactFirstName: firstContactFirstName,
        firstContactLastName: firstContactLastName,
        firstContactRelationship: firstContactRelationship,
        firstContactEmail: firstContactEmail,
        firstContactPhone: firstContactPhone,
        firstContactLanguage: firstContactLanguage,
        firstContactCountry: firstContactCountry,
        firstContactProvince: firstContactProvince,
        firstContactCity: firstContactCity,
        firstContactStreet: firstContactStreet,
        secondContactFirstName: secondContactFirstName,
        secondContactLastName: secondContactLastName,
        secondContactRelationship: secondContactRelationship,
        secondContactEmail: secondContactEmail,
        secondContactPhone: secondContactPhone,
        secondContactLanguage: secondContactLanguage,
        secondContactCountry: secondContactCountry,
        secondContactProvince: secondContactProvince,
        secondContactCity: secondContactCity,
        secondContactStreet: secondContactStreet,
        password: password,
        defaultPassword: defaultPassword,
        passwordExpirationTime: passwordExpirationTime,
        passwordExpirationUnit: passwordExpirationUnit,
        firstLogin: firstLogin,
        lastLogin: lastLogin,
        deactivationDate: deactivationDate,
        activationDate: activationDate,
      );
}
