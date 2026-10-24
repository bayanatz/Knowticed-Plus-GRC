/// Module: roles/r4_active_directory
///
///*************************** FILE INFO ****************************///
/// File Name: employee_data_function_methods.dart
/// Description: Methods of `EmployeeDataItems` — split out of `employee_data_functions.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../employee_data_functions.dart';

// Split from employee_data_functions.dart to keep every file under 700 lines.

extension EmployeeDataFunctionMethods2 on EmployeeDataItems {
  /// ✅ UPDATED: Works with NewEmployeeModelHistory (array-based fields) with MobilePhone integration
  dynamic getItemModelDataFromDataRow({
    required NewEmployeeModelHistory employee,
    required List<dynamic> data,
    bool isWrongEmployee = false,
  }) {
    int now = DateTime.now().millisecondsSinceEpoch;
    String trimmedValue = data[index].toString().trim();
    String trimmedLowerValue = trimmedValue.toLowerCase();
    bool isNotEmpty = trimmedValue.isNotEmpty;

    switch (this) {
      case EmployeeDataItems.id:
        employee.id = trimmedValue;
        return employee;

      case EmployeeDataItems.firstName:
        return employee.copyWithUpdateSynchronized(
          firstName: trimmedLowerValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.middleName:
        return employee.copyWithUpdateSynchronized(
          middleName: trimmedLowerValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.lastName:
        return employee.copyWithUpdateSynchronized(
          lastName: trimmedLowerValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.firstNameArabic:
        return employee.copyWithUpdateSynchronized(
          firstNameInArabic: trimmedValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.middleNameArabic:
        return employee.copyWithUpdateSynchronized(
          middleNameInArabic: trimmedValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.lastNameArabic:
        return employee.copyWithUpdateSynchronized(
          lastNameInArabic: trimmedValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.email:
        return employee.copyWithUpdateSynchronized(
          email: trimmedLowerValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.mobileNumber:
        final MobilePhone mobilePhone = MobilePhone(
          phones: [trimmedValue],
          countryCode: [
            data[EmployeeDataItems.mobileCountryCode.index].toString().trim()
          ],
          countryApp: [
            CsvIdConstants.countryDialCodeMap[
                    '+${data[EmployeeDataItems.mobileCountryCode.index]}'] ??
                ''
          ],
          timestamps: [Timestamp.fromMillisecondsSinceEpoch(now)],
        );
        return employee.copyWithUpdateSynchronized(
          mobilePhone: mobilePhone,
          addTimestamp: now,
        );

      case EmployeeDataItems.homeNumber:
        return employee.copyWithUpdateSynchronized(
          homePhone: trimmedValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.officeNumber:
        return employee.copyWithUpdateSynchronized(
          officePhone: trimmedValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.extension:
        return employee.copyWithUpdateSynchronized(
          extension: trimmedValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.gender:
        return employee.copyWithUpdateSynchronized(
          gender: trimmedLowerValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.country:
        if (isNotEmpty) {
          return employee.copyWithUpdateSynchronized(
            country: trimmedLowerValue,
            addTimestamp: now,
          );
        }
        return employee;

      case EmployeeDataItems.province:
        if (isNotEmpty) {
          return employee.copyWithUpdateSynchronized(
            province: trimmedLowerValue,
            addTimestamp: now,
          );
        }
        return employee;

      case EmployeeDataItems.city:
        if (isNotEmpty) {
          return employee.copyWithUpdateSynchronized(
            city: trimmedLowerValue,
            addTimestamp: now,
          );
        }
        return employee;

      case EmployeeDataItems.postalCode:
        if (isNotEmpty) {
          return employee.copyWithUpdateSynchronized(
            postalCode: trimmedValue,
            addTimestamp: now,
          );
        }
        return employee;

      case EmployeeDataItems.street:
        if (isNotEmpty) {
          return employee.copyWithUpdateSynchronized(
            street: trimmedValue,
            addTimestamp: now,
          );
        }
        return employee;

      case EmployeeDataItems.language:
        if (isNotEmpty) {
          return employee.copyWithUpdateSynchronized(
            language: trimmedLowerValue,
            addTimestamp: now,
          );
        }
        return employee;

      case EmployeeDataItems.departmentId:
        return employee.copyWithUpdateSynchronized(
          departmentId: trimmedLowerValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.departmentEnglishName:
        if (isWrongEmployee && employee is WrongEmployeeModel) {
          employee.departmentEnglishName = SingleValueTrackingModel<String>(
            values: [trimmedLowerValue],
            timestamps: [Timestamp.now()],
          );
        }
        return employee;

      case EmployeeDataItems.departmentArabicName:
        if (isWrongEmployee && employee is WrongEmployeeModel) {
          employee.departmentArabicName = SingleValueTrackingModel<String>(
            values: [trimmedValue],
            timestamps: [Timestamp.now()],
          );
        }
        return employee;

      case EmployeeDataItems.supervisorEmail:
        return employee.copyWithUpdateSynchronized(
          supervisor: trimmedLowerValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.role:
        return employee.copyWithUpdateSynchronized(
          role: trimmedLowerValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.englishTitle:
        return employee.copyWithUpdateSynchronized(
          title: trimmedLowerValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.arabicTitle:
        return employee.copyWithUpdateSynchronized(
          titleInArabic: trimmedValue,
          addTimestamp: now,
        );

      case EmployeeDataItems.workLocation:
        if (isNotEmpty) {
          return employee.copyWithUpdateSynchronized(
            workLocation: trimmedLowerValue,
            addTimestamp: now,
          );
        }
        return employee;

      default:
        return employee;
    }
  }
}
