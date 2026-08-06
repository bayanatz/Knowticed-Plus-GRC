  /// ********************** FILE INFO ********************///
  /// FILE NAME: employees_csv_file_uploader.dart
  /// Purpose: responsible for uploading the active_directory file of employees after apply validations.
  /// Author: Mohamed Elrashidy
  /// created at: 15/12/2024

  import 'dart:io';

  import 'package:csv/csv.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:grc_module/core/custom/loading.dart';

import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
  import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
  import 'package:grc_module/core/helper/role/csv_enums.dart';
  import 'package:grc_module/features/roles/r4_active_directory/domain/constants/active_directory_constants.dart';
  import 'package:grc_module/features/roles/r4_active_directory/domain/enums/employee_data.dart';
import 'package:grc_module/generated/l10n.dart';

  class EmployeesCsvFileUploader {
    String inOrder = '';
    String missing = '';
    List<dynamic> rowInvalid = [];
    CsvStatus? status;
    Map<String, List<List<dynamic>>> usersData = {};

    /// function name: extractExcelFileData
    /// purpose: file responsible for extracting the data from the excel file and apply the needed validations.
    /// parameters:
    ///            length - length of allowed employees to be uploaded.
    /// return: Future<Map<String, List<List>>> which contains the valid and invalid employees data.
    Future<Map<String, List<List>>> extractExcelFileData(
        {required int length}) async
    {

      initUsersData();

      List<List<dynamic>>? result = await getCSVFileData();
      if (result == null) {
        return usersData;
      }

      List<List<dynamic>> data = result;

      if (!validateCSVFileStructure(data)) {
        return usersData;
      }

      validateEachRowFields(data);

      if (!validateIfAdminDataIsUpdated(
          usersData[ActiveDirectoryConstants.validEmployeesData]!)) {
        initUsersData();
      } else {
      }

      bool isInRange = await checkDemoUsersLength(length);
      if (!isInRange) {
        initUsersData();
      } else {
      }


      return usersData;
    }

    /// function name: initUsersData
    /// purpose: responsible for initializing the users data.
    void initUsersData() {
      usersData = {};
      usersData.putIfAbsent(
          ActiveDirectoryConstants.validEmployeesData, () => []);
      usersData.putIfAbsent(
          ActiveDirectoryConstants.invalidEmployeesData, () => []);
    }

    /// function name: getCSVFileData
    /// purpose: responsible for getting the active_directory file from the user.
    /// return: Future<List<List<dynamic>>?> which contains the data of the active_directory file or null.
    Future<List<List<dynamic>>?> getCSVFileData() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      List<List<dynamic>>? csvTable;
      if (result != null) {
        File file = File(result.files.single.path!);

        try {
          String fileContent = file.readAsStringSync();

          csvTable = const CsvToListConverter().convert(fileContent);
        } catch (e, stackTrace) {
          return null;
        }
      } else {
      }
      return csvTable;
    }

    /// function name: validateCSVFileStructure
    /// purpose: responsible for validating the structure of the active_directory file (order, empty, missing values).
    /// parameters:
    ///            data - data of the active_directory file.
    /// return: bool which indicates if the active_directory file structure is valid or not.
    bool validateCSVFileStructure(List<List<dynamic>> data) {
      bool isValid = true;

      isValid &= validateEmptyTable(data);
      if (!isValid) {
        return isValid;
      }

      isValid &= validateMissingFields(data);
      if (!isValid) {
        return isValid;
      }

      isValid &= validateHeadersOrder(data);
      if (!isValid) {
      } else {
      }

      return isValid;
    }

    /// function name: validateEmptyTable
    /// purpose: responsible for validating if the table is empty or not.
    /// parameters:
    ///              data - data of the active_directory file.
    /// return: bool which indicates if the table is empty or not.
    bool validateEmptyTable(List<List<dynamic>> data) {
      if (data.length <= 1) {
        hideLoadingIndicator();
        CustomDialogManager.showMessage(
          context: Get.context!,
          title: "Un Successful",
          subtitle: "The Table Cannot be Empty: $inOrder",
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        );
        return false;
      }
      return true;
    }

    /// function name: validateMissingFields
    /// purpose: responsible for validating the missing fields in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    /// return: bool which indicates if the missing fields are in order or not.
    bool validateMissingFields(List<List<dynamic>> data) {
      int count = 0;
      missing = '';
      for (var item in EmployeeDataItems.values) {
        if (item.name != '') {
          if (!data[0].contains(item.name)) {
            count++;
            if (count <= 5) {
              missing += '${item.name}, ';
            }
          }
        }
      }

      if (count > 5) {
        missing += ' ${S.current.and} +${count - 5} ${S.current.more}';
      }

      if (missing.isNotEmpty) {
        hideLoadingIndicator();
        CustomDialogManager.showMessage(
          context: Get.context!,
          title: "Un Successful",
          subtitle: "The following fields are missing: $missing",
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        );
      } else {
      }

      return missing.isEmpty ? true : false;
    }

    /// function name: validateHeadersOrder
    /// purpose: responsible for validating the headers order in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    /// return: bool which indicates if the headers are in order or not.
    bool validateHeadersOrder(List<List<dynamic>> data) {

      inOrder = '';
      int count = 0;

      if (data[0].length != EmployeeDataItems.values.length - 1) {
        return false;
      }

      for (int i = 0; i < EmployeeDataItems.values.length - 1; i++) {
        String expectedName = EmployeeDataItems.values[i].name;
        String actualName = data[0][i].toString();

        // Only print first 5 to avoid spam
        if (i < 5) {
        }

        if (expectedName != actualName) {
          count++;
          if (count <= 5) {
            inOrder += '$expectedName, ';
          }
        }
      }

      if (count > 5) {
        inOrder += ' ${S.current.and} +${count - 5} ${S.current.more}';
      }

      if (inOrder.isNotEmpty) {
        hideLoadingIndicator();
        CustomDialogManager.showMessage(
          context: Get.context!,
          title: "Un Successful",
          subtitle: "The following fields are not in correct order: $inOrder",
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        );
        return false;
      }

      return true;
    }

    /// function name: validateEachRowFields
    /// purpose: responsible for validating each row in the active_directory file and assign to suitable fields.
    /// parameters:
    ///            data - data of the active_directory file.
    validateEachRowFields(List<List<dynamic>> data) {

      int validCount = 0;
      int invalidCount = 0;

      for (int i = 1; i < data.length; i++) {

        bool isValidRow = validateRowValues(data[i]);

        if (isValidRow) {
          usersData[ActiveDirectoryConstants.validEmployeesData]!.add(data[i]);
          validCount++;
        } else {
          usersData[ActiveDirectoryConstants.invalidEmployeesData]!.add(data[i]);
          invalidCount++;
        }
      }


      // Department consistency is validated by ActiveDirectoryController right
      // after extractExcelFileData(), where the result is awaited and acted on.
      // The previously duplicated (un-awaited) call was removed from here.
    }

    /// function name: validateRowValues
    /// purpose: responsible for validating the values of row in the active_directory file.
    /// parameters:
    ///            data - row data of the active_directory file.
    /// return: bool which indicates if the row values are valid or not.
    bool validateRowValues(List<dynamic> data) {
      bool isValid = true;
      List<String> invalidFields = [];

      // ✅ Check if this is admin ONCE at the start
      bool isAdminRow = adminAccount(data);
      if (isAdminRow) {
      }

      for (int itemIndex = 0; itemIndex < data.length; itemIndex++) {
        // ✅ Skip ALL validations for admin EXCEPT email
        if (isAdminRow) {
          // Only validate email for admin
          if (itemIndex == EmployeeDataItems.email.index) {
            String? validationError = EmployeeDataItems.values[itemIndex].validate
                .call(data[itemIndex].toString());

            if (validationError != null) {
              invalidFields.add("Email (index $itemIndex)");
              isValid = false;
              break;
            }
          }
          // Skip all other validations for admin
          continue;
        }

        // ✅ Regular validation for non-admin rows
        bool fieldValid = true;

        // Special handling for phone numbers
        if (itemIndex == EmployeeDataItems.mobileNumber.index ||
            itemIndex == EmployeeDataItems.homeNumber.index ||
            itemIndex == EmployeeDataItems.officeNumber.index) {
          fieldValid = validatePhoneNumber(itemIndex, data);
        } else {
          String? validationError = EmployeeDataItems.values[itemIndex].validate
              .call(data[itemIndex].toString());
          fieldValid = validationError == null;

          if (!fieldValid) {
          }
        }

        // Check if field is optional and empty
        bool isOptionalField = ActiveDirectoryConstants.optionalItems
            .contains(EmployeeDataItems.values[itemIndex]);
        bool isEmpty = data[itemIndex].toString().trim().isEmpty;

        if (isEmpty && isOptionalField) {
          fieldValid = true;
        }

        if (!fieldValid) {
          invalidFields.add("${EmployeeDataItems.values[itemIndex].name} (index $itemIndex)");
          isValid = false;
          break; // Stop at first invalid field
        }
      }

      if (!isValid && !isAdminRow) {
      } else if (isValid && isAdminRow) {
      }

      return isValid;
    }

    /// function name: validatePhoneNumber
    /// purpose: responsible for validating the phone number.
    /// parameters:
    ///            itemIndex - index of the item in the active_directory file.
    ///            data - data of row in the active_directory file.
    /// return: bool which indicates if the phone number is valid or not.
    bool validatePhoneNumber(int itemIndex, List data) {
      bool isValid = true;
      String phoneNumber = data[itemIndex].toString();
      String originalPhone = phoneNumber;

      if (itemIndex == EmployeeDataItems.mobileNumber.index) {
        phoneNumber =
        '${data[EmployeeDataItems.mobileCountryCode.index]}-$phoneNumber';
      } else if (itemIndex == EmployeeDataItems.homeNumber.index) {
        phoneNumber =
        '${data[EmployeeDataItems.homeCountryCode.index]}-$phoneNumber';
      } else if (itemIndex == EmployeeDataItems.officeNumber.index) {
        phoneNumber =
        '${data[EmployeeDataItems.officeCountryCode.index]}-$phoneNumber';
      }

      String? validationError = EmployeeDataItems.values[itemIndex].validate.call(phoneNumber);
      isValid = validationError == null;

      if (!isValid) {
      }

      return isValid;
    }

    checkDemoUsersLength(int length) {

      Set<String> ids = {};

      // Add IDs from valid uploaded data
      for (var item in usersData[ActiveDirectoryConstants.validEmployeesData]!) {
        ids.add(item[EmployeeDataItems.id.index].toString());
      }

      // Add existing employee IDs
      EmployeeController employeeController = Get.find();
      int existingCount = employeeController.allEmployees?.length ?? 0;
      for (int i = 0; i < existingCount; i++) {
        ids.add(employeeController.allEmployees![i].id!);
      }

      // Remove admin (ID='1') from count
      ids.remove('1');

      if (ids.length > length) {
        hideLoadingIndicator();
        CustomDialogManager.showMessage(
          context: Get.context!,
          title: "Un Successful",
          subtitle: "Employees Numbers are More than allowed ($length). You have ${ids.length} unique employees.",
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        );
        return false;
      }

      return true;
    }


    // validateIfAdminDataIsUpdated(List<List> data) {
    //   print("\n╔════════════════════════════════════════════════════════════╗");
    //   print("║  validateIfAdminDataIsUpdated() STARTED                   ║");
    //   print("╚════════════════════════════════════════════════════════════╝\n");
    //
    //   String? adminEmail;
    //
    //   // Step 1: Get the admin email (employee with ID = '1')
    //   print("Step 1: Looking for admin employee (ID = '1')...");
    //   try {
    //     var employeeController = Get.find<EmployeeController>();
    //     print("  ✓ EmployeeController found");
    //     print("  - Total employees: ${employeeController.allEmployees?.length ?? 'NULL'}");
    //
    //     if (employeeController.allEmployees == null) {
    //       print("  ⚠️ WARNING: allEmployees is NULL!");
    //       return true; // No validation needed if no employees loaded
    //     }
    //
    //     if (employeeController.allEmployees!.isEmpty) {
    //       print("  ⚠️ WARNING: allEmployees is EMPTY!");
    //       return true;
    //     }
    //
    //     // Try to find admin
    //     var adminEmployee = employeeController.allEmployees!.firstWhere(
    //           (employee) => employee.id == '1',
    //       orElse: () => null as dynamic,
    //     );
    //
    //     if (adminEmployee == null) {
    //       print("  ℹ️ INFO: No employee found with ID = '1' (this is OK)");
    //       print("  Existing employee IDs:");
    //       for (var emp in employeeController.allEmployees!.take(5)) {
    //         print("    - ID: ${emp.id}, Email: ${emp.email?.last}");
    //       }
    //       return true; // No admin found, skip validation
    //     }
    //
    //     adminEmail = adminEmployee.email?.last?.trim().toLowerCase();
    //     print("  ✓ Admin employee found!");
    //     print("  - Admin ID: ${adminEmployee.id}");
    //     print("  - Admin Email (raw): ${adminEmployee.email?.last}");
    //     print("  - Admin Email (processed): $adminEmail");
    //
    //   } catch (e, stackTrace) {
    //     print("  !!! ERROR finding admin employee !!!");
    //     print("  Error: $e");
    //     print("  StackTrace: $stackTrace");
    //     return true; // If we can't find admin, skip validation
    //   }
    //
    //   // Step 2: Check if adminEmail is null
    //   if (adminEmail == null || adminEmail.isEmpty) {
    //     print("\nStep 2: Admin email is NULL or EMPTY");
    //     print("  ℹ️ INFO: No admin email to validate, returning true");
    //     return true;
    //   }
    //
    //   print("\nStep 2: Admin email to validate: '$adminEmail'");
    //
    //   // Step 3: Check the uploaded Excel data
    //   print("\nStep 3: Checking uploaded Excel data...");
    //   print("  - Total rows in uploaded VALID data: ${data.length}");
    //   print("  - Total rows in uploaded INVALID data: ${usersData[ActiveDirectoryConstants.invalidEmployeesData]!.length}");
    //
    //   if (data.isEmpty) {
    //     print("  ⚠️ WARNING: No VALID data to validate!");
    //     print("  ⚠️ This means all rows in your CSV are INVALID!");
    //     print("  ⚠️ Check the invalid data to see if admin is there...\n");
    //
    //     // Check if admin is in invalid data
    //     print("  → Searching for admin in INVALID data...");
    //     for (int i = 0; i < usersData[ActiveDirectoryConstants.invalidEmployeesData]!.length; i++) {
    //       try {
    //         var row = usersData[ActiveDirectoryConstants.invalidEmployeesData]![i];
    //         var rowEmail = row[EmployeeDataItems.email.index].toString().trim().toLowerCase();
    //         if (rowEmail == adminEmail) {
    //           print("  ✓✓✓ FOUND! Admin is in INVALID data at row $i");
    //           print("  ⚠️ The admin row has validation errors!");
    //           print("  ⚠️ Fix the admin row data in your CSV file");
    //           print("  Admin row data: $row");
    //           break;
    //         }
    //       } catch (e) {
    //         print("  Error checking row $i: $e");
    //       }
    //     }
    //
    //     return true;
    //   }
    //
    //   print("\n  Listing all emails in uploaded VALID data:");
    //   for (int i = 0; i < data.length; i++) {
    //     try {
    //       var rowEmail = data[i][EmployeeDataItems.email.index];
    //       var processedEmail = rowEmail.toString().trim().toLowerCase();
    //       print("    Row $i: '$rowEmail' -> '$processedEmail'");
    //
    //       // Check if this matches admin email
    //       if (processedEmail == adminEmail) {
    //         print("      ✓✓✓ MATCH FOUND! This row contains admin email ✓✓✓");
    //       }
    //     } catch (e) {
    //       print("    Row $i: ERROR - $e");
    //     }
    //   }
    //
    //   // Step 4: Try to find admin row
    //   print("\nStep 4: Searching for admin email in uploaded VALID data...");
    //   print("  Looking for: '$adminEmail'");
    //
    //   try {
    //     List<dynamic> adminRow = data.firstWhere(
    //           (row) {
    //         String rowEmail = row[EmployeeDataItems.email.index].toString().trim().toLowerCase();
    //         bool matches = rowEmail == adminEmail;
    //
    //         if (matches) {
    //           print("\n  ✓✓✓ ADMIN ROW FOUND! ✓✓✓");
    //           print("  - Row data: $row");
    //         }
    //
    //         return matches;
    //       },
    //     );
    //
    //     print("\n╔════════════════════════════════════════════════════════════╗");
    //     print("║  ✓ VALIDATION PASSED - Admin data found in Excel file     ║");
    //     print("╚════════════════════════════════════════════════════════════╝\n");
    //     return true;
    //
    //   } catch (e) {
    //     print("\n╔════════════════════════════════════════════════════════════╗");
    //     print("║  ✗ VALIDATION FAILED - Admin data NOT found!              ║");
    //     print("╚════════════════════════════════════════════════════════════╝");
    //     print("\n!!! ERROR: Admin email not found in uploaded VALID Excel data !!!");
    //     print("Error: $e");
    //
    //     print("\n=== COMPARISON SUMMARY ===");
    //     print("Admin email from database: '$adminEmail'");
    //     print("\nEmails in uploaded VALID Excel file:");
    //     for (int i = 0; i < data.length; i++) {
    //       try {
    //         var email = data[i][EmployeeDataItems.email.index].toString().trim().toLowerCase();
    //         print("  [$i] '$email' ${email == adminEmail ? '← MATCHES!' : ''}");
    //       } catch (e) {
    //         print("  [$i] ERROR reading email");
    //       }
    //     }
    //
    //     print("\n⚠️ SOLUTION: The Excel file must include a row with email: '$adminEmail'");
    //     print("           This is the admin user (ID='1') and must be included.\n");
    //     print("⚠️ HINT: Check if admin row is in INVALID data due to validation errors!\n");
    //
    //     hideLoadingIndicator();
    //     showDialog(
    //       context: Get.context!,
    //       builder: (contexttt) {
    //         return ResponseDialog(
    //           title: "Un Successful",
    //           subtitle: "Admin Data is not updated, please update it.\n\nThe Excel file must include the admin user:\n$adminEmail",
    //           lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
    //         );
    //       },
    //     );
    //     return false;
    //     return false;
    //   }
    // }
    validateIfAdminDataIsUpdated(List<List> data) {

      String? adminEmail;
      bool adminExistsInDatabase = false;

      // Step 1: Check if admin exists in database
      try {
        var employeeController = Get.find<EmployeeController>();

        if (employeeController.allEmployees == null || employeeController.allEmployees!.isEmpty) {
          adminExistsInDatabase = false;
        } else {
          var adminEmployee = employeeController.allEmployees!.firstWhere(
                (employee) => employee.id == '1',
            orElse: () => null as dynamic,
          );

          if (adminEmployee == null) {
            adminExistsInDatabase = false;
          } else {
            adminEmail = adminEmployee.email?.last?.trim().toLowerCase();
            adminExistsInDatabase = true;
          }
        }
      } catch (e) {
        adminExistsInDatabase = false;
      }

      // Step 2: Handle FIRST UPLOAD vs SUBSEQUENT UPLOAD
      if (!adminExistsInDatabase) {
        // ═══════════════════════════════════════════════════════════
        // FIRST UPLOAD: Admin MUST be included with ID='1'
        // ═══════════════════════════════════════════════════════════

        if (data.isEmpty) {
          hideLoadingIndicator();
          CustomDialogManager.showMessage(
            context: Get.context!,
            title: "Un Successful",
            subtitle: "No valid data found in CSV file.",
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
          );
          return false;
        }

        // Search for row with ID='1'
        try {
          List<dynamic> adminRow = data.firstWhere(
                (row) {
              String rowId = row[EmployeeDataItems.id.index].toString().trim();
              return rowId == '1';
            },
          );

          String adminEmailInCsv = adminRow[EmployeeDataItems.email.index].toString().trim().toLowerCase();


          return true;

        } catch (e) {

          hideLoadingIndicator();
          CustomDialogManager.showMessage(
            context: Get.context!,
            title: "First Upload - Admin Required",
            subtitle: "This is your first upload.\n\n"
                    "Your CSV file MUST include the admin user with:\n"
                    "• ID = 1\n"
                    "• Valid email address\n\n"
                    "The admin row was not found in your CSV file.\n"
                    "Please add the admin user and try again.",
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
          );
          return false;
        }

      } else {
        // ═══════════════════════════════════════════════════════════
        // SUBSEQUENT UPLOAD: Admin CAN be included to UPDATE data
        // ═══════════════════════════════════════════════════════════

        if (data.isEmpty) {
          return true;
        }

        // ✅ NEW: Check if admin is in CSV with correct ID

        for (int i = 0; i < data.length; i++) {
          try {
            String rowEmail = data[i][EmployeeDataItems.email.index].toString().trim().toLowerCase();
            String rowId = data[i][EmployeeDataItems.id.index].toString().trim();

            if (rowEmail == adminEmail) {

              // ✅ Verify admin has ID='1'
              if (rowId != '1') {

                hideLoadingIndicator();
                CustomDialogManager.showMessage(
                  context: Get.context!,
                  title: "Invalid Admin ID",
                  subtitle: "Admin user found in CSV with wrong ID.\n\n"
                          "Admin email: $adminEmail\n"
                          "Current ID in CSV: $rowId\n"
                          "Required ID: 1\n\n"
                          "Please change the ID to '1' in your CSV file or remove the admin row.",
                  lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
                );
                return false;
              }

              break; // Admin found and validated, exit loop
            }
          } catch (e) {
          }
        }


        return true;
      }
    }

    bool adminAccount(data) {
      String email = data[EmployeeDataItems.email.index]
          .toString()
          .trim()
          .toLowerCase();

      String? adminEmail;
      try {
        adminEmail = Get.find<EmployeeController>()
            .allEmployees!
            .firstWhere(
              (employee) => employee.id == '1',
        )
            .email
            ?.last
            ?.trim()
            .toLowerCase();
      } catch (e) {
      }

      bool isAdmin = adminEmail == email;
      if (isAdmin) {
      }

      return isAdmin;
    }
  }