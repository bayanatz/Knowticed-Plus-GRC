///*********************** FILE INFO ********************///
/// FILE NAME: system_logs_constants.dart
/// Purpose: to have all the constants related to the system logs
/// Author: Amr Mesbah
/// Created at: 29/1/2025

import 'package:get/get.dart';
import 'package:grc_module/features/roles/r5_system_logs/domain/system_logs_items.dart';
import 'package:grc_module/generated/l10n.dart';

abstract class SystemLogsConstants {
  static const List<SystemLogsItems> systemLogsItems = [
    SystemLogsItems.firstName,
    SystemLogsItems.middleName,
    SystemLogsItems.lastName,
    SystemLogsItems.role,
    SystemLogsItems.country,
    SystemLogsItems.city,
    SystemLogsItems.date,
    SystemLogsItems.time,
    SystemLogsItems.lat,
    SystemLogsItems.long,
    SystemLogsItems.module,

    SystemLogsItems.action,
  ];

  static List<String> get sortList => [
        "First Name",
        "Last Name",
        "Date",
        "Country",
        "City",
      ];
  static List<String> get sortListInArabic => [
        S.current.firstName,
        S.current.lastName,
        S.current.date,
        S.current.country,
        S.current.city,
      ];
}
