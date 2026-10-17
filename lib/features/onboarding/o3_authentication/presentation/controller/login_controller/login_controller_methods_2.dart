/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: login_controller_methods_2.dart
/// Description: Methods of `LoginController` — split out of `login_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../login_controller.dart';

// Split from login_controller.dart to keep every file under 700 lines.

extension LoginControllerMethods2 on LoginController {
  /// 9/10/2026 DEBUG-ONLY: [password] is nullable for ONE caller,
  /// [debugSignInAsTestEmployee]. A password sign-in always passes it and
  /// behaves exactly as before; `null` stores no credential.
  Future<void> initData(
    BuildContext context,
    bool isTablet,
    String email,
    String? password,
  ) async {
    try {
      // ── Session bookkeeping ────────────────────────────────────────────
      String? previousUser = storage.read('email');

      if (previousUser != null && !Platform.isWindows) {
        // Fire-and-forget: unsubscribing the *previous* account from its push
        // topic has nothing to do with rendering this session's home screen,
        // and on a slow connection it was the first thing the spinner waited
        // on.
        unawaited(
          _ignoreFailure(
            appNotificationController.unsubscribeFromTopic(previousUser),
          ),
        );
      }

      await Get.delete<DrawerController>(force: true);
      await storage.write('email', email);
      if (password != null) {
        // SECURITY: was storage.write('password', password) on GetStorage,
        // an unencrypted on-disk JSON file. Now the Keychain / encrypted
        // shared preferences.
        await secureCredentialStore.writePassword(password);
        // 9/10/2026 DEBUG-ONLY: a real sign-in ends any test-employee
        // session (header badge off). No-op when none is active.
        DebugTestEmployeeSession.end();
      } else if (isDebugTestEmployeeSwitchEnabled()) {
        // 9/10/2026 DEBUG-ONLY — the "Switch to test employee" sign-in has
        // no password. Clear the PREVIOUS user's saved one so the biometric
        // auto-login can never pair it with the test email now in storage.
        await secureCredentialStore.clear();
      }

      // ── Critical path ──────────────────────────────────────────────────
      //
      // PERFORMANCE 22/8/2026: these three used to run one after another,
      // and were followed by another eight sequential awaits (all employees,
      // wrong employees, requests, company modules + a second role fetch,
      // the permission-sync listeners…) before the spinner came down. None of
      // that later work is needed to paint the first screen, so a sign-in
      // cost the sum of a dozen Firestore round-trips — the "loading too much
      // before entering the home page" report.
      //
      // What is genuinely required before navigating:
      //   • roles       — the drawer and every permission gate read them;
      //   • departments — resolved by the employee header;
      //   • the signed-in employee itself.
      // They are independent of each other, so they now run concurrently and
      // the critical path costs one round-trip instead of three.
      // DIAGNOSTIC 21/9/2026 — sign-in stalled after the password store
      // with no further log line. Each critical-path step now logs when it
      // finishes (debug builds only), so the one that never returns is the
      // last "[login-step] start" without a matching "done". Remove once found.
      await Future.wait(<Future<void>>[
        _loginStep('getRoles', getRoles),
        _loginStep('getDepartments', getDepartments),
        _loginStep('getEmployee', () => getEmployee(email)),
      ]);

      // ✅ FIX: await so employeeEntity is set BEFORE navigating to the
      // main screen. Otherwise AppDrawerCubit.onInit() runs with a
      // null employeeEntity and the drawer shows only Home + Settings.
      // Depends on getEmployee above, so it cannot join the group.
      await _loginStep(
        'MainCoreEmployeeController.onInit',
        () => Get.find<MainCoreEmployeeController>().onInit(),
      );

      // Registers MessagingInitController (which runs Dependency().init(),
      // putting every messaging cubit into GetX) and hands it the signed-in
      // user + categories. Without this the Messages tab has no cubits and
      // renders empty. Awaited so the cubits exist before navigation.
      //
      // CHANGED 30/9/2026 (Messages QA p.1): `addEmployeeController` is a
      // long-lived instance, and when the employee read failed it kept the
      // PREVIOUS account's record — so Messages was initialised as the user
      // who signed in before. The record is now checked against the email
      // that just signed in, re-read once if it does not match, and never
      // handed over when it still belongs to someone else.
      bool isThisUser(NewEmployeeModelHistory? e) =>
          e != null &&
          e.email.any(
            (String m) => m.trim().toLowerCase() == email.trim().toLowerCase(),
          );
      NewEmployeeModelHistory? signedInEmployee =
          addEmployeeController.employee;
      if (!isThisUser(signedInEmployee)) {
        signedInEmployee = await addEmployeeController.getEmployee(email);
      }
      if (!isThisUser(signedInEmployee)) signedInEmployee = null;
      if (signedInEmployee != null && context.mounted) {
        try {
          await _loginStep(
            'messaging init',
            () => MessagingInterfaceImplementation().useGroupAndSingleMessaging(
              context,
              signedInEmployee!,
            ),
          );
        } catch (e) {
          // Messaging must never block sign-in.
        }
      }

      hideLoadingIndicator();

      // ── Everything else runs behind the home screen ────────────────────
      // Started here, deliberately not awaited: each of these updates a
      // controller that calls update()/emit() when it lands, so the UI fills
      // in as the data arrives instead of the user staring at a spinner.
      unawaited(_warmUpSessionData(email));

      // ✅ ═══════════════════════════════════════════════════════════════
      // ✅ CRITICAL FIX: Proper navigation based on ACTUAL screen width
      // ✅ ═══════════════════════════════════════════════════════════════

      // FIXED 16/10/2026: remove BOTH menu controllers on every sign-in. Each
      // works out the signed-in user's modules once, when it is created, and
      // the phone branch used to keep the nav bar (the tablet branch the
      // drawer) — so signing in as another account in the same session
      // (test employee → company admin) showed the PREVIOUS user's modules
      // until the app was restarted. MainResponsiveScreen recreates the one
      // the screen needs, for the new user.
      if (Get.isRegistered<AppDrawerCubit>()) {
        await Get.delete<AppDrawerCubit>(force: true);
      }
      if (Get.isRegistered<NavBarCubit>()) {
        await Get.delete<NavBarCubit>(force: true);
      }

      // ✅ Navigate to the correct screen based on width
      // ✅ Navigate to responsive wrapper instead of specific screen
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const MainResponsiveScreen(), // ← NEW: Use responsive wrapper
        ),
        (route) => false,
      );

      // ✅ ═══════════════════════════════════════════════════════════════

      // FIXED 18/8/2026: was `employee!.lastLogin = ...`, which threw
      // "Null check operator used on a null value" out of this async gap —
      // uncaught, because `runZonedGuarded` catches it after the awaits
      // above have already returned. The root cause is fixed in
      // settings_screen.dart (the `employee` setter used to be a silent
      // no-op until SettingsController was registered), but this stays
      // defensive: a login that cannot resolve an employee record must not
      // take the whole session down AFTER the user has been navigated to
      // the main screen, and it must still clear the credential fields.
      final signedIn = employee;
      if (signedIn != null) {
        signedIn.lastLogin = DateTime.now().toString();

        // Not awaited: the user is already on the home screen, and stamping
        // lastLogin is bookkeeping.
        unawaited(
          _ignoreFailure(() async {
            await addEmployeeController.createEmployee(
              signedIn,
              signedIn.email.last,
            );
            systemLogsController.systemLogsAction("update employee");
          }()),
        );
      } else {}

      // REMOVED: `passcontroller = TextEditingController()` /
      // `emailcontroller = TextEditingController()` used to run here. Because
      // this is AFTER the fade transition starts, the sign-in screen is still
      // on screen and rebuilds against the new, empty controllers — the user
      // watched their email and password blank out while the spinner was
      // still up, right before the home screen appeared. It also leaked the
      // replaced controllers (nothing ever disposed them).
      //
      // Nothing else reads these fields after a successful login: the
      // credentials are already persisted through secureCredentialStore. If
      // the fields should be empty when the sign-in screen is reached again,
      // clear them on the LOGOUT path, where no screen is mid-transition.
    } catch (e) {
      hideLoadingIndicator();
      rethrow;
    }

    // Departments load from MainCoreDepartmentCubit's constructor now.
    // configurationDependencies(); // services_app
    // Register todo + role controllers needed by home/roles screens

    // UserManagementController is a shared top-level Cubit instance now, so
    // there is nothing to register here — it is created on first use.

    // REMOVED 22/8/2026: a `NotificationControllerCubit().sendNotification(...)`
    // with the literal payload 'new title' / 'new body' addressed to two
    // hardcoded @bayanatz.com inboxes fired here on *every* successful login.
    // It was left-over manual test code: it notified nobody relevant, and it
    // added a network round-trip to the sign-in path.
  }

  /// Function Name: [_warmUpSessionData]
  ///
  /// Purpose: Load everything the session eventually needs, after the user is
  /// already looking at the home screen.
  ///
  /// Added 22/8/2026. These calls all used to sit on the critical path
  /// between "Sign In" and the first frame of the home screen, each one
  /// awaited in turn. They are non-blocking by nature — every one of them
  /// ends in an `update()` / `emit()` that repaints whatever is on screen
  /// once the data lands — so the only thing serialising them bought was a
  /// longer spinner.
  ///
  /// Failures are swallowed on purpose: the user is signed in, and a slow
  /// secondary fetch must not surface as a login error. Each is logged.
  ///
  /// Parameters:
  /// - [email]: the signed-in user's normalised email.
  Future<void> _warmUpSessionData(String email) async {
    // Push registration — mobile only, never blocking.
    if (Platform.isAndroid) {
      unawaited(
        _ignoreFailure(FirebaseNotificationHandler.subscribeToTopic(email)),
      );
    }
    if (!Platform.isWindows) {
      unawaited(
        _ignoreFailure(
          FCMSubscriptionService.subscribeToPersonalChannel(userEmail: email),
        ),
      );
    }

    // Directory + branding + queues. Independent of one another, so they run
    // together rather than in sequence.
    await Future.wait(<Future<void>>[
      _ignoreFailure(getAllEmployees()),
      _ignoreFailure(addWrongEmployeeController.getAllEmployees()),
      _ignoreFailure(getCompanyData()),
      _ignoreFailure(getRequests()),
      _ignoreFailure(getEvents()),
    ]);

    // Real-time listeners. Synchronous registrations; the callbacks fire
    // later.
    _listenToRoles();
    _listenToPermissions();
    _listenToCurrentEmployee(email);
    _listenToDepartments();

    // Company-module reconciliation. This one re-reads the company document
    // and re-fetches roles, which is exactly why it does not belong in front
    // of the first frame — `getRoles()` has already run on the critical path,
    // so the drawer is populated; this only reconciles Master Admin's module
    // list afterwards.
    await _ignoreFailure(_setupCompanyModulesAndSync());

    if (_companyId != null && _companyId!.isNotEmpty) {
      _permissionSyncService.initialize(_companyId!);
      _permissionSyncService.startDemoPermissionsListener();
      await _ignoreFailure(_permissionSyncService.startAllEmployeeListeners());
    }
  }

  // ✅ NEW: Setup listener AND wait for initial sync to complete
  // ✅ UPDATED: Setup listener AND wait for initial sync to complete
  Future<void> _setupCompanyModulesAndSync() async {
    if (_companyId == null || _companyId!.isEmpty) {
      return;
    }

    try {
      // ✅ STEP 1: Get company document ONCE for initial sync
      DocumentSnapshot companyDoc =
          await db.collection(getBaseUrl('Companys')).doc(_companyId).get();

      if (companyDoc.exists) {
        Map<String, dynamic> companyData =
            companyDoc.data() as Map<String, dynamic>;

        // ✅ Extract modules from company document
        if (companyData.containsKey('modules') &&
            companyData['modules'] is Map) {
          Map<String, dynamic> modulesMap =
              companyData['modules'] as Map<String, dynamic>;

          if (modulesMap.containsKey('modules') &&
              modulesMap['modules'] is List) {
            List<String> companyModules = List<String>.from(
              modulesMap['modules'],
            );

            // ✅ CRITICAL: Sync BEFORE UI loads
            await _syncMasterAdminWithCompanyModules(companyModules);

            // ✅ CRITICAL FIX: Refresh roles_module from Firestore to load updated data
            await getRoles();
          } else {}
        } else {}
      } else {}

      // ✅ STEP 2: Setup real-time listener for future changes
      _listenToCompanyModules();
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }
}
