/// Module: roles/r4_active_directory
///
///*************************** FILE INFO ****************************///
/// File Name: new_employee_model_history_methods.dart
/// Description: Methods of `NewEmployeeModelHistory` — split out of `new_employee_model.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../new_employee_model.dart';

// Split from new_employee_model.dart to keep every file under 700 lines.

extension NewEmployeeModelHistoryMethods on NewEmployeeModelHistory {
  Map<String, dynamic> _toMapImpl() {
    // Helper function to convert nested lists to a format Firebase accepts
    List<Map<String, dynamic>> convertNestedList(
      List<List<String>> nestedList,
    ) {
      return nestedList.map((innerList) {
        return {'items': innerList};
      }).toList();
    }

    return {
      'Id': id,
      'timestamps': timestamps,
      'First_Name': firstName,
      'Middle_Name': middleName,
      'Last_Name': lastName,
      'First_Name_In_Arabic': firstNameInArabic,
      'Middle_Name_In_Arabic': middleNameInArabic,
      'Last_Name_In_Arabic': lastNameInArabic,
      'Email': email,
      'Mobile_Phone': mobilePhone.map((phone) => phone.toMap()).toList(),
      'Office_Phone': officePhone,
      'Home_Phone': homePhone,
      'Extension': extension,
      'Postal_Code': postalCode,
      'Street': street,
      'National_Id': nationalId,
      'National_Id_Expiration_Date': nationalIdExpirationDate,
      'Nationality': nationality,
      'Passport': passport,
      'Passport_Expiration_Date': passportExpirationDate,
      'Country': country,
      'Province': province,
      'City': city,
      'Gender': gender,
      'Marital_Status': maritalStatus,
      'Language': language,
      'Birth_Day': birthDay,
      'Bio': bio,
      'Bio_In_Arabic': bioInArabic,
      'Academic_History': academicHistory,
      'Skills': convertNestedList(skills),
      'Hobbies': convertNestedList(hobbies),
      'Password': password,
      'Default_Password': defaultPassword,
      'Password_Expiration_Time': passwordExpirationTime,
      'Password_Expiration_Unit': passwordExpirationUnit,
      'First_Login': firstLogin,
      'Last_Login': lastLogin,
      'Deactivation_Date': deactivationDate,
      'Activation_Date': activationDate,
      'Role': role,
      'Department_Id': departmentId,
      'Supervisor': supervisor,
      'Work_Location': workLocation,
      'Driving_License_Id': drivingLicenseId,
      'Car_Plates': convertNestedList(carPlates),
      'Photo': photo,
      'Title': title,
      'Title_In_Arabic': titleInArabic,
      'Status': status,
      'Personal_Email': personalEmail,
      'Home_Country_Code': homeCountryCode,
      'Office_Country_Code': officeCountryCode,
      'Home_Phone_Details':
          homePhoneDetails.map((phone) => phone.toMap()).toList(),
      'Office_Phone_Details':
          officePhoneDetails.map((phone) => phone.toMap()).toList(),
      'Job_Type': jobType,
      'Work_Arrangement': workArrangement,
      'Remote_Status': remoteStatus,
      'Employee_Grade': employeeGrade,
      'Start_Date': startDate,
      'Start_Time': startTime,
      'End_Time': endTime,
      'Days_Off': daysOff,
      'Salary': salary,
      'Currency': currency,
      'Institution_Name': institutionName,
      'Degree': degree,
      'Field_Of_Study': fieldOfStudy,
      'Certification_Start_Date': certificationStartDate,
      'Certification_End_Date': certificationEndDate,
      'Grade_Or_Score': gradeOrScore,
      'Certificate_Id': certificateId,
      'Issuing_Authority': issuingAuthority,
      'Certification_Document_Url': certificationDocumentUrl,
      'Certification_Notes': certificationNotes,
      // Health Insurance Fields
      'Insurance_Name': insuranceName,
      'Insurance_Policy_Number': insurancePolicyNumber,
      'Provider_Contact': insuranceProviderContact,
      // 1st Emergency Contact Fields
      'First_Contact_First_Name': firstContactFirstName,
      'First_Contact_Last_Name': firstContactLastName,
      'First_Contact_Relationship': firstContactRelationship,
      'First_Contact_Email': firstContactEmail,
      'First_Contact_Phone': firstContactPhone,
      'First_Contact_Language': firstContactLanguage,
      'First_Contact_Country': firstContactCountry,
      'First_Contact_Province': firstContactProvince,
      'First_Contact_City': firstContactCity,
      'First_Contact_Street': firstContactStreet,
      'First_Contact_First_Name_Arabic': firstContactFirstNameArabic,
      'First_Contact_Middle_Name': firstContactMiddleName,
      'First_Contact_Middle_Name_Arabic': firstContactMiddleNameArabic,
      'First_Contact_Last_Name_Arabic': firstContactLastNameArabic,
      'First_Contact_Phone_Details':
          firstContactPhoneDetails.map((phone) => phone.toMap()).toList(),
      // 2nd Emergency Contact Fields
      'Second_Contact_First_Name': secondContactFirstName,
      'Second_Contact_Last_Name': secondContactLastName,
      'Second_Contact_Relationship': secondContactRelationship,
      'Second_Contact_Email': secondContactEmail,
      'Second_Contact_Phone': secondContactPhone,
      'Second_Contact_Language': secondContactLanguage,
      'Second_Contact_Country': secondContactCountry,
      'Second_Contact_Province': secondContactProvince,
      'Second_Contact_City': secondContactCity,
      'Second_Contact_Street': secondContactStreet,
      'Second_Contact_First_Name_Arabic': secondContactFirstNameArabic,
      'Second_Contact_Middle_Name': secondContactMiddleName,
      'Second_Contact_Middle_Name_Arabic': secondContactMiddleNameArabic,
      'Second_Contact_Last_Name_Arabic': secondContactLastNameArabic,
      'Second_Contact_Phone_Details':
          secondContactPhoneDetails.map((phone) => phone.toMap()).toList(),
      'Passport_Document_Url': passportDocumentUrl,
      'National_Id_Front_Url': nationalIdFrontUrl,
      'National_Id_Back_Url': nationalIdBackUrl,
      'Driving_License_Document_Url': drivingLicenseDocumentUrl,
    };
  }

  NewEmployeeModelHistory _copyWithUpdateSynchronizedImpl({
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
  }) {
    final timestamp = addTimestamp ?? DateTime.now().millisecondsSinceEpoch;
    final newTimestamps = List<int>.from(timestamps)..add(timestamp);

    return NewEmployeeModelHistory(
      id: id ?? this.id,
      timestamps: newTimestamps,

      // All existing fields get new entry - either new value or repeat last value
      firstName: List<String>.from(this.firstName)
        ..add(firstName ?? (this.firstName.isEmpty ? '' : this.firstName.last)),

      middleName: List<String>.from(this.middleName)
        ..add(
          middleName ?? (this.middleName.isEmpty ? '' : this.middleName.last),
        ),

      lastName: List<String>.from(this.lastName)
        ..add(lastName ?? (this.lastName.isEmpty ? '' : this.lastName.last)),

      firstNameInArabic: List<String>.from(this.firstNameInArabic)
        ..add(
          firstNameInArabic ??
              (this.firstNameInArabic.isEmpty
                  ? ''
                  : this.firstNameInArabic.last),
        ),

      middleNameInArabic: List<String>.from(this.middleNameInArabic)
        ..add(
          middleNameInArabic ??
              (this.middleNameInArabic.isEmpty
                  ? ''
                  : this.middleNameInArabic.last),
        ),

      lastNameInArabic: List<String>.from(this.lastNameInArabic)
        ..add(
          lastNameInArabic ??
              (this.lastNameInArabic.isEmpty ? '' : this.lastNameInArabic.last),
        ),

      nationalId: List<String>.from(this.nationalId)
        ..add(
          nationalId ?? (this.nationalId.isEmpty ? '' : this.nationalId.last),
        ),

      nationalIdExpirationDate: List<String>.from(this.nationalIdExpirationDate)
        ..add(
          nationalIdExpirationDate ??
              (this.nationalIdExpirationDate.isEmpty
                  ? ''
                  : this.nationalIdExpirationDate.last),
        ),

      nationality: List<String>.from(this.nationality)
        ..add(
          nationality ??
              (this.nationality.isEmpty ? '' : this.nationality.last),
        ),

      passport: List<String>.from(this.passport)
        ..add(passport ?? (this.passport.isEmpty ? '' : this.passport.last)),

      passportExpirationDate: List<String>.from(this.passportExpirationDate)
        ..add(
          passportExpirationDate ??
              (this.passportExpirationDate.isEmpty
                  ? ''
                  : this.passportExpirationDate.last),
        ),

      email: List<String>.from(this.email)
        ..add(email ?? (this.email.isEmpty ? '' : this.email.last)),

      mobilePhone: NewEmployeeModelHistory._synchronizeMobilePhoneList(
        this.mobilePhone,
        newTimestamps.length,
        mobilePhone,
      ),

      officePhone: List<String>.from(this.officePhone)
        ..add(
          officePhone ??
              (this.officePhone.isEmpty ? '' : this.officePhone.last),
        ),

      homePhone: List<String>.from(this.homePhone)
        ..add(homePhone ?? (this.homePhone.isEmpty ? '' : this.homePhone.last)),

      extension: List<String>.from(this.extension)
        ..add(extension ?? (this.extension.isEmpty ? '' : this.extension.last)),

      birthDay: List<String>.from(this.birthDay)
        ..add(birthDay ?? (this.birthDay.isEmpty ? '' : this.birthDay.last)),

      gender: List<String>.from(this.gender)
        ..add(gender ?? (this.gender.isEmpty ? '' : this.gender.last)),

      country: List<String>.from(this.country)
        ..add(country ?? (this.country.isEmpty ? '' : this.country.last)),

      province: List<String>.from(this.province)
        ..add(province ?? (this.province.isEmpty ? '' : this.province.last)),

      city: List<String>.from(this.city)
        ..add(city ?? (this.city.isEmpty ? '' : this.city.last)),

      postalCode: List<String>.from(this.postalCode)
        ..add(
          postalCode ?? (this.postalCode.isEmpty ? '' : this.postalCode.last),
        ),

      street: List<String>.from(this.street)
        ..add(street ?? (this.street.isEmpty ? '' : this.street.last)),

      maritalStatus: List<String>.from(this.maritalStatus)
        ..add(
          maritalStatus ??
              (this.maritalStatus.isEmpty ? '' : this.maritalStatus.last),
        ),

      language: List<String>.from(this.language)
        ..add(language ?? (this.language.isEmpty ? '' : this.language.last)),

      departmentId: List<String>.from(this.departmentId)
        ..add(
          departmentId ??
              (this.departmentId.isEmpty ? '' : this.departmentId.last),
        ),

      supervisor: List<String>.from(this.supervisor)
        ..add(
          supervisor ?? (this.supervisor.isEmpty ? '' : this.supervisor.last),
        ),

      role: List<String>.from(this.role)
        ..add(role ?? (this.role.isEmpty ? '' : this.role.last)),

      title: List<String>.from(this.title)
        ..add(title ?? (this.title.isEmpty ? '' : this.title.last)),

      titleInArabic: List<String>.from(this.titleInArabic)
        ..add(
          titleInArabic ??
              (this.titleInArabic.isEmpty ? '' : this.titleInArabic.last),
        ),

      workLocation: List<String>.from(this.workLocation)
        ..add(
          workLocation ??
              (this.workLocation.isEmpty ? '' : this.workLocation.last),
        ),

      drivingLicenseId: List<String>.from(this.drivingLicenseId)
        ..add(
          drivingLicenseId ??
              (this.drivingLicenseId.isEmpty ? '' : this.drivingLicenseId.last),
        ),

      carPlates: List<List<String>>.from(
        this.carPlates.map((e) => List<String>.from(e)),
      )..add(carPlates ?? (this.carPlates.isEmpty ? [] : this.carPlates.last)),

      academicHistory: List<Map<String, dynamic>>.from(this.academicHistory)
        ..add(
          academicHistory ??
              (this.academicHistory.isEmpty ? {} : this.academicHistory.last),
        ),

      bio: List<String>.from(this.bio)
        ..add(bio ?? (this.bio.isEmpty ? '' : this.bio.last)),

      bioInArabic: List<String>.from(this.bioInArabic)
        ..add(
          bioInArabic ??
              (this.bioInArabic.isEmpty ? '' : this.bioInArabic.last),
        ),

      photo: List<String>.from(this.photo)
        ..add(photo ?? (this.photo.isEmpty ? '' : this.photo.last)),

      skills: List<List<String>>.from(
        this.skills.map((e) => List<String>.from(e)),
      )..add(skills ?? (this.skills.isEmpty ? [] : this.skills.last)),

      hobbies: List<List<String>>.from(
        this.hobbies.map((e) => List<String>.from(e)),
      )..add(hobbies ?? (this.hobbies.isEmpty ? [] : this.hobbies.last)),

      status: List<String>.from(this.status)
        ..add(status ?? (this.status.isEmpty ? '' : this.status.last)),

      // Health Insurance Fields - Properly sync with existing timestamps
      insuranceName: NewEmployeeModelHistory._synchronizeFieldList(
        this.insuranceName,
        newTimestamps.length,
        insuranceName,
      ),
      insurancePolicyNumber: NewEmployeeModelHistory._synchronizeFieldList(
        this.insurancePolicyNumber,
        newTimestamps.length,
        insurancePolicyNumber,
      ),

      // 1st Emergency Contact Fields - Properly sync with existing timestamps
      firstContactFirstName: NewEmployeeModelHistory._synchronizeFieldList(
        this.firstContactFirstName,
        newTimestamps.length,
        firstContactFirstName,
      ),
      firstContactLastName: NewEmployeeModelHistory._synchronizeFieldList(
        this.firstContactLastName,
        newTimestamps.length,
        firstContactLastName,
      ),
      firstContactRelationship: NewEmployeeModelHistory._synchronizeFieldList(
        this.firstContactRelationship,
        newTimestamps.length,
        firstContactRelationship,
      ),
      firstContactEmail: NewEmployeeModelHistory._synchronizeFieldList(
        this.firstContactEmail,
        newTimestamps.length,
        firstContactEmail,
      ),
      firstContactPhone: NewEmployeeModelHistory._synchronizeFieldList(
        this.firstContactPhone,
        newTimestamps.length,
        firstContactPhone,
      ),
      firstContactLanguage: NewEmployeeModelHistory._synchronizeFieldList(
        this.firstContactLanguage,
        newTimestamps.length,
        firstContactLanguage,
      ),
      firstContactCountry: NewEmployeeModelHistory._synchronizeFieldList(
        this.firstContactCountry,
        newTimestamps.length,
        firstContactCountry,
      ),
      firstContactProvince: NewEmployeeModelHistory._synchronizeFieldList(
        this.firstContactProvince,
        newTimestamps.length,
        firstContactProvince,
      ),
      firstContactCity: NewEmployeeModelHistory._synchronizeFieldList(
        this.firstContactCity,
        newTimestamps.length,
        firstContactCity,
      ),
      firstContactStreet: NewEmployeeModelHistory._synchronizeFieldList(
        this.firstContactStreet,
        newTimestamps.length,
        firstContactStreet,
      ),

      // 2nd Emergency Contact Fields - Properly sync with existing timestamps
      secondContactFirstName: NewEmployeeModelHistory._synchronizeFieldList(
        this.secondContactFirstName,
        newTimestamps.length,
        secondContactFirstName,
      ),
      secondContactLastName: NewEmployeeModelHistory._synchronizeFieldList(
        this.secondContactLastName,
        newTimestamps.length,
        secondContactLastName,
      ),
      secondContactRelationship: NewEmployeeModelHistory._synchronizeFieldList(
        this.secondContactRelationship,
        newTimestamps.length,
        secondContactRelationship,
      ),
      secondContactEmail: NewEmployeeModelHistory._synchronizeFieldList(
        this.secondContactEmail,
        newTimestamps.length,
        secondContactEmail,
      ),
      secondContactPhone: NewEmployeeModelHistory._synchronizeFieldList(
        this.secondContactPhone,
        newTimestamps.length,
        secondContactPhone,
      ),
      secondContactLanguage: NewEmployeeModelHistory._synchronizeFieldList(
        this.secondContactLanguage,
        newTimestamps.length,
        secondContactLanguage,
      ),
      secondContactCountry: NewEmployeeModelHistory._synchronizeFieldList(
        this.secondContactCountry,
        newTimestamps.length,
        secondContactCountry,
      ),
      secondContactProvince: NewEmployeeModelHistory._synchronizeFieldList(
        this.secondContactProvince,
        newTimestamps.length,
        secondContactProvince,
      ),
      secondContactCity: NewEmployeeModelHistory._synchronizeFieldList(
        this.secondContactCity,
        newTimestamps.length,
        secondContactCity,
      ),
      secondContactStreet: NewEmployeeModelHistory._synchronizeFieldList(
        this.secondContactStreet,
        newTimestamps.length,
        secondContactStreet,
      ),

      personalEmail: List<String?>.from(personalEmail),
      homeCountryCode: List<String?>.from(homeCountryCode),
      officeCountryCode: List<String?>.from(officeCountryCode),
      homePhoneDetails: List<HomePhone>.from(homePhoneDetails),
      officePhoneDetails: List<OfficePhone>.from(officePhoneDetails),
      jobType: List<String?>.from(jobType),
      workArrangement: List<String?>.from(workArrangement),
      remoteStatus: List<String?>.from(remoteStatus),
      employeeGrade: List<String?>.from(employeeGrade),
      startDate: List<String?>.from(startDate),
      startTime: List<String?>.from(startTime),
      endTime: List<String?>.from(endTime),
      daysOff: List<String?>.from(daysOff),
      salary: List<String?>.from(salary),
      currency: List<String?>.from(currency),
      institutionName: List<String?>.from(institutionName),
      degree: List<String?>.from(degree),
      fieldOfStudy: List<String?>.from(fieldOfStudy),
      certificationStartDate: List<String?>.from(certificationStartDate),
      certificationEndDate: List<String?>.from(certificationEndDate),
      gradeOrScore: List<String?>.from(gradeOrScore),
      certificateId: List<String?>.from(certificateId),
      issuingAuthority: List<String?>.from(issuingAuthority),
      certificationDocumentUrl: List<String?>.from(
        certificationDocumentUrl,
      ),
      certificationNotes: List<String?>.from(certificationNotes),
      insuranceProviderContact: List<String?>.from(
        insuranceProviderContact,
      ),
      firstContactFirstNameArabic: List<String?>.from(
        firstContactFirstNameArabic,
      ),
      firstContactMiddleName: List<String?>.from(firstContactMiddleName),
      firstContactMiddleNameArabic: List<String?>.from(
        firstContactMiddleNameArabic,
      ),
      firstContactLastNameArabic: List<String?>.from(
        firstContactLastNameArabic,
      ),
      firstContactPhoneDetails: List<MobilePhone>.from(
        firstContactPhoneDetails,
      ),
      secondContactFirstNameArabic: List<String?>.from(
        secondContactFirstNameArabic,
      ),
      secondContactMiddleName: List<String?>.from(secondContactMiddleName),
      secondContactMiddleNameArabic: List<String?>.from(
        secondContactMiddleNameArabic,
      ),
      secondContactLastNameArabic: List<String?>.from(
        secondContactLastNameArabic,
      ),
      secondContactPhoneDetails: List<MobilePhone>.from(
        secondContactPhoneDetails,
      ),
      passportDocumentUrl: List<String?>.from(passportDocumentUrl),
      nationalIdFrontUrl: List<String?>.from(nationalIdFrontUrl),
      nationalIdBackUrl: List<String?>.from(nationalIdBackUrl),
      drivingLicenseDocumentUrl: List<String?>.from(
        drivingLicenseDocumentUrl,
      ),

      password: password ?? this.password,
      defaultPassword: defaultPassword ?? this.defaultPassword,
      passwordExpirationTime:
          passwordExpirationTime ?? this.passwordExpirationTime,
      passwordExpirationUnit:
          passwordExpirationUnit ?? this.passwordExpirationUnit,
      firstLogin: firstLogin ?? this.firstLogin,
      lastLogin: lastLogin ?? this.lastLogin,
      deactivationDate: deactivationDate ?? this.deactivationDate,
      activationDate: activationDate ?? this.activationDate,
    );
  }
}
