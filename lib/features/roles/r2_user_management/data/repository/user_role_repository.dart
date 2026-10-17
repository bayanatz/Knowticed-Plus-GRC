/// Module: roles / r2_user_management / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: user_role_repository.dart
/// Description: Declares `UserManagementAccessRepository`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/features/roles/helpers/image_selector.dart';
// REMOVED 9/10/2026: api_constants.dart — only `_getCompanyId` used it (now in LicenceSeatGuard).
import 'package:grc_module/core/network/failure_model.dart';

import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:grc_module/core/helper/access/main_core_employee_controller.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/entities/new_permission_entity.dart';
import 'package:grc_module/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:grc_module/core/helper/access/constants.dart';
import 'package:grc_module/features/roles/r2_user_management/domain/enums/user_access_status.dart';
import 'package:grc_module/features/roles/r1_role_management/data/data_source/remote_data_source/role_remote_data_source.dart';
// REMOVED 9/10/2026: firebase_collections.dart — only the old `getModuleUserLimits` used it.
import 'package:grc_module/core/di/app_controllers.dart';
// ADDED 25/8/2026 — spec §1.5. See the NOTIFICATIONS section below.
import 'package:grc_module/features/notification/data/repository/user_management_notification_service.dart';
// ADDED 26/8/2026 — the missing trigger for the eighth §1.5 row.
import 'package:grc_module/features/roles/r2_user_management/data/services/scheduled_access_applier.dart';
// ADDED 9/10/2026 — per-module user limits (see the USER LIMITS section).
import 'package:grc_module/features/roles/r2_user_management/data/services/licence_seat_guard.dart';
import 'package:grc_module/features/roles/r2_user_management/data/services/module_user_limit_messages.dart';
import 'package:grc_module/features/roles/r2_user_management/domain/services/module_user_limit_rule.dart';
import 'package:flutter/foundation.dart';

import 'dart:async';

part 'user_role_repository/user_management_access_repository_methods.dart';
part 'user_role_repository/user_management_access_repository_methods_2.dart';

class UserManagementAccessRepository {
  final RoleRemoteDataSource remoteDataSource = RoleRemoteDataSource();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ADDED 9/10/2026 — reads the Admin user limits and re-checks them inside
  /// the grant's transaction. See [_commitWithSeatCheck].
  late final LicenceSeatGuard _seatGuard = LicenceSeatGuard(
    firestore: _firestore,
    parseDate: (String raw) =>
        parseAccessDate(raw, label: 'seat') ?? defaultParseAccessDate(raw),
    deactivatedOn: _deactivationDates,
  );

  /// Detects pre-dated access changes whose start date has arrived. See
  /// [ScheduledAccessApplier] — it is the trigger for §1.5's "Scheduled Access
  /// Applied" pair, which had none.
  final ScheduledAccessApplier _scheduledAccessApplier =
      ScheduledAccessApplier();

  Future<Either<Failure, dynamic>> getUsersPermissionsData() async {
    final totalStopwatch = Stopwatch()..start();

    try {
      Map<String, NewEmployeeModelHistory> users = await _getEmployees();

      if (users.isEmpty) {
        totalStopwatch.stop();
        return Right(<UserPermissionEntity>[]);
      }

      Either<Failure, dynamic> result = await _getUsersPermissions(users);

      // ADDED 26/8/2026 — unawaited on purpose. The screen is waiting on
      // [result] and has no use for the applier's outcome; a Firestore scan and
      // a notification fan-out behind it would otherwise be added to the load
      // time of a screen that is already slow enough to carry a stopwatch.
      // The applier never throws, so nothing escapes this call.
      unawaited(_scheduledAccessApplier.applyDue());

      totalStopwatch.stop();
      return result;
    } catch (e) {
      totalStopwatch.stop();
      return Left(FeatureFailure(e.toString()));
    }
  }

  UserPermissionEntity _getUserPermissions({
    required Map<String, NewEmployeeModelHistory> users,
    required NewEmployeeModelHistory userData,
    required UserPermissionHistoryModel userAccessModel,
  }) {
    try {
      NewEmployeeModelHistory? grantor = users[userAccessModel.currentEditBy];

      String employeeEmail =
          userData.email.isNotEmpty ? userData.email.last : '';

      return UserPermissionEntity(
        employeeEmail: employeeEmail,
        employeeId: userData.id!,
        gender: userData.gender.isNotEmpty ? userData.gender.last : null,
        departmentId: userData.departmentId.isNotEmpty
            ? userData.departmentId.last
            : null,
        arabicJobTitle: userData.titleInArabic.isNotEmpty
            ? userData.titleInArabic.last
            : null,
        englishJobTitle: userData.title.isNotEmpty ? userData.title.last : null,
        imagePath: ImageSelector.getUserImage(
          imagePath: null,
          gender: userData.gender.isNotEmpty ? userData.gender.last : null,
        ),
        englishName: _getEnglishName(userData),
        arabicName: _getArabicName(userData),
        accessName: userAccessModel.currentRole,
        grantorEnglishName:
            grantor != null ? _getEnglishName(grantor) : 'Unknown',
        grantorArabicName:
            grantor != null ? _getArabicName(grantor) : 'غير معروف',
        startDate: userAccessModel.currentFromDate,
        accessStatus: getUserAccessStatus(
          userAccessModel,
          userData.deactivationDate,
        ),
        endDate: userAccessModel.currentToDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  String _getEnglishName(NewEmployeeModelHistory employee) {
    String firstName =
        employee.firstName.isNotEmpty ? employee.firstName.last : '';
    String lastName =
        employee.lastName.isNotEmpty ? employee.lastName.last : '';
    return '$firstName $lastName'.trim();
  }

  String _getArabicName(NewEmployeeModelHistory employee) {
    String firstName = employee.firstNameInArabic.isNotEmpty
        ? employee.firstNameInArabic.last
        : '';
    String lastName = employee.lastNameInArabic.isNotEmpty
        ? employee.lastNameInArabic.last
        : '';
    return '$firstName $lastName'.trim();
  }

  // ✅ FIXED: explicit return types to avoid Right<dynamic,bool> cast errors
  Future<Either<Failure, dynamic>> _deleteEmployeePermission(
    String employeeId,
    String currentUserEmail,
  ) async {
    try {
      final dynamic fetchResult = await remoteDataSource.getUserAccessModels(
        id: employeeId,
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
        return Right(true);
      }

      UserPermissionHistoryModel userPermissionModel =
          UserPermissionHistoryModel.fromMap(data);

      UserPermissionHistoryModel updatedModel = userPermissionModel.copyWith(
        role: Constants.removedEmployeePermission,
        editBy: currentUserEmail,
      );

      remoteDataSource.updateRoleWithinTransaction(
        id: employeeId,
        data: updatedModel.toMap(),
      );
      return Right(true);
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  /// The name to print inside an admin-facing notification. Falls back to the
  /// address rather than to the controller's "no name" sentinel.
  String _displayName(EmployeeEntityPro? employee, String email) {
    final String first = employee?.firstName?.trim() ?? '';
    final String last = employee?.lastName?.trim() ?? '';
    final String full = '$first $last'.trim();
    return full.isEmpty ? email : full;
  }

  Future<Either<Failure, dynamic>> updateUserPermission({
    required String employeeId,
    required String currentUserEmail,
    String? accessName,
    String? accessBegin,
    String? accessEnd,
    bool isCommit = true,
  }) async {
    String? currentExistingRole;
    bool isActuallyNewAssignment = true;

    // The access start date as it stood BEFORE this save. Needed to tell a
    // newly scheduled change from one that was just withdrawn — see
    // `_notifyAccessChanged`.
    String? previousAccessBegin;

    Either<Failure, dynamic> currentCheck =
        await remoteDataSource.getUserAccessModels(id: employeeId);

    if (currentCheck.isRight()) {
      Map<String, dynamic>? currentData = currentCheck.getOrElse(() => null);
      if (currentData != null) {
        try {
          UserPermissionHistoryModel currentModel =
              UserPermissionHistoryModel.fromMap(currentData);
          currentExistingRole = currentModel.currentRole;
          previousAccessBegin = currentModel.currentFromDate;

          if (currentExistingRole.isNotEmpty &&
              accessName != null &&
              currentExistingRole.toLowerCase() == accessName.toLowerCase()) {
            isActuallyNewAssignment = false;
          }
        } catch (e) {
          // Was an empty `catch {}`: a failure here silently left
          // `isActuallyNewAssignment` at its default, which decides whether a
          // notification fires (§11.5).
        }
      }
    }

    // REPLACED 9/10/2026 — the old pre-check here only looked at `services`,
    // only on a role CHANGE, counted through `getModuleUserCount` (which found
    // ~0 holders: wrong role field names, wrong collection) and let any error
    // through. The limit is now checked for EVERY module of the role plus the
    // company total, inside the transaction that commits this write — see
    // [_commitWithSeatCheck]. A date-only save is checked too: extending an
    // expired user's end date gives them their seat back.
    final String effectiveRole = (accessName != null && accessName.isNotEmpty)
        ? accessName
        : (currentExistingRole ?? '');
    final List<ProposedAssignment> seatChange = _seatChangeFor(<String>[
      employeeId,
    ], effectiveRole);

    if (!isCommit && seatChange.isNotEmpty) {
      // The caller owns the batch, so the check cannot ride in a transaction
      // here; check now and refuse before anything is queued.
      final Either<Failure, void> pre = await precheckAssignments(seatChange);
      if (pre.isLeft()) {
        return Left<Failure, dynamic>(
          pre.fold((Failure f) => f, (_) => FeatureFailure('')),
        );
      }
    }

    if (isCommit) {
      remoteDataSource.startTransaction();
    }

    Either<Failure, dynamic> result =
        await remoteDataSource.getUserAccessModels(id: employeeId);

    if (result.isLeft()) {
      return result;
    }

    Map<String, dynamic>? data = result.getOrElse(() => null);

    if (data == null) {
      await _createNewUserPermission(
        employeeId: employeeId,
        role: accessName!,
        fromDate: accessBegin!,
        toDate: accessEnd!,
        editBy: currentUserEmail,
      );

      await _updateEmployeeRoles(employeeId, accessName);
    } else {
      UserPermissionHistoryModel existingModel =
          UserPermissionHistoryModel.fromMap(data);

      String? effectiveRole = accessName?.isNotEmpty == true
          ? accessName
          : existingModel.currentRole;

      await _updateEmployeePermission(
        existingModel: existingModel,
        employeeId: employeeId,
        role: effectiveRole,
        fromDate: accessBegin,
        toDate: accessEnd,
        editBy: currentUserEmail,
      );

      if (accessName != null &&
          accessName.isNotEmpty &&
          accessName != existingModel.currentRole) {
        await _updateEmployeeRoles(employeeId, accessName);
      }
    }

    if (isCommit) {
      // 9/10/2026 — a grant commits in a transaction that re-checks the user
      // limits first; a revocation (no seat change) keeps the plain batch.
      final dynamic commitResult = seatChange.isNotEmpty
          ? await _commitWithSeatCheck(
              proposed: seatChange,
              actorEmail: currentUserEmail,
            )
          : await remoteDataSource.commitTransaction();

      // ADDED 25/8/2026 — spec §1.5. Only after the write actually lands: a
      // failed commit must not tell the user their access changed.
      final bool committed = commitResult is Either<Failure, dynamic>
          ? commitResult.isRight()
          : true;
      if (committed) {
        await _notifyAccessChanged(
          employeeId: employeeId,
          actorEmail: currentUserEmail,
          isNewAssignment: isActuallyNewAssignment,
          accessBegin: accessBegin,
          previousAccessBegin: previousAccessBegin,
        );
      }

      if (commitResult is Either<Failure, dynamic>) {
        return commitResult;
      }
      return Right<Failure, dynamic>(true);
    }

    // `isCommit: false` means the caller owns the transaction — and therefore
    // owns the notification too, once it knows the commit succeeded.
    return Right(true);
  }

  Future<void> _updateEmployeePermission({
    required UserPermissionHistoryModel existingModel,
    required String employeeId,
    String? role,
    String? fromDate,
    String? toDate,
    required String editBy,
  }) async {
    if (role != null && role != existingModel.currentRole) {
      await _updateEmployeeRoles(employeeId, role);
    }

    UserPermissionHistoryModel updatedModel = existingModel.copyWith(
      role: role,
      fromDate: fromDate,
      toDate: toDate,
      editBy: editBy,
    );

    remoteDataSource.updateRoleWithinTransaction(
      id: employeeId,
      data: updatedModel.toMap(),
    );
  }

  Future<void> _createNewUserPermission({
    required String employeeId,
    required String role,
    required String fromDate,
    required String toDate,
    required String editBy,
  }) async {
    UserPermissionHistoryModel userPermissionModel =
        UserPermissionHistoryModel.createNew(
      employeeId: employeeId,
      role: role,
      fromDate: fromDate,
      toDate: toDate,
      editBy: editBy,
    );

    remoteDataSource.updateRoleWithinTransaction(
      id: employeeId,
      data: userPermissionModel.toMap(),
    );
  }

  Future<Either<Failure, dynamic>> updateSelectedMembersPermission({
    required String currentUserEmail,
    required String accessName,
    required String startDate,
    required String endDate,
    required List<EmployeeEntityPro> selectedMembers,
  }) async {
    // REPLACED 9/10/2026 — the old pre-check here only looked at `services`,
    // added the whole selection to a count that found ~0 holders, and was
    // skipped entirely when the company id or the limit could not be read. The
    // selection is now checked against EVERY module of the role and the
    // company total inside the commit's transaction ([_commitWithSeatCheck]).

    remoteDataSource.startTransaction();


    // Only the members whose write went through earn a notification, so the
    // ones that threw above are not told their access changed.
    final List<EmployeeEntityPro> written = <EmployeeEntityPro>[];

    for (EmployeeEntityPro selectedMember in selectedMembers) {
      try {
        final dynamic queued = await _updateUserPermissionWithoutLimitCheck(
          employeeId: selectedMember.id!,
          currentUserEmail: currentUserEmail,
          accessName: accessName,
          accessBegin: startDate,
          accessEnd: endDate,
        );
        // 9/10/2026 — a member whose permission read failed had nothing
        // queued; it was still counted as written (and notified).
        if (queued is Either && queued.isLeft()) {
          continue;
        }
        written.add(selectedMember);
      } catch (e) {
        debugPrint('Ignored error: $e');
      }
    }

    // 9/10/2026 — the whole selection is one seat change, checked and
    // committed in one transaction: all of it lands or none of it does.
    final List<ProposedAssignment> seatChange = _seatChangeFor(<String>[
      for (final EmployeeEntityPro m in written) m.id!,
    ], accessName);
    final dynamic commitResult = seatChange.isNotEmpty
        ? await _commitWithSeatCheck(
            proposed: seatChange,
            actorEmail: currentUserEmail,
          )
        : await remoteDataSource.commitTransaction();

    // ADDED 25/8/2026 — spec §1.5, the bulk path. One notification per member,
    // after the single shared commit: the loop above only queues writes into
    // the transaction, so nothing is persisted until this returns.
    final bool committed = commitResult is Either<Failure, dynamic>
        ? commitResult.isRight()
        : true;
    if (committed) {
      for (final EmployeeEntityPro member in written) {
        await _notifyAccessChanged(
          employeeId: member.id!,
          actorEmail: currentUserEmail,
          // This screen assigns one role to a batch of people, so from each
          // recipient's side it is a grant. Distinguishing per member would
          // need the prior role of each, which this path never reads.
          isNewAssignment: true,
          accessBegin: startDate,
        );
      }
    }

    if (commitResult is Either<Failure, dynamic>) {
      return commitResult;
    }
    return Right<Failure, dynamic>(true);
  }

  // REMOVED 12/8/2026: `_getRoleModules` — dead code, 0 call sites.

  // NOTE 9/10/2026: "WithoutLimitCheck" means only that this QUEUES writes
  // without checking; its one caller, `updateSelectedMembersPermission`,
  // checks the whole selection when it commits (`_commitWithSeatCheck`).
  Future<Either<Failure, dynamic>?> _updateUserPermissionWithoutLimitCheck({
    required String employeeId,
    required String currentUserEmail,
    required String accessName,
    required String accessBegin,
    required String accessEnd,
  }) async {
    Either<Failure, dynamic> result =
        await remoteDataSource.getUserAccessModels(id: employeeId);

    if (result.isLeft()) return result;

    Map<String, dynamic>? data = result.getOrElse(() => null);

    if (data == null) {
      await _createNewUserPermission(
        employeeId: employeeId,
        role: accessName,
        fromDate: accessBegin,
        toDate: accessEnd,
        editBy: currentUserEmail,
      );
      await _updateEmployeeRoles(employeeId, accessName);
    } else {
      UserPermissionHistoryModel existingModel =
          UserPermissionHistoryModel.fromMap(data);
      await _updateEmployeePermission(
        existingModel: existingModel,
        employeeId: employeeId,
        role: accessName,
        fromDate: accessBegin,
        toDate: accessEnd,
        editBy: currentUserEmail,
      );
    }
    return null;
  }

  /// Arabic (transliterated Gregorian) month name → month number.
  static const Map<String, int> _arabicMonths = {
    'يناير': 1,
    'فبراير': 2,
    'مارس': 3,
    'أبريل': 4,
    'ابريل': 4,
    'مايو': 5,
    'يونيو': 6,
    'يونيه': 6,
    'يوليو': 7,
    'يوليه': 7,
    'أغسطس': 8,
    'اغسطس': 8,
    'سبتمبر': 9,
    'أكتوبر': 10,
    'اكتوبر': 10,
    'نوفمبر': 11,
    'ديسمبر': 12,
  };

  /// Convert Arabic-Indic (٠-٩) and Persian (۰-۹) digits to Western (0-9).
  String _normalizeDigits(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    String r = input;
    for (int i = 0; i < 10; i++) {
      r = r
          .replaceAll(arabicIndic[i], western[i])
          .replaceAll(persian[i], western[i]);
    }
    return r;
  }

  /// Parse a date written in Arabic, e.g. "أكتوبر ١٩, ٢٠٢٦".
  /// Digits are already normalized before this is called.
  DateTime? _tryParseArabic(String normalized) {
    // Treat both Western and Arabic commas as separators.
    final cleaned = normalized.replaceAll(',', ' ').replaceAll('،', ' ');
    final tokens = cleaned
        .split(RegExp(r'\s+'))
        .where((t) => t.trim().isNotEmpty)
        .toList();
    if (tokens.length < 3) return null;

    int? month, day, year;
    for (final t in tokens) {
      if (_arabicMonths.containsKey(t)) {
        month = _arabicMonths[t];
      } else {
        final n = int.tryParse(t);
        if (n == null) continue;
        if (n > 31) {
          year = n; // 4-digit year
        } else if (day == null) {
          day = n; // first 1-2 digit number is the day
        } else {
          year ??= n;
        }
      }
    }

    if (month != null && day != null && year != null) {
      try {
        return DateTime(year, month, day);
      } catch (_) {}
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getUserPermissionHistory(
    String employeeId,
  ) async {
    Either<Failure, dynamic> result =
        await remoteDataSource.getUserAccessModels(id: employeeId);

    if (result.isLeft()) return [];

    Map<String, dynamic>? data = result.getOrElse(() => null);
    if (data == null) return [];

    UserPermissionHistoryModel model = UserPermissionHistoryModel.fromMap(data);
    return model.getHistory();
  }

  // ══════════════════════════════════════════════════════════════════
  //  USER LIMITS — per-module and total, set in Knowticed Admin
  //
  //  ADDED 9/10/2026. Replaces `_getCompanyId`, `getModuleUserLimits` and
  //  `getModuleUserCount`, which only ever ran for `services` and could not
  //  block anything:
  //   1. the count matched roles on `roleName` / `selectedModules`, but roles
  //      are saved as `Name` / `Selected_Modules` (role_model.dart toMap) —
  //      only the seeded Master Admin used camelCase, so no role matched;
  //   2. it counted holders in `Users_Access`, while every grant from this
  //      screen is written to `User_Management`;
  //   3. any error (read refused, offline) returned 0 / {} — "no limit".
  //
  //  Now: the rule is `ModuleUserLimitRule` (pure Dart, unit-tested), the
  //  reads are `LicenceSeatGuard`, and every grant commits through
  //  [_commitWithSeatCheck] — a Firestore transaction that re-counts before
  //  it writes. Every failure blocks.
  // ══════════════════════════════════════════════════════════════════

  /// Function Name: [readLicenceUsage]
  ///
  /// Purpose: The limits and current usage, for the User Management screens
  /// (usage lines under the Role Type, and the pre-check of a selection).
  ///
  /// Returns: [Future<Either<Failure, LicenceUsageSnapshot>>] — `Left` with
  /// the "could not verify" message on any read failure. Callers must treat
  /// `Left` as BLOCKED, never as "no limits".
  Future<Either<Failure, LicenceUsageSnapshot>> readLicenceUsage() async {
    try {
      return Right<Failure, LicenceUsageSnapshot>(
        await _seatGuard.readSnapshot(),
      );
    } catch (e, stackTrace) {
      debugPrint('readLicenceUsage failed: $e\n$stackTrace');
      return Left<Failure, LicenceUsageSnapshot>(
        FeatureFailure(ModuleUserLimitMessages.checkFailed),
      );
    }
  }
}
