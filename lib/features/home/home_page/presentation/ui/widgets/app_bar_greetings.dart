import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';

import 'package:demo_app/core/theme/app_text_styles.dart';

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
        "${DateTime.now().hour < 12 ? 'Good Morning'.tr : DateTime.now().hour < 14 ? 'Good Afternoon'.tr : 'Good Evening'.tr} ${FormatHelper.capitalize(name)}",
        style: StyleText.fontSize18Weight500.copyWith(
          fontWeight: FontWeight.w700,
         color: AppColors.text
        )
    )
    ;
  }
}
