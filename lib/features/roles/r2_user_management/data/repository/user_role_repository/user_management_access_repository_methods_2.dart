/// Module: roles/r2_user_management
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_access_repository_methods_2.dart
/// Description: Methods of `UserManagementAccessRepository` — split out of `user_role_repository.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../user_role_repository.dart';

// Split from user_role_repository.dart to keep every file under 700 lines.

extension UserManagementAccessRepositoryMethods2
    on UserManagementAccessRepository {
  /// ✅ Status logic:
  ///   - end unparseable                  → active (loud warning, fix data)
  ///   - now > end                        → inactive
  ///   - now < start                      → scheduled (not started yet)
  ///   - deactivated and that date passed → inactive
  ///   - <= 12 days left until end        → expiringSoon
  ///   - between start and end (>12 left) → active
  /// Heavy prints so you can see WHY a card got its status.
  UserAccessStatus getUserAccessStatus(
    UserPermissionHistoryModel userAccessModel,
    String? deactivationDate,
  ) {
    final now = DateTime.now();

    final DateTime? startDate = parseAccessDate(
      userAccessModel.currentFromDate,
      label: 'start',
    );
    final DateTime? endDate = parseAccessDate(
      userAccessModel.currentToDate,
      label: 'end',
    );

    // 🔴 If we cannot read the END date, DON'T silently mark inactive.
    if (endDate == null) {
      return UserAccessStatus.active;
    }

    // 1) Past the end date → inactive
    if (now.isAfter(endDate)) {
      return UserAccessStatus.inactive;
    }

    // 2) Hasn't started yet (now < start) → scheduled
    if (startDate != null && now.isBefore(startDate)) {
      return UserAccessStatus.scheduled;
    }

    if (startDate == null) {}

    // 3) Deactivated and that date has passed → inactive
    final DateTime? deact = parseAccessDate(
      deactivationDate,
      label: 'deactivation',
    );
    if (deact != null && now.isAfter(deact)) {
      return UserAccessStatus.inactive;
    }

    // 4) 12 days or fewer left until the end date → expiring soon
    final int daysLeft = endDate.difference(now).inDays;
    if (daysLeft <= 12) {
      return UserAccessStatus.expiringSoon;
    }

    // 5) Between start and end with more than 12 days left → active
    return UserAccessStatus.active;
  }

  /// Function Name: [precheckAssignments]
  ///
  /// Purpose: Check [proposed] against a fresh (non-transactional) read. For
  /// the paths whose writes cannot ride in the checked transaction
  /// (`updateUserPermission(isCommit: false)`, the legacy import page).
  ///
  /// Returns: [Future<Either<Failure, void>>] — `Left(ModuleUserLimitFailure)`
  /// when a limit blocks, `Left` with the "could not verify" message when the
  /// read fails, `Right` otherwise.
  Future<Either<Failure, void>> precheckAssignments(
    List<ProposedAssignment> proposed,
  ) async {
    final Either<Failure, LicenceUsageSnapshot> snapshot =
        await readLicenceUsage();
    return snapshot.fold((Failure failure) => Left<Failure, void>(failure), (
      LicenceUsageSnapshot usage,
    ) {
      final LimitVerdict verdict = usage.check(proposed);
      return verdict.allowed
          ? const Right<Failure, void>(null)
          : Left<Failure, void>(ModuleUserLimitFailure(verdict));
    });
  }

  /// The seat change of giving [role] to [employeeIds] — empty when [role]
  /// grants nothing (blank or revoked), i.e. there is nothing to check.
  List<ProposedAssignment> _seatChangeFor(
    List<String> employeeIds,
    String role,
  ) {
    if (role.trim().isEmpty || role == Constants.removedEmployeePermission) {
      return const <ProposedAssignment>[];
    }
    return <ProposedAssignment>[
      for (final String id in employeeIds)
        if (id.trim().isNotEmpty)
          ProposedAssignment(employeeId: id, role: role),
    ];
  }

  /// Function Name: [_commitWithSeatCheck]
  ///
  /// Purpose: Commit the queued permission writes inside a Firestore
  /// transaction that first re-checks the user limits for [proposed].
  ///
  /// Returns: [Future<Either<Failure, dynamic>>]
  /// - `Right(true)` once written;
  /// - `Left(ModuleUserLimitFailure)` — EN/AR message naming the module and
  ///   the limit — when a limit blocks; nothing is written;
  /// - `Left` with the "could not verify" message when the check itself could
  ///   not run (offline, read refused, malformed data); nothing is written;
  /// - `Left` with the raw error when the check passed but the write failed.
  Future<Either<Failure, dynamic>> _commitWithSeatCheck({
    required List<ProposedAssignment> proposed,
    required String actorEmail,
  }) async {
    LimitVerdict? refused;
    bool checked = false;

    final Either<Failure, dynamic> result = await remoteDataSource
        .commitTransactionChecked((Transaction transaction) async {
      // Reset on every attempt: Firestore re-runs this on contention.
      refused = null;
      checked = false;
      try {
        await _seatGuard.checkInTransaction(
          transaction,
          proposed: proposed,
          actorEmail: actorEmail,
        );
        checked = true;
      } on LicenceSeatLimitException catch (e) {
        refused = e.verdict;
        rethrow;
      }
    });

    if (result.isRight()) return result;
    final LimitVerdict? verdict = refused;
    if (verdict != null) return Left(ModuleUserLimitFailure(verdict));
    if (!checked) {
      return Left(FeatureFailure(ModuleUserLimitMessages.checkFailed));
    }
    return result;
  }

  /// Function Name: [countCurrentHolders]
  ///
  /// Purpose: How many employees still hold a role — ADDED 21/10/2026 so
  /// Delete Role is blocked while the role is in use (X-87). An access line
  /// counts when its current role is [roleId] or [roleName] (older lines
  /// stored the name) and its access has not ended. Removed lines never count.
  ///
  /// Returns: [Future<int>] — throws when User_Management cannot be read, so
  /// the caller never deletes a role on an unknown count.
  Future<int> countCurrentHolders({
    required String roleId,
    required String roleName,
  }) async {
    final QuerySnapshot snapshot =
        await remoteDataSource.accessEmployeeCollection.get();
    final Map<String, DateTime?> deactivations = _deactivationDates();
    int holders = 0;
    for (final QueryDocumentSnapshot doc in snapshot.docs) {
      final Object? data = doc.data();
      if (data is! Map<String, dynamic>) continue;
      final UserPermissionHistoryModel access =
          UserPermissionHistoryModel.fromMap(data);
      final String role = access.currentRole;
      if (role == Constants.removedEmployeePermission) continue;
      if (role != roleId && role != roleName) continue;
      final UserAccessStatus status = getUserAccessStatus(
        access,
        deactivations[doc.id]?.toIso8601String(),
      );
      if (status != UserAccessStatus.inactive) holders++;
    }
    return holders;
  }

  /// Employee id → deactivation date, from the already-loaded directory.
  /// Unknown → the employee is counted (the strict side).
  Map<String, DateTime?> _deactivationDates() {
    if (!AppControllers.isEmployeeRegistered) {
      return const <String, DateTime?>{};
    }
    final List<EmployeeEntityPro> employees =
        AppControllers.employee.allEmployeesEntities ??
            const <EmployeeEntityPro>[];
    return <String, DateTime?>{
      for (final EmployeeEntityPro e in employees)
        if ((e.id ?? '').isNotEmpty &&
            (e.deactivationDate ?? '').trim().isNotEmpty)
          e.id!: parseAccessDate(e.deactivationDate, label: 'deactivation'),
    };
  }
}
