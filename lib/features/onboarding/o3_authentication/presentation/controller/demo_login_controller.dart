/// ************************* FILE INFO ************************* ///
/// File Name: demo_login_controller.dart
/// Purpose: Contains the controller for demo login feature.
/// Author: Amr Mesbah
/// Created At: 4/1/2025
/// Updated: 23/12/2025 - Added comprehensive notification system
/// ✅ UPDATED: Added moduleUserLimitReached handler
/// ✅ FIXED: Removed duplicate success handling - login_controller handles navigation

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/constants.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';


import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/core/custom/64_custom_response_dialog.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/features/notification/data/repository/account_status_notification_service.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/repository/demo_login_repository.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/failure_authentication_type.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
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
              title: S.of(context).authenticationError,
              subtitle: errorMessage.isNotEmpty
                  ? errorMessage
                  : S.of(context).anErrorOccurredDuringLoginPleaseTryAgain,
              lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
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
            title: FailureAuthenticationType.emailNotFound.dialogBoxTitle,
            subtitle: FailureAuthenticationType.emailNotFound.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
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
              title: FailureAuthenticationType.wrongPassword.dialogBoxTitle,
              subtitle: "${FailureAuthenticationType.wrongPassword.dialogBoxMessage}\n\n",
              lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
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
            title: FailureAuthenticationType.wrongActivationPassword.dialogBoxTitle,
            subtitle: FailureAuthenticationType.wrongActivationPassword.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  handleNotFoundInCompanyDatabase() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.notFoundInCompanyDatabase.dialogBoxTitle,
            subtitle: FailureAuthenticationType.notFoundInCompanyDatabase.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  handleDemoCancelled() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.demoCancelled.dialogBoxTitle,
            subtitle: FailureAuthenticationType.demoCancelled.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  handleBeforeActivationDate() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.beforActivationDate.dialogBoxTitle,
            subtitle: FailureAuthenticationType.beforActivationDate.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/newAttension.json",
          );
        });
  }

  handleSubscriptionExpired() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.subscriptionExpired.dialogBoxTitle,
            subtitle: FailureAuthenticationType.subscriptionExpired.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  handleNoPermission() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.dontHavePermission.dialogBoxTitle,
            subtitle: FailureAuthenticationType.dontHavePermission.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          );
        });
  }

  handleTooManyUsers() async {
    await showDialog(
        context: Get.context!,
        barrierDismissible: true,
        builder: (context) {
          return ResponseDialog(
            title: FailureAuthenticationType.tooManyUsers.dialogBoxTitle,
            subtitle: FailureAuthenticationType.tooManyUsers.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/newAttension.json",
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
            title: FailureAuthenticationType.moduleUserLimitReached.dialogBoxTitle,
            subtitle: FailureAuthenticationType.moduleUserLimitReached.dialogBoxMessage,
            lottieAsset: "assets/lottie_assets/main_lottie_assets/newAttension.json",
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
              title: failureType.dialogBoxTitle,
              subtitle: failureType.dialogBoxMessage,
              lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
            );
          });
    } catch (e) {
      await showDialog(
          context: Get.context!,
          barrierDismissible: true,
          builder: (context) {
            return ResponseDialog(
              title: S.of(context).authenticationFailed,
              subtitle: errorMessage.isNotEmpty
                  ? errorMessage
                  : S.of(context).invalidCredentialsPleaseVerifyAndTryAgain,
              lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
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
                title: S.of(context).accountLocked,
                subtitle:
                'Your Account Has Been Locked Due To Multiple Unsuccessful Login Attempts. Please Contact The Administrator',
                lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
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
        systemLogsController.systemLogsAction("update employee");

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
                title: S.of(context).accountLocked,
                subtitle:
                'Your Account Has Been Locked Due To Multiple Unsuccessful Login Attempts. Please Contact The Administrator',
                lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
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