/// Module: roles/r4_active_directory
///
///*************************** FILE INFO ****************************///
/// File Name: new_employee_model_methods.dart
/// Description: Methods of `NewEmployeeModel` — split out of `new_employee_model.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../new_employee_model.dart';

// Split from new_employee_model.dart to keep every file under 700 lines.

extension NewEmployeeModelMethods on NewEmployeeModel {
  Map<String, dynamic> _toMapImpl() => {
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
        'Postal_Code': postalCode?.toMap(),
        'Street': street?.toMap(),
        'National_Id': nationalId?.toMap(),
        'National_Id_Expiration_Date': nationalIdExpirationDate?.toMap(),
        'Nationality': nationality?.toMap(),
        'Passport': passport?.toMap(),
        'Passport_Expiration_Date': passportExpirationDate?.toMap(),
        'Country': country?.toMap(),
        'Province': province?.toMap(),
        'City': city?.toMap(),
        'Gender': gender?.toMap(),
        'Marital_Status': maritalStatus?.toMap(),
        'Language': language?.toMap(),
        'Birth_Day': birthDay?.toMap(),
        'Bio': bio?.toMap(),
        'Bio_In_Arabic': bioInArabic?.toMap(),
        'Academic_History': academicHistory?.toMap(),
        'Skills': skills?.toMap(),
        'Hobbies': hobbies?.toMap(),
        'Password': password,
        'Default_Password': defaultPassword,
        'First_Login': firstLogin,
        'Last_Login': lastLogin,
        'Deactivation_Date': deactivationDate,
        'Activation_Date': activationDate,
        'Role': role!.toMap(),
        'Department_Id': departmentid!.toMap(),
        'Supervisor': supervisor!.toMap(),
        'Work_Location': workLocation?.toMap(),
        'Driving_License_Id': drivingLicenseId?.toMap(),
        'Car_Plates': carPlates?.toMap(),
        'Photo': photo?.toMap(),
        'Title': title!.toMap(),
        'Title_In_Arabic': titleInArabic!.toMap(),
        'Status': status!.toMap(),
      };
}
