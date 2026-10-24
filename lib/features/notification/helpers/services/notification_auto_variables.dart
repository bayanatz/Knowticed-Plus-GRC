/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_auto_variables.dart
/// Purpose: The variables EVERY notification can use, filled by
///          AppNotificationSender itself — so an admin can write
///          "{{recipientName}}" into any template of any module without that
///          module's code having to pass it.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026 (Owner: "add all the variables that could be inside")
library;

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

abstract final class NotificationAutoVariables {
  /// Shown on the variable chips of every module, after the module's own.
  static const List<TemplateVariable> all = <TemplateVariable>[
    TemplateVariable.recipientName,
    TemplateVariable.senderName,
    TemplateVariable.moduleName,
    TemplateVariable.date,
    TemplateVariable.time,
  ];

  /// The values for one send. A value the calling module passes itself
  /// always wins over these (Time Tracker's `{{time}}`, GRC's
  /// `{{moduleName}}`), so no existing notification changes wording.
  static Map<String, String> build({
    required AppModule module,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
  }) {
    final DateTime now = DateTime.now();
    final String locale = isArabic ? 'ar' : 'en';
    final MainCoreEmployeeController? employees =
        Get.isRegistered<MainCoreEmployeeController>()
            ? Get.find<MainCoreEmployeeController>()
            : null;
    String name(String email) =>
        employees?.getEmployeeNameEnglishArabic(email, !isArabic).trim() ?? '';

    return <TemplateVariable, String>{
      TemplateVariable.recipientName: name(receiverEmail),
      TemplateVariable.senderName: name(senderEmail),
      TemplateVariable.moduleName: module.label(isArabic: isArabic),
      TemplateVariable.date: DateFormat('d/M/yyyy', locale).format(now),
      TemplateVariable.time: DateFormat('h:mm a', locale).format(now),
    }.toTemplateVariables();
  }
}
