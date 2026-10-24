/// Module: roles/r4_active_directory
///
///*************************** FILE INFO ****************************///
/// File Name: new_employee_model_history_statics.dart
/// Description: `_NewEmployeeModelHistoryStatics` data model — split out of `new_employee_model.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../new_employee_model.dart';

// Split from new_employee_model.dart to keep every file under 700 lines.

abstract final class _NewEmployeeModelHistoryStatics {
  static NewEmployeeModelHistory factoryFromMap(Map? data) {
    if (data == null) {
      return NewEmployeeModelHistory(id: null);
    }

    try {
      final List<int> sharedTimestamps = (data['timestamps'] as List<dynamic>?)
              ?.map((e) => e is int ? e : (e as num).toInt())
              .toList() ??
          [DateTime.now().millisecondsSinceEpoch];

      return NewEmployeeModelHistory(
        id: data['Id'],
        timestamps: sharedTimestamps,
        firstName: NewEmployeeModelHistory._parseListSafely(data['First_Name']),
        middleName: NewEmployeeModelHistory._parseListSafely(
          data['Middle_Name'],
        ),
        lastName: NewEmployeeModelHistory._parseListSafely(data['Last_Name']),
        firstNameInArabic: NewEmployeeModelHistory._parseListSafely(
          data['First_Name_In_Arabic'],
        ),
        middleNameInArabic: NewEmployeeModelHistory._parseListSafely(
          data['Middle_Name_In_Arabic'],
        ),
        lastNameInArabic: NewEmployeeModelHistory._parseListSafely(
          data['Last_Name_In_Arabic'],
        ),
        nationalId: NewEmployeeModelHistory._parseListSafely(
          data['National_Id'],
        ),
        nationalIdExpirationDate: NewEmployeeModelHistory._parseListSafely(
          data['National_Id_Expiration_Date'],
        ),
        nationality: NewEmployeeModelHistory._parseListSafely(
          data['Nationality'],
        ),
        passport: NewEmployeeModelHistory._parseListSafely(data['Passport']),
        passportExpirationDate: NewEmployeeModelHistory._parseListSafely(
          data['Passport_Expiration_Date'],
        ),
        email: NewEmployeeModelHistory._parseListSafely(data['Email']),
        mobilePhone: NewEmployeeModelHistory._parseMobilePhoneList(
          data['Mobile_Phone'],
        ),
        officePhone: NewEmployeeModelHistory._parseListSafely(
          data['Office_Phone'],
        ),
        homePhone: NewEmployeeModelHistory._parseListSafely(data['Home_Phone']),
        extension: NewEmployeeModelHistory._parseListSafely(data['Extension']),
        birthDay: NewEmployeeModelHistory._parseListSafely(data['Birth_Day']),
        gender: NewEmployeeModelHistory._parseListSafely(data['Gender']),
        country: NewEmployeeModelHistory._parseListSafely(data['Country']),
        province: NewEmployeeModelHistory._parseListSafely(data['Province']),
        city: NewEmployeeModelHistory._parseListSafely(data['City']),
        postalCode: NewEmployeeModelHistory._parseListSafely(
          data['Postal_Code'],
        ),
        street: NewEmployeeModelHistory._parseListSafely(data['Street']),
        maritalStatus: NewEmployeeModelHistory._parseListSafely(
          data['Marital_Status'],
        ),
        language: NewEmployeeModelHistory._parseListSafely(data['Language']),
        departmentId: NewEmployeeModelHistory._parseListSafely(
          data['Department_Id'],
        ),
        supervisor: NewEmployeeModelHistory._parseListSafely(
          data['Supervisor'],
        ),
        role: NewEmployeeModelHistory._parseListSafely(data['Role']),
        title: NewEmployeeModelHistory._parseListSafely(data['Title']),
        titleInArabic: NewEmployeeModelHistory._parseListSafely(
          data['Title_In_Arabic'],
        ),
        workLocation: NewEmployeeModelHistory._parseListSafely(
          data['Work_Location'],
        ),
        drivingLicenseId: NewEmployeeModelHistory._parseListSafely(
          data['Driving_License_Id'],
        ),
        carPlates: NewEmployeeModelHistory._parseNestedListSafely(
          data['Car_Plates'],
        ),
        academicHistory: NewEmployeeModelHistory._parseAcademicHistoryList(
          data['Academic_History'],
        ),
        bio: NewEmployeeModelHistory._parseListSafely(data['Bio']),
        bioInArabic: NewEmployeeModelHistory._parseListSafely(
          data['Bio_In_Arabic'],
        ),
        photo: NewEmployeeModelHistory._parseListSafely(data['Photo']),
        skills: NewEmployeeModelHistory._parseNestedListSafely(data['Skills']),
        hobbies: NewEmployeeModelHistory._parseNestedListSafely(
          data['Hobbies'],
        ),
        status: NewEmployeeModelHistory._parseListSafely(data['Status']),
        personalEmail: NewEmployeeModelHistory._parseNullableListSafely(
          data['Personal_Email'],
        ),
        homeCountryCode: NewEmployeeModelHistory._parseNullableListSafely(
          data['Home_Country_Code'],
        ),
        officeCountryCode: NewEmployeeModelHistory._parseNullableListSafely(
          data['Office_Country_Code'],
        ),
        homePhoneDetails: NewEmployeeModelHistory._parseHomePhoneList(
          data['Home_Phone_Details'],
        ),
        officePhoneDetails: NewEmployeeModelHistory._parseOfficePhoneList(
          data['Office_Phone_Details'],
        ),
        jobType: NewEmployeeModelHistory._parseNullableListSafely(
          data['Job_Type'],
        ),
        workArrangement: NewEmployeeModelHistory._parseNullableListSafely(
          data['Work_Arrangement'],
        ),
        remoteStatus: NewEmployeeModelHistory._parseNullableListSafely(
          data['Remote_Status'],
        ),
        employeeGrade: NewEmployeeModelHistory._parseNullableListSafely(
          data['Employee_Grade'],
        ),
        startDate: NewEmployeeModelHistory._parseNullableListSafely(
          data['Start_Date'],
        ),
        startTime: NewEmployeeModelHistory._parseNullableListSafely(
          data['Start_Time'],
        ),
        endTime: NewEmployeeModelHistory._parseNullableListSafely(
          data['End_Time'],
        ),
        daysOff: NewEmployeeModelHistory._parseNullableListSafely(
          data['Days_Off'],
        ),
        salary: NewEmployeeModelHistory._parseNullableListSafely(
          data['Salary'],
        ),
        currency: NewEmployeeModelHistory._parseNullableListSafely(
          data['Currency'],
        ),
        institutionName: NewEmployeeModelHistory._parseNullableListSafely(
          data['Institution_Name'],
        ),
        degree: NewEmployeeModelHistory._parseNullableListSafely(
          data['Degree'],
        ),
        fieldOfStudy: NewEmployeeModelHistory._parseNullableListSafely(
          data['Field_Of_Study'],
        ),
        certificationStartDate:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['Certification_Start_Date'],
        ),
        certificationEndDate: NewEmployeeModelHistory._parseNullableListSafely(
          data['Certification_End_Date'],
        ),
        gradeOrScore: NewEmployeeModelHistory._parseNullableListSafely(
          data['Grade_Or_Score'],
        ),
        certificateId: NewEmployeeModelHistory._parseNullableListSafely(
          data['Certificate_Id'],
        ),
        issuingAuthority: NewEmployeeModelHistory._parseNullableListSafely(
          data['Issuing_Authority'],
        ),
        certificationDocumentUrl:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['Certification_Document_Url'],
        ),
        certificationNotes: NewEmployeeModelHistory._parseNullableListSafely(
          data['Certification_Notes'],
        ),
        // Health Insurance Fields
        insuranceName: NewEmployeeModelHistory._parseListSafely(
          data['Insurance_Name'],
        ),
        insurancePolicyNumber: NewEmployeeModelHistory._parseListSafely(
          data['Insurance_Policy_Number'],
        ),
        insuranceProviderContact:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['Provider_Contact'],
        ),
        // 1st Emergency Contact Fields
        firstContactFirstName: NewEmployeeModelHistory._parseListSafely(
          data['First_Contact_First_Name'],
        ),
        firstContactLastName: NewEmployeeModelHistory._parseListSafely(
          data['First_Contact_Last_Name'],
        ),
        firstContactRelationship: NewEmployeeModelHistory._parseListSafely(
          data['First_Contact_Relationship'],
        ),
        firstContactEmail: NewEmployeeModelHistory._parseListSafely(
          data['First_Contact_Email'],
        ),
        firstContactPhone: NewEmployeeModelHistory._parseListSafely(
          data['First_Contact_Phone'],
        ),
        firstContactLanguage: NewEmployeeModelHistory._parseListSafely(
          data['First_Contact_Language'],
        ),
        firstContactCountry: NewEmployeeModelHistory._parseListSafely(
          data['First_Contact_Country'],
        ),
        firstContactProvince: NewEmployeeModelHistory._parseListSafely(
          data['First_Contact_Province'],
        ),
        firstContactCity: NewEmployeeModelHistory._parseListSafely(
          data['First_Contact_City'],
        ),
        firstContactStreet: NewEmployeeModelHistory._parseListSafely(
          data['First_Contact_Street'],
        ),
        firstContactFirstNameArabic:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['First_Contact_First_Name_Arabic'],
        ),
        firstContactMiddleName:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['First_Contact_Middle_Name'],
        ),
        firstContactMiddleNameArabic:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['First_Contact_Middle_Name_Arabic'],
        ),
        firstContactLastNameArabic:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['First_Contact_Last_Name_Arabic'],
        ),
        firstContactPhoneDetails: NewEmployeeModelHistory._parseMobilePhoneList(
          data['First_Contact_Phone_Details'],
        ),
        // 2nd Emergency Contact Fields
        secondContactFirstName: NewEmployeeModelHistory._parseListSafely(
          data['Second_Contact_First_Name'],
        ),
        secondContactLastName: NewEmployeeModelHistory._parseListSafely(
          data['Second_Contact_Last_Name'],
        ),
        secondContactRelationship: NewEmployeeModelHistory._parseListSafely(
          data['Second_Contact_Relationship'],
        ),
        secondContactEmail: NewEmployeeModelHistory._parseListSafely(
          data['Second_Contact_Email'],
        ),
        secondContactPhone: NewEmployeeModelHistory._parseListSafely(
          data['Second_Contact_Phone'],
        ),
        secondContactLanguage: NewEmployeeModelHistory._parseListSafely(
          data['Second_Contact_Language'],
        ),
        secondContactCountry: NewEmployeeModelHistory._parseListSafely(
          data['Second_Contact_Country'],
        ),
        secondContactProvince: NewEmployeeModelHistory._parseListSafely(
          data['Second_Contact_Province'],
        ),
        secondContactCity: NewEmployeeModelHistory._parseListSafely(
          data['Second_Contact_City'],
        ),
        secondContactStreet: NewEmployeeModelHistory._parseListSafely(
          data['Second_Contact_Street'],
        ),
        secondContactFirstNameArabic:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['Second_Contact_First_Name_Arabic'],
        ),
        secondContactMiddleName:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['Second_Contact_Middle_Name'],
        ),
        secondContactMiddleNameArabic:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['Second_Contact_Middle_Name_Arabic'],
        ),
        secondContactLastNameArabic:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['Second_Contact_Last_Name_Arabic'],
        ),
        secondContactPhoneDetails:
            NewEmployeeModelHistory._parseMobilePhoneList(
          data['Second_Contact_Phone_Details'],
        ),
        passportDocumentUrl: NewEmployeeModelHistory._parseNullableListSafely(
          data['Passport_Document_Url'],
        ),
        nationalIdFrontUrl: NewEmployeeModelHistory._parseNullableListSafely(
          data['National_Id_Front_Url'],
        ),
        nationalIdBackUrl: NewEmployeeModelHistory._parseNullableListSafely(
          data['National_Id_Back_Url'],
        ),
        drivingLicenseDocumentUrl:
            NewEmployeeModelHistory._parseNullableListSafely(
          data['Driving_License_Document_Url'],
        ),
        password: data['Password'],
        defaultPassword: data['Default_Password'],
        passwordExpirationTime: data['Password_Expiration_Time'],
        passwordExpirationUnit: data['Password_Expiration_Unit'],
        firstLogin: data['First_Login'],
        lastLogin: data['Last_Login'],
        deactivationDate: data['Deactivation_Date'],
        activationDate: data['Activation_Date'],
      );
    } catch (e) {
      rethrow;
    }
  }

  static List<String> _parseListSafely(dynamic value) {
    if (value == null) return [];

    // Handle string representation of empty array
    if (value is String) {
      if (value == '[]' || value.trim().isEmpty) {
        return [];
      }
      return [value];
    }

    if (value is List) {
      // Handle empty list
      if (value.isEmpty) return [];

      List<String> result = [];
      for (var item in value) {
        // Skip if item is the string "[]"
        if (item is String && item == '[]') {
          continue;
        }

        // If item is a Map with a field name
        if (item is Map) {
          for (var entry in item.entries) {
            if (entry.key != 'Timestamp' &&
                entry.value != null &&
                entry.value is! Timestamp) {
              // Skip if value is the string "[]"
              if (entry.value is String && entry.value == '[]') {
                continue;
              }

              if (entry.value is List && (entry.value as List).isNotEmpty) {
                result.add((entry.value as List).first?.toString() ?? '');
              } else {
                result.add(entry.value?.toString() ?? '');
              }
              break;
            }
          }
        } else if (item is! Timestamp) {
          result.add(item?.toString() ?? '');
        }
      }
      return result;
    }

    // Single value (not a list)
    if (value is Map) {
      for (var entry in value.entries) {
        if (entry.key != 'Timestamp' &&
            entry.value != null &&
            entry.value is! Timestamp) {
          // Skip if value is the string "[]"
          if (entry.value is String && entry.value == '[]') {
            return [];
          }

          if (entry.value is List && (entry.value as List).isNotEmpty) {
            return [(entry.value as List).first?.toString() ?? ''];
          }
          return [entry.value?.toString() ?? ''];
        }
      }
      return [];
    }

    return [value.toString()];
  }

  static List<List<String>> _parseNestedListSafely(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      if (value.isEmpty) return [];

      List<List<String>> result = [];
      for (var item in value) {
        // If item is a Map with nested structure
        if (item is Map) {
          // Check for the 'items' key (our new format)
          if (item.containsKey('items') && item['items'] is List) {
            result.add(
              List<String>.from(
                (item['items'] as List).map((e) => e?.toString() ?? ''),
              ),
            );
            continue;
          }

          // Find the first non-Timestamp value (old format)
          for (var entry in item.entries) {
            if (entry.key != 'Timestamp' &&
                entry.value != null &&
                entry.value is! Timestamp) {
              if (entry.value is List) {
                result.add(
                  List<String>.from(
                    entry.value.map((e) => e?.toString() ?? ''),
                  ),
                );
              } else {
                result.add([entry.value?.toString() ?? '']);
              }
              break;
            }
          }
        } else if (item is List) {
          // Direct nested list (legacy format)
          result.add(List<String>.from(item.map((e) => e?.toString() ?? '')));
        }
      }
      return result.isEmpty ? [[]] : result;
    }

    return [];
  }

  static List<MobilePhone> _parseMobilePhoneList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      List<MobilePhone> result = [];
      for (var item in value) {
        if (item is Map) {
          try {
            // Check if this is a wrapped map like {Mobile_Phone: {...}, Timestamp: ...}
            Map<String, dynamic>? actualPhone;
            for (var entry in item.entries) {
              if (entry.key != 'Timestamp' && entry.value is Map) {
                actualPhone = Map<String, dynamic>.from(entry.value);
                break;
              }
            }

            if (actualPhone != null) {
              result.add(MobilePhone.fromMap(actualPhone));
            } else {
              // Direct MobilePhone map
              Map<String, dynamic> cleanMap = Map<String, dynamic>.from(item);
              cleanMap.removeWhere(
                (key, val) => val is Timestamp || key == 'Timestamp',
              );
              if (cleanMap.isNotEmpty) {
                result.add(MobilePhone.fromMap(cleanMap));
              }
            }
          } catch (_) {
            // Best effort: this failure must not stop the action.
          }
        } else if (item is MobilePhone) {
          result.add(item);
        }
      }
      return result;
    }

    if (value is Map) {
      try {
        Map<String, dynamic> cleanMap = Map<String, dynamic>.from(value);
        cleanMap.removeWhere(
          (key, val) => val is Timestamp || key == 'Timestamp',
        );
        return cleanMap.isNotEmpty ? [MobilePhone.fromMap(cleanMap)] : [];
      } catch (_) {
        // Best effort: this failure must not stop the action.
      }
    }

    return [];
  }

  static List<Map<String, dynamic>> _parseAcademicHistoryList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      List<Map<String, dynamic>> result = [];
      for (var item in value) {
        if (item is Map) {
          // Check if this is a wrapped map
          Map<String, dynamic>? actualHistory;
          for (var entry in item.entries) {
            if (entry.key != 'Timestamp' && entry.value is Map) {
              actualHistory = Map<String, dynamic>.from(entry.value);
              break;
            }
          }
          if (actualHistory != null) {
            result.add(actualHistory);
          } else {
            // Direct map
            Map<String, dynamic> cleanMap = Map<String, dynamic>.from(item);
            cleanMap.removeWhere(
              (key, val) => val is Timestamp || key == 'Timestamp',
            );
            if (cleanMap.isNotEmpty) {
              result.add(cleanMap);
            }
          }
        }
      }
      return result;
    }

    if (value is Map) {
      Map<String, dynamic> cleanMap = Map<String, dynamic>.from(value);
      cleanMap.removeWhere(
        (key, val) => val is Timestamp || key == 'Timestamp',
      );
      return cleanMap.isNotEmpty ? [cleanMap] : [];
    }

    return [];
  }

  static List<String> _synchronizeFieldList(
    List<String> currentList,
    int targetLength,
    String? newValue,
  ) {
    List<String> result = List<String>.from(currentList);

    // First, ensure the list matches the OLD timestamp length (targetLength - 1)
    int oldLength = targetLength - 1;
    while (result.length < oldLength) {
      // 9/10/2026: carry the last value forward ('' only when there is none).
      result.add(result.isEmpty ? '' : result.last);
    }

    // Now add the new entry
    if (newValue != null) {
      result.add(newValue);
    } else {
      result.add(result.isEmpty ? '' : result.last);
    }

    return result;
  }

  static List<MobilePhone> _synchronizeMobilePhoneList(
    List<MobilePhone> currentList,
    int targetLength,
    MobilePhone? newValue,
  ) {
    List<MobilePhone> result = List<MobilePhone>.from(currentList);

    // First, ensure the list matches the OLD timestamp length (targetLength - 1)
    int oldLength = targetLength - 1;
    while (result.length < oldLength) {
      // 9/10/2026: carry the last phone forward (empty only when there is none).
      result.add(result.isEmpty ? MobilePhone() : result.last);
    }

    // Now add the new entry
    if (newValue != null) {
      result.add(newValue);
    } else {
      result.add(result.isEmpty ? MobilePhone() : result.last);
    }

    return result;
  }
}
