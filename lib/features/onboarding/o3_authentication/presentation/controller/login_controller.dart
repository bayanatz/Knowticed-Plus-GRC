/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: login_controller.dart
/// Purpose: Drives sign-in, biometric login, company bootstrap and role sync.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N10/N13/N14/N15/N16/N17: the biometric operator-precedence bug is
///          fixed; a failed role load is recorded instead of returning silently;
///          RoleRepository is injected; the dead `_listenToDemoPermissions` and the
///          debug `_testBothInstances` are deleted, as are the REMOVED_MODULE
///          comments.
///
/// REMAINING (CR-SKEL-O3-N07/N08/N11/N12): still a 1,141-LOC GetxController that
/// reaches Firestore directly, owns two TextEditingControllers, and starts
/// biometric auth from `onInit()`. Converting it to a Cubit behind a repository
/// is the largest single item left in this feature.

  ///************************ FILE INFO ******************************
  /// File name: login_controller.dart
  /// Purpose: Contains the controller for login feature.
  /// Refactored at: 8/1/2025
  /// Author: Amr Mesbah
  /// Updated: Added real-time listeners with extensive debugging

  import 'dart:async';
  import 'dart:io';
  import 'package:flutter/foundation.dart' show kDebugMode;

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:dartz/dartz.dart';
import 'package:grc_module/features/notification/presentation/controller/app_notification_cubit.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
import 'package:grc_module/core/theme/app_colors.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:get/get.dart';
  import 'package:intl/intl.dart';
  import 'package:grc_module/core/theme/haptic_controller.dart';
  import 'package:grc_module/core/network/api_constants.dart' hide FirebaseCollections;
  import 'package:grc_module/core/custom/66-circle_progress.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/wrong_employee_cubit.dart';
import 'package:grc_module/features/onboarding/o3_authentication/presentation/controller/biometrics_controller.dart';
import 'package:grc_module/features/settings/se6_requests/presentation/controller/request_controller.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:grc_module/core/helper/message_module/main_helper/messaging_interface_implementation.dart';
import 'package:grc_module/core/services/secure_credential_store.dart';
import 'package:grc_module/core/constants/firebase_collections.dart';
  import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
  import 'package:grc_module/features/home/h3_app_drawer/presentation/ui/pages/custom_drawer.dart';
  
  import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
  import 'package:grc_module/features/settings/se3_company/presentation/controller/company_cubit.dart';
  import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
  import 'package:page_transition/page_transition.dart';

  import 'package:grc_module/core/network/failure_model.dart';
  import 'package:grc_module/features/notification/services/firebase_notification_handler.dart';
  import 'package:grc_module/features/onboarding/o3_authentication/presentation/ui/pages/reset_password_screen.dart';
  import 'package:grc_module/core/network/get_base_url.dart';
  import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
  import 'package:grc_module/features/home/h1_home_page/presentation/ui/pages/main_responsive.dart';
  import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
  import 'package:grc_module/features/notification/data/data_source/subscription.dart';
  import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
  import 'package:grc_module/features/roles/r1_role_management/data/repository/role_repository.dart';
  import 'package:grc_module/features/roles/r1_role_management/data/services/permission_sync_service.dart';
  import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/success_authentication_type.dart';
  import 'package:grc_module/features/onboarding/o3_authentication/data/constants.dart';
  import './demo_login_controller.dart';
  import 'package:grc_module/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';

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

    FirebaseFirestore db =
    FirebaseFirestore.instance;
    FirebaseFirestore dbs = FirebaseFirestore.instance;
    GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
    TextEditingController emailcontroller = TextEditingController();
    TextEditingController passcontroller = TextEditingController();
    List<NewEmployeeModelHistory>? employeesWithoutFilter;
    DemoLoginController demoLoginController = DemoLoginController();
    final SystemLogsController systemLogsController = Get.find<SystemLogsController>();

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

      debugPrint('[bio] LoginController.onInit → start (hash=$hashCode)');
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

    // ✅ Setup real-time listener for departments
    void _listenToDepartments() {

      try {
        _departmentsSubscription = db
            .collection(FirebaseCollections.departments)
            .snapshots()
            .listen((snapshot) {

          getDepartments();
          update();

        }, onError: (error) {
        });

      } catch (e, stackTrace) {
      }
    }

    // EmployeeController is a Cubit now, so GetX no longer calls onInit();
    // init() does the employee load that hook used to trigger.
    EmployeeController addEmployeeController =
        Get.put(EmployeeController()..init());
    AddWrongEmployeeController addWrongEmployeeController =
    Get.put(AddWrongEmployeeController());
    AppNotificationCubit appNotificationController =
    Get.put(AppNotificationCubit());

    // EventsEmployeeController employeeController =
    // Get.put(EventsEmployeeController());

    Future<void> getEvents() async {
      // await eventController.fetchEmployees();
      // await eventController.fetchEventsFromFirebase();
      // await employeeController.fetchEmployees();
      // await employeeController.fetchEventsFromFirebase();
      update();
    }

    Future<void> getEmployee(email) async {
      employee = await addEmployeeController.getEmployee(email);
      update();
    }

    // ✅ Setup real-time listener for current logged-in employee
    void _listenToCurrentEmployee(String email) {

      try {
        _currentEmployeeSubscription = db
            .collection(FirebaseCollections.employees)
            .where('email', arrayContains: email)
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
              // print("🔄 AppDrawerCubit.isOwner updated: ${AppDrawerCubit.isOwner}");
              // print("🔄 AppDrawerCubit.isHr updated: ${AppDrawerCubit.isHr}");

              update();

            } catch (e, stackTrace) {
            }
          } else {
          }

        }, onError: (error) {
        });

      } catch (e, stackTrace) {
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

    // EventController eventController = Get.put(EventController());

    Future<void> getAllEmployees() async {
      await addEmployeeController.getAllEmployees();

      if (addEmployeeController.employeesWithoutFilter == null ||
          addEmployeeController.employeesWithoutFilter!.isEmpty) {
        return;
      }


      for (var i = 0;
      i < addEmployeeController.employeesWithoutFilter!.length;
      i++) {
        try {
          NewEmployeeModelHistory emp =
          addEmployeeController.employeesWithoutFilter![i];

          if (emp.status.isEmpty || emp.email.isEmpty) {
            continue;
          }

          String currentStatus = emp.status.last;
          String employeeEmail = emp.email.last;

          if (currentStatus == 'active' && emp.deactivationDate != null) {
            if (isDateBeforeNow(emp.deactivationDate!)) {
              emp = emp.copyWithUpdateSynchronized(
                status: 'deactivated',
                deactivationDate: null,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );

              await addEmployeeController.createEmployee(emp, employeeEmail);

              appNotificationController.sendNotification(
                type: 'employee',
                topic: employeeEmail,
                title: 'Account Deactivated',
                arabicTitle: 'تم ايقاف حسابك',
                body:
                'Your account is now deactivated. You can no longer login.',
                arabicBody: 'تم ايقاف حسابك الان . لا يمكنك تسجيل الدخول',
              );
            }
          } else if (currentStatus == 'deactivated' &&
              emp.activationDate != null) {
            if (isDateBeforeNow(emp.activationDate!)) {
              emp = emp.copyWithUpdateSynchronized(
                status: 'active',
                activationDate: null,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );

              await addEmployeeController.createEmployee(emp, employeeEmail);

              appNotificationController.sendNotification(
                type: 'employee',
                topic: employeeEmail,
                title: 'Account Activated',
                arabicTitle: 'تم تفعيل حسابك',
                body: 'Your account is now activated. You can login now.',
                arabicBody: 'تم تفعيل حسابك الان . يمكنك تسجيل الدخول',
              );
            }
          }
        } catch (e) {
          continue;
        }
      }

    }

    Future<void> getAllWrongEmployees() async {}

    Future<void> getRoles() async {
      await roleCubit.getUnDeletedRoles();
    }

    // ✅ Setup real-time listener for roles_module
    void _listenToRoles() {

      try {
        _rolesSubscription =
            db.collection(FirebaseCollections.roles).snapshots().listen((snapshot) {

              getRoles();
              update();

            }, onError: (error) {
            });

      } catch (e, stackTrace) {
      }
    }

    // ✅ Setup real-time listener for permissions (Demo_Permissions)
    void _listenToPermissions() {

      try {
        _permissionsSubscription =
            db.collection(FirebaseCollections.demoPermissions).snapshots().listen((snapshot) {

              getRoles();
              update();

            }, onError: (error) {
            });

      } catch (e, stackTrace) {
      }
    }

    // `_listenToDemoPermissions()` was deleted: it was defined but never
    // called — `_listenToPermissions` and `_listenToCompanyModules` are the
    // live listeners (CR-SKEL-O3-N16).




    // ✅ NEW: Listen to Company document for modules (not Demo_Permissions)
    void _listenToCompanyModules() {

      if (_companyId == null || _companyId!.isEmpty) {
        return;
      }


      try {
        _demoPermissionsSubscription = db

            .collection(getBaseUrl('Companys'))
            .doc(_companyId)
            .snapshots()
            .listen((snapshot) async {

          if (snapshot.exists) {

            try {
              Map<String, dynamic> companyData =
              snapshot.data() as Map<String, dynamic>;

              // ✅ Extract modules from company document
              if (companyData.containsKey('modules') &&
                  companyData['modules'] is Map) {
                Map<String, dynamic> modulesMap =
                companyData['modules'] as Map<String, dynamic>;

                if (modulesMap.containsKey('modules') &&
                    modulesMap['modules'] is List) {
                  List<String> companyModules =
                  List<String>.from(modulesMap['modules']);


                  // ✅ Sync Master Admin with these modules
                  await _syncMasterAdminWithCompanyModules(companyModules);

                  await getRoles();
                  update();

                } else {
                }
              } else {
              }
            } catch (e, stackTrace) {
            }
          } else {
          }

        }, onError: (error, stackTrace) {
        });

      } catch (e, stackTrace) {
      }
    }


    // ✅ NEW: Sync Master Admin role with company's actual modules
    Future<void> _syncMasterAdminWithCompanyModules(
        List<String> companyModules) async
    {

      try {
        var rolesResult = await roleRepository.getUnDeletedRoles();

        if (rolesResult.isLeft()) {
          // Was a bare `return`. A transient Firestore error then looked
          // identical to "this tenant has no roles", and the Master-Admin
          // module sync below would run against an empty set — drifting or
          // erasing assignments (CR-SKEL-O3-N14). Recorded so the caller can
          // tell the difference.
          lastRoleSyncError = rolesResult.fold(
              (failure) => failure.errMessage, (_) => 'Could not load roles.');
          return;
        }

        List<RoleHistoryModel> allRoles = rolesResult.getOrElse(() => []);

        // ✅ Find Master Admin role
        List<RoleHistoryModel> masterAdminRoles = allRoles.where((role) {
          bool isMasterAdmin = role.currentRoleName.toLowerCase() == 'master admin';
          return isMasterAdmin;
        }).toList();

        if (masterAdminRoles.isEmpty) {
          return;
        }

        RoleHistoryModel masterAdmin = masterAdminRoles.first;
        String roleId = masterAdmin.roleId;

        // ✅ Check if selected modules match company modules
        List<String> currentModules = masterAdmin.currentSelectedModules;

        // ✅ Compare: Check if different
        bool needsUpdate = false;
        List<String> missingModules = [];
        List<String> extraModules = [];

        if (currentModules.length != companyModules.length) {
          needsUpdate = true;
        }

        // Find missing modules (in company but not in role)
        for (String module in companyModules) {
          if (!currentModules.contains(module)) {
            needsUpdate = true;
            missingModules.add(module);
          }
        }

        // Find extra modules (in role but not in company)
        for (String module in currentModules) {
          if (!companyModules.contains(module)) {
            needsUpdate = true;
            extraModules.add(module);
          }
        }

        if (missingModules.isNotEmpty) {
        }

        if (extraModules.isNotEmpty) {
        }

        if (needsUpdate) {

          WriteBatch batch = db.batch();

          // ✅ Update role's Selected_Modules field in Roles collection
          DocumentReference roleRef = db

              .collection(getBaseUrl('Roles'))
              .doc(roleId);


          batch.update(roleRef, {
            'Selected_Modules': companyModules,
          });

          await batch.commit();
        } else {
        }

      } catch (e, stackTrace) {
      }
    }

    // ✅ NEW: Sync all existing roles_module with updated Demo_Permissions
    Future<void> _syncAllRolesWithDemoPermissions(
        Map<String, dynamic> demoPermissions) async {

      try {
        var rolesResult = await roleRepository.getUnDeletedRoles();

        if (rolesResult.isLeft()) {
          // Was a bare `return`. A transient Firestore error then looked
          // identical to "this tenant has no roles", and the Master-Admin
          // module sync below would run against an empty set — drifting or
          // erasing assignments (CR-SKEL-O3-N14). Recorded so the caller can
          // tell the difference.
          lastRoleSyncError = rolesResult.fold(
              (failure) => failure.errMessage, (_) => 'Could not load roles.');
          return;
        }

        List<RoleHistoryModel> allRoles = rolesResult.getOrElse(() => []);

        // ✅ FILTER: Only get "Master Admin" role
        List<RoleHistoryModel> roles = allRoles.where((role) {
          bool isMasterAdmin = role.currentRoleName.toLowerCase() == 'master admin';
          return isMasterAdmin;
        }).toList();


        if (roles.isEmpty) {
          return;
        }

        WriteBatch batch = db.batch();
        int totalUpdates = 0;

        for (int roleIndex = 0; roleIndex < roles.length; roleIndex++) {
          RoleHistoryModel role = roles[roleIndex];
          String roleId = role.roleId;
          String roleName = role.currentRoleName;


          int moduleUpdateCount = 0;

          for (String moduleName in demoPermissions.keys) {

            var moduleData = demoPermissions[moduleName];

            if (moduleData is! Map) {
              continue;
            }

            Map<String, dynamic> modulePermissions =
            Map<String, dynamic>.from(moduleData);

            String collectionName = _getPermissionCollectionName(moduleName);

            if (collectionName.isEmpty) {
              continue;
            }

            String permDocPath = "Demo/$_companyId/$collectionName/$roleId";

            DocumentReference rolePermRef = db

                .collection(getBaseUrl('collectionName'))
                .doc(roleId);

            DocumentSnapshot rolePermDoc = await rolePermRef.get();

            if (!rolePermDoc.exists) {
              continue;
            }

            Map<String, dynamic> currentPermissions =
            Map<String, dynamic>.from(rolePermDoc.data() as Map<String, dynamic>);

            Map<String, dynamic> updatedPermissions =
            Map<String, dynamic>.from(currentPermissions);
            int timestamp = DateTime.now().millisecondsSinceEpoch;

            List<int> timestamps =
            List<int>.from(updatedPermissions['timestamps'] ?? []);
            timestamps.add(timestamp);
            updatedPermissions['timestamps'] = timestamps;

            int permissionChangeCount = 0;

            modulePermissions.forEach((permKey, demoValue) {
              if (permKey == 'Role_Id' || permKey == 'timestamps') {
                return;
              }

              List<bool> permHistory = [];

              if (updatedPermissions.containsKey(permKey) &&
                  updatedPermissions[permKey] is List) {
                permHistory = List<bool>.from(
                    updatedPermissions[permKey].map((v) => v == true));
              } else {
                permHistory =
                    List.filled(timestamps.length - 1, false, growable: true);
              }

              bool currentValue =
              permHistory.isNotEmpty ? permHistory.last : false;
              bool newValue = (demoValue == true);

              permHistory.add(newValue);
              updatedPermissions[permKey] = permHistory;

              if (newValue != currentValue) {
                permissionChangeCount++;
              }
            });

            if (permissionChangeCount > 0) {
              batch.set(rolePermRef, updatedPermissions);
              moduleUpdateCount++;
              totalUpdates++;

            } else {
            }
          }

          if (moduleUpdateCount > 0) {
          } else {
          }
        }

        if (totalUpdates > 0) {
          await batch.commit();
        } else {
        }

      } catch (e, stackTrace) {
      }
    }

    // ✅ Helper method to map module name to collection name
    String _getPermissionCollectionName(String moduleName) {

      String result;
      switch (moduleName.toLowerCase()) {
        case 'services':
          result = 'services_module_permissions';
          break;
        case 'roles':
          result = 'roles_module_permissions';
          break;
        case 'inventory':
          result = 'inventory_module_permissions';
          break;
        case 'settings':
          result = 'settings_module_permissions';
          break;
        case 'services_app':
          result = 'services_app_module_permissions';
          break;
        case 'messages':
          result = 'messages_module_permissions';
          break;
        case 'qiyas':
          result = 'qiyas_module_permissions';
          break;
        case 'knowledge_hub':
          result = 'knowledge_hub_module_permissions';
          break;
        case 'grc':
          result = 'grc_module_permissions';
          break;
        case 'hr':  // ✅ ADD THIS
          result = 'hr_module_permissions';
          break;
        case 'crm':  // ✅ ADD THIS
          result = 'crm_module_permissions';
          break;
        case 'notification':  // ✅ ADD THIS
          result = 'notification_module_permissions';
          break;
        default:
          result = '';
      }

      return result;
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

      } catch (e, stackTrace) {
        hideLoadingIndicator();

        Get.snackbar(
          'Error',
          'Failed to refresh data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.signOut,
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
      debugPrint('[bio] checkCanBiometrics → canBiometrics=$canBiometrics, '
          "stored 'Biometric' pref=${storage.read('Biometric')}, "
          'isUseBiometrics=$isUseBiometrics');
      update();
      return canBiometrics;
    }

    RequestController requestController = Get.find();

    Future<void> getRequests() async {
      requestController.allRequestsPending =
      await requestController.getAllRequests(true);
      requestController.allRequestReview =
      await requestController.getAllRequests(false);
    }

    void signWithBiometrics() async {
      debugPrint('[bio] signWithBiometrics → isUseBiometrics=$isUseBiometrics, '
          "saved email=${storage.read('email')}");
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
        final String? savedPassword =
            await secureCredentialStore.readPassword();
        if (savedPassword == null || savedPassword.isEmpty) {
          debugPrint('[bio] signWithBiometrics → SKIPPED: no saved password in '
              'secure storage, so a fingerprint could not sign in. Staying on '
              'the sign-in screen.');
          return;
        }

        bool authenticated = await authenticate();
        debugPrint('[bio] signWithBiometrics → authenticated=$authenticated');

        switch (authenticated) {
          case true:
            String email = storage.read('email');
            final String? password =
                await secureCredentialStore.readPassword();
            debugPrint('[bio] signWithBiometrics → saved password '
                '${password == null ? "is NULL" : password.isEmpty ? "is EMPTY" : "found (${password.length} chars)"}');
            if (password == null || password.isEmpty) {
              debugPrint('[bio] → no saved password, sending to SignInScreen');
              // No stored credential (or it was cleared): fall back to the
              // normal sign-in screen rather than calling login with an empty
              // password, which would surface as "wrong password".
              Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SignInScreen()));
              break;
            }
            // countsTowardLockout: false — this fires from onInit() before
            // the user has typed anything. A stale saved credential must not
            // spend one of the three attempts that lead to an account lock.
            debugPrint('[bio] → calling login($email) with saved password');
            login(Get.context!, email, password, countsTowardLockout: false);
            break;
          case false:
            debugPrint('[bio] → authentication false, replacing route with SignInScreen');
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
                builder: (context) => const SignInScreen()));
        }
      } else {
        debugPrint('[bio] signWithBiometrics → SKIPPED (no prompt): '
            '${!isUseBiometrics ? "biometrics off or unavailable" : "no saved email"}');
      }
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
    login(BuildContext context, String email, String password,
        {bool countsTowardLockout = true}) async {

      // ✅ Normalize email to lowercase for case-insensitive comparison
      String normalizedEmail = email.trim().toLowerCase();


      showLoadingIndicator();
      bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

      // ✅ Use normalized email for login
      Either<Failure, dynamic> result =
          await demoLoginController.loginWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
        countsTowardLockout: countsTowardLockout,
      );

      if (result.isLeft()) {
        debugPrint('[bio] login($normalizedEmail) → FAILED: '
            '${result.fold((f) => '${f.runtimeType}: $f', (_) => '')} '
            '(biometric auto-login=${!countsTowardLockout})');
        hideLoadingIndicator();
        return;
      }

      Map<String, dynamic> successAuthenticationData =
      result.getOrElse(() => {});
      var successType =
      successAuthenticationData[AuthenticationConstants.successTypeKey];
      debugPrint('[bio] login($normalizedEmail) → successType=$successType '
          '(biometric auto-login=${!countsTowardLockout})');

      if (successType == SuccessAuthenticationType.login) {
        employee =successAuthenticationData[AuthenticationConstants.successData];

        // ✅ Use normalized email for all subsequent operations
        initData(context, isTablet, normalizedEmail, password);
      } else if (successType == SuccessAuthenticationType.inactive ||
          successType == SuccessAuthenticationType.resetPassword) {
        // `inactive`  → first sign-in with the temporary / default password.
        // `resetPassword` → the account was unlocked or an admin approved a
        //                   reset, so the user signed in with the default
        //                   password held in User Access and must choose a new
        //                   one before going any further.
        hideLoadingIndicator();
        employee =
        successAuthenticationData[AuthenticationConstants.successData];

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
      final Stopwatch watch = Stopwatch()..start();
      if (kDebugMode) debugPrint('[login-step] start $name');
      try {
        await step();
        if (kDebugMode) {
          debugPrint('[login-step] done  $name (${watch.elapsedMilliseconds} ms)');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[login-step] FAIL  $name (${watch.elapsedMilliseconds} ms): $e');
        }
        rethrow;
      }
    }

    Future<void> initData(BuildContext context, bool isTablet, String email,
        String password) async
    {

      try {
        // ── Session bookkeeping ────────────────────────────────────────────
        String? previousUser = storage.read('email');

        if (previousUser != null && !Platform.isWindows) {
          // Fire-and-forget: unsubscribing the *previous* account from its push
          // topic has nothing to do with rendering this session's home screen,
          // and on a slow connection it was the first thing the spinner waited
          // on.
          unawaited(_ignoreFailure(
              appNotificationController.unsubscribeFromTopic(previousUser)));
        }

        await Get.delete<DrawerController>(force: true);
        await storage.write('email', email);
        // SECURITY: was storage.write('password', password) on GetStorage,
        // an unencrypted on-disk JSON file. Now the Keychain / encrypted
        // shared preferences.
        await secureCredentialStore.writePassword(password);

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
        await _loginStep('MainCoreEmployeeController.onInit',
            () => Get.find<MainCoreEmployeeController>().onInit());

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
            e.email.any((String m) =>
                m.trim().toLowerCase() == email.trim().toLowerCase());
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
                () => MessagingInterfaceImplementation()
                    .useGroupAndSingleMessaging(context, signedInEmployee!));
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

        // ✅ Get ACTUAL screen width (not shortest side)
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // ✅ CORRECT BREAKPOINT: Use width, not shortest side
        // Mobile: width < 768
        // Tablet/Desktop: width >= 768
        const double MOBILE_BREAKPOINT = 768.0;
        final bool isMobileSize = screenWidth < MOBILE_BREAKPOINT;


        // ✅ Clean up wrong controller BEFORE navigation
        if (isMobileSize) {
          // Mobile - remove drawer controller if it exists
          if (Get.isRegistered<AppDrawerCubit>()) {
            await Get.delete<AppDrawerCubit>(force: true);
          }
        } else {
          // Desktop/Tablet - remove navbar controller if it exists
          if (Get.isRegistered<NavBarCubit>()) {
            await Get.delete<NavBarCubit>(force: true);
          }
        }

        // ✅ Navigate to the correct screen based on width
        // ✅ Navigate to responsive wrapper instead of specific screen
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              child: const MainResponsiveScreen()  // ← NEW: Use responsive wrapper
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
          unawaited(_ignoreFailure(() async {
            await addEmployeeController.createEmployee(
                signedIn, signedIn.email.last);
            systemLogsController.systemLogsAction("update employee");
          }()));
        } else {
          debugPrint(
            '⚠️ [LOGIN] No employee record resolved for this session — '
            'lastLogin not recorded.',
          );
        }

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

      } catch (e, stackTrace) {
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
        unawaited(_ignoreFailure(
            FirebaseNotificationHandler.subscribeToTopic(email)));
      }
      if (!Platform.isWindows) {
        unawaited(_ignoreFailure(
            FCMSubscriptionService.subscribeToPersonalChannel(userEmail: email)));
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
        await _ignoreFailure(
            _permissionSyncService.startAllEmployeeListeners());
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
      } catch (e, stackTrace) {
        debugPrint('post-login background task failed: $e\n$stackTrace');
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
        DocumentSnapshot companyDoc = await db

            .collection(getBaseUrl('Companys'))
            .doc(_companyId)
            .get();


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
              List<String> companyModules =
              List<String>.from(modulesMap['modules']);


              // ✅ CRITICAL: Sync BEFORE UI loads
              await _syncMasterAdminWithCompanyModules(companyModules);


              // ✅ CRITICAL FIX: Refresh roles_module from Firestore to load updated data
              await getRoles();

            } else {
            }
          } else {
          }
        } else {
        }

        // ✅ STEP 2: Setup real-time listener for future changes
        _listenToCompanyModules();

      } catch (e, stackTrace) {
      }

    }


    Position? _currentPosition;
    Position? get currentPosition => _currentPosition;

    void _getCurrentLocation() async {

      bool serviceEnabled;
      LocationPermission permission;
      if (Platform.isMacOS) {
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
          desiredAccuracy: LocationAccuracy.high);

      _currentPosition = position;
      update();

    }
  }