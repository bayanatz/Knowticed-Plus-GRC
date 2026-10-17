/// Module: roles/r2_user_management
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_controller_methods.dart
/// Description: Methods of `UserManagementController` — split out of `user_management_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../user_management_controller.dart';

// Split from user_management_controller.dart to keep every file under 700 lines.

extension UserManagementControllerMethods on UserManagementController {
  // ───────────────────────────────────────────────────────────────────────
  // REQUEST-DETAILS PRESENTATION LOGIC
  //
  // Moved out of umdr_methods1.dart (user_mangement_details_request page) so
  // that part file only builds widgets. Everything here is pure — no context,
  // no setState — which is why only these helpers moved; the rest of that file
  // drives widget state or shows dialogs and stays in the UI layer.
  // ───────────────────────────────────────────────────────────────────────

  /// Maps an incoming request field name onto the employee-model field path.
  String mapFieldName(String requestFieldName) {
    const fieldMappings = {
      'first_name': 'firstName',
      'middle_name': 'middleName',
      'last_name': 'lastName',
      'first_name_arabic': 'firstNameInArabic',
      'middle_name_arabic': 'middleNameInArabic',
      'last_name_arabic': 'lastNameInArabic',
      'email': 'email',
      'gender': 'gender',
      'date_of_birth': 'birthDay',
      'marital_status': 'maritalStatus',
      'street': 'street',
      'city': 'city',
      'province': 'province',
      'country': 'country',
      'postalCode': 'postalCode',
      'postal_code': 'postalCode',
      'phone': 'mobilePhone.phones',
      'Phone': 'mobilePhone.phones',
      'country_code': 'mobilePhone.countryCode',
      'Country_Code': 'mobilePhone.countryCode',
      'country_app': 'mobilePhone.countryApp',
      'Country_App': 'mobilePhone.countryApp',
      'insuranceName': 'insuranceName',
      'insurance_name': 'insuranceName',
      'Insurance_Name': 'insuranceName',
      'insurancePolicyNumber': 'insurancePolicyNumber',
      'insurance_policy_number': 'insurancePolicyNumber',
      'Insurance_Policy_Number': 'insurancePolicyNumber',
      'firstContactFirstName': 'firstContactFirstName',
      'firstContactLastName': 'firstContactLastName',
      'firstContactRelationship': 'firstContactRelationship',
      'firstContactEmail': 'firstContactEmail',
      'firstContactPhone': 'firstContactPhone',
      'secondContactFirstName': 'secondContactFirstName',
      'secondContactLastName': 'secondContactLastName',
      'secondContactRelationship': 'secondContactRelationship',
      'secondContactEmail': 'secondContactEmail',
      'secondContact_email': 'secondContactEmail',
      'secondContactPhone': 'secondContactPhone',
      // Address / language for both emergency contacts. These were missing,
      // so approving a request that touched them fell through to the raw key
      // and NewEmployeeModelHistory threw "Unknown field: secondContact_province".
      'firstContactLanguage': 'firstContactLanguage',
      'firstContactCountry': 'firstContactCountry',
      'firstContactProvince': 'firstContactProvince',
      'firstContactCity': 'firstContactCity',
      'firstContactStreet': 'firstContactStreet',
      'secondContactLanguage': 'secondContactLanguage',
      'secondContactCountry': 'secondContactCountry',
      'secondContactProvince': 'secondContactProvince',
      'secondContactCity': 'secondContactCity',
      'secondContactStreet': 'secondContactStreet',
    };

    final direct = fieldMappings[requestFieldName];
    if (direct != null) return direct;

    // The health-insurance screens write snake_case variants
    // (secondContact_province), the model uses camelCase
    // (secondContactProvince). Fold one into the other rather than listing
    // every spelling twice.
    final camel = _snakeToCamel(requestFieldName);
    return fieldMappings[camel] ?? camel;
  }

  /// Renders date-like values as `dd MMM yyyy`; other values pass through.
  String formatValueForDisplay(String value, String fieldName) {
    final bool isDateField = fieldName.toLowerCase().contains('date') ||
        fieldName.toLowerCase().contains('birth') ||
        fieldName.toLowerCase().contains('_of_');

    if (!isDateField) return value;

    try {
      DateTime? dateTime;
      if (value.contains('T')) {
        dateTime = DateTime.tryParse(value);
      } else if (value.contains('-') && value.split('-').length == 3) {
        dateTime = DateTime.tryParse(value);
      } else if (value.contains('/')) {
        final List<String> parts = value.split('/');
        if (parts.length == 3) {
          int month = int.tryParse(parts[0]) ?? 0;
          int day = int.tryParse(parts[1]) ?? 0;
          int year = int.tryParse(parts[2]) ?? 0;
          if (year < 100) year += (year <= 30) ? 2000 : 1900;
          if (month > 0 && day > 0 && year > 0) {
            dateTime = DateTime(year, month, day);
          }
        }
      } else if (int.tryParse(value) != null) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(value));
      }
      if (dateTime != null) return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (_) {}

    return value;
  }

  /// Method Name: [bulkAssignRole]
  ///
  /// Purpose: Assign role to multiple employees at once
  Future<void> bulkAssignRole({
    required List<String> employeeIds,
    required String roleName,
    required String startDate,
    required String endDate,
  }) async {
    List<NewEmployeeModelHistory>? allEmployees =
        AppControllers.employeeDirectory.allEmployees;

    if (allEmployees == null) {
      return;
    }

    for (String employeeId in employeeIds) {
      NewEmployeeModelHistory? employee = allEmployees.firstWhereOrNull(
        (emp) => emp.id == employeeId,
      );
      if (employee != null) {
        selectedMembersIds[employeeId] = employee;
      }
    }

    await addNewUsersPermissions(
      accessName: roleName,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Method Name: [getRoleFromHistory]
  ///
  /// Purpose: Get role details from RoleHistoryModel
  Map<String, dynamic>? getRoleFromHistory(String roleName) {
    if (_roleCubit == null) {
      return null;
    }

    RoleHistoryModel? role = _roleCubit!.roles.firstWhereOrNull(
      (r) => r.currentRoleName.toLowerCase() == roleName.toLowerCase(),
    );

    if (role == null) return null;

    return {
      'roleName': role.currentRoleName,
      'roleNameAr': role.currentRoleNameAr,
      'roleDescription': role.currentRoleDescription,
      'roleDescriptionAr': role.currentRoleDescriptionAr,
      'roleImage': role.currentRoleImage,
      'status': role.currentStatus.name,
      'createdAt': role.currentCreatedAt,
      'createdBy': role.currentCreatedBy,
      'modules': role.currentSelectedModules,
    };
  }

  /// Method Name: [compareRolePermissions]
  ///
  /// Purpose: Compare permissions between two roles_module
  Map<String, dynamic> compareRolePermissions(
    String roleNameA,
    String roleNameB,
  ) {
    if (_roleCubit == null) {
      return {'error': 'RoleCubit not set'};
    }

    RoleHistoryModel? roleA = _roleCubit!.roles.firstWhereOrNull(
      (r) => r.currentRoleName.toLowerCase() == roleNameA.toLowerCase(),
    );
    RoleHistoryModel? roleB = _roleCubit!.roles.firstWhereOrNull(
      (r) => r.currentRoleName.toLowerCase() == roleNameB.toLowerCase(),
    );

    if (roleA == null || roleB == null) {
      return {'error': 'One or both roles_module not found'};
    }

    return {
      'roleA': roleA.currentRoleName,
      'roleB': roleB.currentRoleName,
      'roleAModules': _getGrantedModules(roleA),
      'roleBModules': _getGrantedModules(roleB),
    };
  }

  /// Method Name: [getRoleDetails]
  ///
  /// Purpose: Get detailed information about a role
  Map<String, dynamic>? getRoleDetails(String roleName) {
    if (_roleCubit == null) {
      return null;
    }

    RoleHistoryModel? role = _roleCubit!.roles.firstWhereOrNull(
      (r) => r.currentRoleName.toLowerCase() == roleName.toLowerCase(),
    );

    if (role == null) return null;

    return {
      'roleName': role.currentRoleName,
      'roleNameAr': role.currentRoleNameAr,
      'description': role.currentRoleDescription,
      'descriptionAr': role.currentRoleDescriptionAr,
      'image': role.currentRoleImage,
      'status': role.currentStatus.name,
      'createdBy': role.currentCreatedBy,
      'createdAt': role.currentCreatedAt.toDate(),
      'grantedModules': _getGrantedModules(role),
      'userCount': searchUsersByRole(roleName).length,
    };
  }
}
