// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';

import 'package:demo_app/features/employee/data/models/emplyees_model/city_model.dart';
import 'package:demo_app/features/employee/data/models/emplyees_model/province_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/country_model.dart';

import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/salery_model/job_location_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/academic_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/bio_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/birthday_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/email_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/first_name_arabic_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/first_name_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/gender_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/hobbies_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/language_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/last_name_arabic_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/last_name_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/marital_status_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/middle_name_arabic_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/middle_name_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/national_id_date_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/national_id_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/nationality_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/passport_date_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/passport_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/postal_code_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/role_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/skills_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/status_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/title_arabic_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/title_model.dart';

import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/car_plates_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/department_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/driving_license_id.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/employee_photo_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/extension_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/home_phone_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/supervisor_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/mobile_phone_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/office_phone_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/street_model.dart';

// date:January/7/2024
// by:MohamedFouad
// lastUpdate:November/5/2024

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

  factory NewEmployeeModel.fromMap(Map? data) {
    return NewEmployeeModel(
      id: data?['Id'],
      firstName: FirstName.fromMap(data?['First_Name']),
      middleName: MiddleName.fromMap(data?['Middle_Name']),
      lastName: LastName.fromMap(data?['Last_Name']),
      firstNameInArabic:
          FirstNameInArabic.fromMap(data?['First_Name_In_Arabic']),
      middleNameInArabic:
          MiddleNameInArabic.fromMap(data?['Middle_Name_In_Arabic']),
      lastNameInArabic: LastNameInArabic.fromMap(data?['Last_Name_In_Arabic']),
      nationalId:
      data?['National_Id'] == null ? null :
      NationalId.fromMap(data?['National_Id']),
      nationalIdExpirationDate:
       data?['National_Id_Expiration_Date'] == null ? null :
      NationalIdExpirationDate.fromMap(
          data?['National_Id_Expiration_Date']),
      nationality:
      data?['Nationality'] == null ? null :
      Nationality.fromMap(data?['Nationality']),
      passport:
        data?['Passport'] == null ? null :
      Passport.fromMap(data?['Passport']),
      passportExpirationDate:
          PassportExpirationDate.fromMap(data?['Passport_Expiration_Date']),
      email: Email.fromMap(data?['Email']),
      mobilePhone: MobilePhone.fromMap(data?['Mobile_Phone']),
      officePhone: OfficePhone.fromMap(data?['Office_Phone']),
      homePhone: HomePhone.fromMap(data?['Home_Phone']),
      extension: Extension.fromMap(data?['Extension']),
      birthDay:
      data?['Birth_Day'] == null ? null :
      BirthDay.fromMap(data?['Birth_Day']),
      gender:
      data?['Gender'] == null ? null :
      Gender.fromMap(data?['Gender']),
      country:
      data?['Country'] == null ? null :
      Country.fromMap(data?['Country']),
      province:
      data?['Province'] == null ? null :
      Province.fromMap(data?['Province']),
      city:
      data?['City'] == null ? null :
      City.fromMap(data?['City']),
      postalCode:
      data?['Postal_Code'] == null ? null :
      PostalCode.fromMap(data?['Postal_Code']),
      street:
      data?['Street'] == null ? null :
      Street.fromMap(data?['Street']),
      maritalStatus:
      data?['Marital_Status'] == null ? null :
      MaritalStatus.fromMap(data?['Marital_Status']),
      language:
      data?['Language'] == null ? null :
      Language.fromMap(data?['Language']),
      departmentid: DepartmentId.fromMap(data?['Department_Id']),
      supervisor: Supervisor.fromMap(data?['Supervisor']),
      role: Role.fromMap(data?['Role']),
      workLocation:
      data?['Work_Location'] == null ? null :
      WorkLocation.fromMap(data?['Work_Location']),
      drivingLicenseId:
      data?['Driving_License_Id'] == null ? null :
      DrivingLicenseId.fromMap(data?['Driving_License_Id']),
      carPlates:
      data?['Car_Plates'] == null ? null :
      CarPlates.fromMap(data?['Car_Plates']),
      academicHistory:
      data?['Academic_History'] == null ? null :
      AcademicHistory.fromMap(data?['Academic_History']),
      bio:
      data?['Bio'] == null ? null :
      Bio.fromMap(data?['Bio']),
      skills:
      data?['Skills'] == null ? null :
      Skills.fromMap(data?['Skills']),
      hobbies:
      data?['Hobbies'] == null ? null :
      Hobbies.fromMap(data?['Hobbies']),
      status: Status.fromMap(data?['Status']),
      photo:
      data?['Photo'] == null ? null :
      Photo.fromMap(data?['Photo']),
      title:
      data?['Title'] == null ? null :
      TitleModel.fromMap(data?['Title']),
      titleInArabic:
      data?['Title_In_Arabic'] == null ? null :
      TitleInArabic.fromMap(data?['Title_In_Arabic']),
      password: data?['Password'],
      defaultPassword: data?['Default_Password'],
      firstLogin: data?['First_Login'],
      lastLogin: data?['Last_Login'],
      deactivationDate: data?['Deactivation_Date'],
      activationDate: data?['Activation_Date'],
    );
  }

  Map<String, dynamic> toMap() => {
        'Id': id,
        'First_Name': firstName!.toMap(),
        'Middle_Name': middleName!.toMap(),
        'Last_Name': lastName!.toMap(),
        'First_Name_In_Arabic': firstNameInArabic!.toMap(),
        'Middle_Name_In_Arabic': middleNameInArabic!.toMap(),
        'Last_Name_In_Arabic': lastNameInArabic!.toMap(),
        'Email': email!.toMap(),
        'Mobile_Phone': mobilePhone!.toMap(),
        'Office_Phone': officePhone!.toMap(),
        'Home_Phone': homePhone!.toMap(),
        'Extension': extension!.toMap(),
        'Postal_Code': postalCode != null ? postalCode!.toMap() : null,
        'Street': street != null ? street!.toMap() : null,
        'National_Id': nationalId != null ? nationalId!.toMap() : null,
        'National_Id_Expiration_Date': nationalIdExpirationDate != null
            ? nationalIdExpirationDate!.toMap()
            : null,
        'Nationality': nationality != null ? nationality!.toMap() : null,
        'Passport': passport != null ? passport!.toMap() : null,
        'Passport_Expiration_Date': passportExpirationDate != null
            ? passportExpirationDate!.toMap()
            : null,
        'Country': country != null ? country!.toMap() : null,
        'Province': province != null ? province!.toMap() : null,
        'City': city != null ? city!.toMap() : null,
        'Gender': gender != null ? gender!.toMap() : null,
        'Marital_Status': maritalStatus != null ? maritalStatus!.toMap() : null,
        'Language': language != null ? language!.toMap() : null,
        'Birth_Day': birthDay != null ? birthDay!.toMap() : null,
        'Bio': bio != null ? bio!.toMap() : null,
        'Academic_History':
            academicHistory != null ? academicHistory!.toMap() : null,
        'Skills': skills != null ? skills!.toMap() : null,
        'Hobbies': hobbies != null ? hobbies!.toMap() : null,
        'Password': password,
        'Default_Password': defaultPassword,
        'First_Login': firstLogin,
        'Last_Login': lastLogin,
        'Deactivation_Date': deactivationDate,
        'Activation_Date': activationDate,
        'Role': role!.toMap(),
        'Department_Id': departmentid!.toMap(),
        'Supervisor': supervisor!.toMap(),
        'Work_Location': workLocation != null ? workLocation!.toMap() : null,
        'Driving_License_Id':
            drivingLicenseId != null ? drivingLicenseId!.toMap() : null,
        'Car_Plates': carPlates != null ? carPlates!.toMap() : null,
        'Photo': photo != null ? photo!.toMap() : null,
        'Title': title!.toMap(),
        'Title_In_Arabic': titleInArabic!.toMap(),
        'Status': status!.toMap(),
      };

  String toJson() => json.encode(toMap());
  Map<String, dynamic> fromJson(String jsonString) => json.decode(jsonString);
}
