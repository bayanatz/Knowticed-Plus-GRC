/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: demo_login_repository.dart
/// Purpose: Validates a demo login and the account's access window.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Round 3 removed the `?? defaultPassword` acceptance and the `84763782`
///          authorization backdoor; this pass adds the header.
/// Updated: 29/8/2026 - First sign-in and post-unlock sign-in now require the
///          employee's own Default Password (the value shown in the Default
///          Password column of User Access). The company-wide temporary
///          password is accepted only for an account that has no default of its
///          own, and for the demo admin.

/// ************************* FILE INFO ************************* ///
/// File Name: demo_login_repository.dart
/// Purpose: Contains the repository for demo login feature.
/// Author: Amr Mesbah
/// Created At: 4/1/2025
/// Updated: Migrated to NewEmployeeModelHistory model
/// ✅ UPDATED: Added case-insensitive email handling

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/data_source/remote_data_source/demo_remote_data_source.dart' hide Right;
import 'package:grc_module/features/onboarding/o3_authentication/data/models/demo_company_model.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/models/demo_user_account_overview.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/repository/demo_initialization_repository.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/success_authentication_type.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/constants.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
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

    // ✅ Specific error for email not found
    if (accountOverview == null) {
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

    // A missing demo-request document is NOT a Firestore error: getDocumentWithId
    // returns Right(null) for it (DocumentSnapshot.data() is null when the doc
    // does not exist). Typing the payload as non-nullable therefore threw
    // "type 'Null' is not a subtype of type 'Map<String, dynamic>'" instead of
    // surfacing a login failure. An empty map is treated the same way, because
    // DemoCompanyModel.fromMap does unguarded lookups and would throw on it too.
    // Same shape as the null check in _checkIfAccountExists above.
    Map<String, dynamic>? demoRequest = result.getOrElse(() => null);

    if (demoRequest == null || demoRequest.isEmpty) {
      return Left(FirebaseFailure(
          FailureAuthenticationType.notFoundInCompanyDatabase.dialogBoxMessage));
    }

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
  ///
  /// UPDATED 22/8/2026 — the unlock flow.
  ///
  /// When an administrator unlocks an account, `UserAccessRepository`
  /// clears the employee's chosen `Password` and flips
  /// `Demo_Users_Accounts/{email}.Is_Activated` back to false, which routes the
  /// next sign-in through here. The password the user must now type is the
  /// **Default Password shown against their row in User Access**
  /// (`Employees_Info/{id}.Default_Password`), not the one they had chosen and
  /// not, necessarily, the company-wide temporary password.
  ///
  /// This method previously compared only against
  /// `companyModel.demoDetails.temporaryPassword`, so an unlocked user typing
  /// the default password an admin had just read to them was told the
  /// activation password was wrong. It now accepts either:
  ///   • the company temporary password — the original first-run activation
  ///     path, unchanged; or
  ///   • that employee's own `Default_Password` — the unlock path.
  ///
  /// The employee record is fetched *before* the comparison now, because the
  /// per-employee default lives on it. The demo-admin branch is untouched: the
  /// company contact has no employee record to carry a default, so it still
  /// only accepts the company temporary password.
  Future<Either<Failure, dynamic>> validateInactiveAccount({
    required DemoCompanyModel companyModel,
    required String password,
    required DemoUserAccountOverview accountOverview
  }) async {
    final String companyTemporaryPassword =
        companyModel.demoDetails!.temporaryPassword!.values.last;

    // ✅ CRITICAL: Compare normalized emails (both should be lowercase)
    final String normalizedAccountEmail = accountOverview.email.toLowerCase();
    final String normalizedCompanyEmail =
        companyModel.contactInformation.email.values.last.toLowerCase();

    if (normalizedAccountEmail == normalizedCompanyEmail) {
      // Demo admin — only the company temporary password activates the tenant.
      if (password != companyTemporaryPassword) {
        return Left(FirebaseFailure(
            FailureAuthenticationType.wrongActivationPassword.dialogBoxMessage));
      }
      return await DemoInitializationRepository()
          .startDemoAdminData(companyModel: companyModel);
    }

    // Regular user — get the existing employee first, so their per-account
    // default password is available to the check below.
    Either<Failure, dynamic> result = await demoRemoteDataSource
        .getEmployeeAccount(email: accountOverview.email);
    if (result.isLeft()) return result;

    List<Map<String, dynamic>> employeeAccount = result.getOrElse(() => null);

    // ✅ Specific error for employee not found in company database
    if (employeeAccount.isEmpty) {
      return Left(FirebaseFailure(
          FailureAuthenticationType.notFoundInCompanyDatabase.dialogBoxMessage));
    }

    final NewEmployeeModelHistory employeeModel =
        NewEmployeeModelHistory.fromMap(employeeAccount.first);

    final String? employeeDefaultPassword = employeeModel.defaultPassword;
    final bool hasOwnDefault = employeeDefaultPassword != null &&
        employeeDefaultPassword.isNotEmpty;

    // TIGHTENED 29/8/2026 — the employee's OWN default is the only key, when
    // they have one.
    //
    // This branch is both the first sign-in and the post-unlock sign-in, and
    // it used to accept the employee's `Default_Password` OR the company-wide
    // temporary password. That second door is the problem: the value an admin
    // reads out of the Default Password column in User Access is the
    // per-employee one, and it is the one that gets rotated when an account is
    // unlocked. Leaving the company temporary password valid meant one shared
    // string — the same for every employee in the tenant, never rotated —
    // could still activate any account that had just been unlocked, so
    // unlocking handed out a credential the admin never chose and could not
    // revoke.
    //
    // The company temporary password now applies only where there is nothing
    // else to check against: an employee record with no `Default_Password` of
    // its own, which is the original first-run activation path. (The demo-admin
    // branch above is untouched — the company contact has no employee record to
    // carry a default.)
    final String expectedPassword =
        hasOwnDefault ? employeeDefaultPassword : companyTemporaryPassword;

    if (password != expectedPassword) {
      return Left(FirebaseFailure(
          FailureAuthenticationType.wrongActivationPassword.dialogBoxMessage));
    }

    return Right(employeeModel);
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
      return Left(FirebaseFailure(FailureAuthenticationType
          .notFoundInCompanyDatabase.dialogBoxMessage));
    }

    NewEmployeeModelHistory employeeModel =
    NewEmployeeModelHistory.fromMap(employeeAccount.first);


    // FIXED 29/8/2026 — an EMPTY chosen password used to shadow the default.
    //
    // The rule is: a password the employee chose wins; if they have not chosen
    // one — a first sign-in, or an unlock, which clears `Password` precisely so
    // this falls through — the Default Password shown against their row in
    // User Access is what they must type. Only an account with neither falls
    // back to the company-wide temporary password.
    //
    // `employeeModel.password ?? employeeModel.defaultPassword` only fell
    // through on NULL. Firestore hands back `''` rather than a missing field in
    // several places here (`copyWithUpdateSynchronized` writes empty strings for
    // cleared values), and an empty `Password` therefore won the `??` and then
    // failed the `isEmpty` test below — dropping the account onto the company
    // temporary password while its own default sat unused. The empty case is
    // now treated as "not chosen", the same as null.
    String? chosenPassword = employeeModel.password;
    if (chosenPassword != null && chosenPassword.isEmpty) chosenPassword = null;

    String? defaultPassword = employeeModel.defaultPassword;
    if (defaultPassword != null && defaultPassword.isEmpty) {
      defaultPassword = null;
    }

    final String storedPassword = chosenPassword ??
        defaultPassword ??
        companyModel.demoDetails!.temporaryPassword!.values.last;

    // ✅ Specific error for wrong password
    if (storedPassword != password) {
      return Left(FirebaseFailure(
          FailureAuthenticationType.wrongPassword.dialogBoxMessage));
    }


    result = await _checkEmployeePermission(employeeModel: employeeModel);
    if (result.isLeft()) return result;


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

    // SECURITY: a hardcoded branch used to short-circuit this entire
    // permission check whenever the tenant's baseUri contained one specific
    // company id, granting unconditional access to every employee of that
    // tenant regardless of role or status. Removed — every tenant now goes
    // through the same checks below.

    // ✅ Get employee role and status
    //
    // TRIMMED 30/8/2026. Both are the LAST entry of a history list written by
    // several different screens, and Firestore stores whatever string it was
    // handed — `'active '` with a trailing space compared unequal to
    // `'active'` and denied a perfectly valid account, with the same message
    // an expired date range produces.
    String currentRole = employeeModel.role.isNotEmpty
        ? employeeModel.role.last.trim()
        : '';

    String currentStatus = employeeModel.status.isNotEmpty
        ? employeeModel.status.last.trim()
        : '';


    // ✅ Master Admin - always allow
    if (currentRole.toLowerCase() == 'master admin') {
      return Right<Failure, dynamic>(null);
    }

    // ✅ Check employee status - if not active, deny immediately
    if (currentStatus.toLowerCase() != 'active') {
      // ⚠️ DIAGNOSTICS ADDED 30/8/2026.
      //
      // Two completely different conditions raise
      // `FailureAuthenticationType.dontHavePermission`, and they share one
      // message: the account is not `active`, or its User_Management date
      // window does not contain today. From the "Access Denied" dialog the two
      // are indistinguishable, so "the status says Active in Firebase, why am
      // I blocked?" could not be answered without reading this code. Each
      // refusal now says which gate it was and on what values.
      //
      // ⚠️ The status compared here is `Employees_Info.Status.last` — the LAST
      // entry of the history list, NOT the first, and not whatever a screen
      // happens to display.
      debugPrint(
        '[login] DENIED (status) ${employeeModel.email.isNotEmpty ? employeeModel.email.last : '?'} '
        '— Employees_Info.Status.last is "$currentStatus", expected "active". '
        'Full status history: ${employeeModel.status}',
      );
      return Left(FirebaseFailure(
          FailureAuthenticationType.dontHavePermission.dialogBoxMessage));
    }

    // ✅ For active employees, check permission record (optional)
    Either<Failure, dynamic> result = await demoRemoteDataSource
        .getEmployeePermission(employeeId: employeeModel.id!);

    if (result.isLeft()) {
      return result;
    }

    Map<String, dynamic>? employeePermission = result.getOrElse(() => null);

    // ✅ If no permission record exists, allow access for active employees
    if (employeePermission == null) {
      return Right<Failure, dynamic>(null);
    }


    try {
      // ✅ Extract dates from the correct field names (From_Date/To_Date)
      Map<String, dynamic>? fromDateMap = employeePermission['From_Date'];
      Map<String, dynamic>? toDateMap = employeePermission['To_Date'];

      if (fromDateMap == null || toDateMap == null) {
        // If dates are missing but employee is active, allow access
        return Right<Failure, dynamic>(null);
      }

      // ✅ Get the last value from the Values array
      List<dynamic>? fromValues = fromDateMap['Values'];
      List<dynamic>? toValues = toDateMap['Values'];

      if (fromValues == null || fromValues.isEmpty ||
          toValues == null || toValues.isEmpty) {
        // If date values are empty but employee is active, allow access
        return Right<Failure, dynamic>(null);
      }

      String fromDateStr = fromValues.last.toString();
      String toDateStr = toValues.last.toString();


      // ✅ Parse dates using the format in your database
      DateTime from;
      DateTime to;

      try {
        DateFormat dateFormat = DateFormat("MMM dd, yyyy", 'en');
        from = dateFormat.parse(fromDateStr);
        to = dateFormat.parse(toDateStr);
      } catch (e) {
        try {
          DateFormat dateFormat = DateFormat("MMM dd, yyyy", 'ar');
          from = dateFormat.parse(fromDateStr);
          to = dateFormat.parse(toDateStr);
        } catch (e2) {
          // If can't parse dates but employee is active, allow access
          return Right<Failure, dynamic>(null);
        }
      }

      // The "to" date is inclusive: access is valid through the END of that
      // day, not from its midnight. Without this, permission expires at
      // 00:00 on the last day, denying access for the entire final day.
      to = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);

      DateTime now = DateTime.now();

      // ✅ Validate permission date range
      bool isFromValid = from.isBefore(now) || from.isAtSameMomentAs(now);
      bool isToValid = to.isAfter(now) || to.isAtSameMomentAs(now);


      if (!isFromValid || !isToValid) {
        // See the diagnostics note on the status gate above. This is the OTHER
        // way to reach the same "Access Denied" dialog, and by far the more
        // confusing one: the account IS active, and the block comes from
        // `User_Management/<employeeId>` — From_Date not yet reached, or
        // To_Date already passed. These are the same two fields the Role
        // Management calendar hangs its access cards off.
        // The path is logged by `DemoRemoteDataSource.getEmployeePermission`
        // on the line immediately above this one. It is `Users_Access`, NOT
        // `User_Management` — the two hold the same From_Date / To_Date shape
        // and only the former gates sign-in.
        debugPrint(
          '[login] DENIED (date window) — the Users_Access record for '
          'employeeId "${employeeModel.id}" does not cover now. '
          'From_Date "$fromDateStr" (valid: $isFromValid), '
          'To_Date "$toDateStr" (valid: $isToValid), now $now.',
        );
        return Left(FirebaseFailure(
            FailureAuthenticationType.dontHavePermission.dialogBoxMessage));
      }

      return Right<Failure, dynamic>(employeePermission);

    } catch (e, stackTrace) {
      // If there's an error but employee is active, allow access.
      //
      // The swallow is deliberate — a malformed permission record must not
      // lock out an active employee — but it was silent, so a record this
      // code could not read looked exactly like a record that said yes.
      debugPrint(
        '[login] permission record unreadable, allowing active employee '
        'through — $e\n$stackTrace',
      );
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
    Either<Failure, dynamic> result;

    // ✅ CRITICAL: Compare normalized emails (both should be lowercase)
    String normalizedEmail = email.toLowerCase();
    String normalizedCompanyEmail = companyModel.contactInformation.email.values.last.toLowerCase();

    // Skip validation for demo admin (company contact)
    if (normalizedEmail == normalizedCompanyEmail) {
      return result = Right(null);
    }


    // Get actual number of users in the company
    result = await demoRemoteDataSource.getCompanyActualNumberOfUsers(
        companyId: companyModel.requestId);
    if (result.isLeft()) return result;

    int actualNumberOfUsers = result.getOrElse(() => 0);
    int allowedUsers = companyModel.demoDetails!.numberOfUsers!.values.last;


    // Check if we've exceeded the user limit
    if (actualNumberOfUsers > allowedUsers) {
      return result = Left(FirebaseFailure(
          FailureAuthenticationType.tooManyUsers.dialogBoxMessage));
    }

    return result = Right(null);
  }
}