  ///************************ FILE INFO ******************************
  /// File name: login_controller.dart
  /// Purpose: Contains the controller for login feature.
  /// Refactored at: 8/1/2025
  /// Author: Mohamed Elrashidy
  /// Updated: Added real-time listeners with extensive debugging

  import 'dart:async';
  import 'dart:io';

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:dartz/dartz.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/features/notification/presentation/controller/app_notification_controller.dart';
import 'package:demo_app/features/roles/user_management/controller/user_role_controller.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:get/get.dart';
  import 'package:intl/intl.dart';
  import 'package:demo_app/core/constants/system_actions.dart';
  import 'package:demo_app/features/settings/mode_changer.dart';
  import 'package:demo_app/core/haptic/haptic_controller.dart';
  import 'package:demo_app/core/network/api_constants.dart';
  import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/helper/employees/add_wrong_employee_controller.dart';
import 'package:demo_app/core/helper/employees/biometrics_contoller.dart';
// REMOVED_MODULE:   import 'package:demo_app/features/skeleton/controllers/notification_controller.dart';
import 'package:demo_app/features/settings/presentation/controller/request_controller.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/employee_controller.dart';
// REMOVED_MODULE: import 'package:demo_app/features/events/controllers/events_controllers/event_controller.dart';
// REMOVED_MODULE:   import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
  import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
  import 'package:demo_app/features/home/app_drawer/presentation/ui/pages/custom_drawer.dart';
  
  import 'package:demo_app/core/helper/employees/presentation/controller/main_core_department_controller.dart';
  import 'package:demo_app/features/roles/role_management/ui/pages/role_responsive_page.dart';
  import 'package:demo_app/core/helper/settings/presentation/controller/add_company_controller.dart';
  import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
  import 'package:page_transition/page_transition.dart';

  import '../../../../../core/network/failure_model.dart';
  import '../../../../../core/services/notifications/firebase_notification_handler.dart';
  import 'package:demo_app/features/roles/role_management/controller/add_access_type_controller.dart';
  import '../../welcome_screen/views/mobile_view/mobile_sign_in.dart';
  import '../../welcome_screen/views/reset_password/reset_password_screen.dart';
  import '../../welcome_screen/views/start_sign_in.dart';
  // REMOVED_MODULE: import '../../../../form_builder_module/core/di/injection.dart';
  import '../../../../messaging/interface/messaging_interface_implementation.dart';
  import 'package:demo_app/core/network/get_base_url.dart';
  import '../../../../employee/data/models/emplyees_model/new_employee_model.dart';
  import '../../../../employee/presentation/controller/main_core_employee_controller.dart';
  import '../../../../notification/presentation/controller/notification_controller_cubit_main_core.dart';
  // REMOVED_MODULE: import '../../../../task_management_module/borad/controller/board_controller.dart';
  import '../../../../home/app_drawer/presentation/controller/drawer_controller.dart';
  import 'package:demo_app/core/helper/employees/data/models/new_employee_model/emplyees_model/new_employee_model.dart';
  import 'package:demo_app/features/home/home_page/presentation/ui/pages/main_responnsive.dart';
  import '../../../../home/nav_bar/presentation/controller/nav_bar_controller.dart';
  import 'package:demo_app/features/notification/data/data_source/subscrip.dart';
  import 'package:demo_app/features/roles/role_management/data/models/role_model.dart';
  import 'package:demo_app/features/roles/role_management/data/repository/role_repository.dart';
  import 'package:demo_app/features/roles/role_management/data/services/permission_sync_service.dart';
  import '../../domain/enums/success_authentication_type.dart';
  import '../../utils/constants.dart';
  import 'demo_login_controller.dart';
  import 'package:demo_app/features/roles/system_logs/controller/system_logs_controller.dart';

  class LoginController extends GetxController {
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
      print("🟢 ════════════════════════════════════════");
      print("🟢 LoginController.onInit() START");
      print("🟢 ════════════════════════════════════════");

      await getCompanyData();

      await checkCanBiometrics().then((value) {
        print("🟢 Biometrics check complete: $value");
        signWithBiometrics();
      });

      _getCurrentLocation();
      wrongPasswordCount = 0;

      print("🟢 LoginController.onInit() COMPLETE");
      super.onInit();
    }

    @override
    void onClose() {
      print("🔴 ════════════════════════════════════════");
      print("🔴 LoginController.onClose() START");
      print("🔴 ════════════════════════════════════════");

      _cancelAllSubscriptions();

      // ✅ ADD: Dispose permission sync service
      _permissionSyncService.dispose();

      print("🔴 LoginController.onClose() COMPLETE");
      super.onClose();
    }

    // ✅ Cancel all real-time listeners
    void _cancelAllSubscriptions() {
      print("🔴 Cancelling all real-time subscriptions...");

      if (_rolesSubscription != null) {
        _rolesSubscription!.cancel();
        print("   ✓ Cancelled _rolesSubscription");
      }

      if (_permissionsSubscription != null) {
        _permissionsSubscription!.cancel();
        print("   ✓ Cancelled _permissionsSubscription");
      }

      if (_currentEmployeeSubscription != null) {
        _currentEmployeeSubscription!.cancel();
        print("   ✓ Cancelled _currentEmployeeSubscription");
      }

      if (_departmentsSubscription != null) {
        _departmentsSubscription!.cancel();
        print("   ✓ Cancelled _departmentsSubscription");
      }

      if (_demoPermissionsSubscription != null) {
        _demoPermissionsSubscription!.cancel();
        print("   ✓ Cancelled _demoPermissionsSubscription");
      }

      print("🔴 All subscriptions cancelled");
    }

    int wrongPasswordCount = 0;
    AddDepartmentController addDepartmentController =
    Get.put(AddDepartmentController());

    Future<void> getDepartments() async {
      print("📦 getDepartments() called");
      await addDepartmentController.getDepartments();
      print("📦 getDepartments() complete");
    }

    // ✅ Setup real-time listener for departments
    void _listenToDepartments() {
      print("\n🟢 ════════════════════════════════════════");
      print("🟢 _listenToDepartments() START");
      print("🟢 ════════════════════════════════════════");

      try {
        _departmentsSubscription = db
            .collection('departments')
            .snapshots()
            .listen((snapshot) {
          print("\n🔄 ════════════════════════════════════════");
          print("🔄 Departments snapshot received");
          print("🔄 Number of departments: ${snapshot.docs.length}");
          print("🔄 ════════════════════════════════════════");

          getDepartments();
          update();

          print("🔄 Departments update complete");
        }, onError: (error) {
          print("🔴 ════════════════════════════════════════");
          print("🔴 Error listening to departments: $error");
          print("🔴 ════════════════════════════════════════");
        });

        print("✅ Departments listener setup complete");
      } catch (e, stackTrace) {
        print("🔴 ════════════════════════════════════════");
        print("🔴 Exception in _listenToDepartments: $e");
        print("🔴 Stack trace: $stackTrace");
        print("🔴 ════════════════════════════════════════");
      }
    }

    AddAccessTypeController addAccessTypeController =
    Get.put(AddAccessTypeController());

    EmployeeController addEmployeeController = Get.put(EmployeeController());
    AddWrongEmployeeController addWrongEmployeeController =
    Get.put(AddWrongEmployeeController());
    AppNotificationController appNotificationController =
    Get.put(AppNotificationController());

    // EventsEmployeeController employeeController =
    // Get.put(EventsEmployeeController());

    Future<void> getEvents() async {
      print("📅 getEvents() called");
      // await eventController.fetchEmployees();
      // await eventController.fetchEventsFromFirebase();
      // await employeeController.fetchEmployees();
      // await employeeController.fetchEventsFromFirebase();
      update();
      print("📅 getEvents() complete");
    }

    Future<void> getEmployee(email) async {
      print("👤 getEmployee() called for: $email");
      employee = await addEmployeeController.getEmployee(email);
      update();
      print("👤 getEmployee() complete");
    }

    // ✅ Setup real-time listener for current logged-in employee
    void _listenToCurrentEmployee(String email) {
      print("\n🟢 ════════════════════════════════════════");
      print("🟢 _listenToCurrentEmployee() START");
      print("🟢 Email: $email");
      print("🟢 ════════════════════════════════════════");

      try {
        _currentEmployeeSubscription = db
            .collection('employees')
            .where('email', arrayContains: email)
            .snapshots()
            .listen((snapshot) async {
          print("\n🔄 ════════════════════════════════════════");
          print("🔄 Current employee snapshot received");
          print("🔄 Documents found: ${snapshot.docs.length}");

          if (snapshot.docs.isNotEmpty) {
            print("🔄 Employee data exists");

            try {
              NewEmployeeModelHistory updatedEmployee =
              NewEmployeeModelHistory.fromMap(snapshot.docs.first.data());

              print("🔄 Employee parsed successfully");
              print("🔄 Employee ID: ${updatedEmployee.id}");
              print("🔄 Employee email: ${updatedEmployee.email.lastOrNull}");
              print("🔄 Employee role: ${updatedEmployee.role.lastOrNull}");

              employee = updatedEmployee;

              Mode.owner = employee?.role?.isNotEmpty == true &&
                  employee!.role.last == 'super admin';
              Mode.hr = employee?.role?.isNotEmpty == true &&
                  employee!.role.last == 'hr';

              print("🔄 Mode.owner updated: ${Mode.owner}");
              print("🔄 Mode.hr updated: ${Mode.hr}");

              update();

              print("✅ Employee update complete");
            } catch (e, stackTrace) {
              print("🔴 Error parsing employee: $e");
              print("🔴 Stack trace: $stackTrace");
            }
          } else {
            print("⚠️ No employee documents found");
          }

          print("🔄 ════════════════════════════════════════");
        }, onError: (error) {
          print("🔴 ════════════════════════════════════════");
          print("🔴 Error listening to current employee: $error");
          print("🔴 ════════════════════════════════════════");
        });

        print("✅ Current employee listener setup complete");
      } catch (e, stackTrace) {
        print("🔴 ════════════════════════════════════════");
        print("🔴 Exception in _listenToCurrentEmployee: $e");
        print("🔴 Stack trace: $stackTrace");
        print("🔴 ════════════════════════════════════════");
      }
    }

    // Reuse the core CompanyController already registered by ThemeController;
    // re-putting the legacy features/settings version caused a GetX type-name
    // collision ("CompanyController is not a subtype of CompanyController").
    CompanyController addCompanyController = Get.isRegistered<CompanyController>()
        ? Get.find<CompanyController>()
        : Get.put(CompanyController());

    Future<void> getCompanyData() async {
      print("\n🏢 ════════════════════════════════════════");
      print("🏢 getCompanyData() START");
      print("🏢 ════════════════════════════════════════");

      String companyName = ApiConstants.baseUri.split("/").last;
      print("🏢 Extracted company name: '$companyName'");

      if (companyName.isEmpty) {
        companyName = 'bayanatz';
        print("🏢 Company name was empty, using default: '$companyName'");
      }

      _companyId = companyName;
      print("🏢 Set _companyId to: '$_companyId'");

      addCompanyController.getCompany(companyName: companyName);

      print("🏢 getCompanyData() COMPLETE");
      print("🏢 ════════════════════════════════════════");
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
      print("👥 getAllEmployees() called");
      await addEmployeeController.getAllEmployees();

      if (addEmployeeController.employeesWithoutFilter == null ||
          addEmployeeController.employeesWithoutFilter!.isEmpty) {
        print("⚠️ No employees found");
        return;
      }

      print("👥 Processing ${addEmployeeController.employeesWithoutFilter!.length} employees");

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
          print("⚠️ Error processing employee at index $i: $e");
          continue;
        }
      }

      print("👥 getAllEmployees() complete");
    }

    Future<void> getAllWrongEmployees() async {}

    Future<void> getRoles() async {
      print("🎭 getRoles() called");
      await roleCubit.getUnDeletedRoles();
      print("🎭 getRoles() complete");
    }

    // ✅ Setup real-time listener for roles_module
    void _listenToRoles() {
      print("\n🟢 ════════════════════════════════════════");
      print("🟢 _listenToRoles() START");
      print("🟢 ════════════════════════════════════════");

      try {
        _rolesSubscription =
            db.collection('Roles').snapshots().listen((snapshot) {
              print("\n🔄 ════════════════════════════════════════");
              print("🔄 Roles snapshot received");
              print("🔄 Number of roles_module: ${snapshot.docs.length}");
              print("🔄 ════════════════════════════════════════");

              getRoles();
              update();

              print("🔄 Roles update complete");
            }, onError: (error) {
              print("🔴 ════════════════════════════════════════");
              print("🔴 Error listening to roles_module: $error");
              print("🔴 ════════════════════════════════════════");
            });

        print("✅ Roles listener setup complete");
      } catch (e, stackTrace) {
        print("🔴 ════════════════════════════════════════");
        print("🔴 Exception in _listenToRoles: $e");
        print("🔴 Stack trace: $stackTrace");
        print("🔴 ════════════════════════════════════════");
      }
    }

    // ✅ Setup real-time listener for permissions (Demo_Permissions)
    void _listenToPermissions() {
      print("\n🟢 ════════════════════════════════════════");
      print("🟢 _listenToPermissions() START");
      print("🟢 ════════════════════════════════════════");

      try {
        _permissionsSubscription =
            db.collection('Demo_Permissions').snapshots().listen((snapshot) {
              print("\n🔄 ════════════════════════════════════════");
              print("🔄 Demo_Permissions collection snapshot received");
              print("🔄 Number of documents: ${snapshot.docs.length}");
              print("🔄 ════════════════════════════════════════");

              getRoles();
              update();

              print("🔄 Permissions update complete");
            }, onError: (error) {
              print("🔴 ════════════════════════════════════════");
              print("🔴 Error listening to permissions: $error");
              print("🔴 ════════════════════════════════════════");
            });

        print("✅ Permissions listener setup complete");
      } catch (e, stackTrace) {
        print("🔴 ════════════════════════════════════════");
        print("🔴 Exception in _listenToPermissions: $e");
        print("🔴 Stack trace: $stackTrace");
        print("🔴 ════════════════════════════════════════");
      }
    }

    // ✅ NEW: Setup real-time listener for Demo_Permissions document
    void _listenToDemoPermissions() {
      print("\n🟢 ════════════════════════════════════════════════════════");
      print("🟢 _listenToDemoPermissions() START");
      print("🟢 ════════════════════════════════════════════════════════");

      if (_companyId == null || _companyId!.isEmpty) {
        print("🔴 ERROR: Company ID is null or empty!");
        print("🔴 _companyId: '$_companyId'");
        print("🔴 Cannot setup Demo_Permissions listener");
        print("🔴 ════════════════════════════════════════════════════════");
        return;
      }

      print("🟢 Company ID: '$_companyId'");
      print("🟢 Listening to: Demo_Permissions/$_companyId");
      print("🟢 Using Firestore instance: db (prod)");  // ← UPDATED

      try {
        _demoPermissionsSubscription = db  // ← ALREADY CORRECT
            .collection('Demo_Permissions')
            .doc(_companyId)
            .snapshots()
            .listen((snapshot) async {
          print("\n🔄 ════════════════════════════════════════════════════════");
          print("🔄 Demo_Permissions document snapshot received");
          print("🔄 Document path: Demo_Permissions/$_companyId");
          print("🔄 Document exists: ${snapshot.exists}");
          print("🔄 Using: db (PROD INSTANCE)");  // ← UPDATED THIS LINE

          if (snapshot.exists) {
            print("🔄 Document has data");

            try {
              Map<String, dynamic> demoPermissions =
              snapshot.data() as Map<String, dynamic>;

              print("🔄 Parsed Demo_Permissions data");
              print("🔄 Number of keys: ${demoPermissions.keys.length}");
              print("🔄 Keys: ${demoPermissions.keys.toList()}");

              print("🔄 Starting sync with all roles_module...");
              await _syncAllRolesWithDemoPermissions(demoPermissions);
              print("🔄 Sync complete");

              print("🔄 Refreshing roles_module...");
              await getRoles();
              update();
              print("🔄 Roles refreshed");

              print("✅ Demo_Permissions update complete");
            } catch (e, stackTrace) {
              print("🔴 Error processing Demo_Permissions data: $e");
              print("🔴 Stack trace: $stackTrace");
            }
          } else {
            print("⚠️ Document does not exist at path: Demo_Permissions/$_companyId");
          }

          print("🔄 ════════════════════════════════════════════════════════");
        }, onError: (error, stackTrace) {
          print("🔴 ════════════════════════════════════════════════════════");
          print("🔴 Error listening to Demo_Permissions: $error");
          print("🔴 Stack trace: $stackTrace");
          print("🔴 ════════════════════════════════════════════════════════");
        });

        print("✅ Demo_Permissions listener setup complete (using db/prod)");  // ← UPDATED
        print("✅ ════════════════════════════════════════════════════════");
      } catch (e, stackTrace) {
        print("🔴 ════════════════════════════════════════════════════════");
        print("🔴 Exception in _listenToDemoPermissions: $e");
        print("🔴 Stack trace: $stackTrace");
        print("🔴 ════════════════════════════════════════════════════════");
      }
    }



    // ✅ NEW: Listen to Company document for modules (not Demo_Permissions)
    void _listenToCompanyModules() {
      print("\n🟢 ════════════════════════════════════════════════════════");
      print("🟢 _listenToCompanyModules() START");
      print("🟢 ════════════════════════════════════════════════════════");

      if (_companyId == null || _companyId!.isEmpty) {
        print("🔴 ERROR: Company ID is null or empty!");
        print("🔴 _companyId: '$_companyId'");
        print("🔴 Cannot setup Company Modules listener");
        print("🔴 ════════════════════════════════════════════════════════");
        return;
      }

      print("🟢 Company ID: '$_companyId'");
      print("🟢 Listening to: Demo/$_companyId/Companys/$_companyId");
      print("🟢 Using Firestore instance: db (prod)");

      try {
        _demoPermissionsSubscription = db

            .collection(getBaseUrl('Companys'))
            .doc(_companyId)
            .snapshots()
            .listen((snapshot) async {
          print("\n🔄 ════════════════════════════════════════════════════════");
          print("🔄 Company document snapshot received");
          print("🔄 Document path: Demo/$_companyId/Companys/$_companyId");
          print("🔄 Document exists: ${snapshot.exists}");

          if (snapshot.exists) {
            print("🔄 Document has data");

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

                  print("🔄 Company has ${companyModules.length} modules: $companyModules");
                  print("🔄 Starting sync with Master Admin role...");

                  // ✅ Sync Master Admin with these modules
                  await _syncMasterAdminWithCompanyModules(companyModules);

                  print("🔄 Refreshing roles_module...");
                  await getRoles();
                  update();

                  print("✅ Company modules sync complete");
                } else {
                  print("⚠️ 'modules' field exists but no 'modules' array found");
                }
              } else {
                print("⚠️ No 'modules' field in company document");
              }
            } catch (e, stackTrace) {
              print("🔴 Error processing company data: $e");
              print("🔴 Stack trace: $stackTrace");
            }
          } else {
            print("⚠️ Company document does not exist at path: Demo/$_companyId/Companys/$_companyId");
          }

          print("🔄 ════════════════════════════════════════════════════════");
        }, onError: (error, stackTrace) {
          print("🔴 ════════════════════════════════════════════════════════");
          print("🔴 Error listening to Company document: $error");
          print("🔴 Stack trace: $stackTrace");
          print("🔴 ════════════════════════════════════════════════════════");
        });

        print("✅ Company modules listener setup complete");
        print("✅ ════════════════════════════════════════════════════════");
      } catch (e, stackTrace) {
        print("🔴 ════════════════════════════════════════════════════════");
        print("🔴 Exception in _listenToCompanyModules: $e");
        print("🔴 Stack trace: $stackTrace");
        print("🔴 ════════════════════════════════════════════════════════");
      }
    }


    // ✅ NEW: Sync Master Admin role with company's actual modules
    Future<void> _syncMasterAdminWithCompanyModules(
        List<String> companyModules) async
    {
      print("\n════════════════════════════════════════════════════════");
      print("🔄 _syncMasterAdminWithCompanyModules() START");
      print("════════════════════════════════════════════════════════");
      print("📊 Company Modules (${companyModules.length}): $companyModules");

      try {
        print("\n🔍 Step 1: Getting Master Admin role...");
        RoleRepository roleRepository = RoleRepository();
        var rolesResult = await roleRepository.getUnDeletedRoles();

        if (rolesResult.isLeft()) {
          print("❌ Failed to get roles_module");
          return;
        }

        List<RoleHistoryModel> allRoles = rolesResult.getOrElse(() => []);
        print("📊 Total roles_module found: ${allRoles.length}");

        // ✅ Find Master Admin role
        List<RoleHistoryModel> masterAdminRoles = allRoles.where((role) {
          bool isMasterAdmin = role.currentRoleName.toLowerCase() == 'master admin';
          print("   ${role.currentRoleName}: ${isMasterAdmin ? '✅ MASTER ADMIN' : '⏭️  Skip'}");
          return isMasterAdmin;
        }).toList();

        if (masterAdminRoles.isEmpty) {
          print("⚠️ No Master Admin role found - exiting");
          return;
        }

        RoleHistoryModel masterAdmin = masterAdminRoles.first;
        String roleId = masterAdmin.roleId;
        print("✅ Found Master Admin role");
        print("   Role ID: $roleId");
        print("   Role Name: ${masterAdmin.currentRoleName}");

        // ✅ Check if selected modules match company modules
        List<String> currentModules = masterAdmin.currentSelectedModules;
        print("\n📊 Current Master Admin modules (${currentModules.length}): $currentModules");

        // ✅ Compare: Check if different
        bool needsUpdate = false;
        List<String> missingModules = [];
        List<String> extraModules = [];

        if (currentModules.length != companyModules.length) {
          needsUpdate = true;
          print("⚠️ Module count mismatch: ${currentModules.length} vs ${companyModules.length}");
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
          print("📋 Missing modules (need to add): $missingModules");
        }

        if (extraModules.isNotEmpty) {
          print("📋 Extra modules (need to remove): $extraModules");
        }

        if (needsUpdate) {
          print("\n🔄 Updating Master Admin selected modules...");
          print("   FROM: $currentModules");
          print("   TO:   $companyModules");

          WriteBatch batch = db.batch();

          // ✅ Update role's Selected_Modules field in Roles collection
          DocumentReference roleRef = db

              .collection(getBaseUrl('Roles'))
              .doc(roleId);

          print("\n📝 Updating document: Demo/$_companyId/Roles/$roleId");
          print("   Setting Selected_Modules to: $companyModules");

          batch.update(roleRef, {
            'Selected_Modules': companyModules,
          });

          await batch.commit();
          print("✅ Batch committed - Master Admin modules updated!");
          print("✅ Master Admin now has ${companyModules.length} modules");
        } else {
          print("✅ Master Admin already has correct modules - no update needed");
        }

        print("\n════════════════════════════════════════════════════════");
        print("✅ _syncMasterAdminWithCompanyModules() COMPLETE");
        print("════════════════════════════════════════════════════════\n");
      } catch (e, stackTrace) {
        print("\n════════════════════════════════════════════════════════");
        print("❌ ERROR IN _syncMasterAdminWithCompanyModules");
        print("❌ Error: $e");
        print("❌ Stack trace:");
        print(stackTrace);
        print("════════════════════════════════════════════════════════\n");
      }
    }

    // ✅ NEW: Sync all existing roles_module with updated Demo_Permissions
    Future<void> _syncAllRolesWithDemoPermissions(
        Map<String, dynamic> demoPermissions) async {
      print("\n════════════════════════════════════════════════════════");
      print("🔄 _syncAllRolesWithDemoPermissions() START");
      print("════════════════════════════════════════════════════════");
      print("📊 Demo_Permissions keys: ${demoPermissions.keys.length}");
      print("📊 Keys list: ${demoPermissions.keys.toList()}");

      try {
        print("\n🔍 Step 1: Getting Master Admin role...");
        RoleRepository roleRepository = RoleRepository();
        var rolesResult = await roleRepository.getUnDeletedRoles();

        if (rolesResult.isLeft()) {
          print("❌ Failed to get roles_module for syncing");
          return;
        }

        List<RoleHistoryModel> allRoles = rolesResult.getOrElse(() => []);
        print("📊 Total roles_module found: ${allRoles.length}");

        // ✅ FILTER: Only get "Master Admin" role
        List<RoleHistoryModel> roles = allRoles.where((role) {
          bool isMasterAdmin = role.currentRoleName.toLowerCase() == 'master admin';
          print("   ${role.currentRoleName}: ${isMasterAdmin ? '✅ MASTER ADMIN' : '❌ Skip'}");
          return isMasterAdmin;
        }).toList();

        print("✅ Filtered to ${roles.length} Master Admin role(s)");

        if (roles.isEmpty) {
          print("⚠️ No Master Admin role found - exiting");
          return;
        }

        print("\n🔍 Step 2: Creating batch...");
        WriteBatch batch = db.batch();
        int totalUpdates = 0;
        print("✅ Batch created");

        print("\n🔍 Step 3: Processing Master Admin role...");
        for (int roleIndex = 0; roleIndex < roles.length; roleIndex++) {
          RoleHistoryModel role = roles[roleIndex];
          String roleId = role.roleId;
          String roleName = role.currentRoleName;

          print("\n┌─────────────────────────────────────────────────");
          print("│ 🔄 Master Admin Role");
          print("│    Name: $roleName");
          print("│    ID: $roleId");
          print("└─────────────────────────────────────────────────");

          int moduleUpdateCount = 0;

          print("   🔍 Processing modules in Demo_Permissions...");
          for (String moduleName in demoPermissions.keys) {
            print("\n      📦 Module: $moduleName");

            var moduleData = demoPermissions[moduleName];
            print("         Data type: ${moduleData.runtimeType}");

            if (moduleData is! Map) {
              print("         ⚠️ Not a Map - skipping");
              continue;
            }

            Map<String, dynamic> modulePermissions =
            Map<String, dynamic>.from(moduleData);
            print("         Permission keys count: ${modulePermissions.keys.length}");

            String collectionName = _getPermissionCollectionName(moduleName);
            print("         Collection name: '$collectionName'");

            if (collectionName.isEmpty) {
              print("         ⚠️ No collection mapping - skipping");
              continue;
            }

            String permDocPath = "Demo/$_companyId/$collectionName/$roleId";
            print("         Document path: $permDocPath");

            DocumentReference rolePermRef = db

                .collection(getBaseUrl('collectionName'))
                .doc(roleId);

            print("         🔍 Fetching existing document...");
            DocumentSnapshot rolePermDoc = await rolePermRef.get();
            print("         Document exists: ${rolePermDoc.exists}");

            if (!rolePermDoc.exists) {
              print("         ⚠️ No existing permissions - skipping");
              continue;
            }

            Map<String, dynamic> currentPermissions =
            Map<String, dynamic>.from(rolePermDoc.data() as Map<String, dynamic>);
            print("         Current permissions keys: ${currentPermissions.keys.length}");

            Map<String, dynamic> updatedPermissions =
            Map<String, dynamic>.from(currentPermissions);
            int timestamp = DateTime.now().millisecondsSinceEpoch;

            List<int> timestamps =
            List<int>.from(updatedPermissions['timestamps'] ?? []);
            timestamps.add(timestamp);
            updatedPermissions['timestamps'] = timestamps;

            int permissionChangeCount = 0;

            print("         🔄 Processing ${modulePermissions.keys.length} permissions...");
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
                print("            ✓ $permKey: $currentValue → $newValue (CHANGED)");
              }
            });

            if (permissionChangeCount > 0) {
              batch.set(rolePermRef, updatedPermissions);
              moduleUpdateCount++;
              totalUpdates++;

              print("         ✅ Updated $permissionChangeCount permissions");
            } else {
              print("         ℹ️ No changes needed");
            }
          }

          if (moduleUpdateCount > 0) {
            print("   ✅ Master Admin - Updated $moduleUpdateCount modules");
          } else {
            print("   ℹ️ Master Admin - No updates needed");
          }
        }

        print("\n🔍 Step 4: Committing batch...");
        if (totalUpdates > 0) {
          print("   📝 Total updates to commit: $totalUpdates");
          await batch.commit();
          print("   ✅ Batch committed successfully");
        } else {
          print("   ℹ️ No updates to commit - Master Admin already in sync");
        }

        print("\n════════════════════════════════════════════════════════");
        print("✅ _syncAllRolesWithDemoPermissions() COMPLETE");
        print("════════════════════════════════════════════════════════\n");
      } catch (e, stackTrace) {
        print("\n════════════════════════════════════════════════════════");
        print("❌ ERROR IN _syncAllRolesWithDemoPermissions");
        print("❌ Error: $e");
        print("❌ Stack trace:");
        print(stackTrace);
        print("════════════════════════════════════════════════════════\n");
      }
    }

    // ✅ Helper method to map module name to collection name
    String _getPermissionCollectionName(String moduleName) {
      print("         🔍 _getPermissionCollectionName('$moduleName')");

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
        case 'form_builder':
          result = 'form_builder_module_permissions';
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
        case 'notification':  // ✅ ADD THIS
          result = 'notification_module_permissions';
          break;
        default:
          result = '';
      }

      print("         → Mapped to: '$result'");
      return result;
    }

    // ✅ Manual refresh method for pull-to-refresh
    Future<void> refreshAllData() async {
      print("\n🔄 ════════════════════════════════════════");
      print("🔄 refreshAllData() START");
      print("🔄 ════════════════════════════════════════");

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

        print("✅ refreshAllData() COMPLETE");
      } catch (e, stackTrace) {
        hideLoadingIndicator();
        print("🔴 Error during manual refresh: $e");
        print("🔴 Stack trace: $stackTrace");

        Get.snackbar(
          'Error',
          'Failed to refresh data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      print("🔄 ════════════════════════════════════════");
    }

    bool canBiometrics = false;
    bool isUseBiometrics = false;

    Future<bool> checkCanBiometrics() async {
      print("🔐 checkCanBiometrics() called");
      canBiometrics = await checkBiometrics();
      isUseBiometrics = storage.read('Biometric') ?? true && canBiometrics;
      update();
      print("🔐 checkCanBiometrics() result: $canBiometrics");
      return canBiometrics;
    }

    RequestController requestController = Get.find();

    Future<void> getRequests() async {
      print("📋 getRequests() called");
      requestController.allRequestsPending =
      await requestController.getAllRequests(true);
      requestController.allRequestReview =
      await requestController.getAllRequests(false);
      print("📋 getRequests() complete");
    }

    void signWithBiometrics() async {
      print("🔐 signWithBiometrics() called");
      if (isUseBiometrics && storage.read('email') != null) {
        bool authenticated = await authenticate();
        print("🔐 Authentication result: $authenticated");

        switch (authenticated) {
          case true:
            String email = storage.read('email');
            String password = storage.read('password');
            print("🔐 Proceeding with login for: $email");
            login(Get.context!, email, password);
            break;
          case false:
            print("🔐 Authentication failed - redirecting to login");
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
                builder: (context) => Get.size.shortestSide > 600
                    ? StartSignIn()
                    : const StartSignInMobile()));
        }
      } else {
        print("🔐 Biometrics not enabled or no saved email");
      }
    }

    // ✅ PATCH FOR login_controller.dart
  // Apply this change to the login() method:

    login(BuildContext context, String email, String password) async {
      print("\n🔐 ════════════════════════════════════════");
      print("🔐 login() START");
      print("🔐 Original Email: $email");

      // ✅ Normalize email to lowercase for case-insensitive comparison
      String normalizedEmail = email.trim().toLowerCase();
      print("🔐 Normalized Email: $normalizedEmail");
      print("🔐 ════════════════════════════════════════");

      MessagingInterfaceImplementation().initMessagingModule();

      showLoadingIndicator();
      bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
      print("🔐 Is tablet: $isTablet");

      // ✅ Use normalized email for login
      Either<Failure, dynamic> result = await demoLoginController
          .loginWithEmailAndPassword(email: normalizedEmail, password: password);

      if (result.isLeft()) {
        print("❌ Login failed");
        hideLoadingIndicator();
        return;
      }

      print("✅ Login successful");
      Map<String, dynamic> successAuthenticationData =
      result.getOrElse(() => {});
      var successType =
      successAuthenticationData[AuthenticationConstants.successTypeKey];
      print("🔐 Success type: $successType");

      if (successType == SuccessAuthenticationType.login) {
        print("🔐 Normal login - proceeding to initData");
        employee =successAuthenticationData[AuthenticationConstants.successData];

        // ✅ Use normalized email for all subsequent operations
        initData(context, isTablet, normalizedEmail, password);
      } else if (successType == SuccessAuthenticationType.inactive) {
        print("🔐 Inactive account - redirecting to reset password");
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
            ),
          ),
        );
      }

      print("🔐 login() COMPLETE");
    }

    void _testBothInstances() async {
      print("\n🧪 TESTING BOTH FIRESTORE INSTANCES");

      // Test default instance
      print("🧪 Testing DEFAULT instance...");
      final defaultDoc = await FirebaseFirestore.instance
          .collection('Demo_Permissions')
          .doc('39185362')
          .get();
      print("🧪 DEFAULT - Document exists: ${defaultDoc.exists}");
      if (defaultDoc.exists) {
        print("🧪 DEFAULT - Data: ${defaultDoc.data()}");
      }

      // Test db instance
      print("🧪 Testing DB instance...");
      final dbDoc = await db
          .collection('Demo_Permissions')
          .doc('39185362')
          .get();
      print("🧪 DB - Document exists: ${dbDoc.exists}");
      if (dbDoc.exists) {
        print("🧪 DB - Data: ${dbDoc.data()}");
      }
    }




    Future<void> initData(BuildContext context, bool isTablet, String email,
        String password) async
    {
      print("\n🟢 ══════════════════════════════════════════════════════════");
      print("🟢 initData() START");
      print("🟢 Email: $email");
      print("🟢 Is tablet: $isTablet");
      print("🟢 ══════════════════════════════════════════════════════════");

      try {
        print("\n🔹 Initializing controllers...");
        // Get.put(BoardController());

        MessagingInterfaceImplementation().initMessagingModule();

        String? previousUser = storage.read('email');
        print("🔹 Previous user: $previousUser");

        if (previousUser != null && !Platform.isWindows) {
          await appNotificationController.unsubscribeFromTopic(previousUser);
        }

        await Get.delete<DrawerController>(force: true);
        await storage.write('email', email);
        await storage.write('password', password);

        if (!Platform.isWindows) {
          if (Platform.isAndroid) {
            await FirebaseNotificationHandler.subscribeToTopic(email);
          }
        }

        print("\n🟢 Step 1: Getting roles_module...");
        await getRoles();

        print("\n🟢 Step 2: Getting departments...");
        await getDepartments();

        print("\n🟢 Step 3: Getting employee...");
        await getEmployee(email);

        print("\n🟢 Step 4: Initializing MainCoreEmployeeController...");
        // ✅ FIX: await so employeeEntity is set BEFORE navigating to the
        // main screen. Otherwise AppDrawerController.onInit() runs with a
        // null employeeEntity and the drawer shows only Home + Settings.
        await Get.find<MainCoreEmployeeController>().onInit();

        print("\n🟢 Step 5: Getting all employees...");
        await getAllEmployees();

        print("\n🟢 Step 6: Getting events...");
        getEvents();

        print("\n🟢 Step 7: Getting access types...");
        await addAccessTypeController.getAllAccessTypes();

        print("\n🟢 Step 7.5: Setting up personal notification channel...");
        try {
          await FCMSubscriptionService.subscribeToPersonalChannel(userEmail: email);
          print("✅ Personal notification channel configured");
        } catch (e) {
          print("⚠️ Failed to setup notification channel: $e");
          // Don't fail login if subscription fails
        }

        print("\n🟢 Step 8: Getting wrong employees...");
        await addWrongEmployeeController.getAllEmployees();

        print("\n🟢 Step 9: Getting company data...");
        await getCompanyData();

        print("\n🟢 Step 10: Getting requests...");
        getRequests();

        Mode.owner = employee?.role?.isNotEmpty == true &&
            employee!.role.last == 'super admin';
        Mode.hr = employee?.role?.isNotEmpty == true &&
            employee!.role.last == 'hr';

        print("\n🔹 Mode.owner: ${Mode.owner}");
        print("🔹 Mode.hr: ${Mode.hr}");

        print("\n🟢 Step 11: Setting up real-time listeners...");
        print("   🔹 Setting up roles_module listener...");
        _listenToRoles();

        print("   🔹 Setting up permissions listener...");
        _listenToPermissions();

        print("   🔹 Setting up current employee listener...");
        _listenToCurrentEmployee(email);

        print("   🔹 Setting up departments listener...");
        _listenToDepartments();

        // ✅ UPDATED: Setup company modules and sync
        print("   🔹 Setting up Company Modules and performing initial sync...");
        await _setupCompanyModulesAndSync();

        // ✅ NEW: Initialize and start permission sync service
        print("\n🟢 Step 12: Initializing Permission Sync Service...");
        if (_companyId != null && _companyId!.isNotEmpty) {
          _permissionSyncService.initialize(_companyId!);

          print("   🔹 Starting Demo_Permissions listener...");
          _permissionSyncService.startDemoPermissionsListener();

          print("   🔹 Starting employee subscription listeners...");
          await _permissionSyncService.startAllEmployeeListeners();

          print("   ✅ Permission sync service started");
        } else {
          print("   ⚠️ Cannot start permission sync - no company ID");
        }

        print("   ✅ All listeners setup complete");

        print("\n🟢 Step 13: Initializing messaging...");
        MessagingInterfaceImplementation()
            .useGroupAndSingleMessaging(context, employee!);

        hideLoadingIndicator();

        // ✅ ═══════════════════════════════════════════════════════════════
        // ✅ CRITICAL FIX: Proper navigation based on ACTUAL screen width
        // ✅ ═══════════════════════════════════════════════════════════════
        print("\n🟢 Step 14: Navigating to main screen...");

        // ✅ Get ACTUAL screen width (not shortest side)
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // ✅ CORRECT BREAKPOINT: Use width, not shortest side
        // Mobile: width < 768
        // Tablet/Desktop: width >= 768
        const double MOBILE_BREAKPOINT = 768.0;
        final bool isMobileSize = screenWidth < MOBILE_BREAKPOINT;

        print("📱 [NAV] Screen dimensions: ${screenWidth}x${screenHeight}");
        print("📱 [NAV] Screen width: $screenWidth");
        print("📱 [NAV] Mobile breakpoint: $MOBILE_BREAKPOINT");
        print("📱 [NAV] Is mobile size: $isMobileSize");
        print("📱 [NAV] Will navigate to: ${isMobileSize ? 'NavScreen (mobile)' : 'CustomDrawer (desktop/tablet)'}");

        // ✅ Clean up wrong controller BEFORE navigation
        if (isMobileSize) {
          // Mobile - remove drawer controller if it exists
          if (Get.isRegistered<AppDrawerController>()) {
            await Get.delete<AppDrawerController>(force: true);
            print("🗑️ [NAV] Removed AppDrawerController (mobile mode)");
          }
        } else {
          // Desktop/Tablet - remove navbar controller if it exists
          if (Get.isRegistered<NavBarController>()) {
            await Get.delete<NavBarController>(force: true);
            print("🗑️ [NAV] Removed NavBarController (desktop mode)");
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

        print("✅ [NAV] Navigation complete to MainResponsiveScreen (handles resize)");

        print("✅ [NAV] Navigation complete to ${isMobileSize ? 'mobile' : 'desktop/tablet'} layout");
        // ✅ ═══════════════════════════════════════════════════════════════

        print("\n🟢 Step 15: Updating last login...");
        employee!.lastLogin = DateTime.now().toString();

        await addEmployeeController.createEmployee(
            employee!, employee!.email.last);

        systemLogsController.systemLogsAction(SystemActions.updateEmployee);

        passcontroller = TextEditingController();
        emailcontroller = TextEditingController();

        print("\n🟢 ══════════════════════════════════════════════════════════");
        print("🟢 initData() COMPLETE");
        print("🟢 ══════════════════════════════════════════════════════════");
      } catch (e, stackTrace) {
        print("\n🔴 ══════════════════════════════════════════════════════════");
        print("🔴 ERROR IN initData()");
        print("🔴 Error: $e");
        print("🔴 Stack trace:");
        print(stackTrace);
        print("🔴 ══════════════════════════════════════════════════════════");
        hideLoadingIndicator();
        rethrow;
      }

      Get.find<MainCoreDepartmentController>().getAllDepartments();
      // configurationDependencies(); // form_builder
      // Register todo + role controllers needed by home/roles screens

      if (!Get.isRegistered<EmployeeRoleController>()) {
        Get.put(EmployeeRoleController());
      }

      NotificationControllerCubit().sendNotification(
        title: 'new title',
        body: 'new body',
        emails: [
          "yousef_saeed_1807@bayanatz.com",
          "ibrahim_saeed_1702@bayanatz.com",
        ],
        arabicBody: 'العربية',
        arabicTitle: 'العربية',
        type: 'type',
      );
    }

    // ✅ NEW: Setup listener AND wait for initial sync to complete
    // ✅ UPDATED: Setup listener AND wait for initial sync to complete
    Future<void> _setupCompanyModulesAndSync() async {
      print("\n🟢 ════════════════════════════════════════════════════════");
      print("🟢 _setupCompanyModulesAndSync() START");
      print("🟢 ════════════════════════════════════════════════════════");

      if (_companyId == null || _companyId!.isEmpty) {
        print("🔴 ERROR: Company ID is null or empty!");
        print("🔴 Cannot setup Company Modules");
        return;
      }

      print("🟢 Company ID: '$_companyId'");
      print("🟢 Step 1: Performing initial sync...");

      try {
        // ✅ STEP 1: Get company document ONCE for initial sync
        DocumentSnapshot companyDoc = await db

            .collection(getBaseUrl('Companys'))
            .doc(_companyId)
            .get();

        print("🟢 Company document fetched");
        print("🟢 Document exists: ${companyDoc.exists}");

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

              print("🟢 Company has ${companyModules.length} modules: $companyModules");
              print("🟢 Performing initial sync with Master Admin...");

              // ✅ CRITICAL: Sync BEFORE UI loads
              await _syncMasterAdminWithCompanyModules(companyModules);

              print("✅ Initial sync complete!");

              // ✅ CRITICAL FIX: Refresh roles_module from Firestore to load updated data
              print("🟢 Step 1.5: Refreshing roles_module after sync...");
              await getRoles();
              print("✅ Roles refreshed with updated modules!");

              print("✅ Master Admin now has correct modules");
            } else {
              print("⚠️ No modules array found in company document");
            }
          } else {
            print("⚠️ No modules field in company document");
          }
        } else {
          print("⚠️ Company document does not exist");
        }

        // ✅ STEP 2: Setup real-time listener for future changes
        print("\n🟢 Step 2: Setting up real-time listener...");
        _listenToCompanyModules();
        print("✅ Real-time listener setup complete");

      } catch (e, stackTrace) {
        print("🔴 ════════════════════════════════════════════════════════");
        print("🔴 Exception in _setupCompanyModulesAndSync: $e");
        print("🔴 Stack trace: $stackTrace");
        print("🔴 ════════════════════════════════════════════════════════");
      }

      print("\n🟢 ════════════════════════════════════════════════════════");
      print("🟢 _setupCompanyModulesAndSync() COMPLETE");
      print("🟢 ════════════════════════════════════════════════════════");
    }


    Position? _currentPosition;
    Position? get currentPosition => _currentPosition;

    void _getCurrentLocation() async {
      print("📍 _getCurrentLocation() called");

      bool serviceEnabled;
      LocationPermission permission;
      if (Platform.isMacOS) {
        print("⚠️ Skipping location on macOS platform");
        return;
      }
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("⚠️ Location services are disabled");
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("⚠️ Location permissions denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("⚠️ Location permissions permanently denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _currentPosition = position;
      update();

      print("📍 Location acquired: ${position.latitude}, ${position.longitude}");
    }
  }