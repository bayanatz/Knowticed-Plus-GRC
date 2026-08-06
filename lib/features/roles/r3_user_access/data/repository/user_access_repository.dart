///********************** FILE INFO **********************
/// File: user_access_repository.dart (WITH NOTIFICATIONS)
/// Purpose: repository contains all function related to database for account status feature.
/// Author: Amr Mesbah
/// Date: 22/1/2025
/// Updated: 23/12/2025 - Added comprehensive notification system

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:grc_module/core/helper/main_helper/biometric_controller.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/models/demo_user_account_overview.dart';
import 'package:grc_module/features/roles/r3_user_access/domain/entity/user_access_entity.dart';
import 'package:grc_module/features/notification/data/repository/account_status_notification_service.dart';
import 'package:grc_module/features/roles/r3_user_access/data/data_source/user_access_remote_data_source.dart';

class UserAccessRepository {
  UserAccessRemoteDataSource remoteDataSource =
  UserAccessRemoteDataSource();

  /// Method Name: [getAccountsStatusEntities]
  ///
  /// Purpose: get all employees from the database and convert them to UserAccessEntity
  ///
  /// return: [Either<Failure, dynamic>]
  ///                                 - Failure: if there is an error in the process or [UserAccessEntity] data.
  getAccountsStatusEntities() async {
    Either<Failure, dynamic> result = await remoteDataSource.getEmployees();
    if (result.isLeft()) return result;

    List<Map<String, dynamic>> employees = result.getOrElse(() => []);
    List<UserAccessEntity> entities = [];

    for (Map<String, dynamic> employee in employees) {
      entities.add(UserAccessEntity.fromEmployeeModelHistory(
          NewEmployeeModelHistory.fromMap(employee)));
    }

    result = Right(entities);
    return result;
  }

  /// Method Name: [updateAccountStatus]
  ///
  /// Purpose: Update employee status using synchronized history pattern
  ///
  /// Parameters:
  ///   [UserAccessEntity] accountStatusAccessEntity
  ///   [EmployeeStatusEnum] status - new status to set
  /// ✅ UPDATED: Now sends notifications based on status change
  updateAccountStatus(UserAccessEntity accountStatusAccessEntity,
      EmployeeStatusEnum status) async {

    Either<Failure, dynamic> result = await remoteDataSource
        .getEmployeeModel(accountStatusAccessEntity.employeeId);

    if (result.isLeft()) {
      return result;
    }

    var employeeDataOrNull = result.getOrElse(() => null);

    if (employeeDataOrNull == null) {
      return Left(FirebaseFailure(
          'Employee data not found for ID: ${accountStatusAccessEntity.employeeId}'));
    }

    Map<String, dynamic> employeeData =
    employeeDataOrNull as Map<String, dynamic>;


    NewEmployeeModelHistory employeeModel =
    NewEmployeeModelHistory.fromMap(employeeData);


    // ✅ Store old values for notification logic
    String oldStatus = employeeModel.status.isNotEmpty
        ? employeeModel.status.last
        : '';
    String? oldActivationDate = employeeModel.activationDate;
    String? oldDeactivationDate = employeeModel.deactivationDate;


    // Update the employee model
    employeeModel = employeeModel.copyWithUpdateSynchronized(
      status: status.name,
      deactivationDate: '', // Clear scheduled deactivation
      activationDate: '',   // Clear scheduled activation
    );


    Map<String, dynamic> mapToSave = employeeModel.toMap();

    var updateResult = await remoteDataSource.updateEmployeeModel(employeeModel);

    if (updateResult.isRight()) {

      // ═══════════════════════════════════════════════════════════
      // ✅ SEND NOTIFICATIONS BASED ON STATUS CHANGE
      // ═══════════════════════════════════════════════════════════

      String userEmail = accountStatusAccessEntity.email;
      String userName = accountStatusAccessEntity.englishName ?? _buildEmployeeFullName(employeeModel);
      String adminEmail = storage.read('email') ?? "system@company.com";

      // 1. Account Activated
      if (status == EmployeeStatusEnum.active && oldStatus != 'active') {
        await AccountStatusNotificationService.sendAccountActivatedNotification(
          userEmail: userEmail,
          userName: userName,
          senderEmail: adminEmail, // ✅ ADD THIS
        );
      }

      // 2. Account Deactivated
      if (status == EmployeeStatusEnum.deactivated && oldStatus != 'deactivated') {
        await AccountStatusNotificationService.sendAccountDeactivatedNotification(
          userEmail: userEmail,
          userName: userName,
          senderEmail: adminEmail, // ✅ ADD THIS

        );
      }

      // 3. Account Unlocked (from locked to active)
      if (status == EmployeeStatusEnum.active &&
          (oldStatus == 'locked' || oldStatus == 'locked with send request')) {
        await AccountStatusNotificationService.sendAccountUnlockedNotification(
          userEmail: userEmail,
          userName: userName,
          senderEmail: adminEmail, // ✅ ADD THIS
        );
      }

      // 4. Schedule Canceled (if had scheduled dates and now cleared)
      if ((oldActivationDate != null && oldActivationDate.isNotEmpty) ||
          (oldDeactivationDate != null && oldDeactivationDate.isNotEmpty)) {
        await AccountStatusNotificationService.sendScheduleCanceledNotification(
          userEmail: userEmail,
          userName: userName,
          senderEmail: adminEmail, // ✅ ADD THIS
        );
      }

    } else {
    }

    return updateResult;
  }

  /// Method Name: [scheduleDeactivationTime]
  ///
  /// Purpose: schedule deactivation time for the employee.
  ///
  /// Parameters:
  ///            [UserAccessEntity] accountStatusAccessEntity
  ///            [String] deactivationTime
  /// ✅ UPDATED: Now sends notifications when scheduling deactivation
  scheduleDeactivationTime(UserAccessEntity accountStatusAccessEntity,
      String deactivationTime) async {

    Either<Failure, dynamic> result = await remoteDataSource
        .getEmployeeModel(accountStatusAccessEntity.employeeId);
    if (result.isLeft()) return result;

    var employeeDataOrNull = result.getOrElse(() => null);

    if (employeeDataOrNull == null) {
      return Left(FirebaseFailure(
          'Employee data not found for ID: ${accountStatusAccessEntity.employeeId}'));
    }

    NewEmployeeModelHistory employeeModel =
    NewEmployeeModelHistory.fromMap(employeeDataOrNull as Map<String, dynamic>);


    // ✅ Store old value to detect edit vs new schedule
    String? oldDeactivationDate = employeeModel.deactivationDate;

    // Update dates
    employeeModel.deactivationDate = deactivationTime;
    employeeModel.activationDate = ''; // Clear activation schedule


    var updateResult = await remoteDataSource.updateEmployeeModel(employeeModel);

    // ═══════════════════════════════════════════════════════════
    // ✅ SEND NOTIFICATIONS
    // ═══════════════════════════════════════════════════════════
    if (updateResult.isRight()) {
      String userEmail = accountStatusAccessEntity.email;
      String userName = accountStatusAccessEntity.englishName ?? _buildEmployeeFullName(employeeModel);
      String adminEmail = "admin@company.com";

      // Check if this is a NEW schedule or EDIT
      if (oldDeactivationDate != null && oldDeactivationDate.isNotEmpty) {
        // EDIT - schedule was changed
        await AccountStatusNotificationService.sendScheduleEditedNotification(
          userEmail: userEmail,
          userName: userName,
          newScheduledDate: deactivationTime,
          scheduleType: "deactivation",
          senderEmail: adminEmail, // ✅ ADD THIS
        );
      } else {
        // NEW - first time scheduling
        await AccountStatusNotificationService.sendDeactivationScheduledNotification(
          userEmail: userEmail,
          userName: userName,
          scheduledDate: deactivationTime,
          senderEmail: adminEmail, // ✅ ADD THIS
        );
      }
    }

    return updateResult;
  }

  /// Method Name: [scheduleReactivationTime]
  ///
  /// Purpose: schedule reactivation time for the employee.
  ///
  /// Parameters:
  ///            [UserAccessEntity] accountStatusAccessEntity
  ///            [String] reactivationTime
  /// ✅ UPDATED: Now sends notifications when scheduling reactivation
  scheduleReactivationTime(UserAccessEntity accountStatusAccessEntity,
      String reactivationTime) async {

    Either<Failure, dynamic> result = await remoteDataSource
        .getEmployeeModel(accountStatusAccessEntity.employeeId);
    if (result.isLeft()) return result;

    var employeeDataOrNull = result.getOrElse(() => null);

    if (employeeDataOrNull == null) {
      return Left(FirebaseFailure(
          'Employee data not found for ID: ${accountStatusAccessEntity.employeeId}'));
    }

    NewEmployeeModelHistory employeeModel =
    NewEmployeeModelHistory.fromMap(employeeDataOrNull as Map<String, dynamic>);


    // ✅ Store old value to detect edit vs new schedule
    String? oldActivationDate = employeeModel.activationDate;

    // Update dates
    employeeModel.activationDate = reactivationTime;
    employeeModel.deactivationDate = ''; // Clear deactivation schedule


    var updateResult = await remoteDataSource.updateEmployeeModel(employeeModel);

    // ═══════════════════════════════════════════════════════════
    // ✅ SEND NOTIFICATIONS
    // ═══════════════════════════════════════════════════════════
    if (updateResult.isRight()) {
      String userEmail = accountStatusAccessEntity.email;
      String userName = accountStatusAccessEntity.englishName ?? _buildEmployeeFullName(employeeModel);
      String adminEmail = "admin@company.com";

      // Check if this is a NEW schedule or EDIT
      if (oldActivationDate != null && oldActivationDate.isNotEmpty) {
        // EDIT - schedule was changed
        await AccountStatusNotificationService.sendScheduleEditedNotification(
          userEmail: userEmail,
          userName: userName,
          newScheduledDate: reactivationTime,
          scheduleType: "activation",
        );
      } else {
        // NEW - first time scheduling
        await AccountStatusNotificationService.sendActivationScheduledNotification(
          userEmail: userEmail,
          userName: userName,
          scheduledDate: reactivationTime,
        );
      }
    }

    return updateResult;
  }

  /// Method Name: [approveResetPassword]
  ///
  /// Purpose: Approve reset password request and deactivate account
  ///
  /// Parameters:
  ///            [UserAccessEntity] accountStatusAccessEntity
  approveResetPassword(
      UserAccessEntity accountStatusAccessEntity) async {
    remoteDataSource.startTransaction();

    Either<Failure, dynamic> result = await remoteDataSource
        .getEmployeeModel(accountStatusAccessEntity.employeeId);
    if (result.isLeft()) {
      return result;
    }

    var employeeDataOrNull = result.getOrElse(() => null);

    if (employeeDataOrNull == null) {
      return Left(FirebaseFailure(
          'Employee data not found for ID: ${accountStatusAccessEntity.employeeId}'));
    }

    NewEmployeeModelHistory employeeModel =
    NewEmployeeModelHistory.fromMap(employeeDataOrNull as Map<String, dynamic>);

    // Use copyWithUpdateSynchronized for status change
    employeeModel = employeeModel.copyWithUpdateSynchronized(
      status: EmployeeStatusEnum.inactive.name,
      deactivationDate: '',
      activationDate: '',
    );

    remoteDataSource.updateDemoUsersAccountWithinTransaction(
        accountStatusAccessEntity.email,
        {DemoUserAccountOverview.isActivatedField: false});

    remoteDataSource.updateEmployeeWithinTransaction(employeeModel);

    var commitResult = await remoteDataSource.commitTransaction();

    // ═══════════════════════════════════════════════════════════
    // ✅ SEND NOTIFICATION (Password Reset Approved)
    // ═══════════════════════════════════════════════════════════
    if (commitResult.isRight()) {
      String userName = accountStatusAccessEntity.englishName ?? _buildEmployeeFullName(employeeModel);

      await AccountStatusNotificationService.sendAccountDeactivatedNotification(
        userEmail: accountStatusAccessEntity.email,
        userName: userName,
      );
    }

    return commitResult;
  }

  /// Method Name: [updateAccessDetails]
  ///
  /// Purpose: Update default password and expiration time in Firebase
  Future<Either<Failure, dynamic>> updateAccessDetails(
      UserAccessEntity entity) async {


    try {
      String? documentId = entity.employeeId;

      if (documentId == null || documentId.isEmpty) {
        return Left(FirebaseFailure('Document ID cannot be null or empty'));
      }

      final employeesInfoRef = FirebaseFirestore.instance
          .collection(getBaseUrl('Employees_Info'));

      DocumentSnapshot docSnapshot = await employeesInfoRef
          .doc(documentId)
          .get(const GetOptions(source: Source.server));

      if (!docSnapshot.exists) {
        return Left(FirebaseFailure('Employee document not found'));
      }

      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      data['Id'] = documentId;
      NewEmployeeModelHistory employeeModel =
      NewEmployeeModelHistory.fromMap(data);


      // Update ALL THREE fields
      employeeModel.defaultPassword = entity.tempPassword;
      employeeModel.passwordExpirationTime = entity.expirationTimeOfPassword;
      employeeModel.passwordExpirationUnit = entity.expirationTimeUnit;


      Map<String, dynamic> mapToSave = employeeModel.toMap();

      await employeesInfoRef.doc(documentId).set(
          mapToSave, SetOptions(merge: true));

      return Right(null);
    } catch (e, stackTrace) {
      return Left(FirebaseFailure('Failed to update access details: $e'));
    }
  }

  /// ✅ HELPER METHOD: Build full name from employee model
  String _buildEmployeeFullName(NewEmployeeModelHistory employee) {
    List<String> nameParts = [];

    if (employee.firstName.isNotEmpty && employee.firstName.last.isNotEmpty) {
      nameParts.add(employee.firstName.last);
    }

    if (employee.middleName.isNotEmpty && employee.middleName.last.isNotEmpty) {
      nameParts.add(employee.middleName.last);
    }

    if (employee.lastName.isNotEmpty && employee.lastName.last.isNotEmpty) {
      nameParts.add(employee.lastName.last);
    }

    return nameParts.isEmpty ? 'Unknown User' : nameParts.join(' ');
  }
}