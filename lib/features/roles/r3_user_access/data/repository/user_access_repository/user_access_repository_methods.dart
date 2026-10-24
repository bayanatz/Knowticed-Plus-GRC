/// Module: roles/r3_user_access
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_repository_methods.dart
/// Description: Methods of `UserAccessRepository` — split out of `user_access_repository.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../user_access_repository.dart';

// Split from user_access_repository.dart to keep every file under 700 lines.

extension UserAccessRepositoryMethods on UserAccessRepository {
  /// Method Name: [updateAccountStatus]
  ///
  /// Purpose: Update employee status using synchronized history pattern
  ///
  /// Parameters:
  ///   [UserAccessEntity] accountStatusAccessEntity
  ///   [EmployeeStatusEnum] status - new status to set
  /// ✅ UPDATED: Now sends notifications based on status change
  Future<Either<Failure, dynamic>> updateAccountStatus(
      UserAccessEntity accountStatusAccessEntity,
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
    String oldStatus =
        employeeModel.status.isNotEmpty ? employeeModel.status.last : '';
    String? oldActivationDate = employeeModel.activationDate;
    String? oldDeactivationDate = employeeModel.deactivationDate;

    // Is this the admin lifting a lock, as opposed to any other status change?
    final bool isUnlocking = status == EmployeeStatusEnum.active &&
        (oldStatus == EmployeeStatusEnum.locked.name ||
            oldStatus == EmployeeStatusEnum.lockedWithRequest.name ||
            oldStatus == UserAccessRepository._lockedWithRequestStatus);

    // Update the employee model
    employeeModel = employeeModel.copyWithUpdateSynchronized(
      status: status.name,
      deactivationDate: '', // Clear scheduled deactivation
      activationDate: '', // Clear scheduled activation
    );

    if (isUnlocking) {
      // ADDED 22/8/2026 — unlocking must NOT hand the account straight back to
      // the user's old password.
      //
      // `DemoLoginRepository.validateActiveAccount` resolves the accepted
      // credential as `employeeModel.password ?? employeeModel.defaultPassword`,
      // so as long as `Password` holds a value the personal password the user
      // was locked out on keeps working — the lock taught them nothing and the
      // admin had no way to hand over a fresh credential.
      //
      // Clearing `Password` makes the account fall back to `Default_Password`,
      // which is exactly the value the admin can see in the Default Password
      // column of this screen and read out to the user.
      employeeModel.password = null;
    }

    // REMOVED 12/8/2026: `Map<String, dynamic> mapToSave = employeeModel.toMap();`
    // — computed and never used; the write below sends `employeeModel` directly.
    var updateResult =
        await remoteDataSource.updateEmployeeModel(employeeModel);

    if (updateResult.isRight() && isUnlocking) {
      // …and flipping Is_Activated back to false routes the next sign-in
      // through `validateInactiveAccount`, whose success type is
      // `SuccessAuthenticationType.inactive` — which `LoginController.login`
      // already sends to the ResetPassword screen. So the unlocked user signs
      // in once with the default password and is then required to create a new
      // one before reaching the app. `DemoLoginRepository.updateEmployeePassword`
      // sets both fields back when they save.
      await _requirePasswordResetOnNextLogin(accountStatusAccessEntity.email);

      // The failure history that produced the lock is spent. Without this the
      // unlocked user would be one wrong password away from being locked again.
      LoginAttemptStore.reset(accountStatusAccessEntity.email);
    }

    if (updateResult.isRight()) {
      // ═══════════════════════════════════════════════════════════
      // ✅ SEND NOTIFICATIONS BASED ON STATUS CHANGE
      // ═══════════════════════════════════════════════════════════

      String userEmail = accountStatusAccessEntity.email;
      String userName = accountStatusAccessEntity.englishName;
      String adminEmail =
          storage.read('email') ?? UserAccessRepository._systemSenderEmail;

      // 1. Account Activated
      if (status == EmployeeStatusEnum.active && oldStatus != 'active') {
        await AccountStatusNotificationService.sendAccountActivatedNotification(
          userEmail: userEmail,
          userName: userName,
          senderEmail: adminEmail, // ✅ ADD THIS
        );
      }

      // 2. Account Deactivated
      if (status == EmployeeStatusEnum.deactivated &&
          oldStatus != 'deactivated') {
        await AccountStatusNotificationService
            .sendAccountDeactivatedNotification(
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
    }

    return updateResult;
  }

  // ══════════════════════════════════════════════════════════════════
  //  UNLOCK REQUEST — added 26/8/2026
  //
  //  `AccountStatusNotificationService.sendUnlockRequestNotification` and its
  //  event `accountUnlockRequestedAdmin` have existed since the catalog was
  //  written, with no caller anywhere in `lib/`. The same is true of the
  //  status the request produces: `EmployeeStatusEnum.lockedWithRequest` is
  //  READ in three places — `_checkEmployeeStatus` maps it to
  //  `SuccessAuthenticationType.lockedWithRequest`, [updateAccountStatus]
  //  treats it as unlockable, and the User Access screen styles it — and was
  //  WRITTEN by nothing. Half a feature, wired at both ends and missing its
  //  middle.
  //
  //  This is that middle. The trigger is the locked user's next sign-in
  //  attempt: someone who has been locked out and comes back to try again IS
  //  asking to be let in, and making them find a button to say so adds a step
  //  without adding information. The caller is
  //  `DemoLoginController.handleLockedAccountSignIn`, reached from both sign-in
  //  paths that can land on a locked account — `lockAccount`'s "already locked"
  //  branch (wrong password again) and `LoginController`'s catch-all `else`
  //  (right password, locked account).
  //
  //  It is idempotent by construction: the status it writes is the same status
  //  it refuses to act on, so a user who tries five times raises one request.
  // ══════════════════════════════════════════════════════════════════

  /// Function Name: [requestAccountUnlock]
  ///
  /// Purpose: Record that a locked-out user has asked to be unlocked, and tell
  /// the Master Admins.
  ///
  /// Parameters:
  /// - [employeeModel]: the locked account, freshly read by the caller.
  /// - [userName]: the display name to print in the admin notification.
  ///
  /// Returns: [Future<bool>] true when a NEW request was raised. False when the
  /// account was not locked, when a request was already outstanding, or when
  /// the write failed — in all three cases no notification is sent.
  Future<bool> requestAccountUnlock({
    required NewEmployeeModelHistory employeeModel,
    required String userName,
  }) async {
    final String email =
        employeeModel.email.isNotEmpty ? employeeModel.email.last : '';
    if (email.isEmpty) return false;

    final String currentStatus =
        employeeModel.status.isNotEmpty ? employeeModel.status.last : '';

    // Already asked. Both spellings, for the reason [_lockedWithRequestStatus]
    // gives.
    if (currentStatus == EmployeeStatusEnum.lockedWithRequest.name ||
        currentStatus == UserAccessRepository._lockedWithRequestStatus) {
      return false;
    }

    // Only a locked account can ask to be unlocked.
    if (currentStatus != EmployeeStatusEnum.locked.name) return false;

    // `updateEmployeeModel` addresses the document by `id`, and this model was
    // read by EMAIL — `FirebaseRepository.getDocumentWithFieldLasValue` returns
    // `document.data()` without folding in `document.id`, so `Id` is there only
    // because `toMap()` happens to write it as a field. A record last written
    // through an older path may not carry it, and a null id would write to a
    // document literally named "null". Resolved from the address in that case,
    // and resolved BEFORE the copy: `copyWithUpdateSynchronized` appends a row
    // to every history list, so calling it twice would record two status
    // changes for one request.
    String? documentId = employeeModel.id;
    if (documentId == null || documentId.trim().isEmpty) {
      documentId = await _employeeIdForEmail(email);
      if (documentId == null) return false;
    }

    final NewEmployeeModelHistory requested =
        employeeModel.copyWithUpdateSynchronized(
      id: documentId,
      status: EmployeeStatusEnum.lockedWithRequest.name,
    );

    final Either<Failure, dynamic> updateResult =
        await remoteDataSource.updateEmployeeModel(requested);
    if (updateResult.isLeft()) return false;

    await AccountStatusNotificationService.sendUnlockRequestNotification(
      userEmail: email,
      userName: userName,
      // The user IS the sender here — this is the one notification in the
      // module that travels upward, from the locked account to the
      // administrators, rather than from an admin to a user.
      senderEmail: email,
    );

    return true;
  }
}
