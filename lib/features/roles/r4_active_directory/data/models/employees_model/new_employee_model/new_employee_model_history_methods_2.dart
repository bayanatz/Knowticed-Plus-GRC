/// Module: roles/r4_active_directory
///
///*************************** FILE INFO ****************************///
/// File Name: new_employee_model_history_methods_2.dart
/// Description: Methods of `NewEmployeeModelHistory` — split out of `new_employee_model.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../new_employee_model.dart';

// Split from new_employee_model.dart to keep every file under 700 lines.

extension NewEmployeeModelHistoryMethods2 on NewEmployeeModelHistory {
  /// Update a single field with synchronized history
  NewEmployeeModelHistory updateFieldSynchronized(
    String fieldName,
    dynamic value,
  ) {
    switch (fieldName) {
      case 'first_Name':
        return copyWithUpdateSynchronized(firstName: value.toString());
      case 'middle_Name':
        return copyWithUpdateSynchronized(middleName: value.toString());
      case 'last_name':
        return copyWithUpdateSynchronized(lastName: value.toString());
      case 'firstNameInArabic':
        return copyWithUpdateSynchronized(firstNameInArabic: value.toString());
      case 'middleNameInArabic':
        return copyWithUpdateSynchronized(middleNameInArabic: value.toString());
      case 'lastNameInArabic':
        return copyWithUpdateSynchronized(lastNameInArabic: value.toString());
      case 'nationalId':
        return copyWithUpdateSynchronized(nationalId: value.toString());
      case 'nationalIdExpirationDate':
        return copyWithUpdateSynchronized(
          nationalIdExpirationDate: value.toString(),
        );
      case 'nationality':
        return copyWithUpdateSynchronized(nationality: value.toString());
      case 'passport':
        return copyWithUpdateSynchronized(passport: value.toString());
      case 'passportExpirationDate':
        return copyWithUpdateSynchronized(
          passportExpirationDate: value.toString(),
        );
      case 'email':
        return copyWithUpdateSynchronized(email: value.toString());
      case 'mobilePhone':
        if (value is MobilePhone) {
          return copyWithUpdateSynchronized(mobilePhone: value);
        }
        throw ArgumentError(
          'Value for mobilePhone must be of type MobilePhone',
        );
      case 'officePhone':
        return copyWithUpdateSynchronized(officePhone: value.toString());
      case 'homePhone':
        return copyWithUpdateSynchronized(homePhone: value.toString());
      case 'extension':
        return copyWithUpdateSynchronized(extension: value.toString());
      case 'birthDay':
        return copyWithUpdateSynchronized(birthDay: value.toString());
      case 'gender':
        return copyWithUpdateSynchronized(gender: value.toString());
      case 'country':
        return copyWithUpdateSynchronized(country: value.toString());
      case 'province':
        return copyWithUpdateSynchronized(province: value.toString());
      case 'city':
        return copyWithUpdateSynchronized(city: value.toString());
      case 'postalCode':
        return copyWithUpdateSynchronized(postalCode: value.toString());
      case 'street':
        return copyWithUpdateSynchronized(street: value.toString());
      case 'maritalStatus':
        return copyWithUpdateSynchronized(maritalStatus: value.toString());
      case 'language':
        return copyWithUpdateSynchronized(language: value.toString());
      case 'departmentId':
        return copyWithUpdateSynchronized(departmentId: value.toString());
      case 'supervisor':
        return copyWithUpdateSynchronized(supervisor: value.toString());
      case 'role':
        return copyWithUpdateSynchronized(role: value.toString());
      case 'title':
        return copyWithUpdateSynchronized(title: value.toString());
      case 'titleInArabic':
        return copyWithUpdateSynchronized(titleInArabic: value.toString());
      case 'workLocation':
        return copyWithUpdateSynchronized(workLocation: value.toString());
      case 'drivingLicenseId':
        return copyWithUpdateSynchronized(drivingLicenseId: value.toString());
      case 'carPlates':
        return copyWithUpdateSynchronized(carPlates: value as List<String>);
      case 'academicHistory':
        return copyWithUpdateSynchronized(
          academicHistory: value as Map<String, dynamic>,
        );
      case 'bio':
        return copyWithUpdateSynchronized(bio: value.toString());
      case 'bioInArabic':
        return copyWithUpdateSynchronized(bioInArabic: value.toString());
      case 'photo':
        return copyWithUpdateSynchronized(photo: value.toString());
      case 'skills':
        return copyWithUpdateSynchronized(skills: value as List<String>);
      case 'hobbies':
        return copyWithUpdateSynchronized(hobbies: value as List<String>);
      case 'status':
        return copyWithUpdateSynchronized(status: value.toString());
      // Health Insurance Fields
      case 'insuranceName':
        return copyWithUpdateSynchronized(insuranceName: value.toString());
      case 'insurancePolicyNumber':
        return copyWithUpdateSynchronized(
          insurancePolicyNumber: value.toString(),
        );
      // 1st Emergency Contact Fields
      case 'firstContactFirstName':
        return copyWithUpdateSynchronized(
          firstContactFirstName: value.toString(),
        );
      case 'firstContactLastName':
        return copyWithUpdateSynchronized(
          firstContactLastName: value.toString(),
        );
      case 'firstContactRelationship':
        return copyWithUpdateSynchronized(
          firstContactRelationship: value.toString(),
        );
      case 'firstContactEmail':
        return copyWithUpdateSynchronized(firstContactEmail: value.toString());
      case 'firstContactPhone':
        return copyWithUpdateSynchronized(firstContactPhone: value.toString());
      case 'firstContactLanguage':
        return copyWithUpdateSynchronized(
          firstContactLanguage: value.toString(),
        );
      case 'firstContactCountry':
        return copyWithUpdateSynchronized(
          firstContactCountry: value.toString(),
        );
      case 'firstContactProvince':
        return copyWithUpdateSynchronized(
          firstContactProvince: value.toString(),
        );
      case 'firstContactCity':
        return copyWithUpdateSynchronized(firstContactCity: value.toString());
      case 'firstContactStreet':
        return copyWithUpdateSynchronized(firstContactStreet: value.toString());
      // 2nd Emergency Contact Fields
      case 'secondContactFirstName':
        return copyWithUpdateSynchronized(
          secondContactFirstName: value.toString(),
        );
      case 'secondContactLastName':
        return copyWithUpdateSynchronized(
          secondContactLastName: value.toString(),
        );
      case 'secondContactRelationship':
        return copyWithUpdateSynchronized(
          secondContactRelationship: value.toString(),
        );
      case 'secondContactEmail':
        return copyWithUpdateSynchronized(secondContactEmail: value.toString());
      case 'secondContactPhone':
        return copyWithUpdateSynchronized(secondContactPhone: value.toString());
      case 'secondContactLanguage':
        return copyWithUpdateSynchronized(
          secondContactLanguage: value.toString(),
        );
      case 'secondContactCountry':
        return copyWithUpdateSynchronized(
          secondContactCountry: value.toString(),
        );
      case 'secondContactProvince':
        return copyWithUpdateSynchronized(
          secondContactProvince: value.toString(),
        );
      case 'secondContactCity':
        return copyWithUpdateSynchronized(secondContactCity: value.toString());
      case 'secondContactStreet':
        return copyWithUpdateSynchronized(
          secondContactStreet: value.toString(),
        );
      case 'password':
        return copyWithUpdateSynchronized(password: value.toString());
      case 'defaultPassword':
        return copyWithUpdateSynchronized(defaultPassword: value.toString());
      case 'passwordExpirationTime':
        return copyWithUpdateSynchronized(
          passwordExpirationTime: value.toString(),
        );
      case 'passwordExpirationUnit':
        return copyWithUpdateSynchronized(
          passwordExpirationUnit: value.toString(),
        );
      case 'firstLogin':
        return copyWithUpdateSynchronized(firstLogin: value.toString());
      case 'lastLogin':
        return copyWithUpdateSynchronized(lastLogin: value.toString());
      case 'deactivationDate':
        return copyWithUpdateSynchronized(deactivationDate: value.toString());
      case 'activationDate':
        return copyWithUpdateSynchronized(activationDate: value.toString());
      default:
        throw ArgumentError('Unknown field: $fieldName');
    }
  }

  /// Convert NewEmployeeModelHistory to NewEmployeeModel
  NewEmployeeModel toNewEmployeeModel() {

    return NewEmployeeModel.fromMap({
      'Id': id,
      'First_Name': firstName,
      'Middle_Name': middleName,
      'Last_Name': lastName,
      'First_Name_In_Arabic': firstNameInArabic,
      'Middle_Name_In_Arabic': middleNameInArabic,
      'Last_Name_In_Arabic': lastNameInArabic,
      'National_Id': nationalId.isNotEmpty ? nationalId : null,
      'National_Id_Expiration_Date':
          nationalIdExpirationDate.isNotEmpty ? nationalIdExpirationDate : null,
      'Nationality': nationality.isNotEmpty ? nationality : null,
      'Passport': passport.isNotEmpty ? passport : null,
      'Passport_Expiration_Date':
          passportExpirationDate.isNotEmpty ? passportExpirationDate : null,
      'Email': email,
      'Mobile_Phone': mobilePhone.isNotEmpty ? mobilePhone.last.toMap() : null,
      'Office_Phone': officePhone,
      'Home_Phone': homePhone,
      'Extension': extension,
      'Birth_Day': birthDay.isNotEmpty ? birthDay : null,
      'Gender': gender.isNotEmpty ? gender : null,
      'Country': country.isNotEmpty ? country : null,
      'Province': province.isNotEmpty ? province : null,
      'City': city.isNotEmpty ? city : null,
      'Postal_Code': postalCode.isNotEmpty ? postalCode : null,
      'Street': street.isNotEmpty ? street : null,
      'Marital_Status': maritalStatus.isNotEmpty ? maritalStatus : null,
      'Language': language.isNotEmpty ? language : null,
      'Department_Id': departmentId,
      'Supervisor': supervisor,
      'Role': role,
      'Title': title.isNotEmpty ? title : null,
      'Title_In_Arabic': titleInArabic.isNotEmpty ? titleInArabic : null,
      'Work_Location': workLocation.isNotEmpty ? workLocation : null,
      'Driving_License_Id':
          drivingLicenseId.isNotEmpty ? drivingLicenseId : null,
      'Car_Plates': carPlates.isNotEmpty
          ? carPlates.map((plate) => {'items': plate}).toList()
          : null,
      'Academic_History': academicHistory.isNotEmpty ? academicHistory : null,
      'Bio': bio.isNotEmpty ? bio : null,
      'Bio_In_Arabic': bioInArabic.isNotEmpty ? bioInArabic : null,
      'Photo': photo.isNotEmpty ? photo : null,
      'Skills': skills.isNotEmpty
          ? skills.map((skill) => {'items': skill}).toList()
          : null,
      'Hobbies': hobbies.isNotEmpty
          ? hobbies.map((hobby) => {'items': hobby}).toList()
          : null,
      'Status': status,
      'Password': password,
      'Default_Password': defaultPassword,
      'First_Login': firstLogin,
      'Last_Login': lastLogin,
      'Deactivation_Date': deactivationDate,
      'Activation_Date': activationDate,
    });
  }

  /// Helper method to get current mobile phone
  MobilePhone? get currentMobilePhone {
    return mobilePhone.isNotEmpty ? mobilePhone.last : null;
  }

  /// Helper method to add a new mobile phone entry
  NewEmployeeModelHistory addMobilePhone(MobilePhone newPhone) {
    return copyWithUpdateSynchronized(mobilePhone: newPhone);
  }

  /// Get the current value of any field
  dynamic getCurrentValue(String fieldName) {
    switch (fieldName) {
      // Basic Information
      case 'firstName':
        return firstName.isNotEmpty ? firstName.last : '';
      case 'middleName':
        return middleName.isNotEmpty ? middleName.last : '';
      case 'lastName':
        return lastName.isNotEmpty ? lastName.last : '';
      case 'firstNameInArabic':
        return firstNameInArabic.isNotEmpty ? firstNameInArabic.last : '';
      case 'middleNameInArabic':
        return middleNameInArabic.isNotEmpty ? middleNameInArabic.last : '';
      case 'lastNameInArabic':
        return lastNameInArabic.isNotEmpty ? lastNameInArabic.last : '';
      case 'title':
        return title.isNotEmpty ? title.last : '';
      case 'titleInArabic':
        return titleInArabic.isNotEmpty ? titleInArabic.last : '';

      // Identification
      case 'nationalId':
        return nationalId.isNotEmpty ? nationalId.last : '';
      case 'nationalIdExpirationDate':
        return nationalIdExpirationDate.isNotEmpty
            ? nationalIdExpirationDate.last
            : '';
      case 'nationality':
        return nationality.isNotEmpty ? nationality.last : '';
      case 'passport':
        return passport.isNotEmpty ? passport.last : '';
      case 'passportExpirationDate':
        return passportExpirationDate.isNotEmpty
            ? passportExpirationDate.last
            : '';
      case 'drivingLicenseId':
        return drivingLicenseId.isNotEmpty ? drivingLicenseId.last : '';

      // Contact Information
      case 'email':
        return email.isNotEmpty ? email.last : '';
      case 'mobilePhone':
        return currentMobilePhone;
      case 'officePhone':
        return officePhone.isNotEmpty ? officePhone.last : '';
      case 'homePhone':
        return homePhone.isNotEmpty ? homePhone.last : '';
      case 'extension':
        return extension.isNotEmpty ? extension.last : '';

      // Personal Information
      case 'birthDay':
        return birthDay.isNotEmpty ? birthDay.last : '';
      case 'gender':
        return gender.isNotEmpty ? gender.last : '';
      case 'maritalStatus':
        return maritalStatus.isNotEmpty ? maritalStatus.last : '';
      case 'language':
        return language.isNotEmpty ? language.last : '';

      // Address Information
      case 'country':
        return country.isNotEmpty ? country.last : '';
      case 'province':
        return province.isNotEmpty ? province.last : '';
      case 'city':
        return city.isNotEmpty ? city.last : '';
      case 'postalCode':
        return postalCode.isNotEmpty ? postalCode.last : '';
      case 'street':
        return street.isNotEmpty ? street.last : '';

      // Employment Information
      case 'departmentId':
        return departmentId.isNotEmpty ? departmentId.last : '';
      case 'supervisor':
        return supervisor.isNotEmpty ? supervisor.last : '';
      case 'role':
        return role.isNotEmpty ? role.last : '';
      case 'workLocation':
        return workLocation.isNotEmpty ? workLocation.last : '';
      case 'status':
        return status.isNotEmpty ? status.last : '';

      // Additional Information
      case 'carPlates':
        return carPlates.isNotEmpty ? carPlates.last : [];
      case 'academicHistory':
        return academicHistory.isNotEmpty ? academicHistory.last : {};
      case 'bio':
        return bio.isNotEmpty ? bio.last : '';
      case 'bioInArabic':
        return bioInArabic.isNotEmpty ? bioInArabic.last : '';
      case 'photo':
        return photo.isNotEmpty ? photo.last : '';
      case 'skills':
        return skills.isNotEmpty ? skills.last : [];
      case 'hobbies':
        return hobbies.isNotEmpty ? hobbies.last : [];

      // Health Insurance
      case 'insuranceName':
        return insuranceName.isNotEmpty ? insuranceName.last : '';
      case 'insurancePolicyNumber':
        return insurancePolicyNumber.isNotEmpty
            ? insurancePolicyNumber.last
            : '';

      // 1st Emergency Contact
      case 'firstContactFirstName':
        return firstContactFirstName.isNotEmpty
            ? firstContactFirstName.last
            : '';
      case 'firstContactLastName':
        return firstContactLastName.isNotEmpty ? firstContactLastName.last : '';
      case 'firstContactRelationship':
        return firstContactRelationship.isNotEmpty
            ? firstContactRelationship.last
            : '';
      case 'firstContactEmail':
        return firstContactEmail.isNotEmpty ? firstContactEmail.last : '';
      case 'firstContactPhone':
        return firstContactPhone.isNotEmpty ? firstContactPhone.last : '';
      case 'firstContactLanguage':
        return firstContactLanguage.isNotEmpty ? firstContactLanguage.last : '';
      case 'firstContactCountry':
        return firstContactCountry.isNotEmpty ? firstContactCountry.last : '';
      case 'firstContactProvince':
        return firstContactProvince.isNotEmpty ? firstContactProvince.last : '';
      case 'firstContactCity':
        return firstContactCity.isNotEmpty ? firstContactCity.last : '';
      case 'firstContactStreet':
        return firstContactStreet.isNotEmpty ? firstContactStreet.last : '';

      // 2nd Emergency Contact
      case 'secondContactFirstName':
        return secondContactFirstName.isNotEmpty
            ? secondContactFirstName.last
            : '';
      case 'secondContactLastName':
        return secondContactLastName.isNotEmpty
            ? secondContactLastName.last
            : '';
      case 'secondContactRelationship':
        return secondContactRelationship.isNotEmpty
            ? secondContactRelationship.last
            : '';
      case 'secondContactEmail':
        return secondContactEmail.isNotEmpty ? secondContactEmail.last : '';
      case 'secondContactPhone':
        return secondContactPhone.isNotEmpty ? secondContactPhone.last : '';
      case 'secondContactLanguage':
        return secondContactLanguage.isNotEmpty
            ? secondContactLanguage.last
            : '';
      case 'secondContactCountry':
        return secondContactCountry.isNotEmpty ? secondContactCountry.last : '';
      case 'secondContactProvince':
        return secondContactProvince.isNotEmpty
            ? secondContactProvince.last
            : '';
      case 'secondContactCity':
        return secondContactCity.isNotEmpty ? secondContactCity.last : '';
      case 'secondContactStreet':
        return secondContactStreet.isNotEmpty ? secondContactStreet.last : '';

      // Account Information
      case 'password':
        return password ?? '';
      case 'defaultPassword':
        return defaultPassword ?? '';
      case 'passwordExpirationTime':
        return passwordExpirationTime ?? '';
      case 'passwordExpirationUnit':
        return passwordExpirationUnit ?? '';
      case 'firstLogin':
        return firstLogin ?? '';
      case 'lastLogin':
        return lastLogin ?? '';
      case 'deactivationDate':
        return deactivationDate ?? '';
      case 'activationDate':
        return activationDate ?? '';

      // Timestamps
      case 'timestamps':
        return timestamps.isNotEmpty ? timestamps.last : 0;

      default:
        return null;
    }
  }
}
