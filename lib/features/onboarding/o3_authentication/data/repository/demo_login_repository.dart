/// ************************* FILE INFO ************************* ///
/// File Name: demo_login_repository.dart
/// Purpose: Contains the repository for demo login feature.
/// Author: Amr Mesbah
/// Created At: 4/1/2025
/// Updated: Migrated to NewEmployeeModelHistory model
/// ✅ UPDATED: Added case-insensitive email handling

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/data_source/remote_data_source.dart' hide Right;
import 'package:grc_module/features/onboarding/o3_authentication/data/models/demo_company_model.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/models/demo_user_account_overview.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/repository/demo_initialiazation_repository.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/success_authentication_type.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/constants.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_access_model.dart';

import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/approval_status.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/failure_authentication_type.dart';

class DemoLoginRepository {
  DemoRemoteDataSource demoRemoteDataSource = DemoRemoteDataSource();

  /// Persists a new password chosen on the first-login reset screen.
  ///
  /// Two writes are required, and BOTH matter:
  ///  1. `Employees_Info/{id}.Password` — this is what [validateActiveAccount]
  ///     compares against (`employeeModel.password ?? employeeModel.defaultPassword`).
  ///  2. `Demo_Users_Accounts/{email}.Is_Activated` — [loginWithEmailAndPassword]
  ///     branches on this flag. While it stays false every login is routed to
  ///     [validateInactiveAccount], which only ever accepts the company's
  ///     temporary password, so the new password would appear to "not work".
  ///
  /// Returns the failure from whichever write fails first.
  Future<Either<Failure, void>> updateEmployeePassword({
    required NewEmployeeModelHistory employee,
    required String newPassword,
  }) async {
    try {
      final String? employeeId = employee.id;
      final String? email = employee.email.lastOrNull?.trim().toLowerCase();

      if (employeeId == null || employeeId.isEmpty) {
        return Left(FirebaseFailure('Employee id is missing.'));
      }
      if (email == null || email.isEmpty) {
        return Left(FirebaseFailure('Employee email is missing.'));
      }

      final String employeesPath = ApiConstants.baseUri.isNotEmpty
          ? '${ApiConstants.baseUri}/${ApiConstants.employeeInfo}'
          : ApiConstants.employeeInfo;

      final DateTime now = DateTime.now();
      final String nowLabel = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // 1 — the credential itself
      await FirebaseFirestore.instance
          .collection(employeesPath)
          .doc(employeeId)
          .update({
        'Password': newPassword,
        'First_Login': nowLabel,
        'Activation_Date': nowLabel,
      });

      // 2 — flip the account out of the "inactive / temporary password" branch
      await FirebaseFirestore.instance
          .collection(ApiConstants.demoUsersAccounts)
          .doc(email)
          .update({
        DemoUserAccountOverview.isActivatedField: true,
        DemoUserAccountOverview.demoActivatedField: Timestamp.fromDate(now),
      });

      return Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }


  /// function name: loginWithEmailAndPassword
  /// function purpose: login with email and password and check if the account is active or inactive.
  /// ✅ UPDATED: Added case-insensitive email handling
  /// return type: Future<Either<Failure, dynamic>> - Either of Failure class contains error message or data.
  loginWithEmailAndPassword({
    required String email,
    required String password
  }) async
  {
    // ✅ Normalize email to lowercase for case-insensitive comparison
    String normalizedEmail = email.trim().toLowerCase();
    print("🔍 Original email: $email");
    print("🔍 Normalized email: $normalizedEmail");

    Either<Failure, dynamic> result = await _checkIfAccountExists(email: normalizedEmail);
    if (result.isLeft()) return result;

    DemoUserAccountOverview accountOverview = result.getOrElse(() => null);

    result = await _getValidCompanyDemoRequest(companyId: accountOverview.companyId);
    if (result.isLeft()) return result;

    DemoCompanyModel companyModel = result.getOrElse(() => null);

    result = await checkNumberOfUsersIsValid(companyModel, normalizedEmail);
    if (result.isLeft()) return result;

    Map<String, dynamic> successAuthenticationData = {};

    if (accountOverview.isActivated) {
      result = await validateActiveAccount(
          companyModel: companyModel,
          accountOverview: accountOverview,
          password: password);
      if (result.isLeft()) return result;

      NewEmployeeModelHistory employeeModel = result.getOrElse(() => null);

      successAuthenticationData[AuthenticationConstants.successTypeKey] =
          _checkEmployeeStatus(employee: employeeModel);
      successAuthenticationData[AuthenticationConstants.successData] =
          employeeModel;
      result = Right(successAuthenticationData);
    } else {
      result = await validateInactiveAccount(
          companyModel: companyModel,
          accountOverview: accountOverview,
          password: password);
      if (result.isLeft()) return result;

      successAuthenticationData[AuthenticationConstants.successTypeKey] =
          SuccessAuthenticationType.inactive;
      successAuthenticationData[AuthenticationConstants.successData] =
          result.getOrElse(() => null);
      result = Right(successAuthenticationData);
    }
    return result;
  }

  /// function name: _checkIfAccountExists
  /// function purpose: check if the account exists in the database.
  /// ✅ UPDATED: Email is already normalized by caller
  /// return type: Future<Either<Failure, dynamic>> - Either of Failure class contains error message or data.
  /// parameters: email - String - the email of the account (already normalized to lowercase).
  _checkIfAccountExists({required String email}) async {
    Either<Failure, dynamic> result =
    await demoRemoteDataSource.getDemoAccountOverview(email: email);

    if (result.isLeft()) return result;

    Map<String, dynamic>? accountOverview = result.getOrElse(() => null);
    print("accountOverview is $accountOverview");

    // ✅ Specific error for email not found
    if (accountOverview == null) {
      print("❌ Email not found in system: $email");
      return Left(
          FirebaseFailure(FailureAuthenticationType.emailNotFound.dialogBoxMessage));
    }

    DemoUserAccountOverview demo =
    DemoUserAccountOverview.fromMap(accountOverview);
    ApiConstants.baseUri = "Demo/${demo.companyId}";

    return result = Right(DemoUserAccountOverview.fromMap(accountOverview));
  }

  /// function name: _getValidCompanyDemoRequest
  /// function purpose: get the company demo request from the database.
  /// parameters:
  ///            companyId - String - the name of the company.
  /// return type:
  ///             Future<Either<Failure, dynamic>> - Either of Failure class contains error message or data.
  _getValidCompanyDemoRequest({required String companyId}) async {
    Either<Failure, dynamic> result =
    await demoRemoteDataSource.getCompanyDemoRequest(companyId: companyId);

    if (result.isLeft()) return result;

    Map<String, dynamic> demoRequest = result.getOrElse(() => null);
    DemoCompanyModel companyModel = DemoCompanyModel.fromMap(demoRequest);

    result = await _checkIfDemoIsApprovedAndInDuration(companyModel: companyModel);
    if (result.isLeft()) return result;

    return result = Right(companyModel);
  }

  /// function name: _checkIfDemoIsApprovedAndInDuration
  /// function purpose: check if the demo is approved and in duration.
  /// parameters:
  ///            companyModel - CompanyModel - the company model to get values to check.
  /// return type:
  ///            Either<Failure, dynamic> - Either of Failure class contains error message or data.
  _checkIfDemoIsApprovedAndInDuration({
    required DemoCompanyModel companyModel
  }) {
    Either<Failure, dynamic> result;
    bool isValidDemo = true;

    isValidDemo &= companyModel.requestStatus == ApprovalStatus.approved;
    if (!isValidDemo) {
      if (companyModel.requestStatus == ApprovalStatus.canceled) {
        return result = Left(FirebaseFailure(
            FailureAuthenticationType.demoCancelled.dialogBoxMessage));
      }
      return result = Left(FirebaseFailure(
          FailureAuthenticationType.subscriptionError.dialogBoxMessage));
    }

    isValidDemo &= companyModel.demoDetails!.accessBegin!.values.last
        .toDate()
        .isBefore(DateTime.now());
    if (!isValidDemo) {
      print("print error before activation date");
      return result = Left(FirebaseFailure(
          FailureAuthenticationType.beforActivationDate.dialogBoxMessage));
    }

    isValidDemo &= companyModel.demoDetails!.accessEnd!.values.last
        .toDate()
        .isAfter(DateTime.now());

    if (!isValidDemo) {
      return result = Left(FirebaseFailure(
          FailureAuthenticationType.subscriptionExpired.dialogBoxMessage));
    }

    return result = Right(companyModel);
  }

  /// function name: validateInactiveAccount
  /// function purpose: validate the inactive account password and if it is the default password,
  ///                    start the demo if is demo admin admin data or get employee model of normal user.
  /// ✅ UPDATED: Specific error messages for wrong activation password and missing employee
  /// parameters:
  ///            companyModel - CompanyModel - the company model to get values to check.
  ///            password - String - the password to check.
  ///            accountOverview - DemoUserAccountOverview - the account overview to get the email.
  Future<Either<Failure, dynamic>> validateInactiveAccount({
    required DemoCompanyModel companyModel,
    required String password,
    required DemoUserAccountOverview accountOverview
  }) async {
    print("🔍 validateInactiveAccount called");
    print("🔍 Email: ${accountOverview.email}");
    print("🔍 Company admin: ${companyModel.contactInformation.email.values.last}");

    // ✅ Specific error for wrong activation password
    if (password != companyModel.demoDetails!.temporaryPassword!.values.last) {
      print("❌ Wrong activation password");
      return Left(FirebaseFailure(
          FailureAuthenticationType.wrongActivationPassword.dialogBoxMessage));
    } else {
      // ✅ CRITICAL: Compare normalized emails (both should be lowercase)
      String normalizedAccountEmail = accountOverview.email.toLowerCase();
      String normalizedCompanyEmail = companyModel.contactInformation.email.values.last.toLowerCase();

      if (normalizedAccountEmail == normalizedCompanyEmail) {
        // Demo admin - validate structure exists
        print("✅ Demo admin detected - validating structure...");
        return await DemoInitializationRepository()
            .startDemoAdminData(companyModel: companyModel);
      } else {
        // Regular user - get existing employee
        print("✅ Regular user - fetching employee data...");
        Either<Failure, dynamic> result = await demoRemoteDataSource
            .getEmployeeAccount(email: accountOverview.email);
        if (result.isLeft()) return result;

        List<Map<String, dynamic>> employeeAccount = result.getOrElse(() => null);

        // ✅ Specific error for employee not found in company database
        if (employeeAccount.isEmpty) {
          print("❌ Employee not found in company database");
          return Left(FirebaseFailure(
              FailureAuthenticationType.notFoundInCompanyDatabase.dialogBoxMessage));
        }

        return result = Right(NewEmployeeModelHistory.fromMap(employeeAccount.first));
      }
    }
  }

  /// function name: validateActiveAccount
  /// purpose: validate if password is correct and validate if the employee have permission to access the system.
  /// ✅ UPDATED: Specific error messages for wrong password and missing employee
  /// parameters:
  ///            companyModel - CompanyModel - the company model to get values to check.
  ///            accountOverview - DemoUserAccountOverview - the account overview to get the email.
  ///            password - String - the password to check.
  Future<Either<Failure, dynamic>> validateActiveAccount({
    required DemoCompanyModel companyModel,
    required DemoUserAccountOverview accountOverview,
    required String password
  }) async {
    Either<Failure, dynamic> result = await demoRemoteDataSource
        .getEmployeeAccount(email: accountOverview.email);

    if (result.isLeft()) return result;

    List<Map<String, dynamic>> employeeAccount = result.getOrElse(() => null);

    // ✅ Specific error for employee not found in company database
    if (employeeAccount.isEmpty) {
      print("❌ Employee not found in company database");
      return Left(FirebaseFailure(FailureAuthenticationType
          .notFoundInCompanyDatabase.dialogBoxMessage));
    }

    NewEmployeeModelHistory employeeModel =
    NewEmployeeModelHistory.fromMap(employeeAccount.first);

    print("🔍 Employee found: ${employeeModel.email.lastOrNull}");
    print("🔍 Checking password...");

    String? storedPassword = employeeModel.password ?? employeeModel.defaultPassword;

    print("🔍 Stored password exists: ${storedPassword != null}");
    print("🔍 Password length: ${storedPassword?.length ?? 0}");
    print("🔍 Input password length: ${password.length}");

    if (storedPassword == null || storedPassword.isEmpty) {
      print("⚠️ No password stored for employee, checking default password...");
      storedPassword = companyModel.demoDetails!.temporaryPassword!.values.last;
    }

    // ✅ Specific error for wrong password
    if (storedPassword != password) {
      print("🔴 Password mismatch!");
      return Left(FirebaseFailure(
          FailureAuthenticationType.wrongPassword.dialogBoxMessage));
    }

    print("✅ Password matches!");
    print("🔍 Checking employee permissions...");

    result = await _checkEmployeePermission(employeeModel: employeeModel);
    if (result.isLeft()) return result;

    print("✅ Employee validated successfully!");

    return Right(employeeModel);
  }

  /// function name: _checkEmployeePermission
  /// function purpose: check if the employee have permission to access the system.
  /// parameters:
  ///            employeeModel - NewEmployeeModelHistory - the employee model to get values to check.
  /// return type:
  ///             Either<Failure, dynamic> - Either of Failure class contains error message or data.
  /// ✅ UPDATED: Handles correct field names (From_Date/To_Date) and active status bypass
  Future<Either<Failure, dynamic>> _checkEmployeePermission({
    required NewEmployeeModelHistory employeeModel
  }) async {
    print("🔍 _checkEmployeePermission called for employee ID: ${employeeModel.id}");

    // ✅ Skip permission check for company 84763782
    if (ApiConstants.baseUri.contains("84763782")) {
      print("✅ Skipping permission check for company 84763782");
      return Right<Failure, dynamic>(null);
    }

    // ✅ Get employee role and status
    String currentRole = employeeModel.role.isNotEmpty
        ? employeeModel.role.last
        : '';

    String currentStatus = employeeModel.status.isNotEmpty
        ? employeeModel.status.last
        : '';

    print("🔍 Employee role: $currentRole");
    print("🔍 Employee status: $currentStatus");

    // ✅ Master Admin - always allow
    if (currentRole.toLowerCase() == 'master admin') {
      print("✅ Master Admin - access granted");
      return Right<Failure, dynamic>(null);
    }

    // ✅ Check employee status - if not active, deny immediately
    if (currentStatus.toLowerCase() != 'active') {
      print("❌ Employee status is not active: $currentStatus");
      return Left(FirebaseFailure(
          FailureAuthenticationType.dontHavePermission.dialogBoxMessage));
    }

    // ✅ For active employees, check permission record (optional)
    print("🔍 Employee is active, checking permission record...");

    Either<Failure, dynamic> result = await demoRemoteDataSource
        .getEmployeePermission(employeeId: employeeModel.id!);

    if (result.isLeft()) {
      print("❌ Error fetching permission record");
      return result;
    }

    Map<String, dynamic>? employeePermission = result.getOrElse(() => null);

    // ✅ If no permission record exists, allow access for active employees
    if (employeePermission == null) {
      print("ℹ️ No permission record found - allowing access for active employee");
      return Right<Failure, dynamic>(null);
    }

    print("✅ Permission record found, validating dates...");
    print("   Permission data keys: ${employeePermission.keys.toList()}");

    try {
      // ✅ Extract dates from the correct field names (From_Date/To_Date)
      Map<String, dynamic>? fromDateMap = employeePermission['From_Date'];
      Map<String, dynamic>? toDateMap = employeePermission['To_Date'];

      if (fromDateMap == null || toDateMap == null) {
        print("⚠️ Missing From_Date or To_Date fields");
        print("   From_Date: ${fromDateMap != null ? 'exists' : 'missing'}");
        print("   To_Date: ${toDateMap != null ? 'exists' : 'missing'}");
        // If dates are missing but employee is active, allow access
        return Right<Failure, dynamic>(null);
      }

      // ✅ Get the last value from the Values array
      List<dynamic>? fromValues = fromDateMap['Values'];
      List<dynamic>? toValues = toDateMap['Values'];

      if (fromValues == null || fromValues.isEmpty ||
          toValues == null || toValues.isEmpty) {
        print("⚠️ Empty Values arrays in date fields");
        // If date values are empty but employee is active, allow access
        return Right<Failure, dynamic>(null);
      }

      String fromDateStr = fromValues.last.toString();
      String toDateStr = toValues.last.toString();

      print("🔍 From date string: $fromDateStr");
      print("🔍 To date string: $toDateStr");

      // ✅ Parse dates using the format in your database
      DateTime from;
      DateTime to;

      try {
        DateFormat dateFormat = DateFormat("MMM dd, yyyy", 'en');
        from = dateFormat.parse(fromDateStr);
        to = dateFormat.parse(toDateStr);
      } catch (e) {
        print("⚠️ Error parsing dates with English format: $e");
        try {
          DateFormat dateFormat = DateFormat("MMM dd, yyyy", 'ar');
          from = dateFormat.parse(fromDateStr);
          to = dateFormat.parse(toDateStr);
        } catch (e2) {
          print("⚠️ Error parsing dates with Arabic format: $e2");
          // If can't parse dates but employee is active, allow access
          return Right<Failure, dynamic>(null);
        }
      }

      // The "to" date is inclusive: access is valid through the END of that
      // day, not from its midnight. Without this, permission expires at
      // 00:00 on the last day, denying access for the entire final day.
      to = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);

      DateTime now = DateTime.now();
      print("🔍 Current date: $now");
      print("🔍 Permission valid from: $from");
      print("🔍 Permission valid to (inclusive end-of-day): $to");

      // ✅ Validate permission date range
      bool isFromValid = from.isBefore(now) || from.isAtSameMomentAs(now);
      bool isToValid = to.isAfter(now) || to.isAtSameMomentAs(now);

      print("🔍 From date valid (before/same as now): $isFromValid");
      print("🔍 To date valid (after/same as now): $isToValid");

      if (!isFromValid || !isToValid) {
        print("❌ Permission date range invalid - access denied");
        return Left(FirebaseFailure(
            FailureAuthenticationType.dontHavePermission.dialogBoxMessage));
      }

      print("✅ Permission dates are valid - access granted");
      return Right<Failure, dynamic>(employeePermission);

    } catch (e, stackTrace) {
      print("❌ Error processing permission dates: $e");
      print("❌ Stack trace: $stackTrace");
      // If there's an error but employee is active, allow access
      print("ℹ️ Error processing dates - allowing access for active employee");
      return Right<Failure, dynamic>(null);
    }
  }

  /// function name: _checkEmployeeStatus
  /// function purpose: check the employee status and return the type of success authentication.
  /// parameters:
  ///             employee - NewEmployeeModelHistory - the employee model to get values to check.
  /// return type:
  ///             SuccessAuthenticationType - the type of authentication.
  /// ✅ UPDATED: Uses NewEmployeeModelHistory with array-based status
  SuccessAuthenticationType _checkEmployeeStatus({
    required NewEmployeeModelHistory employee
  }) {
    // ✅ Get last status from array (current status)
    String currentStatus = employee.status.isNotEmpty
        ? employee.status.last
        : 'active';

    // ✅ Find matching enum with safe fallback
    EmployeeStatusEnum status = EmployeeStatusEnum.values.firstWhere(
            (element) => element.name == currentStatus,
        orElse: () => EmployeeStatusEnum.active
    );

    // Map status to authentication type
    if (status == EmployeeStatusEnum.resetPassword) {
      return SuccessAuthenticationType.resetPassword;
    } else if (status == EmployeeStatusEnum.lockedWithRequest) {
      return SuccessAuthenticationType.lockedWithRequest;
    } else if (status == EmployeeStatusEnum.locked) {
      return SuccessAuthenticationType.locked;
    } else if (status == EmployeeStatusEnum.inactive) {
      return SuccessAuthenticationType.inactive;
    } else if (status == EmployeeStatusEnum.deactivated) {
      return SuccessAuthenticationType.deactivated;
    } else {
      return SuccessAuthenticationType.login;
    }
  }

  /// function name: getEmployee
  /// function purpose: get employee by email
  /// parameters: email - String - the employee email
  /// return type: Future<Either<Failure, dynamic>>
  getEmployee({required String email}) async {
    return await demoRemoteDataSource.getEmployeeAccount(email: email);
  }

  /// function name: checkNumberOfUsersIsValid
  /// function purpose: validate that the number of active users doesn't exceed the demo limit
  /// parameters:
  ///            companyModel - DemoCompanyModel - company configuration
  ///            email - String - user email to check
  /// return type: Future<Either<Failure, dynamic>>
  checkNumberOfUsersIsValid(DemoCompanyModel companyModel, String email) async {
    print("entered checkNumberOfUsersIsValid with email: $email");
    Either<Failure, dynamic> result;

    // ✅ CRITICAL: Compare normalized emails (both should be lowercase)
    String normalizedEmail = email.toLowerCase();
    String normalizedCompanyEmail = companyModel.contactInformation.email.values.last.toLowerCase();

    // Skip validation for demo admin (company contact)
    if (normalizedEmail == normalizedCompanyEmail) {
      return result = Right(null);
    }

    print("Validating user limit for: $email");

    // Get actual number of users in the company
    result = await demoRemoteDataSource.getCompanyActualNumberOfUsers(
        companyId: companyModel.requestId);
    if (result.isLeft()) return result;

    int actualNumberOfUsers = result.getOrElse(() => 0);
    int allowedUsers = companyModel.demoDetails!.numberOfUsers!.values.last;

    print("actualNumberOfUsers: $actualNumberOfUsers, allowedUsers: $allowedUsers");

    // Check if we've exceeded the user limit
    if (actualNumberOfUsers > allowedUsers) {
      return result = Left(FirebaseFailure(
          FailureAuthenticationType.tooManyUsers.dialogBoxMessage));
    }

    return result = Right(null);
  }
}