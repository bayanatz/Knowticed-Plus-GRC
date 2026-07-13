/// **************************** FILE INFO ****************************
/// File: update_account_status_use_case.dart
/// Purpose: use case to update account status in the database.
/// Author: Mohamed Elrashidy
/// Date: 27/1/2025
import 'package:dartz/dartz.dart';
import 'package:demo_app/features/notification/presentation/controller/app_notification_controller.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/network/failure_model.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/controllers/notification_controller.dart';
import 'package:demo_app/features/roles/account_status/data/repository/account_status_repository.dart';
import 'package:demo_app/features/roles/account_status/domain/entity/account_status_access_entity.dart';
import 'package:demo_app/features/onboarding/authentication/domain/enums/employee_status_enum.dart';

class UpdateAccountStatusUseCase {
  AccountStatusRepository repository;

  UpdateAccountStatusUseCase(this.repository);

  /// Method Name: [execute]
  ///
  /// Purpose: update account status in the database.
  ///
  /// Parameters: [AccountStatusAccessEntity] accountStatusAccessEntity
  ///             [EmployeeStatusEnum] status
  execute(AccountStatusAccessEntity accountStatusAccessEntity) async {
    EmployeeStatusEnum newStatus = _getNewStatus(accountStatusAccessEntity);
    Either<Failure, dynamic> result = await repository.updateAccountStatus(
        accountStatusAccessEntity, newStatus);
    _sendNotification(accountStatusAccessEntity);

    return result;
  }

  /// Method Name: [_getNewStatus]
  ///
  /// Purpose: get the new status of the account.
  ///
  /// Parameters: [AccountStatusAccessEntity] accountStatusAccessEntity
  ///
  /// return: [EmployeeStatusEnum] - new status of the account.
  EmployeeStatusEnum _getNewStatus(
      AccountStatusAccessEntity accountStatusAccessEntity) {
    if (accountStatusAccessEntity.isLocked ||
        accountStatusAccessEntity.isLockedWithRequest) {
      return EmployeeStatusEnum.active;
    }
    if (accountStatusAccessEntity.isActive ||
        accountStatusAccessEntity.isInactive) {
      return EmployeeStatusEnum.deactivated;
    }
    if (accountStatusAccessEntity.isDeactivated) {
      return EmployeeStatusEnum.active;
    }

    return EmployeeStatusEnum.active;
  }

  /// Method Name: [_sendNotification]
  ///
  /// Purpose: send notification to the employee according to the new status.
  ///
  /// Parameters: [AccountStatusAccessEntity] accountStatusAccessEntity
  _sendNotification(AccountStatusAccessEntity accountStatusAccessEntity) {
    AppNotificationController appNotificationController =
        Get.find<AppNotificationController>();
    if (accountStatusAccessEntity.isLocked) {
      appNotificationController.sendNotification(
        type: 'employee',
        topic: accountStatusAccessEntity.email,
        title: 'Account Activated',
        arabicTitle: 'تم تفعيل حسابك',
        body: 'Your account is now activated. You can login now.',
        arabicBody: 'تم تفعيل حسابك الان . يمكنك تسجيل الدخول',
      );
    }
    if (accountStatusAccessEntity.isActive ||
        accountStatusAccessEntity.isInactive) {
      appNotificationController.sendNotification(
        type: 'employee',
        topic: accountStatusAccessEntity.email,
        title: 'Account Deactivated',
        arabicTitle: 'تم ايقاف حسابك',
        body: 'Your account is now deactivated. You can no longer login.',
        arabicBody: 'تم ايقاف حسابك الان . لا يمكنك تسجيل الدخول',
      );
    }
    if (accountStatusAccessEntity.isDeactivated) {
      appNotificationController.sendNotification(
        type: 'employee',
        topic: accountStatusAccessEntity.email,
        title: 'Account Reactivated',
        arabicTitle: 'تم اعادة تفعيل حسابك',
        body: 'Your account is now reactivated. You can now login.',
        arabicBody: 'تم اعادة تفعيل حسابك الان . يمكنك تسجيل الدخول',
      );
    }
  }
}
