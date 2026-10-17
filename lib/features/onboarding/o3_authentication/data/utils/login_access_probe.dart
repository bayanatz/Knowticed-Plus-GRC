/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: login_access_probe.dart
/// Description: Debug-only probe that names the exact Firestore path a sign-in was
///          refused on.
/// Author: Amr Mesbah
/// Created at: 7/9/2026
///
/// WHY THIS EXISTS
/// ---------------
/// The sign-in dialog can read:
///
///   Authentication Error
///   [cloud_firestore/permission-denied] The caller does not have permission
///   to execute the specified operation.
///
/// That string is not a login failure at all. It is a raw `FirebaseException`
/// caught by one of the `catch (e) => Left(FirebaseFailure(e.toString()))`
/// sites in the login chain, wrapped as a `Failure`, and then dropped into
/// `DemoLoginController.handleAuthenticationErrorMessage`, where
/// `FailureAuthenticationType.values.firstWhere(...)` cannot match it and the
/// generic "Authentication Error" dialog is shown verbatim.
///
/// The message never says WHICH read was refused, and a sign-in touches at
/// least six different Firestore locations across two top-level collections:
///
///   1. Demo_Users_Accounts/{email}          — the account overview
///   2. Demo_Requests/{companyId}            — the demo request + limits
///   3. Demo/{companyId}/Employees_Info      — count(), for the user limit
///   4. Demo/{companyId}/Employees_Info      — where Email arrayContains email
///   5. Demo/{companyId}/Roles               — per-module user counting
///   6. Demo/{companyId}/Users_Access        — per-module user counting
///   7. Demo/{companyId}/Users_Access/{id}   — the access date window
///
/// This probe walks the same seven reads in the same order and prints the
/// outcome of each, so the security rule that refuses the request is named
/// instead of guessed at.
///
/// NOTE: the app never calls `FirebaseAuth.signIn*` anywhere, so every one of
/// these reads arrives at the rules with `request.auth == null`. Any rule of
/// the form `allow read: if request.auth != null;` — or an expired test-mode
/// rule, `allow read, write: if request.time < timestamp.date(...)` — denies
/// all seven at once. The probe distinguishes that (everything DENIED) from a
/// single collection whose rule changed (one line DENIED, the rest OK).
///
/// Debug builds only: `debugPrint` is NOT stripped from release builds, and
/// these lines carry the tenant path and the employee id. Same gating as
/// `DemoRemoteDataSource.getEmployeePermission`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/models/demo_user_account_overview.dart';

abstract class LoginAccessProbe {

  /// Function Name: [run]
  ///
  /// Purpose: Attempt every Firestore read the sign-in chain performs and log
  ///          which ones the security rules allow.
  ///
  /// Parameters:
  /// - [email]: the normalised (trimmed, lower-cased) sign-in email.
  ///
  /// Returns: nothing — this is a diagnostic. It never throws, and it must
  /// never change what the real login does, so call it *before* `login()` and
  /// ignore its outcome.
  static Future<void> run(String email) async {
    if (!kDebugMode) return;

    final FirebaseFirestore db = FirebaseFirestore.instance;

    // No FirebaseAuth in this codebase — stated explicitly, because it is the
    // single most likely cause of a blanket permission-denied.

    // ── 1. Demo_Users_Accounts/{email} ────────────────────────────────────
    final String accountPath = '${ApiConstants.demoUsersAccounts}/$email';
    final Map<String, dynamic>? account = await _readDoc(
      db,
      accountPath,
      label: 'account overview',
    );

    if (account == null) {
      return;
    }

    final Object? rawCompanyId =
        account[DemoUserAccountOverview.companyIdField];
    final String companyId = rawCompanyId?.toString() ?? '';

    if (companyId.isEmpty) {
      return;
    }

    // ── 2. Demo_Requests/{companyId} ──────────────────────────────────────
    await _readDoc(
      db,
      '${ApiConstants.demoRequests}/$companyId',
      label: 'demo request + module limits',
    );

    // ── 3/4. Demo/{companyId}/Employees_Info ──────────────────────────────
    final String employeesPath = 'Demo/$companyId/${ApiConstants.employeeInfo}';
    await _count(db, employeesPath, label: 'employee count (user limit)');

    final List<QueryDocumentSnapshot<Map<String, dynamic>>>? employees =
        await _readQuery(
      db.collection(employeesPath).where('Email', arrayContains: email),
      employeesPath,
      label: 'employee record for this email',
    );

    // ── 5/6. Roles and Users_Access collections ───────────────────────────
    await _readQuery(
      db.collection('Demo/$companyId/Roles'),
      'Demo/$companyId/Roles',
      label: 'roles (per-module user count)',
    );

    await _readQuery(
      db.collection('Demo/$companyId/Users_Access'),
      'Demo/$companyId/Users_Access',
      label: 'users access (per-module user count)',
    );

    // ── 7. The employee's own access-window document ──────────────────────
    if (employees != null && employees.isNotEmpty) {
      final String employeeId = employees.first.id;
      await _readDoc(
        db,
        'Demo/$companyId/Users_Access/$employeeId',
        label: 'access date window for employee $employeeId',
      );
    } else {}
  }

  /// One document read, reported rather than thrown.
  ///
  /// Returns the document data on success, `null` on any other outcome —
  /// including a document that simply does not exist, which is NOT a rules
  /// problem and is labelled differently.
  static Future<Map<String, dynamic>?> _readDoc(
    FirebaseFirestore db,
    String path, {
    required String label,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await db.doc(path).get();

      if (!snapshot.exists) {
        return null;
      }

      return snapshot.data();
    } on FirebaseException {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// One collection / query read, reported rather than thrown.
  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> _readQuery(
    Query<Map<String, dynamic>> query,
    String path, {
    required String label,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      return snapshot.docs;
    } on FirebaseException {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// `count()` aggregation — worth probing separately, because an aggregation
  /// query is evaluated against the rules of the whole collection and can be
  /// refused where a single-document read is allowed.
  static Future<void> _count(
    FirebaseFirestore db,
    String path, {
    required String label,
  }) async {
    try {
      await db.collection(path).count().get();
    } on FirebaseException {
      // Ignored on purpose: nothing to do when this fails.
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }

}
