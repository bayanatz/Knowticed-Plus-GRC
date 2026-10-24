/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: app_bar_greetings.dart
/// Purpose: Declares `AppBarGreetings`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AppBarGreetings extends StatelessWidget {
  const AppBarGreetings({super.key, this.style});

  /// Overrides the 18 / 500 default (Home Layout uses 20 / 600, D-217).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    // Resolved in build, not in a field initializer: the name depends on the
    // active locale, and a StatelessWidget field would freeze it at the value
    // captured when the widget was first constructed.
    final employee = Get.find<MainCoreEmployeeController>().employeeEntity;
    // Falls back to the other language's name when the active one is missing:
    // an account with no Arabic first name used to greet in Arabic with no
    // name at all ("مساء الخير" instead of "مساء الخير Bayanatz").
    final String? preferred =
        context.isEnglish ? employee?.firstName : employee?.firstNameInArabic;
    final String? other =
        context.isEnglish ? employee?.firstNameInArabic : employee?.firstName;
    final String name =
        (preferred?.trim().isNotEmpty ?? false) ? preferred! : (other ?? '');
    return Text(
        "${DateTime.now().hour < 12 ? S.of(context).goodMorning : DateTime.now().hour < 14 ? S.of(context).goodAfternoon : S.of(context).goodEvening} ${FormatHelper.capitalize(name)}",
        style: (style ?? StyleText.fontSize18Weight500)
            .copyWith(fontWeight: FontWeight.w700, color: AppColors.text));
  }
}
