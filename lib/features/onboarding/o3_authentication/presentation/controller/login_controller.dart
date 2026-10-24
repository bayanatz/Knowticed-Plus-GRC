/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: login_controller.dart
/// Description: Drives sign-in, biometric login, company bootstrap and role sync.
/// Author: Amr Mesbah
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N10/N13/N14/N15/N16/N17: the biometric operator-precedence bug is
///          fixed; a failed role load is recorded instead of returning silently;
///          RoleRepository is injected; the dead `_listenToDemoPermissions` and the
///          debug `_testBothInstances` are deleted, as are the REMOVED_MODULE
///          comments.
///
/// Updated: 9/10/2026 - DEBUG-ONLY "Switch to test employee" (owner option B):
///          `debugLastUsedCompanyId` / `debugLoadTestEmployees` /
///          `debugSignInAsTestEmployee` reuse the normal post-auth path
///          (`initData`, whose password is now nullable for that one caller)
///          and the `_loginInProgress` guard; nothing runs outside debug.
///
/// REMAINING (CR-SKEL-O3-N07/N08/N11/N12): still a 1,141-LOC GetxController that
/// reaches Firestore directly, owns two TextEditingControllers, and starts
/// biometric auth from `onInit()`. Converting it to a Cubit behind a repository
/// is the largest single item left in this feature.
library;

///************************ FILE INFO ******************************
/// File name: login_controller.dart
/// Purpose: Contains the controller for login feature.
/// Refactored at: 8/1/2025
/// Author: Amr Mesbah
/// Updated: Added real-time listeners with extensive debugging

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kDebugMode;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/notification/presentation/controller/app_notification_cubit.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/network/api_constants.dart'
    hide FirebaseCollections;
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/wrong_employee_cubit.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/controller/biometrics_controller.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/main_helper/messaging_interface_implementation.dart';
import 'package:knowticed_plus/core/app_services/secure_credential_store.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:page_transition/page_transition.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/notification/helpers/services/firebase_notification_handler.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/pages/reset_password_screen.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/main_responsive.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/features/notification/data/data_source/subscription.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/services/permission_sync_service.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/success_authentication_type.dart';
import 'package:knowticed_plus/features/onboarding/helpers/constants/auth_constants.dart';

import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/controller/demo_login_controller.dart';

import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
// ADDED 9/10/2026 — DEBUG-ONLY "Switch to test employee".
import 'package:knowticed_plus/core/custom/dialogs/custom_response_dialog.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/models/debug_test_employee.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart';
import 'package:knowticed_plus/generated/l10n.dart';

part 'login_controller/login_controller_methods.dart';
part 'login_controller/login_controller_methods_2.dart';

class LoginController extends GetxController {
  /// main() owns the single CompanyCubit and passes it in. The parameter is
  /// optional because mobile_sign_in.dart and start_sign_in.dart also call
  /// `Get.put(LoginController())`; those fall back to the registered instance.
  LoginController([CompanyCubit? companyCubit, RoleRepository? roleRepository])
      : _injectedCompanyCubit = companyCubit,
        roleRepository = roleRepository ?? RoleRepository();

  final CompanyCubit? _injectedCompanyCubit;

  /// Injected rather than `RoleRepository()` constructed inline at two call
  /// sites, so it can be faked (CR-SKEL-O3-N10).
  final RoleRepository roleRepository;

  /// Why the last Master-Admin role sync failed, or `null`. The two call
  /// sites used to `return` silently on a failed load (CR-SKEL-O3-N14).
  String? lastRoleSyncError;

  CompanyCubit get companyCubit =>
      _injectedCompanyCubit ?? Get.find<CompanyCubit>();

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseFirestore dbs = FirebaseFirestore.instance;
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  List<NewEmployeeModelHistory>? employeesWithoutFilter;
  DemoLoginController demoLoginController = DemoLoginController();
  final SystemLogsController systemLogsController =
      Get.find<SystemLogsController>();

  // ✅ Stream subscriptions for real-time updates
  StreamSubscription? _rolesSubscription;
  StreamSubscription? _permissionsSubscription;
  StreamSubscription? _currentEmployeeSubscription;
  StreamSubscription? _departmentsSubscription;
  StreamSubscription? _demoPermissionsSubscription;
  final PermissionSyncService _permissionSyncService = PermissionSyncService();

  // ✅ Company ID for Demo_Permissions
  String? _companyId;

  @override
  void onInit() async {
    await getCompanyData();

    await checkCanBiometrics().then((value) {
      signWithBiometrics();
    });

    _getCurrentLocation();
    wrongPasswordCount = 0;

    super.onInit();
  }

  @override
  void onClose() {
    _cancelAllSubscriptions();

    // ✅ ADD: Dispose permission sync service
    _permissionSyncService.dispose();

    super.onClose();
  }

  // ✅ Cancel all real-time listeners
  void _cancelAllSubscriptions() {
    if (_rolesSubscription != null) {
      _rolesSubscription!.cancel();
    }

    if (_permissionsSubscription != null) {
      _permissionsSubscription!.cancel();
    }

    if (_currentEmployeeSubscription != null) {
      _currentEmployeeSubscription!.cancel();
    }

    if (_departmentsSubscription != null) {
      _departmentsSubscription!.cancel();
    }

    if (_demoPermissionsSubscription != null) {
      _demoPermissionsSubscription!.cancel();
    }
  }

  int wrongPasswordCount = 0;
  // Resolved, not constructed: a second instance here duplicated the
  // Firestore department fetch and could diverge from the one main() owns.
  MainCoreDepartmentCubit addDepartmentController =
      Get.find<MainCoreDepartmentCubit>();

  Future<void> getDepartments() async {
    await addDepartmentController.getAllDepartments();
  }

  // Departments stay live inside MainCoreDepartmentCubit itself (it watches
  // `<baseUri>/Departments`). This listener used to watch the legacy top-level
  // `departments` collection, which no tenant data lives in, so it never fired.
  void _listenToDepartments() {}

  // EmployeeController is a Cubit now, so GetX no longer calls onInit();
  // init() does the employee load that hook used to trigger.
  EmployeeController addEmployeeController = Get.put(
    EmployeeController()..init(),
  );
  AddWrongEmployeeController addWrongEmployeeController = Get.put(
    AddWrongEmployeeController(),
  );
  AppNotificationCubit appNotificationController = Get.put(
    AppNotificationCubit(),
  );

  // EventsEmployeeController employeeController =
  // Get.put(EventsEmployeeController());

  Future<void> getEvents() async {
    // await eventController.fetchEmployees();
    // await eventController.fetchEventsFromFirebase();
    // await employeeController.fetchEmployees();
    // await employeeController.fetchEventsFromFirebase();
    update();
  }

  Future<void> getEmployee(String email) async {
    employee = await addEmployeeController.getEmployee(email);
    update();
  }

  // ✅ Setup real-time listener for current logged-in employee
  void _listenToCurrentEmployee(String email) {
    try {
      _currentEmployeeSubscription = db
          .collection(getBaseUrl(ApiConstants.employeesInfo))
          .where('Email', arrayContains: email)
          .snapshots()
          .listen((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          try {
            NewEmployeeModelHistory updatedEmployee =
                NewEmployeeModelHistory.fromMap(snapshot.docs.first.data());

            employee = updatedEmployee;

            // AppDrawerCubit.isOwner = employee?.role?.isNotEmpty == true &&
            //     employee!.role.last == 'super admin';
            // AppDrawerCubit.isHr = employee?.role?.isNotEmpty == true &&
            //     employee!.role.last == 'hr';
            //

            update();
          } catch (e) {
            debugPrint('Ignored error: $e');
          }
        } else {}
      }, onError: (error) {});
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }

  Future<void> getCompanyData() async {
    String companyName = ApiConstants.baseUri.split("/").last;

    if (companyName.isEmpty) {
      companyName = 'bayanatz';
    }

    _companyId = companyName;

    companyCubit.getCompany(companyName: companyName);
  }

  bool isDateBeforeNow(String dateString) {
    // ✅ FIX: empty/invalid date strings used to throw
    // FormatException ("Trying to read d from  at 0") and skip employees.
    if (dateString.trim().isEmpty) return false;
    try {
      DateFormat dateFormat = DateFormat("d MMMM yyyy, hh:mm a", 'en');
      DateTime parsedDate = dateFormat.parse(dateString);
      return parsedDate.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  Future<void> getAllWrongEmployees() async {}

  Future<void> getRoles({bool silent = false}) async {
    await roleCubit.getUnDeletedRoles(silent: silent);
  }

  // Roles stay live inside RoleCubit itself (it watches `<baseUri>/Roles` and
  // `<baseUri>/Subscription_Admin`). This listener used to watch the legacy
  // top-level `Roles` collection, which never fired for tenant roles.
  void _listenToRoles() {}

  // ✅ Setup real-time listener for permissions (Demo_Permissions)
  void _listenToPermissions() {
    try {
      _permissionsSubscription = db
          .collection(FirebaseCollections.demoPermissions)
          .snapshots()
          .listen((snapshot) {
        getRoles(silent: true);
        update();
      }, onError: (error) {});
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }

  // ✅ Manual refresh method for pull-to-refresh
  Future<void> refreshAllData() async {
    try {
      showLoadingIndicator();

      await Future.wait([
        getRoles(),
        getDepartments(),
        getEmployee(storage.read('email')),
        getAllEmployees(),
      ]);

      hideLoadingIndicator();

      Get.snackbar(
        'Success',
        'Data refreshed successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      hideLoadingIndicator();

      Get.snackbar(
        'Error',
        'Failed to refresh data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: AppColors.white,
      );
    }
  }

  bool canBiometrics = false;
  bool isUseBiometrics = false;

  Future<bool> checkCanBiometrics() async {
    canBiometrics = await checkBiometrics();
    // Was `storage.read('Biometric') ?? true && canBiometrics`, which parses
    // as `read(...) ?? (true && canBiometrics)` — so once the preference was
    // stored, `canBiometrics` was ignored entirely and a user with biometrics
    // switched off at the OS level was still routed into the biometric path
    // (CR-SKEL-O3-N13).
    isUseBiometrics =
        (storage.read('Biometric') as bool? ?? true) && canBiometrics;
    update();
    return canBiometrics;
  }

  // REMOVED 20/10/2026 (CR-KNP-SET-HR-02): `requestController` / `getRequests`
  // — the change-request queue is owned by RequestsCubit (se6_requests), which
  // loads on demand; the legacy GetX controller is deleted.

  void signWithBiometrics() async {
    if (isUseBiometrics && storage.read('email') != null) {
      // FIXED 27/9/2026 — check for a saved password BEFORE the prompt.
      //
      // The fingerprint only unlocks the saved password; it is not a
      // credential on its own. When the Keychain holds none (always the case
      // in an ad-hoc-signed macOS debug build: no keychain-access-groups, so
      // flutter_secure_storage can neither write nor read), the user used to
      // be asked for their fingerprint, succeed, and then be thrown back to
      // the sign-in screen anyway. Now the prompt is skipped and the user
      // simply signs in with the password; that sign-in saves it for next
      // time on platforms where the Keychain works.
      final String? savedPassword = await secureCredentialStore.readPassword();
      if (savedPassword == null || savedPassword.isEmpty) {
        return;
      }

      bool authenticated = await authenticate();

      switch (authenticated) {
        case true:
          String email = storage.read('email');
          final String? password = await secureCredentialStore.readPassword();
          if (password == null || password.isEmpty) {
            // No stored credential (or it was cleared): fall back to the
            // normal sign-in screen rather than calling login with an empty
            // password, which would surface as "wrong password".
            Navigator.of(Get.context!).pushReplacement(
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
            break;
          }
          // countsTowardLockout: false — this fires from onInit() before
          // the user has typed anything. A stale saved credential must not
          // spend one of the three attempts that lead to an account lock.
          login(Get.context!, email, password, countsTowardLockout: false);
          break;
        case false:
          Navigator.of(Get.context!).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
      }
    } else {}
  }

  // ✅ PATCH FOR login_controller.dart
  // Apply this change to the login() method:

  /// Function Name: [login]
  ///
  /// Purpose: Authenticate [email] / [password] and route the result.
  ///
  /// Parameters:
  /// - [countsTowardLockout]: whether a wrong password here counts against
  ///   the three-strike account lock. `false` for the biometric auto-login.
  Future<void> login(
    BuildContext context,
    String email,
    String password, {
    bool countsTowardLockout = true,
  }) async {
    // ADDED 9/10/2026 — one sign-in at a time. A second tap (or the
    // biometric auto-login racing a manual tap) used to run login() twice
    // concurrently: both reached initData, two app shells were pushed and
    // the iPad crashed with "Duplicate GlobalKeys detected" (seen 9/10/2026).
    if (_loginInProgress) {
      debugPrint('[bio] login ignored — a sign-in is already running');
      return;
    }
    _loginInProgress = true;
    try {
      await _login(
        context,
        email,
        password,
        countsTowardLockout: countsTowardLockout,
      );
    } finally {
      _loginInProgress = false;
    }
  }

  /// True while [login] is running (see the guard in [login]).
  /// 9/10/2026 DEBUG-ONLY: also held by [debugSignInAsTestEmployee], so a
  /// password sign-in and a debug switch can never run at the same time.
  bool _loginInProgress = false;

  // ══════════════════════════════════════════════════════════════════════
  // DEBUG-ONLY 9/10/2026 — "Switch to test employee" (owner option B).
  // Reached only from widgets built under `kDebugTestEmployeeSwitchBuild`
  // (compile-time false in release/profile, so these are tree-shaken), and
  // each method re-checks `isDebugTestEmployeeSwitchEnabled()` as well.
  // No password is read, stored, shown or logged on this path.
  // ══════════════════════════════════════════════════════════════════════

  /// Function Name: [debugLastUsedCompanyId]
  ///
  /// Purpose: DEBUG-ONLY 9/10/2026 — the company to prefill in the picker:
  /// the signed-in one, else the last signed-in account's company, else
  /// [kDebugDefaultTestCompanyId].
  ///
  /// Returns: [Future<String>]
  Future<String> debugLastUsedCompanyId() async {
    if (!isDebugTestEmployeeSwitchEnabled()) return '';
    final dynamic savedEmail = storage.read('email');
    return demoLoginController.demoLoginRepository.debugLastUsedCompanyId(
      savedEmail: savedEmail is String ? savedEmail : null,
    );
  }

  /// Function Name: [debugLoadTestEmployees]
  ///
  /// Purpose: DEBUG-ONLY 9/10/2026 — the test accounts of [companyId].
  ///
  /// Parameters:
  /// - [companyId]: the company typed in the picker.
  ///
  /// Returns: [Future<Either<Failure, List<DebugTestEmployee>>>]
  Future<Either<Failure, List<DebugTestEmployee>>> debugLoadTestEmployees(
    String companyId,
  ) async {
    if (!isDebugTestEmployeeSwitchEnabled()) {
      return const Left(FeatureFailure('debug-only'));
    }
    return demoLoginController.demoLoginRepository.debugListTestEmployees(
      companyId: companyId,
    );
  }

  /// Function Name: [debugSignInAsTestEmployee]
  ///
  /// Purpose: DEBUG-ONLY 9/10/2026 — sign in as a test employee without a
  /// password, through the NORMAL post-authentication path.
  ///
  /// What is skipped compared with [login]: the password comparison and the
  /// lockout counter (no `LoginAttemptStore` call at all). Everything else
  /// is the normal code: the repository runs the same account / company /
  /// seat / status / `Users_Access` checks, refuses an account that is not
  /// activated, and then [initData] — the exact method a password sign-in
  /// calls — loads roles, departments, the employee, permissions and
  /// navigates. [initData] gets `password: null`, so nothing is written to
  /// the secure store (the previous user's saved password is cleared instead,
  /// so biometrics cannot pair it with the test email).
  ///
  /// The previous session's real-time listeners are cancelled first, so the
  /// old account's employee listener cannot overwrite the new one.
  ///
  /// Parameters:
  /// - [context]: a context that stays mounted until navigation (the picker).
  /// - [companyId]: the company chosen in the picker.
  /// - [email]: the test account.
  ///
  /// Returns: [Future<void>]
  Future<void> debugSignInAsTestEmployee(
    BuildContext context, {
    required String companyId,
    required String email,
  }) async {
    if (!isDebugTestEmployeeSwitchEnabled()) return;
    if (_loginInProgress) {
      debugPrint('$kDebugSwitchLogTag ignored — a sign-in is already running');
      return;
    }
    _loginInProgress = true;
    final String normalizedEmail = email.trim().toLowerCase();
    try {
      showLoadingIndicator();
      final Either<Object, NewEmployeeModelHistory> result =
          await demoLoginController.demoLoginRepository
              .debugSignInAsTestEmployee(
        companyId: companyId,
        email: normalizedEmail,
      );

      final Object? refusal = result.fold((Object l) => l, (_) => null);
      if (refusal != null) {
        debugPrint('$kDebugSwitchLogTag refused $normalizedEmail — $refusal');
        // `hideLoadingIndicator()` is a blind `Get.back()`, so it must run
        // exactly ONCE here or it would pop the picker page as well.
        if (refusal is Failure) {
          // One of the normal sign-in failures (subscription, Access Denied,
          // too many users…): the normal dialog, which hides the indicator
          // itself. countsTowardLockout: false — and no wrong-password
          // failure can come from this path anyway.
          await demoLoginController.handleAuthenticationErrorMessage(
            errorMessage: refusal.errMessage,
            email: normalizedEmail,
            countsTowardLockout: false,
          );
        } else {
          hideLoadingIndicator();
          if (refusal is DebugSwitchFailure) {
            await _debugShowSwitchRefusal(refusal);
          }
        }
        return;
      }

      if (!context.mounted) {
        hideLoadingIndicator();
        return;
      }

      // Clean hand-over from whoever was signed in before.
      _cancelAllSubscriptions();
      _permissionSyncService.dispose();

      employee = result.getOrElse(() => NewEmployeeModelHistory());
      DebugTestEmployeeSession.start(normalizedEmail);
      final bool isTablet = !kpIsPhoneLayout(context);
      try {
        await initData(context, isTablet, normalizedEmail, null);
      } catch (e) {
        DebugTestEmployeeSession.end();
        debugPrint(
          '$kDebugSwitchLogTag initData failed for '
          '$normalizedEmail: $e',
        );
        return;
      }
      debugPrint('$kDebugSwitchLogTag signed in as $normalizedEmail');
    } finally {
      _loginInProgress = false;
    }
  }

  /// Function Name: [_debugShowSwitchRefusal]
  ///
  /// Purpose: DEBUG-ONLY 9/10/2026 — say why a debug switch was refused.
  ///
  /// Parameters:
  /// - [failure]: the refusal and the value it names.
  ///
  /// Returns: [Future<void>]
  Future<void> _debugShowSwitchRefusal(DebugSwitchFailure failure) async {
    final BuildContext? dialogContext = Get.context;
    if (dialogContext == null) return;
    await showAppDialog<void>(
      context: dialogContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final S s = S.of(context);
        final String domains = kDebugTestEmailDomains.join(', ');
        final String message = switch (failure.refusal) {
          DebugSwitchRefusal.disabled => s.debugTestEmployeeDebugOnly,
          DebugSwitchRefusal.notTestEmail => s.debugTestEmployeeNotTestEmail(
              domains,
            ),
          DebugSwitchRefusal.companyAdmin => s.debugTestEmployeeCompanyAdmin,
          DebugSwitchRefusal.otherCompany => s.debugTestEmployeeOtherCompany(
              failure.detail,
            ),
          DebugSwitchRefusal.notActivated => s.debugTestEmployeeNotActivated,
          DebugSwitchRefusal.statusBlocked => s.debugTestEmployeeStatusBlocked(
              failure.detail,
            ),
        };
        return ResponseDialog(
          title: s.debugTestEmployeeCannotSwitch,
          subtitle: message,
          lottieAsset:
              'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
        );
      },
    );
  }

  Future<void> _login(
    BuildContext context,
    String email,
    String password, {
    bool countsTowardLockout = true,
  }) async {
    // ✅ Normalize email to lowercase for case-insensitive comparison
    String normalizedEmail = email.trim().toLowerCase();

    showLoadingIndicator();
    bool isTablet = !kpIsPhoneLayout(context);

    // ✅ Use normalized email for login
    Either<Failure, dynamic> result =
        await demoLoginController.loginWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
      countsTowardLockout: countsTowardLockout,
    );

    if (result.isLeft()) {
      hideLoadingIndicator();
      return;
    }

    Map<String, dynamic> successAuthenticationData = result.getOrElse(() => {});
    var successType =
        successAuthenticationData[AuthenticationConstants.successTypeKey];

    if (successType == SuccessAuthenticationType.login) {
      employee = successAuthenticationData[AuthenticationConstants.successData];

      // ✅ Use normalized email for all subsequent operations
      if (!context.mounted) return;
      initData(context, isTablet, normalizedEmail, password);
    } else if (successType == SuccessAuthenticationType.inactive ||
        successType == SuccessAuthenticationType.resetPassword) {
      // `inactive`  → first sign-in with the temporary / default password.
      // `resetPassword` → the account was unlocked or an admin approved a
      //                   reset, so the user signed in with the default
      //                   password held in User Access and must choose a new
      //                   one before going any further.
      hideLoadingIndicator();
      employee = successAuthenticationData[AuthenticationConstants.successData];

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: ResetPassword(
            savedPassword: password,
            employee: employee,
            isDemoActivation: true,
            // CHANGED 21/9/2026 — Settings bug report p.2: never ask for the
            // old password here. Both paths reach this screen straight after
            // a successful sign-in WITH that password (the temporary one for
            // `inactive`, the User Access default for `resetPassword`), so
            // asking for it again, and the "Old password matches" rule under
            // it, proved nothing.
            requireOldPassword: false,
          ),
        ),
      );
    } else {
      // FIXED 22/8/2026: every other SuccessAuthenticationType — locked,
      // lockedWithRequest, deactivated — fell off the end of this if/else
      // with the modal loading indicator still up and no navigation, so the
      // app sat on an endless spinner over the sign-in screen. That is the
      // "loading too much before entering the home page" report.
      hideLoadingIndicator();

      // CORRECTED 26/8/2026. The note here used to add "the repository has
      // already surfaced the reason via its own dialog", and for `locked`
      // that was not true — `demo_login_repository` raises no dialog on this
      // path. A user whose account was locked and who then typed the RIGHT
      // password got the spinner dismissed and nothing else: no reason, no
      // instruction, no trace that they had tried.
      //
      // This is also the one moment the app can be certain someone WANTS back
      // into a locked account — they proved the credential — which makes it
      // the natural trigger for the unlock request. See
      // `DemoLoginController.handleLockedAccountSignIn`; it both raises the
      // request and shows the locked dialog.
      if (successType == SuccessAuthenticationType.locked) {
        final dynamic lockedEmployee =
            successAuthenticationData[AuthenticationConstants.successData];
        if (lockedEmployee is NewEmployeeModelHistory) {
          await demoLoginController.handleLockedAccountSignIn(
            employee: lockedEmployee,
          );
        }
      }
    }
  }

  // `_testBothInstances()` was deleted: debug code shipped to production
  // that probed two Firestore instances against a hardcoded document id
  // (CR-SKEL-O3-N15).

  /// DIAGNOSTIC 21/9/2026 — see the note in [initData]. Logs the start and
  /// end (with duration) of one sign-in step in debug builds only.
  Future<void> _loginStep(String name, Future<void> Function() step) async {
    Stopwatch().start();
    try {
      await step();
      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
      rethrow;
    }
  }

  /// Function Name: [_ignoreFailure]
  ///
  /// Purpose: Run [future] for its side effect and log — never rethrow — any
  /// error, so one slow or broken background fetch cannot take down the
  /// `Future.wait` around it (or the zone, now that these are unawaited).
  Future<void> _ignoreFailure(Future<void> future) async {
    try {
      await future;
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // kIsWeb first: `Platform` (dart:io) throws on web (7/10/2026).
    if (kIsWeb || Platform.isMacOS) {
      return;
    }
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      // The settings the deprecated `desiredAccuracy:` built.
      locationSettings: defaultTargetPlatform == TargetPlatform.android
          ? AndroidSettings(accuracy: LocationAccuracy.high)
          : LocationSettings(accuracy: LocationAccuracy.high),
    );

    _currentPosition = position;
    update();
  }
}
