import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';

import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/generated/l10n.dart';

class AppBarGreetings extends StatelessWidget {
  AppBarGreetings({super.key});
  String name = Get.locale.toString().contains('en')
      ? Get.find<MainCoreEmployeeController>().employeeEntity!.firstName!
      : Get.find<MainCoreEmployeeController>()
          .employeeEntity!
          .firstNameInArabic!;
  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Text(
        "${DateTime.now().hour < 12 ? S.of(context).goodMorning : DateTime.now().hour < 14 ? S.of(context).goodAfternoon : S.of(context).goodEvening} ${FormatHelper.capitalize(name)}",
        style: StyleText.fontSize18Weight500.copyWith(
          fontWeight: FontWeight.w700,
         color: AppColors.text
        )
    )
    ;
  }
}
