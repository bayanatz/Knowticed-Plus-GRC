/// Module: roles / r4_active_directory / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: employee_data_functions.dart
/// Description: Declares `EmployeeDataFunction`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/helper/single_value_tracking_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/invalid_import_row_model.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/roles/helpers/constants/id_constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data.dart';

part 'employee_data_functions/employee_data_function_methods.dart';

extension EmployeeDataFunction on EmployeeDataItems {
  /// ✅ NEW METHOD: Update field directly WITHOUT adding timestamp
  /// Used when creating NEW employees from CSV (not editing existing ones)
  void updateFieldDirectly({
    required NewEmployeeModelHistory employee,
    required List<dynamic> data,
    required bool isWrongEmployee,
  }) {
    // Get the value from CSV at this field's index.
    //
    // Was a `try { data[this.index] } catch { value = '' }` guarding a short
    // row. §11.2 forbids try/catch under `domain/`, and a length check says
    // exactly the same thing without one.
    final String value = (index >= 0 && index < data.length)
        ? (data[index]?.toString().trim() ?? '')
        : '';

    String valueLower = value.toLowerCase();

    // Update the field at index 0 (the only index for new employees)
    switch (this) {
      case EmployeeDataItems.none:
        break;

      case EmployeeDataItems.id:
        employee.id = value;
        break;

      case EmployeeDataItems.firstName:
        employee.firstName[0] = valueLower;
        break;

      case EmployeeDataItems.middleName:
        employee.middleName[0] = valueLower;
        break;

      case EmployeeDataItems.lastName:
        employee.lastName[0] = valueLower;
        break;

      case EmployeeDataItems.firstNameArabic:
        employee.firstNameInArabic[0] = value;
        break;

      case EmployeeDataItems.middleNameArabic:
        employee.middleNameInArabic[0] = value;
        break;

      case EmployeeDataItems.lastNameArabic:
        employee.lastNameInArabic[0] = value;
        break;

      case EmployeeDataItems.email:
        employee.email[0] = valueLower;
        break;

      case EmployeeDataItems.mobileCountryCode:
        // Handled in mobileNumber case
        break;

      case EmployeeDataItems.mobileNumber:
        // Was wrapped in try/catch (forbidden under `domain/`, §11.2). The only
        // thing that could throw was the country-code index on a short row, so
        // the bounds check replaces the catch and the empty-MobilePhone
        // fallback is preserved.
        final int codeIndex = EmployeeDataItems.mobileCountryCode.index;
        if (codeIndex < 0 || codeIndex >= data.length) {
          employee.mobilePhone[0] = MobilePhone();
          break;
        }

        final String countryCode = data[codeIndex]?.toString().trim() ?? '';
        final int nowMillis = DateTime.now().millisecondsSinceEpoch;
        employee.mobilePhone[0] = MobilePhone(
          phones: [value],
          countryCode: [countryCode],
          countryApp: [
            CsvIdConstants.countryDialCodeMap['+$countryCode'] ?? ''
          ],
          timestamps: [Timestamp.fromMillisecondsSinceEpoch(nowMillis)],
        );
        break;

      case EmployeeDataItems.officeCountryCode:
        // Handled in officeNumber case
        break;

      case EmployeeDataItems.officeNumber:
        employee.officePhone[0] = value;
        break;

      case EmployeeDataItems.homeCountryCode:
        // Handled in homeNumber case
        break;

      case EmployeeDataItems.homeNumber:
        employee.homePhone[0] = value;
        break;

      case EmployeeDataItems.extension:
        employee.extension[0] = value;
        break;

      case EmployeeDataItems.gender:
        employee.gender[0] = valueLower;
        break;

      case EmployeeDataItems.country:
        if (value.isNotEmpty) {
          employee.country[0] = valueLower;
        }
        break;

      case EmployeeDataItems.province:
        if (value.isNotEmpty) {
          employee.province[0] = valueLower;
        }
        break;

      case EmployeeDataItems.city:
        if (value.isNotEmpty) {
          employee.city[0] = valueLower;
        }
        break;

      case EmployeeDataItems.postalCode:
        if (value.isNotEmpty) {
          employee.postalCode[0] = value;
        }
        break;

      case EmployeeDataItems.street:
        if (value.isNotEmpty) {
          employee.street[0] = value;
        }
        break;

      case EmployeeDataItems.language:
        if (value.isNotEmpty) {
          employee.language[0] = valueLower;
        }
        break;

      case EmployeeDataItems.departmentId:
        employee.departmentId[0] = valueLower;
        break;

      case EmployeeDataItems.departmentEnglishName:
        if (isWrongEmployee && employee is WrongEmployeeModel) {
          employee.departmentEnglishName = SingleValueTrackingModel<String>(
            values: [valueLower],
            timestamps: [Timestamp.now()],
          );
        }
        break;

      case EmployeeDataItems.departmentArabicName:
        if (isWrongEmployee && employee is WrongEmployeeModel) {
          employee.departmentArabicName = SingleValueTrackingModel<String>(
            values: [value],
            timestamps: [Timestamp.now()],
          );
        }
        break;

      case EmployeeDataItems.supervisorEmail:
        employee.supervisor[0] = valueLower;
        break;

      case EmployeeDataItems.role:
        employee.role[0] = valueLower;
        break;

      case EmployeeDataItems.englishTitle:
        employee.title[0] = valueLower;
        break;

      case EmployeeDataItems.arabicTitle:
        employee.titleInArabic[0] = value;
        break;

      case EmployeeDataItems.workLocation:
        if (value.isNotEmpty) {
          employee.workLocation[0] = valueLower;
        }
        break;
    }
  }

  /// ✅ UPDATED: Works with NewEmployeeModelHistory (array-based fields) with MobilePhone integration
  /// The `required MainCoreDepartmentCubit departments` parameter was replaced
  /// on 12/8/2026 by [departmentName], a plain callback. The two department
  /// cases below do need the lookup, but taking the cubit itself made a
  /// `domain/` file import a presentation type (§3). The caller closes over its
  /// cubit and passes a function.
  ///
  /// Parameters:
  /// - [row]: The CSV row being filled, mutated in place.
  /// - [employee]: The source record.
  /// - [departmentName]: Resolves a department id to its display name;
  ///   `arabic` selects the language.
  /// - [isWrongEmployee]: Reads from the invalid-row model instead.
  void getRowDataFromModelItem({
    required List<dynamic> row,
    required NewEmployeeModelHistory employee,
    required String Function(String departmentId, {required bool arabic})
        departmentName,
    bool isWrongEmployee = false,
  }) {
    switch (this) {
      case EmployeeDataItems.id:
        row[index] = employee.id;

      case EmployeeDataItems.firstName:
        row[index] = employee.getCurrentValue('firstName');

      case EmployeeDataItems.middleName:
        row[index] = employee.getCurrentValue('middleName');

      case EmployeeDataItems.lastName:
        row[index] = employee.getCurrentValue('lastName');

      case EmployeeDataItems.firstNameArabic:
        row[index] = employee.getCurrentValue('firstNameInArabic');

      case EmployeeDataItems.middleNameArabic:
        row[index] = employee.getCurrentValue('middleNameInArabic');

      case EmployeeDataItems.lastNameArabic:
        row[index] = employee.getCurrentValue('lastNameInArabic');

      case EmployeeDataItems.email:
        row[index] = employee.getCurrentValue('email');

      case EmployeeDataItems.mobileCountryCode:
        final mobilePhone =
            employee.getCurrentValue('mobilePhone') as MobilePhone?;
        if (mobilePhone != null &&
            mobilePhone.countryCode != null &&
            mobilePhone.countryCode!.isNotEmpty) {
          row[index] = mobilePhone.countryCode!.last.replaceAll('+', '');
        } else {
          row[index] = '';
        }

      case EmployeeDataItems.mobileNumber:
        final mobilePhone =
            employee.getCurrentValue('mobilePhone') as MobilePhone?;
        if (mobilePhone != null &&
            mobilePhone.phones != null &&
            mobilePhone.phones!.isNotEmpty) {
          row[index] = mobilePhone.phones!.last;
        } else {
          row[index] = '';
        }

      case EmployeeDataItems.homeCountryCode:
        row[index] = ''; // Need to implement if stored

      case EmployeeDataItems.homeNumber:
        row[index] = employee.getCurrentValue('homePhone');

      case EmployeeDataItems.officeCountryCode:
        row[index] = ''; // Need to implement if stored

      case EmployeeDataItems.officeNumber:
        row[index] = employee.getCurrentValue('officePhone');

      case EmployeeDataItems.extension:
        row[index] = employee.getCurrentValue('extension');

      case EmployeeDataItems.gender:
        row[index] = employee.getCurrentValue('gender');

      case EmployeeDataItems.country:
        row[index] = employee.getCurrentValue('country');

      case EmployeeDataItems.province:
        row[index] = employee.getCurrentValue('province');

      case EmployeeDataItems.city:
        row[index] = employee.getCurrentValue('city');

      case EmployeeDataItems.postalCode:
        row[index] = employee.getCurrentValue('postalCode');

      case EmployeeDataItems.street:
        row[index] = employee.getCurrentValue('street');

      case EmployeeDataItems.language:
        row[index] = employee.getCurrentValue('language');

      case EmployeeDataItems.departmentId:
        row[index] = employee.getCurrentValue('departmentId');

      case EmployeeDataItems.departmentEnglishName:
        if (row[EmployeeDataItems.departmentId.index].toString().isNotEmpty) {
          if (isWrongEmployee && employee is WrongEmployeeModel) {
            row[index] = employee.departmentEnglishName?.values.last ?? '';
          } else {
            row[index] = departmentName(
                row[EmployeeDataItems.departmentId.index].toString(),
                arabic: false);
          }
        }

      case EmployeeDataItems.departmentArabicName:
        if (isWrongEmployee && employee is WrongEmployeeModel) {
          row[index] = employee.departmentArabicName?.values.last ?? '';
        } else {
          if (row[EmployeeDataItems.departmentId.index].toString().isNotEmpty) {
            row[index] = departmentName(
                row[EmployeeDataItems.departmentId.index].toString(),
                arabic: true);
          }
        }

      case EmployeeDataItems.supervisorEmail:
        row[index] = employee.getCurrentValue('supervisor');

      case EmployeeDataItems.role:
        row[index] = employee.getCurrentValue('role');

      case EmployeeDataItems.englishTitle:
        row[index] = employee.getCurrentValue('title');

      case EmployeeDataItems.arabicTitle:
        row[index] = employee.getCurrentValue('titleInArabic');

      case EmployeeDataItems.workLocation:
        row[index] = employee.getCurrentValue('workLocation');

      default:
    }
  }

  /// ✅ UPDATED: Uses copyWithUpdateSynchronized for all field updates
  NewEmployeeModelHistory editModelItem({
    required NewEmployeeModelHistory employee,
    required List<String?> row,
    bool isWrongEmployee = false,
  }) {
    String? newValue = row[index];
    int now = DateTime.now().millisecondsSinceEpoch;

    switch (this) {
      case EmployeeDataItems.firstName:
        return employee.copyWithUpdateSynchronized(
          firstName: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.middleName:
        return employee.copyWithUpdateSynchronized(
          middleName: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.lastName:
        return employee.copyWithUpdateSynchronized(
          lastName: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.firstNameArabic:
        return employee.copyWithUpdateSynchronized(
          firstNameInArabic: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.middleNameArabic:
        return employee.copyWithUpdateSynchronized(
          middleNameInArabic: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.lastNameArabic:
        return employee.copyWithUpdateSynchronized(
          lastNameInArabic: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.email:
        return employee.copyWithUpdateSynchronized(
          email: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.mobileNumber:
        final countryCode =
            row[EmployeeDataItems.mobileCountryCode.index] ?? '';

        final updatedMobilePhone = MobilePhone(
          phones: [newValue ?? ''],
          countryCode: [countryCode],
          countryApp: [
            CsvIdConstants.countryDialCodeMap['+$countryCode'] ?? ''
          ],
          timestamps: [Timestamp.fromMillisecondsSinceEpoch(now)],
        );

        return employee.copyWithUpdateSynchronized(
          mobilePhone: updatedMobilePhone,
          addTimestamp: now,
        );

      case EmployeeDataItems.homeNumber:
        return employee.copyWithUpdateSynchronized(
          homePhone: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.officeNumber:
        return employee.copyWithUpdateSynchronized(
          officePhone: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.extension:
        return employee.copyWithUpdateSynchronized(
          extension: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.gender:
        return employee.copyWithUpdateSynchronized(
          gender: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.country:
        return employee.copyWithUpdateSynchronized(
          country: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.province:
        return employee.copyWithUpdateSynchronized(
          province: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.city:
        return employee.copyWithUpdateSynchronized(
          city: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.postalCode:
        return employee.copyWithUpdateSynchronized(
          postalCode: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.street:
        return employee.copyWithUpdateSynchronized(
          street: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.language:
        return employee.copyWithUpdateSynchronized(
          language: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.departmentId:
        return employee.copyWithUpdateSynchronized(
          departmentId: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.supervisorEmail:
        return employee.copyWithUpdateSynchronized(
          supervisor: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.role:
        return employee.copyWithUpdateSynchronized(
          role: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.englishTitle:
        return employee.copyWithUpdateSynchronized(
          title: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.arabicTitle:
        return employee.copyWithUpdateSynchronized(
          titleInArabic: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.workLocation:
        return employee.copyWithUpdateSynchronized(
          workLocation: newValue ?? '',
          addTimestamp: now,
        );

      case EmployeeDataItems.departmentEnglishName:
        if (isWrongEmployee && employee is WrongEmployeeModel) {
          if (employee.departmentEnglishName == null) {
            employee.departmentEnglishName = SingleValueTrackingModel<String>(
              values: [newValue ?? ''],
              timestamps: [Timestamp.now()],
            );
          } else {
            employee.departmentEnglishName!.values.add(newValue ?? '');
            employee.departmentEnglishName!.timestamps.add(Timestamp.now());
          }
        }
        return employee;

      case EmployeeDataItems.departmentArabicName:
        if (isWrongEmployee && employee is WrongEmployeeModel) {
          if (employee.departmentArabicName == null) {
            employee.departmentArabicName = SingleValueTrackingModel<String>(
              values: [newValue ?? ''],
              timestamps: [Timestamp.now()],
            );
          } else {
            employee.departmentArabicName!.values.add(newValue ?? '');
            employee.departmentArabicName!.timestamps.add(Timestamp.now());
          }
        }
        return employee;

      default:
        return employee;
    }
  }
}
