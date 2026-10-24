/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: health_insurance_section.dart
/// Purpose: Displays the employee's insurance provider and policy number.
/// Author: Amr Mesbah
/// Created at: 12/11/2024
/// Updated: 11/8/2026 - Added the standard header (Docs).
library;

///************************** FILE INFO ************************///
/// Purpose: This file contains the HealthInsuranceSection in health insurance settings page.
/// Author: Amr Mesbah
/// Created At: 12/11/2023
/// Updated At: 31/10/2025
/// Updated By: Claude AI Assistant
/// Changes: Updated to fetch data from NewEmployeeModelHistory model

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_controller.dart';

// REMOVED: import '../../../../authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class HealthInsuranceSection extends StatelessWidget {
  HealthInsuranceSection({super.key});

  // Controllers
  final MainCoreEmployeeController employeeController =
      Get.find<MainCoreEmployeeController>();
  final SettingsController settingsController = Get.find();

  // Create controllers for each field
  final TextEditingController insuranceNameController = TextEditingController();
  final TextEditingController policyNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    MediaQuery.of(context).orientation == Orientation.portrait;
    !kpIsPhoneLayout(context);

    // Get current employee's history data
    // CHANGED 9/10/2026 — was `employee!.email?.last`, which throws while the
    // settings employee is still loading (the section is reachable again from
    // the menu, so it can now build before that load lands). Same null-safe
    // read HealthInsuranceFields already uses.
    String currentUserEmail =
        Get.find<EmployeeController>().employee?.email.lastOrNull ?? '';

    // Find the current employee from the history model
    NewEmployeeModelHistory? currentEmployeeHistory =
        employeeController.allNewEmployees?.firstWhereOrNull((emp) =>
            emp.email.isNotEmpty && emp.email.last == currentUserEmail);

    // Get the latest values (last item in the list)
    String insuranceName = '';
    String policyNumber = '';

    if (currentEmployeeHistory != null) {
      // Get last value from history lists
      if (currentEmployeeHistory.insuranceName.isNotEmpty) {
        insuranceName = currentEmployeeHistory.insuranceName.last;
      }
      if (currentEmployeeHistory.insurancePolicyNumber.isNotEmpty) {
        policyNumber = currentEmployeeHistory.insurancePolicyNumber.last;
      }
    }

    // Initialize controllers with values
    insuranceNameController.text = FormatHelper.capitalize(insuranceName);
    policyNumberController.text = policyNumber;
    Localizations.localeOf(context).languageCode == 'ar';

    return isMobile
        ? Padding(
            padding: EdgeInsets.only(
                right: 16.sp,
                left: 16.sp,
                top: 16.sp,
                // D-223: the next group's top inset is the gap.
                bottom: 0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 12.sp, top: 0),
                  child: SettingsHeader(
                      // 0: the Padding wrapping this card already applies 16.sp on
                      // each side. SettingsHeader's own 16.sp stacked on top of it,
                      // putting the icon 30.sp in while the fields sat at 16.sp.
                      horizontalPadding: 0,
                      imagePath:
                          'assets/icons_assets/main_icons_assets/ic_hr_insurance_document.svg',
                      text: S.of(context).healthInsurance),
                ),

                // Insurance Name Field
                CustomTextField(
                  label: S.of(context).insuranceName,
                  hint: '-',
                  // `showCharCount: false` does NOT hide the counter — CustomTextField
                  // shows it whenever `showCharCount` is true OR `maxLength` is set,
                  // and this field sets maxLength. `hideCounter` is the flag that
                  // suppresses the counter while keeping the cap.
                  showCharCount: false,
                  hideCounter: true,
                  controller: insuranceNameController,
                  enabled: false,
                  textDirection: TextDirection.ltr,
                  maxLength: 100,
                ),
                // Mobile only: 10.sp between fields.
                SizedBox(height: 12.sp),
                // Policy Number Field
                CustomTextField(
                  label: S.of(context).insurancePolicyNumber,
                  hint: "-",
                  controller: policyNumberController,
                  enabled: false,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          )
        : Column(
            children: [
              Padding(
                // Item 171 (21/10/2026): no extra top — the box's 16 is the
                // inset on every side (diagonal cut); title → first label 12.
                padding: EdgeInsets.only(bottom: 12.sp, top: 0),
                child: SettingsHeader(
                    imagePath:
                        'assets/icons_assets/main_icons_assets/ic_hr_insurance_document.svg',
                    text: S.of(context).healthInsurance),
              ),
              // D-205 (20/10/2026): iPad PORTRAIT stacks the two fields (one per
              // row); landscape keeps them side by side.
              if (MediaQuery.of(context).orientation == Orientation.portrait)
                Column(
                  children: [
                    CustomTextField(
                      label: S.of(context).insuranceName,
                      hint: "-",
                      controller: insuranceNameController,
                      enabled: false,
                      textDirection: TextDirection.ltr,
                    ),
                    SizedBox(height: 12.sp),
                    CustomTextField(
                      label: S.of(context).insurancePolicyNumber,
                      hint: "-",
                      controller: policyNumberController,
                      enabled: false,
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    // Insurance Name Field
                    Expanded(
                      child: CustomTextField(
                        label: S.of(context).insuranceName,
                        hint: "-",
                        controller: insuranceNameController,
                        enabled: false,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    SizedBox(width: 16.w), // R-1 (was 16.h)
                    // Policy Number Field
                    Expanded(
                      child: CustomTextField(
                        label: S.of(context).insurancePolicyNumber,
                        hint: "-",
                        controller: policyNumberController,
                        enabled: false,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
            ],
          );
  }
}
