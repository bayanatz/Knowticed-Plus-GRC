/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: login_controller_methods.dart
/// Description: Methods of `LoginController` — split out of `login_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../login_controller.dart';

// Split from login_controller.dart to keep every file under 700 lines.

extension LoginControllerMethods on LoginController {
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
              body: 'Your account is now deactivated. You can no longer login.',
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
                List<String> companyModules = List<String>.from(
                  modulesMap['modules'],
                );

                // ✅ Sync Master Admin with these modules
                await _syncMasterAdminWithCompanyModules(companyModules);

                await getRoles();
                update();
              } else {}
            } else {}
          } catch (e) {
            debugPrint('Ignored error: $e');
          }
        } else {}
      }, onError: (error, stackTrace) {});
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }

  // ✅ NEW: Sync Master Admin role with company's actual modules
  Future<void> _syncMasterAdminWithCompanyModules(
    List<String> companyModules,
  ) async {
    try {
      var rolesResult = await roleRepository.getUnDeletedRoles();

      if (rolesResult.isLeft()) {
        // Was a bare `return`. A transient Firestore error then looked
        // identical to "this tenant has no roles", and the Master-Admin
        // module sync below would run against an empty set — drifting or
        // erasing assignments (CR-SKEL-O3-N14). Recorded so the caller can
        // tell the difference.
        lastRoleSyncError = rolesResult.fold(
          (failure) => failure.errMessage,
          (_) => 'Could not load roles.',
        );
        return;
      }

      List<RoleHistoryModel> allRoles = rolesResult.getOrElse(() => []);

      // ✅ Find Master Admin role
      List<RoleHistoryModel> masterAdminRoles = allRoles.where((role) {
        bool isMasterAdmin =
            role.currentRoleName.toLowerCase() == 'master admin';
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

      if (missingModules.isNotEmpty) {}

      if (extraModules.isNotEmpty) {}

      if (needsUpdate) {
        WriteBatch batch = db.batch();

        // ✅ Update role's Selected_Modules field in Roles collection
        DocumentReference roleRef =
            db.collection(getBaseUrl('Roles')).doc(roleId);

        batch.update(roleRef, {'Selected_Modules': companyModules});

        await batch.commit();
      } else {}
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }


  // ✅ Helper method to map module name to collection name
}
