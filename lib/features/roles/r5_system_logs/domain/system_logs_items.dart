import 'package:get/get.dart';
import 'package:grc_module/features/roles/r5_system_logs/data/models/system_logs_model.dart';

import 'package:grc_module/core/helper/main_helper/date_time_helper.dart';

///*********************** FILE INFO ********************///
/// FILE NAME: system_logs_items.dart
/// Purpose: to have all the items that will be shown in the system logs
/// Author: Amr Mesbah
/// Created at: 29/1/2025

enum SystemLogsItems {
  firstName,
  middleName,
  lastName,
  role,
  country,
  city,
  date,
  time,
  lat,
  long,
  module,
  action;

  String get name {
    switch (this) {
      case SystemLogsItems.firstName:
        return 'First Name';
      case SystemLogsItems.middleName:
        return 'Middle Name';
      case SystemLogsItems.lastName:
        return 'Last Name';
      case SystemLogsItems.role:
        return 'Role';
      case SystemLogsItems.country:
        return 'Country';
      case SystemLogsItems.city:
        return 'City';
      case SystemLogsItems.date:
        return 'Date';
      case SystemLogsItems.time:
        return 'Time';
      case SystemLogsItems.lat:
        return 'Lat';
      case SystemLogsItems.long:
        return 'Long';
      case SystemLogsItems.action:
        return 'Action';
      case SystemLogsItems.module:
        return 'Module';
    }
  }

  /// Method Name: [itemValue]
  ///
  /// Description: this method will return the value of the item based on the model.
  ///
  /// Parameters:
  ///            [SystemLogsModel] model: the model that will be used to get the value
  ///
  /// Returns: [String] the value of the item or empty string if the value is null
  String itemValue(SystemLogsModel model) {
    switch (this) {
      case SystemLogsItems.firstName:
        return Get.locale.toString().contains('en')
            ? model.firstName ?? ""
            : model.firstNameInArabic ?? "";
      case SystemLogsItems.middleName:
        return Get.locale.toString().contains('en')
            ? model.middleName ?? ""
            : model.middleNameInArabic ?? "";
      case SystemLogsItems.lastName:
        return Get.locale.toString().contains('en')
            ? model.lastName ?? ""
            : model.lastNameInArabic ?? "";
      case SystemLogsItems.role:
        return model.role ?? "";
      case SystemLogsItems.country:
        return model.country ?? "";
      case SystemLogsItems.city:
        return model.city ?? "";
      case SystemLogsItems.date:
        return DateTimeHelper.formatDateTimeMMMDDYYYY(
            model.timestamp!.toDate());

      case SystemLogsItems.time:
        return DateTimeHelper.formatDateTimeHHMM(model.timestamp!.toDate());
      case SystemLogsItems.lat:
        return model.lat ?? "";
      case SystemLogsItems.long:
        return model.long ?? "";
      case SystemLogsItems.action:
        return model.action ?? "";
      case SystemLogsItems.module:
        return model.module?.name ?? "";
      default:
        return "";
    }
    return "";
  }
}
