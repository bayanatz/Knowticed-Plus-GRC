  ///************************ FILE INFO ********************///
  /// FILE NAME: employees_csv_file_data_consistency.dart
  /// Purpose: responsible for validating the active_directory file of employees data consistency.
  /// Author: Mohamed Elrashidy
  /// created at: 28/12/2024
  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:get/get.dart';
  import 'package:grc_module/core/custom/loading.dart';
  import 'package:grc_module/features/roles/r4_active_directory/domain/enums/department_reference.dart';
  import 'package:grc_module/features/roles/r4_active_directory/domain/constants/active_directory_constants.dart';

  import 'package:grc_module/features/roles/r4_active_directory/domain/enums/employee_data.dart';
  import 'package:grc_module/features/roles/r4_active_directory/domain/enums/employee_data_functions.dart';

import 'package:grc_module/core/helper/main_helper/get_dialog_helper.dart';
import 'package:grc_module/core/custom/default_dialog.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

  class EmployeesCsvFileDataConsistency {
    /// Department lookups are injected; no service locator.
    final MainCoreDepartmentCubit departmentCubit;

    EmployeesCsvFileDataConsistency({required this.departmentCubit});

    bool isRepeatDepartmentValidation = false;
    DepartmentReference departmentReference = DepartmentReference.departmentId;
    String departmentReferenceValue = "";
    String referenceDepartmentId = "";
    String referenceDepartmentEnglishName = "";
    String referenceDepartmentArabicName = "";
    Map<String, String> departmentsIdReference = {};
    Map<String, String> departmentsEnglishNameReference = {};
    Map<String, String> departmentsArabicNameReference = {};

    /// function name: validateDepartmentsConsistency
    /// purpose: responsible for validating the departments consistency in the active_directory file.
    /// parameters:
    ///           data - data of the active_directory file.
    validateDepartmentsConsistency(List<List<dynamic>> data) async {
      bool isValid = true;
      do {
        isValid = true;
        isRepeatDepartmentValidation = false;
        for (int referenceIndex = 0;
            referenceIndex < DepartmentReference.values.length;
            referenceIndex++) {
          departmentsArabicNameReference = {};
          departmentsEnglishNameReference = {};
          departmentsIdReference = {};
          isValid &= await validateDepartmentConflicts(data, referenceIndex);
          if (!isValid) break;
        }
      } while (isRepeatDepartmentValidation);
      return isValid;
    }

    /// function name: validateDepartmentConflicts
    /// purpose: responsible for validating the department conflicts in the active_directory file.
    /// parameters:
    ///             departmentsReference - map contains id, arabic name, and english name of the department with the reference value.
    ///             data - data of the active_directory file.
    ///             referenceIndex - the index of the department reference.
    validateDepartmentConflicts(List<List> data, int referenceIndex) async {
      initDepartmentReference(DepartmentReference.values[referenceIndex]);
      bool isValid = true;
      for (int i = 0; i < data.length; i++) {
        isValid &= await validateNewRowAccordingToDepartment(
            data, DepartmentReference.values[referenceIndex], i);
        if (!isValid) break;
      }
      return isValid;
    }

    /// function name: initDepartmentReference
    /// purpose: responsible for initializing the department reference with values in database.
    /// parameters:
    ///            departmentsIdReference - map contains id, arabic name, and english name of the department with the reference value.
    ///            reference - the reference type of the department.
    void initDepartmentReference(DepartmentReference reference) {
      final departmentController = departmentCubit;
      for (int i = 0; i < departmentController.departmentIds.length; i++) {
        String referenceValue = "";
        switch (reference) {
          case DepartmentReference.departmentId:
            referenceValue = departmentController.departmentIds[i];
            break;
          case DepartmentReference.departmentEnglishName:
            referenceValue = departmentController.departmentsEnglishName[i];
            break;
          case DepartmentReference.departmentArabicName:
            referenceValue = departmentController.departmentsArabicName[i];
            break;
        }

        departmentsIdReference.putIfAbsent(
            departmentController.departmentIds[i], () => referenceValue);
        departmentsEnglishNameReference.putIfAbsent(
            departmentController.departmentsEnglishName[i], () => referenceValue);
        departmentsArabicNameReference.putIfAbsent(
            departmentController.departmentsArabicName[i], () => referenceValue);
      }
    }

    /// function name: validateNewRowAccordingToDepartment
    /// purpose: responsible for validating the new row according to the department and add the department to the reference map if new.
    /// parameters:
    ///             departmentsIdReference - map contains id, arabic name, and english name of the department with the reference value.
    ///             data - specific row to validate.
    ///             reference - the reference type of the department.
    Future<bool> validateNewRowAccordingToDepartment(
        List data, DepartmentReference reference, int selectedRowIndex) async {
      String departmentReference = "";
      List<dynamic> selectedRow = data[selectedRowIndex];
      switch (reference) {
        case DepartmentReference.departmentId:
          departmentReference =
              selectedRow[EmployeeDataItems.departmentId.index] != null
                  ? selectedRow[EmployeeDataItems.departmentId.index].toString()
                  : "";
          break;
        case DepartmentReference.departmentEnglishName:
          departmentReference =
              selectedRow[EmployeeDataItems.departmentEnglishName.index].trim();
          break;
        case DepartmentReference.departmentArabicName:
          departmentReference =
              selectedRow[EmployeeDataItems.departmentArabicName.index].trim();
          break;
      }
      String departmentId =
          selectedRow[EmployeeDataItems.departmentId.index] == null
              ? ""
              : selectedRow[EmployeeDataItems.departmentId.index].toString();
      String departmentEnglishName =
          selectedRow[EmployeeDataItems.departmentEnglishName.index].trim();
      String departmentArabicName =
          selectedRow[EmployeeDataItems.departmentArabicName.index].trim();

      if (departmentsIdReference[departmentId] ==
              departmentsEnglishNameReference[departmentEnglishName] &&
          departmentsIdReference[departmentId] ==
              departmentsArabicNameReference[departmentArabicName]) {
        departmentsIdReference.putIfAbsent(
            departmentId, () => departmentReference);
        departmentsEnglishNameReference.putIfAbsent(
            departmentEnglishName, () => departmentReference);
        departmentsArabicNameReference.putIfAbsent(
            departmentArabicName, () => departmentReference);
        return true;
      }
      hideLoadingIndicator();
      setUpdateDepartmentValues(departmentReference);
      await GetDialogHelper.generalDialog(
        child: DefaultDialog(
          width: ContextExtension(Get.context!).isPhone ? 343.w : 411.w,
          showButtons: true,
          lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          title: S.current.unSuccessful,
          subTitle:
              "There is an error at the department for employee with id: ${selectedRow[EmployeeDataItems.id.index]}",
          onConfirm: () {
            updateRowsWithNewDepartmentValues(reference, data);
            Get.back();
          },
        ),
        context: Get.context!,
      );

      return false;
    }

    /// function name: setUpdateDepartmentValues
    /// purpose: responsible for setting the department values will be used at updating rows
    /// parameters:
    ///            departmentReference - has reference value to get all department values.
    void setUpdateDepartmentValues(String departmentReference) {
      referenceDepartmentArabicName = departmentsArabicNameReference.entries
          .firstWhere((element) => element.value == departmentReference,
              orElse: () => MapEntry("", ""))
          .key;
      referenceDepartmentEnglishName = departmentsEnglishNameReference.entries
          .firstWhere((element) => element.value == departmentReference,
              orElse: () => MapEntry("", ""))
          .key;
      referenceDepartmentId = departmentsIdReference.entries
          .firstWhere((element) => element.value == departmentReference,
              orElse: () => MapEntry("", ""))
          .key;
    }

    /// function name: checkUniqueItems
    /// purpose: responsible for checking the unique items in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    /// function name: checkUniqueItems
    /// purpose: responsible for checking the unique items in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    /// function name: checkUniqueItems
    /// purpose: responsible for checking the unique items in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    /// Replace this function in employees_csv_file_data_consistency.dart

    /// function name: checkUniqueItems
    /// purpose: responsible for checking the unique items in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    // bool checkUniqueItems(List<dynamic> data) {
    //   print("\n╔════════════════════════════════════════════════════════════╗");
    //   print("║  checkUniqueItems() STARTED                               ║");
    //   print("╚════════════════════════════════════════════════════════════╝\n");
    //
    //   EmployeeController employeeController = Get.find();
    //
    //   print("📊 Total unique fields to check: ${ActiveDirectoryConstants.uniqueItems.length}");
    //   print("📊 Unique fields: ${ActiveDirectoryConstants.uniqueItems.map((e) => e.name).toList()}");
    //   print("📊 CSV rows to check: ${data.length}");
    //   print("📊 Existing employees in DB: ${employeeController.allEmployees?.length ?? 0}\n");
    //
    //   for (int uniqueItemIndex = 0;
    //   uniqueItemIndex < ActiveDirectoryConstants.uniqueItems.length;
    //   uniqueItemIndex++) {
    //
    //     EmployeeDataItems currentUniqueField = ActiveDirectoryConstants.uniqueItems[uniqueItemIndex];
    //     print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    //     print("→ Checking unique field: ${currentUniqueField.name}");
    //     print("  Index: ${currentUniqueField.index}");
    //     print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    //
    //     Set<String> uniqueItemsSet = {};
    //     Map<String, String> valueToEmployeeMap = {}; // Track where each value came from
    //
    //     // Initialize with existing database values
    //     print("\n  Step 1: Loading existing values from database...");
    //     if (employeeController.allEmployees != null) {
    //       for (int i = 0; i < employeeController.allEmployees!.length; i++) {
    //         List<String> employeeDataRow =
    //         List.generate(EmployeeDataItems.values.length, (index) => '');
    //
    //         currentUniqueField.getRowDataFromModelItem(
    //           departments: departmentCubit,
    //             employee: employeeController.allEmployees![i],
    //             row: employeeDataRow);
    //
    //         String value = employeeDataRow[currentUniqueField.index]
    //             .toString()
    //             .trim()
    //             .toLowerCase();
    //
    //         if (value.isNotEmpty) {
    //           uniqueItemsSet.add(value);
    //           valueToEmployeeMap[value] = "DB Employee ID: ${employeeController.allEmployees![i].id}";
    //         }
    //       }
    //     }
    //
    //     print("  ✓ Loaded ${uniqueItemsSet.length} existing values from database");
    //
    //     if (uniqueItemsSet.length > 0 && uniqueItemsSet.length <= 5) {
    //       print("  Existing values from DB:");
    //       for (var value in uniqueItemsSet.take(5)) {
    //         print("    - '$value' (${valueToEmployeeMap[value]})");
    //       }
    //     }
    //
    //     print("\n  Step 2: Checking CSV data for duplicates...");
    //
    //     int duplicatesFound = 0;
    //     int emptyCount = 0;
    //     int validCount = 0;
    //
    //     for (int i = 0; i < data.length; i++) {
    //       String fieldValue = '';
    //
    //       try {
    //         fieldValue = data[i][currentUniqueField.index]
    //             .toString()
    //             .trim()
    //             .toLowerCase();
    //       } catch (e) {
    //         print("  ⚠️ [$i] Error reading field: $e");
    //         continue;
    //       }
    //
    //       // Skip empty values
    //       if (fieldValue.isEmpty) {
    //         emptyCount++;
    //         continue;
    //       }
    //
    //       // Special handling for admin email
    //       if (adminAccount(data[i]) && currentUniqueField == EmployeeDataItems.email) {
    //         print("  [$i] '$fieldValue' - 👑 ADMIN account, allowing duplicate");
    //         uniqueItemsSet.add(fieldValue);
    //         valueToEmployeeMap[fieldValue] = "CSV Row $i (ADMIN)";
    //         validCount++;
    //         continue;
    //       }
    //
    //       // Check for duplicate
    //       if (uniqueItemsSet.contains(fieldValue)) {
    //         print("\n  ❌❌❌ DUPLICATE FOUND! ❌❌❌");
    //         print("  Row: $i (CSV row ${i + 2} including header)");
    //         print("  Field: ${currentUniqueField.name}");
    //         print("  Duplicate value: '$fieldValue'");
    //         print("\n  CSV Row Details:");
    //         print("    Employee ID: ${data[i][EmployeeDataItems.id.index]}");
    //         print("    First Name: ${data[i][EmployeeDataItems.firstName.index]}");
    //         print("    Last Name: ${data[i][EmployeeDataItems.lastName.index]}");
    //         print("    Email: ${data[i][EmployeeDataItems.email.index]}");
    //         print("\n  This value already exists at:");
    //         print("    ${valueToEmployeeMap[fieldValue]}");
    //         print("\n  CONFLICT:");
    //         print("    ❌ CSV is trying to add: ${data[i][EmployeeDataItems.id.index]} - ${data[i][EmployeeDataItems.firstName.index]} ${data[i][EmployeeDataItems.lastName.index]}");
    //         print("    ❌ But ${currentUniqueField.name} '$fieldValue' is already used by: ${valueToEmployeeMap[fieldValue]}");
    //
    //         duplicatesFound++;
    //
    //         hideLoadingIndicator();
    //         showDialog(
    //           context: Get.context!,
    //           builder: (context) {
    //             return ResponseDialog(
    //               title: "Duplicate Value Found",
    //               subtitle: "❌ Duplicate detected!\n\n"
    //                   "Field: ${currentUniqueField.name}\n"
    //                   "Value: '$fieldValue'\n\n"
    //                   "CSV Employee: ${data[i][EmployeeDataItems.firstName.index]} ${data[i][EmployeeDataItems.lastName.index]} (ID: ${data[i][EmployeeDataItems.id.index]})\n"
    //                   "Row: ${i + 2} (including header)\n\n"
    //                   "This value already exists in: ${valueToEmployeeMap[fieldValue]}\n\n"
    //                   "Please either:\n"
    //                   "1. Remove this employee from CSV (if duplicate)\n"
    //                   "2. Change the ${currentUniqueField.name} to a unique value",
    //               lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
    //             );
    //           },
    //         );
    //
    //         print("\n╔════════════════════════════════════════════════════════════╗");
    //         print("║  ✗ checkUniqueItems() FAILED                              ║");
    //         print("║  Field: ${currentUniqueField.name.padRight(48)}║");
    //         print("║  Duplicate value: ${fieldValue.padRight(40)}║");
    //         print("╚════════════════════════════════════════════════════════════╝\n");
    //
    //         return false;
    //       }
    //
    //       // Add to set
    //       uniqueItemsSet.add(fieldValue);
    //       valueToEmployeeMap[fieldValue] = "CSV Row $i - ${data[i][EmployeeDataItems.firstName.index]} ${data[i][EmployeeDataItems.lastName.index]}";
    //       validCount++;
    //     }
    //
    //     print("\n  ✓ Summary for ${currentUniqueField.name}:");
    //     print("    - Valid unique values: $validCount");
    //     print("    - Empty values (skipped): $emptyCount");
    //     print("    - Duplicates found: $duplicatesFound");
    //     print("    - Total values in set: ${uniqueItemsSet.length}");
    //
    //     if (duplicatesFound > 0) {
    //       return false;
    //     }
    //   }
    //
    //   print("\n╔════════════════════════════════════════════════════════════╗");
    //   print("║  ✓ checkUniqueItems() PASSED - No duplicates found!      ║");
    //   print("╚════════════════════════════════════════════════════════════╝\n");
    //
    //   return true;
    // }


    /// function name: initUniqueItemsSet
    /// purpose: responsible for initializing the unique items set.
    /// parameters:
    ///            uniqueItemsSet - the set of unique field items.
    ///            uniqueItem - the unique field.
    /// function name: initUniqueItemsSet
    /// purpose: responsible for initializing the unique items set.
    /// parameters:
    ///            uniqueItemsSet - the set of unique field items.
    ///            uniqueItem - the unique field.
    void initUniqueItemsSet(
        Set<String> uniqueItemsSet, EmployeeDataItems uniqueItem) {
      EmployeeController employeeController = Get.find();

      if (employeeController.allEmployees == null) {
        return;
      }

      for (int i = 0; i < employeeController.allEmployees!.length; i++) {
        List<String> employeeDataRow =
        List.generate(EmployeeDataItems.values.length, (index) => '');

        uniqueItem.getRowDataFromModelItem(
          departments: departmentCubit,
            employee: employeeController.allEmployees![i],
            row: employeeDataRow);

        String value = employeeDataRow[uniqueItem.index]
            .toString()
            .trim()
            .toLowerCase();  // ✅ Add toLowerCase()

        if (value.isNotEmpty) {
          uniqueItemsSet.add(value);
        }
      }
    }


    /// function name: updateRowsWithNewDepartmentValues
    /// purpose: responsible for updating the rows with the new department values.
    /// parameters:
    ///            reference - the reference type of the department.
    ///            data - data of the active_directory file.
    updateRowsWithNewDepartmentValues(
        DepartmentReference reference, List<dynamic> data) {
      isRepeatDepartmentValidation = true;
      for (int i = 0; i < data.length; i++) {
        bool isUpdated = false;
        switch (reference) {
          case DepartmentReference.departmentId:
            isUpdated = data[i][EmployeeDataItems.departmentId.index] ==
                referenceDepartmentId;
            break;
          case DepartmentReference.departmentEnglishName:
            isUpdated = data[i][EmployeeDataItems.departmentEnglishName.index] ==
                referenceDepartmentEnglishName;
            break;
          case DepartmentReference.departmentArabicName:
            isUpdated = data[i][EmployeeDataItems.departmentArabicName.index] ==
                referenceDepartmentArabicName;
            break;
        }
        if (isUpdated) {
          data[i][EmployeeDataItems.departmentId.index] = referenceDepartmentId;
          data[i][EmployeeDataItems.departmentEnglishName.index] =
              referenceDepartmentEnglishName;
          data[i][EmployeeDataItems.departmentArabicName.index] =
              referenceDepartmentArabicName;
        }
      }
    }

    bool adminAccount(data) {
      String email =
          data[EmployeeDataItems.email.index].toString().trim().toLowerCase();
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
      } catch (e) {}
      return adminEmail == email;
    }
  }
