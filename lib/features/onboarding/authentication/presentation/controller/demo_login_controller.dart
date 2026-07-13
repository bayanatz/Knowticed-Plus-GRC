/// ************************* FILE INFO ************************* ///
/// File Name: demo_login_controller.dart
/// Purpose: Contains the controller for demo login feature.
/// Author: Mohamed Elrashidy
/// Created At: 4/1/2025
/// Updated: 23/12/2025 - Added comprehensive notification system
/// ✅ UPDATED: Added moduleUserLimitReached handler
/// ✅ FIXED: Removed duplicate success handling - login_controller handles navigation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/onboarding/authentication/utils/constants.dart';


import '../../../../../core/constants/system_actions.dart';
import '../../../../../core/network/failure_model.dart';
import 'package:demo_app/features/onboarding/core_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/core/custom/loading.dart';
import '../../../../employee/data/models/emplyees_model/new_employee_model.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_notification_service.dart';
import '../../data/repository/demo_login_repository.dart';
import '../../domain/enums/employee_status_enum.dart';
import '../../domain/enums/failure_authentication_type.dart';
import 'package:demo_app/features/roles/system_logs/controller/system_logs_controller.dart';

class DemoLoginController {
  final DemoLoginRepository demoLoginRepository = DemoLoginRepository();
  int wrongPasswordCount = 0;
  SystemLogsController systemLogsController = Get.find<SystemLogsController>();

  loginWithEmailAndPassword({
    required String email,
    required String password
  }) async {
    Either<Failure, dynamic> result = await demoLoginRepository
        .loginWithEmailAndPassword(email: email, password: password);

    if (result.isLeft()) {
      String errorMessage = result.fold((l) => l.errMessage, (r) => "");
      await handleAuthenticationErrorMessage(
          errorMessage: errorMessage,
          email: email);
    }
    return result;
  }

  // ✅ UPDATED: Added moduleUserLimitReached case
  handleAuthenticationErrorMessage({
    required String errorMessage,
    required String email
  }) async {
    hideLoadingIndicator();
    await Future.delayed(const Duration(milliseconds: 300));

    FailureAuthenticationType? failureType;

    try {
      failureType = FailureAuthenticationType.values
          .firstWhere((element) => element.dialogBoxMessage == errorMessage);
    } catch (e) {
      await showDialog(
          context: Get.context!,
          barrierDismissible: true,
          builder: (context) {
            return ResponseDialog(
              title: "Authentication Error".tr,
              subtitle: errorMessage.isNotEmpty
                  ? errorMessage
                  : "An error occurred during login. Please try again.".tr,
              lottieAsset: "assets/images/error.json",
            );
          });
      return;
    }

    switch (failureType) {
      case FailureAuthenticationType.emailNotFound:
        await handleEmailNotFound();
        break;
      case FailureAuthenticationType.wrongPassword:
        await handleFailureWrongPassword(email);
        break;
      case FailureAuthenticationType.wrongActivationPassword:
        await handleWrongActivationPassword();
        break;
      case FailureAuthenticationType.notFoundInCompanyDatabase:
        await handleNotFoundInCompanyDatabase();
        break;
      case FailureAuthenticationType.demoCancelled:
        await handleDemoCancelled();
        break;
      case FailureAuthenticationType.beforActivationDate:
        await handleBeforeActivationDate();
        break;
      case FailureAuthenticationType.subscriptionExpired:
        await handleSubscriptionExpired();
        break;
      case FailureAuthenticationType.dontHavePermission:
        await handleNoPermission();
        break;
      case FailureAuthenticationType.tooManyUsers:
        await handleTooManyUsers();
        break;
      case FailureAuthenticationType.moduleUserLimitReached: // ✅ NEW
        await handleModuleUserLimitReached();
        break;
      default:
        await handleDefaultFailure(errorMessage);
    }
  }

  handleEmailNotFound() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.emailNotFound.dialogBoxTitle.tr,
            subtitle: FailureAuthenticationType.emailNotFound.dialogBoxMessage.tr,
            lottieAsset: "assets/images/error.json",
          );
        });
  }

  handleFailureWrongPassword(String email) async {
    wrongPasswordCount++;

    if (wrongPasswordCount >= 3) {
      await lockAccount(email: email);
    } else {
      await showDialog(
          context: Get.context!,
          barrierDismissible: true,
          builder: (context) {
            return ResponseDialog(
              title: FailureAuthenticationType.wrongPassword.dialogBoxTitle.tr,
              subtitle: "${FailureAuthenticationType.wrongPassword.dialogBoxMessage}\n\n",
              lottieAsset: "assets/images/error.json",
            );
          });
    }
  }

  handleWrongActivationPassword() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.wrongActivationPassword.dialogBoxTitle.tr,
            subtitle: FailureAuthenticationType.wrongActivationPassword.dialogBoxMessage.tr,
            lottieAsset: "assets/images/error.json",
          );
        });
  }

  handleNotFoundInCompanyDatabase() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.notFoundInCompanyDatabase.dialogBoxTitle.tr,
            subtitle: FailureAuthenticationType.notFoundInCompanyDatabase.dialogBoxMessage.tr,
            lottieAsset: "assets/images/error.json",
          );
        });
  }

  handleDemoCancelled() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.demoCancelled.dialogBoxTitle.tr,
            subtitle: FailureAuthenticationType.demoCancelled.dialogBoxMessage.tr,
            lottieAsset: "assets/images/error.json",
          );
        });
  }

  handleBeforeActivationDate() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.beforActivationDate.dialogBoxTitle.tr,
            subtitle: FailureAuthenticationType.beforActivationDate.dialogBoxMessage.tr,
            lottieAsset: "assets/images/newAttension.json",
          );
        });
  }

  handleSubscriptionExpired() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.subscriptionExpired.dialogBoxTitle.tr,
            subtitle: FailureAuthenticationType.subscriptionExpired.dialogBoxMessage.tr,
            lottieAsset: "assets/images/error.json",
          );
        });
  }

  handleNoPermission() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.dontHavePermission.dialogBoxTitle.tr,
            subtitle: FailureAuthenticationType.dontHavePermission.dialogBoxMessage.tr,
            lottieAsset: "assets/images/error.json",
          );
        });
  }

  handleTooManyUsers() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.tooManyUsers.dialogBoxTitle.tr,
            subtitle: FailureAuthenticationType.tooManyUsers.dialogBoxMessage.tr,
            lottieAsset: "assets/images/newAttension.json",
          );
        });
  }

  // ✅ NEW: Handle module user limit reached error dialog
  handleModuleUserLimitReached() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.moduleUserLimitReached.dialogBoxTitle.tr,
            subtitle: FailureAuthenticationType.moduleUserLimitReached.dialogBoxMessage.tr,
            lottieAsset: "assets/images/newAttension.json",
          );
        });
  }

  handleDefaultFailure(String errorMessage) async {
    try {
      FailureAuthenticationType failureType = FailureAuthenticationType.values
          .firstWhere((element) => element.dialogBoxMessage == errorMessage);

      await showDialog(
          context: Get.context!,
          barrierDismissible: true,
          builder: (context) {
            return ResponseDialog(
              title: failureType.dialogBoxTitle.tr,
              subtitle: failureType.dialogBoxMessage.tr,
              lottieAsset: "assets/images/error.json",
            );
          });
    } catch (e) {
      await showDialog(
          context: Get.context!,
          barrierDismissible: true,
          builder: (context) {
            return ResponseDialog(
              title: "Authentication Failed".tr,
              subtitle: errorMessage.isNotEmpty
                  ? errorMessage
                  : "Invalid credentials. Please verify and try again.".tr,
              lottieAsset: "assets/images/error.json",
            );
          });
    }
  }

  lockAccount({required String email}) async {
    Either<Failure, dynamic> result =
    await demoLoginRepository.getEmployee(email: email);

    if (result.isRight()) {
      List<Map<String, dynamic>> employeeData = result.getOrElse(() => []);
      NewEmployeeModelHistory employee =
      NewEmployeeModelHistory.fromMap(employeeData.first);

      String currentStatus = employee.status.isNotEmpty
          ? employee.status.last
          : '';

      if (currentStatus == EmployeeStatusEnum.locked.name) {
        await showDialog(
            context: Get.context!,
            barrierDismissible: true,
            builder: (context) {
              return ResponseDialog(
                title: "Account Locked".tr,
                subtitle:
                'Your Account Has Been Locked Due To Multiple Unsuccessful Login Attempts. Please Contact The Administrator',
                lottieAsset: "assets/images/error.json",
              );
            });
        hideLoadingIndicator();
      } else {
        employee = employee.copyWithUpdateSynchronized(
          status: 'locked',
          addTimestamp: DateTime.now().millisecondsSinceEpoch,
        );

        EmployeeController employeeController = Get.find<EmployeeController>();
        await employeeController.createEmployee(employee, email);
        systemLogsController.systemLogsAction(SystemActions.updateEmployee);

        String userName = _getEmployeeFullName(employee);
        await AccountStatusNotificationService.sendAccountLockedNotification(
          userEmail: email,
          userName: userName,
        );

        await showDialog(
            context: Get.context!,
            barrierDismissible: true,
            builder: (context) {
              return ResponseDialog(
                title: "Account Locked".tr,
                subtitle:
                'Your Account Has Been Locked Due To Multiple Unsuccessful Login Attempts. Please Contact The Administrator',
                lottieAsset: "assets/images/error.json",
              );
            });

        hideLoadingIndicator();
      }
    }
  }

  String _getEmployeeFullName(NewEmployeeModelHistory employee) {
    List<String> nameParts = [];

    if (employee.firstName.isNotEmpty && employee.firstName.last.isNotEmpty) {
      nameParts.add(employee.firstName.last);
    }

    if (employee.middleName.isNotEmpty && employee.middleName.last.isNotEmpty) {
      nameParts.add(employee.middleName.last);
    }

    if (employee.lastName.isNotEmpty && employee.lastName.last.isNotEmpty) {
      nameParts.add(employee.lastName.last);
    }

    if (nameParts.isEmpty) {
      return 'Unknown User';
    }

    return nameParts.join(' ');
  }
}