///***************************** FILE INFO ****************************
/// File: schedule_deactivation_time_use_case.dart
/// Purpose: use case to schedule deactivation time for the account.
/// Author: Mohamed Elrashidy
/// Date: 27/1/2025

import 'package:dartz/dartz.dart';
import 'package:demo_app/features/notification/presentation/controller/app_notification_controller.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/controllers/notification_controller.dart';

import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/roles/account_status/data/repository/account_status_repository.dart';
import 'package:demo_app/features/roles/account_status/domain/entity/account_status_access_entity.dart';

class ScheduleDeactivationTimeUseCase {
  AccountStatusRepository repository;

  ScheduleDeactivationTimeUseCase(this.repository);

  execute(AccountStatusAccessEntity accountStatusAccessEntity,
      String deactivationTime) async {
    Either<Failure, dynamic> result = await repository.scheduleDeactivationTime(
        accountStatusAccessEntity, deactivationTime);
    if (result.isRight()) {
      try{
      Get.find<AppNotificationController>().sendNotification(
        type: 'employee',
        topic: accountStatusAccessEntity.email,
        title: 'Deactivated Account',
        arabicTitle: 'تم ايقاف حسابك',
        body: 'Your account will be deactivated at $deactivationTime.',
        arabicBody:
            'سيتم الغاء تنشيط حسابك في ${dateforamtToArabic(deactivationTime)}.',
      );}
          catch(e){}
    }
    return result;
  }
}
