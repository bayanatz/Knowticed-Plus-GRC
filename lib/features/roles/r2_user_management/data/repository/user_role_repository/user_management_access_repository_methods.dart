/// Module: roles/r2_user_management
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_access_repository_methods.dart
/// Description: Methods of `UserManagementAccessRepository` — split out of `user_role_repository.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../user_role_repository.dart';

// Split from user_role_repository.dart to keep every file under 700 lines.

extension UserManagementAccessRepositoryMethods
    on UserManagementAccessRepository {
  Future<Map<String, NewEmployeeModelHistory>> _getEmployees() async {
    final stopwatch = Stopwatch()..start();

    try {
      // Was `Get.isRegistered<...>` — the locator now stays behind the
      // AppControllers seam (GetX standing rule).
      if (!AppControllers.isEmployeeRegistered) {
        return {};
      }

      MainCoreEmployeeController controller = AppControllers.employee;
      List<EmployeeEntityPro>? employeesList = controller.allEmployeesEntities;

      if (employeesList == null || employeesList.isEmpty) {
        stopwatch.stop();
        return {};
      }

      Map<String, NewEmployeeModelHistory> users = {};

      final parallelStopwatch = Stopwatch()..start();

      List<Future<void>> fetchFutures = [];

      for (int i = 0; i < employeesList.length; i++) {
        EmployeeEntityPro entity = employeesList[i];

        if (entity.id == null ||
            entity.id!.isEmpty ||
            entity.email == null ||
            entity.email!.isEmpty) {
          continue;
        }

        fetchFutures.add(
          remoteDataSource.getEmployeeModel(entity.id!).then((result) {
            if (result.isRight()) {
              Map<String, dynamic>? data = result.getOrElse(() => null);
              if (data != null) {
                NewEmployeeModelHistory employee =
                    NewEmployeeModelHistory.fromMap(data);
                if (employee.email.isNotEmpty) {
                  String latestEmail = employee.email.last;
                  users[latestEmail] = employee;
                } else {
                }
              } else {
              }
            } else {
            }
          }).catchError((e) {
          }),
        );
      }

      await Future.wait(fetchFutures);

      parallelStopwatch.stop();
      stopwatch.stop();

      return users;
    } catch (e) {
      stopwatch.stop();
      return {};
    }
  }

  // REMOVED 9/10/2026: `checkModuleUserLimitsSimple` — only the unused debug
  // dialog in user_management_home_methods1.dart called it, and it carried the
  // same three bugs as the old `getModuleUserCount` (camelCase role fields,
  // `Users_Access`, errors read as "OK"). See the USER LIMITS section.

  Future<Either<Failure, dynamic>> _getUsersPermissions(
    Map<String, NewEmployeeModelHistory> users,
  ) async {
    final stopwatch = Stopwatch()..start();

    if (users.isEmpty) {
      return Right(<UserPermissionEntity>[]);
    }

    try {
      List<UserPermissionEntity> userPermissions = [];

      final parallelStopwatch = Stopwatch()..start();

      List<String> userEmails = users.keys.toList();
      List<Future<void>> accessFutures = [];

      for (String userEmail in userEmails) {
        NewEmployeeModelHistory userValue = users[userEmail]!;
        String? employeeId = userValue.id;

        if (employeeId == null || employeeId.isEmpty) {
          continue;
        }

        if (userValue.role.isNotEmpty) {
          String currentRole = userValue.role.last;
          if (currentRole == Constants.removedEmployeePermission) {
            continue;
          }
        }

        accessFutures.add(
          remoteDataSource.getUserAccessModels(id: employeeId).then((result) {
            if (result.isLeft()) {
              return;
            }

            Map<String, dynamic>? data = result.getOrElse(() => null);
            if (data == null) {
              return;
            }

            try {
              UserPermissionHistoryModel userAccessModel =
                  UserPermissionHistoryModel.fromMap(data);

              UserPermissionEntity permission = _getUserPermissions(
                users: users,
                userData: userValue,
                userAccessModel: userAccessModel,
              );

              userPermissions.add(permission);
            } catch (e) {
              debugPrint('Ignored error: $e');
            }
          }).catchError((e) {
          }),
        );
      }

      await Future.wait(accessFutures);

      parallelStopwatch.stop();
      stopwatch.stop();

      return Right(userPermissions);
    } catch (e) {
      stopwatch.stop();
      return Left(FeatureFailure(e.toString()));
    }
  }

  // ✅ FIXED: explicit return types to avoid Right<dynamic,bool> cast errors
  Future<Either<Failure, dynamic>> _updateEmployeeRoles(
    String employeeId,
    String accessName,
  ) async {
    try {
      final dynamic fetchResult = await remoteDataSource.getEmployeeModel(
        employeeId,
      );

      Either<Failure, dynamic> result;
      if (fetchResult is Either<Failure, dynamic>) {
        result = fetchResult;
      } else {
        result = Right<Failure, dynamic>(fetchResult);
      }

      if (result.isLeft()) return result;

      Map<String, dynamic>? data = result.getOrElse(() => null);
      if (data == null) {
        return Left(FeatureFailure("Employee not found"));
      }

      NewEmployeeModelHistory employeeModel = NewEmployeeModelHistory.fromMap(
        data,
      );

      NewEmployeeModelHistory updatedModel =
          employeeModel.copyWithUpdateSynchronized(role: accessName);

      remoteDataSource.updateEmployeeModel(
        id: employeeId,
        data: updatedModel.toMap(),
      );

      return Right(true);
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  // ✅ FIXED: explicit return types to avoid Right<dynamic,bool> cast errors
  Future<Either<Failure, dynamic>> deleteEmployeePermission({
    required String employeeId,
    required String currentUserEmail,
  }) async {
    try {
      remoteDataSource.startTransaction();

      Either<Failure, dynamic> result = await _deleteEmployeePermission(
        employeeId,
        currentUserEmail,
      );
      if (result.isLeft()) return result;

      Either<Failure, dynamic> result2 = await _updateEmployeeRoles(
        employeeId,
        Constants.removedEmployeePermission,
      );
      if (result2.isLeft()) return result2;

      final dynamic commitResult = await remoteDataSource.commitTransaction();

      // ADDED 25/8/2026 — spec §1.5 "Access Revoked": the affected user, then
      // every Master Admin. Only once the revocation is actually persisted.
      final bool committed = commitResult is Either<Failure, dynamic>
          ? commitResult.isRight()
          : true;
      if (committed) {
        final EmployeeEntityPro? employee = _employeeById(employeeId);
        final String? email = employee?.email;
        if (email != null && email.isNotEmpty) {
          await UserManagementNotificationService.sendAccessRevokedNotification(
            userEmail: email,
            userName: _displayName(employee, email),
            senderEmail: currentUserEmail,
          );
        }
      }

      if (commitResult is Either<Failure, dynamic>) {
        return commitResult;
      }
      return Right<Failure, dynamic>(true);
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS — spec §1.5 "User Management & Permissions"
  //
  //  ADDED 25/8/2026. `user_management_events.dart` has carried all eight
  //  of these events since the catalog was written and
  //  `UserManagementNotificationService` has been able to send them since
  //  18/8/2026 — but nothing in this module ever called it, so every one of
  //  the eight admin-editable templates was dead weight. Its own header
  //  said as much: "It does NOT wire itself into r2_user_management."
  //  This section is that wiring.
  //
  //  Six of the eight fire from this file. Note SIX, not seven: the note that
  //  stood here said "seven of the eight now fire", which double-counted —
  //  `sendScheduledAccessAppliedNotification` sends BOTH the user and the
  //  admin row of that pair, so one uncalled method left two spec rows unsent.
  //
  //  UPDATE 26/8/2026 — the remaining pair now fires too, from
  //  `ScheduledAccessApplier`, called at the top of
  //  `getUsersPermissionsData()`. The note this replaces was right that no job
  //  existed and wrong about what the job had to be: `From_Date` is not a
  //  deferred write waiting to be flushed — `updateUserPermission` puts the
  //  role on the account in the same transaction that stores the date — so
  //  there was never anything to "execute". What was missing was something to
  //  NOTICE the date arriving. That is what the applier does, and its header
  //  carries the reasoning.
  //
  //  All eight §1.5 rows are therefore live.
  // ══════════════════════════════════════════════════════════════════

  /// Function Name: [_employeeById]
  ///
  /// Purpose: The directory record for [employeeId].
  ///
  /// The permission collection is keyed by employee id but every
  /// notification is addressed by email, so one of the two has to be
  /// resolved against the other. `MainCoreEmployeeController` only indexes
  /// by email, hence the scan — the map is the already-loaded directory, so
  /// this costs no I/O.
  ///
  /// Parameters:
  /// - [employeeId]: the `Employee_Id` the permission document is keyed by.
  ///
  /// Returns: [EmployeeEntityPro?] — `null` when the directory has no such id.
  EmployeeEntityPro? _employeeById(String employeeId) {
    if (employeeId.trim().isEmpty) return null;
    for (final EmployeeEntityPro employee
        in AppControllers.employee.mapOfEmployeesWithEmailKey.values) {
      if (employee.id == employeeId) return employee;
    }
    return null;
  }

  /// Function Name: [_notifyAccessChanged]
  ///
  /// Purpose: Send the notification a saved permission change earns, once the
  /// write has committed.
  ///
  /// Which of the four it is:
  /// - a role assigned where the user had none, or a different one →
  ///   **Access Granted** (§1.5.1)
  /// - the same role re-saved with different dates or permissions →
  ///   **Access Updated** (§1.5.2)
  /// - the new start date is in the future → **Access Change Scheduled**
  ///   (§1.5.4), carrying that date
  /// - the start date WAS in the future and no longer is → **Scheduled Access
  ///   Change Cancelled** (§1.5.6)
  ///
  /// The scheduled pair is additive: a change that both takes effect now and
  /// withdraws a pending one legitimately sends two notices, because two
  /// distinct things happened to the user's access.
  ///
  /// Parameters:
  /// - [employeeId]: whose access changed.
  /// - [actorEmail]: the administrator who saved it; becomes the sender.
  /// - [isNewAssignment]: granted vs updated, as computed by the caller.
  /// - [accessBegin] / [previousAccessBegin]: the new and prior start dates.
  ///
  /// Returns: [Future<void>] — never throws. A notification that cannot be
  /// sent must not fail the permission change that has already been written.
  Future<void> _notifyAccessChanged({
    required String employeeId,
    required String actorEmail,
    required bool isNewAssignment,
    String? accessBegin,
    String? previousAccessBegin,
  }) async {
    try {
      final EmployeeEntityPro? employee = _employeeById(employeeId);
      final String? email = employee?.email;
      if (email == null || email.isEmpty) return;

      if (isNewAssignment) {
        await UserManagementNotificationService.sendAccessGrantedNotification(
          userEmail: email,
          senderEmail: actorEmail,
        );
      } else {
        await UserManagementNotificationService.sendAccessUpdatedNotification(
          userEmail: email,
          senderEmail: actorEmail,
        );
      }

      final DateTime now = DateTime.now();
      final DateTime? newStart = parseAccessDate(accessBegin, label: 'from');
      final DateTime? oldStart = parseAccessDate(
        previousAccessBegin,
        label: 'previous from',
      );

      final bool startsInFuture = newStart != null && newStart.isAfter(now);
      final bool startedInFuture = oldStart != null && oldStart.isAfter(now);

      if (startsInFuture) {
        await UserManagementNotificationService
            .sendAccessChangeScheduledNotification(
          userEmail: email,
          scheduledDate: accessBegin ?? '',
          senderEmail: actorEmail,
        );
      }

      // A pending start date that is no longer pending — cleared, or moved to
      // a date that has already passed — is a withdrawn schedule.
      if (startedInFuture && !startsInFuture) {
        await UserManagementNotificationService
            .sendScheduledAccessCancelledNotification(
          userEmail: email,
          senderEmail: actorEmail,
        );
      }
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }

  // REMOVED 9/10/2026: `checkModuleUserLimitsBeforeAssignment` — 0 call
  // sites, and its catch returned `Right(null)`: any read error meant "OK".

  /// ✅ Robust date parser — handles BOTH English and Arabic stored dates.
  /// Some records were saved in Arabic (e.g. "أكتوبر ١٩, ٢٠٢٦") because the
  /// write side formatted with the Arabic locale; this reads them all.
  /// Returns null only if NONE of the formats matched.
  /// Function Name: [parseAccessDate]
  ///
  /// Purpose: Parse a stored access date, tolerating every format this data
  /// has been written in (ISO, dd/MM/yyyy, English named-month, Arabic
  /// named-month, and `Constants.userAccessDateFormat`).
  ///
  /// Made public 12/8/2026: `UserManagementController.getExpiringPermissions`
  /// and `validatePermissionDates` were calling `DateTime.parse` on strings
  /// written as "MMM dd, yyyy". `DateTime.parse` accepts ISO-8601 only, so both
  /// threw on every row, were swallowed by their local catch, and silently
  /// returned `[]` / `false` — the "expiring soon" surfacing and the date
  /// validation had never worked. They now share this parser.
  ///
  /// Parameters:
  /// - [raw]: The stored date string.
  /// - [label]: Optional tag used in the diagnostic log.
  ///
  /// Returns: [DateTime?] `null` when no known format matches.
  DateTime? parseAccessDate(String? raw, {String label = ''}) {
    if (raw == null || raw.trim().isEmpty || raw == '-' || raw == 'null') {
      return null;
    }

    // Normalize Arabic/Persian digits up front so every branch benefits.
    final s = _normalizeDigits(raw.trim());

    // 1) ISO / yyyy-MM-dd (also yyyy-MM-ddTHH:mm:ss)
    try {
      final d = DateTime.parse(s);
      return d;
    } catch (_) {}

    // 2) dd/MM/yyyy
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length == 3) {
        try {
          final d = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          return d;
        } catch (_) {}
      }
    }

    // 3) English named-month formats (with / without comma)
    const formats = [
      'MMM dd, yyyy',
      'dd MMM, yyyy',
      'MMMM dd, yyyy',
      'dd MMMM, yyyy',
      'dd MMM yyyy',
      'MMM dd yyyy',
      'dd MMMM yyyy',
      'MMMM dd yyyy',
    ];
    for (final f in formats) {
      try {
        final d = DateFormat(f, 'en').parse(s);
        return d;
      } catch (_) {}
    }

    // 4) Arabic month names (e.g. "أكتوبر 19, 2026" after digit normalization)
    final ar = _tryParseArabic(s);
    if (ar != null) {
      return ar;
    }

    // 5) the configured app format, last resort
    try {
      final d = DateFormat(Constants.userAccessDateFormat, 'en').parse(s);
      return d;
    } catch (_) {}

    return null;
  }
}
