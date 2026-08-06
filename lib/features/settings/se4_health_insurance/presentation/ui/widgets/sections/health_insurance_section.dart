///************************** FILE INFO ************************///
/// Purpose: This file contains the HealthInsuranceSection in health insurance settings page.
/// Author: Amr Mesbah
/// Created At: 12/11/2023
/// Updated At: 31/10/2025
/// Updated By: Claude AI Assistant
/// Changes: Updated to fetch data from NewEmployeeModelHistory model

import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';


import 'package:grc_module/core/custom/59-custom_intl_phone_field.dart';
// REMOVED: import '../../../../authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:grc_module/generated/l10n.dart';


import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/settings_header.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class HealthInsuranceSection extends StatelessWidget {
  HealthInsuranceSection({super.key});

  // Controllers
  final MainCoreEmployeeController employeeController = Get.find<MainCoreEmployeeController>();
  final SettingsController settingsController = Get.find();

  // Create controllers for each field
  final TextEditingController insuranceNameController = TextEditingController();
  final TextEditingController policyNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    // Get current employee's history data
    String currentUserEmail = Get.find<EmployeeController>().employee!.email?.last ?? '';

    // Find the current employee from the history model
    NewEmployeeModelHistory? currentEmployeeHistory = employeeController.allNewEmployees?.firstWhereOrNull(
            (emp) => emp.email.isNotEmpty && emp.email.last == currentUserEmail
    );

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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return isMobile
        ? Padding(
      padding: EdgeInsets.only(right: 15.sp,left: 15.sp,top: 15.sp),
          child: Column(
                children: [

          Padding(
            padding: EdgeInsets.only(bottom: 0.02.h, top: 0.h),
            child: SettingsHeader(
                imagePath: 'assets/icons_assets/main_icons_assets/insurance_document_shield.svg',
                text: S.of(context).healthInsurance),
          ),


          // Insurance Name Field
          CustomTextField(
            label: S.of(context).insuranceName,
            hint: '-',
            controller: insuranceNameController,
            enabled: false,
            textDirection: TextDirection.ltr,
            maxLength: 100,
          ),
                 isMobile ? SizedBox(height: 0,) : SizedBox(height: 10.h),
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
          padding: EdgeInsets.only(bottom: 0.02.h, top: 0.01.h),
          child: SettingsHeader(
              imagePath: 'assets/icons_assets/main_icons_assets/insurance_document_shield.svg',
              text: S.of(context).healthInsurance),
        ),
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
                maxLength: 100,
              ),
            ),
            SizedBox(width: 15.h),
            // Policy Number Field
            Expanded(
              child: CustomTextField(
                label: S.of(context).insurancePolicyNumber,
                hint: "-",
                controller: policyNumberController,
                enabled: false,
                textDirection: TextDirection.ltr,
                maxLength: 100,
              ),
            ),
          ],
        ),
      ],
    );
  }
}