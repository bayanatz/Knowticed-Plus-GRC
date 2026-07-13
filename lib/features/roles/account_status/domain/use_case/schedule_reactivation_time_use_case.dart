import 'package:dartz/dartz.dart';
import 'package:demo_app/features/notification/presentation/controller/app_notification_controller.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/controllers/notification_controller.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/roles/account_status/data/repository/account_status_repository.dart';
import 'package:demo_app/features/roles/account_status/domain/entity/account_status_access_entity.dart';

class ScheduleReactivationTimeUseCase {
  AccountStatusRepository repository;
  ScheduleReactivationTimeUseCase(this.repository);

  execute(AccountStatusAccessEntity accountStatusAccessEntity,
      String reactivationTime) async {

    Either<Failure, dynamic> result = await repository.scheduleReactivationTime(
        accountStatusAccessEntity, reactivationTime);
    try{
    Get.find<AppNotificationController>().sendNotification(
      type: 'employee',
      topic: accountStatusAccessEntity.email,
      title: 'Reactivated Account',
      arabicTitle: ' إعادة تنشيط الحساب',
      body: 'Your account will be reactivated at $reactivationTime.',
      arabicBody:
          'سيتم اعادة تنشيط حسابك في ${dateforamtToArabic(reactivationTime)}.',
    );}
    catch(e){

    }
    return result;
  }
}
