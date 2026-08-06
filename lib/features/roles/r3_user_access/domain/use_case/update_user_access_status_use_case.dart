/// **************************** FILE INFO ****************************
/// File: update_account_status_use_case.dart
/// Purpose: use case to update account status in the database.
/// Author: Amr Mesbah
/// Date: 27/1/2025
import 'package:dartz/dartz.dart';
import 'package:grc_module/features/notification/presentation/controller/app_notification_cubit.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/network/failure_model.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/controllers/notification_controller.dart';
import 'package:grc_module/features/roles/r3_user_access/data/repository/user_access_repository.dart';
import 'package:grc_module/features/roles/r3_user_access/domain/entity/user_access_entity.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';

class UpdateUserAccessStatusUseCase {
  UserAccessRepository repository;

  UpdateUserAccessStatusUseCase(this.repository);

  /// Method Name: [execute]
  ///
  /// Purpose: update account status in the database.
  ///
  /// Parameters: [UserAccessEntity] accountStatusAccessEntity
  ///             [EmployeeStatusEnum] status
  execute(UserAccessEntity accountStatusAccessEntity) async {
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
  /// Parameters: [UserAccessEntity] accountStatusAccessEntity
  ///
  /// return: [EmployeeStatusEnum] - new status of the account.
  EmployeeStatusEnum _getNewStatus(
      UserAccessEntity accountStatusAccessEntity) {
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
  /// Parameters: [UserAccessEntity] accountStatusAccessEntity
  _sendNotification(UserAccessEntity accountStatusAccessEntity) {
    AppNotificationCubit appNotificationController =
        Get.find<AppNotificationCubit>();
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
