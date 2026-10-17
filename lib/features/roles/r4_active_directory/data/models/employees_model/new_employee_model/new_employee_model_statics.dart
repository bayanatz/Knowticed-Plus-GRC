/// Module: roles/r4_active_directory
///
///*************************** FILE INFO ****************************///
/// File Name: new_employee_model_statics.dart
/// Description: `_NewEmployeeModelStatics` data model — split out of `new_employee_model.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../new_employee_model.dart';

// Split from new_employee_model.dart to keep every file under 700 lines.

abstract final class _NewEmployeeModelStatics {
  static NewEmployeeModel factoryFromMap(Map? data) {
    return NewEmployeeModel(
      id: data?['Id'],
      firstName: FirstName.fromMap(data?['First_Name']),
      middleName: MiddleName.fromMap(data?['Middle_Name']),
      lastName: LastName.fromMap(data?['Last_Name']),
      firstNameInArabic: FirstNameInArabic.fromMap(
        data?['First_Name_In_Arabic'],
      ),
      middleNameInArabic: MiddleNameInArabic.fromMap(
        data?['Middle_Name_In_Arabic'],
      ),
      lastNameInArabic: LastNameInArabic.fromMap(data?['Last_Name_In_Arabic']),
      nationalId: data?['National_Id'] == null
          ? null
          : NationalId.fromMap(data?['National_Id']),
      nationalIdExpirationDate: data?['National_Id_Expiration_Date'] == null
          ? null
          : NationalIdExpirationDate.fromMap(
              data?['National_Id_Expiration_Date'],
            ),
      nationality: data?['Nationality'] == null
          ? null
          : Nationality.fromMap(data?['Nationality']),
      passport: data?['Passport'] == null
          ? null
          : Passport.fromMap(data?['Passport']),
      passportExpirationDate: PassportExpirationDate.fromMap(
        data?['Passport_Expiration_Date'],
      ),
      email: Email.fromMap(data?['Email']),
      mobilePhone: MobilePhone.fromMap(data?['Mobile_Phone']),
      officePhone: OfficePhone.fromMap(data?['Office_Phone']),
      homePhone: HomePhone.fromMap(data?['Home_Phone']),
      extension: Extension.fromMap(data?['Extension']),
      birthDay: data?['Birth_Day'] == null
          ? null
          : BirthDay.fromMap(data?['Birth_Day']),
      gender: data?['Gender'] == null ? null : Gender.fromMap(data?['Gender']),
      country:
          data?['Country'] == null ? null : Country.fromMap(data?['Country']),
      province: data?['Province'] == null
          ? null
          : Province.fromMap(data?['Province']),
      city: data?['City'] == null ? null : City.fromMap(data?['City']),
      postalCode: data?['Postal_Code'] == null
          ? null
          : PostalCode.fromMap(data?['Postal_Code']),
      street: data?['Street'] == null ? null : Street.fromMap(data?['Street']),
      maritalStatus: data?['Marital_Status'] == null
          ? null
          : MaritalStatus.fromMap(data?['Marital_Status']),
      language: data?['Language'] == null
          ? null
          : Language.fromMap(data?['Language']),
      departmentid: DepartmentId.fromMap(data?['Department_Id']),
      supervisor: Supervisor.fromMap(data?['Supervisor']),
      role: Role.fromMap(data?['Role']),
      workLocation: data?['Work_Location'] == null
          ? null
          : WorkLocation.fromMap(data?['Work_Location']),
      drivingLicenseId: data?['Driving_License_Id'] == null
          ? null
          : DrivingLicenseId.fromMap(data?['Driving_License_Id']),
      carPlates: data?['Car_Plates'] == null
          ? null
          : CarPlates.fromMap(data?['Car_Plates']),
      academicHistory: data?['Academic_History'] == null
          ? null
          : AcademicHistory.fromMap(data?['Academic_History']),
      bio: data?['Bio'] == null ? null : Bio.fromMap(data?['Bio']),
      bioInArabic: data?['Bio_In_Arabic'] == null
          ? null
          : BioInArabic.fromMap(data?['Bio_In_Arabic']),
      skills: data?['Skills'] == null ? null : Skills.fromMap(data?['Skills']),
      hobbies:
          data?['Hobbies'] == null ? null : Hobbies.fromMap(data?['Hobbies']),
      status: Status.fromMap(data?['Status']),
      photo: data?['Photo'] == null ? null : Photo.fromMap(data?['Photo']),
      title: data?['Title'] == null ? null : TitleModel.fromMap(data?['Title']),
      titleInArabic: data?['Title_In_Arabic'] == null
          ? null
          : TitleInArabic.fromMap(data?['Title_In_Arabic']),
      password: data?['Password'],
      defaultPassword: data?['Default_Password'],
      firstLogin: data?['First_Login'],
      lastLogin: data?['Last_Login'],
      deactivationDate: data?['Deactivation_Date'],
      activationDate: data?['Activation_Date'],
    );
  }
}
