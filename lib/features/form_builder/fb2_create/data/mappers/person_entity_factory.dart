/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: person_entity_factory.dart
/// Description: Builds `PersonEntity` objects from employees, emails and
///              access lists (moved out of the domain entity).
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_directory.dart';
import 'package:knowticed_plus/features/form_builder/data/models/users_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Builds [PersonEntity] objects.
class PersonEntityFactory {
  const PersonEntityFactory._();

  /// Method Name: [fromEmployeeEntity]
  ///
  /// Purpose: maps an employee to a person. Null-safe (FB-HOME-16 /
  /// FB-SHARE-03 / FB-RESULT-01): a missing Arabic name, job title or
  /// department falls back to the other language or to ''.
  ///
  /// Parameters:
  /// - [employeeEntity]: the employee.
  ///
  /// Returns: the person.
  static PersonEntity fromEmployeeEntity(EmployeeEntityPro employeeEntity) {
    final String englishName =
        "${employeeEntity.firstName ?? ''} ${employeeEntity.lastName ?? ''}"
            .trim();
    final String arabicName =
        "${employeeEntity.firstNameInArabic ?? ''} ${employeeEntity.lastNameInArabic ?? ''}"
            .trim();
    final String titleEnglish = employeeEntity.title ?? '';
    final String titleArabic = employeeEntity.titleInArabic ?? '';
    final String departmentId = employeeEntity.departmentId ?? '';
    return PersonEntity(
      phone: (employeeEntity.mobilePhone?.countryCode ?? '') +
          (employeeEntity.mobilePhone?.phone ?? ''),
      department: departmentId,
      id: employeeEntity.email ?? '',
      isSelected: false,
      image: employeeEntity.photo ??
          (employeeEntity.gender == 'female'
              ? AppAssets.female
              : AppAssets.male),
      arabicName: arabicName.isEmpty ? englishName : arabicName,
      englishName: englishName.isEmpty ? arabicName : englishName,
      titleEnglish: titleEnglish.isEmpty ? titleArabic : titleEnglish,
      titleArabic: titleArabic.isEmpty ? titleEnglish : titleArabic,
      departmentNameEnglish:
          FormBuilderDirectory.departmentName(departmentId, english: true),
      departmentNameArabic:
          FormBuilderDirectory.departmentName(departmentId, english: false),
    );
  }

  /// Method Name: [unknown]
  ///
  /// Purpose: a placeholder for an email that is no longer in the employee
  /// list (someone who left, or an old typo). Used instead of throwing
  /// (FB-HOME-08 / FB-RESULT-01).
  ///
  /// Parameters:
  /// - [email]: the email that was not found.
  ///
  /// Returns: a "Former employee (email)" person.
  static PersonEntity unknown(String email) {
    final String label = '${S.current.formerEmployee} ($email)';
    return PersonEntity(
      phone: '',
      department: '',
      id: email,
      isSelected: false,
      image: AppAssets.male,
      arabicName: label,
      englishName: label,
      titleEnglish: '',
      titleArabic: '',
    );
  }

  /// Method Name: [fromEmail]
  ///
  /// Purpose: safe lookup by email.
  ///
  /// Parameters:
  /// - [email]: the employee's email.
  ///
  /// Returns: the person, or [unknown] when the email is not found.
  static PersonEntity fromEmail(String email) {
    final EmployeeEntityPro? employee =
        FormBuilderDirectory.employeeByEmail(email);
    return employee == null ? unknown(email) : fromEmployeeEntity(employee);
  }

  /// Method Name: [fromUsersModel]
  ///
  /// Purpose: the people on an access list. FB-HOME-06: every person is
  /// added (they used to be built and dropped).
  ///
  /// Parameters:
  /// - [userModel]: the stored access list.
  ///
  /// Returns: one person per non-empty email; `isSelected` is true when the
  /// matching status is "active" (or missing).
  static List<PersonEntity> fromUsersModel(UsersModel userModel) {
    final List<PersonEntity> persons = [];
    final List<String>? emails = userModel.emails;
    if (emails == null) return persons;
    for (int i = 0; i < emails.length; i++) {
      final String email = emails[i];
      if (email.isEmpty) continue;
      final PersonEntity personEntity = fromEmail(email);
      personEntity.isSelected =
          (userModel.status != null && i < userModel.status!.length)
              ? userModel.status![i] == 'active'
              : true;
      persons.add(personEntity);
    }
    return persons;
  }
}
