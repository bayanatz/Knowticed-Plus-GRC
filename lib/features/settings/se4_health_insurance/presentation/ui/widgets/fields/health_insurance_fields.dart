///********************* FILE INFO ***********************///
/// Purpose: This file contains the HealthInsuranceFields in health insurance settings page.
/// Author: Amr Mesbah
/// Refactored at: 12/11/2023
/// Updated: Added 2nd Emergency Contact section

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';


import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:grc_module/features/settings/se5_emergency_contact/presentation/ui/widgets/sections/emergency_contact_information_section.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/ui/widgets/sections/health_insurance_section.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class HealthInsuranceFields extends StatefulWidget {
  HealthInsuranceFields({super.key});

  @override
  State<HealthInsuranceFields> createState() => _HealthInsuranceFieldsState();
}

class _HealthInsuranceFieldsState extends State<HealthInsuranceFields> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // 🔍 Check if second contact has data
    final MainCoreEmployeeController employeeController = Get.find<MainCoreEmployeeController>();
    String currentUserEmail = Get.find<EmployeeController>().employee!.email?.last ?? '';

    NewEmployeeModelHistory? currentEmployeeHistory = employeeController.allNewEmployees?.firstWhereOrNull(
            (emp) => emp.email.isNotEmpty && emp.email.last == currentUserEmail
    );

    bool hasSecondContact = false;
    if (currentEmployeeHistory != null) {
      hasSecondContact = currentEmployeeHistory.secondContactFirstName.any((name) => name.isNotEmpty) ||
          currentEmployeeHistory.secondContactEmail.any((email) => email.isNotEmpty) ||
          currentEmployeeHistory.secondContactPhone.any((phone) => phone.isNotEmpty);
    }

    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (_) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Insurance Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.card
              ),
              child: isMobile ? HealthInsuranceSection() : Padding(
                padding: EdgeInsets.only(top: 15.sp, right: 15.sp, left: 15.sp),
                child: HealthInsuranceSection(),
              ),
            ),

            isMobile ? SizedBox(height: 15.sp) : SizedBox(height: 0),

            // 1st Emergency Contact Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.card
              ),
              child: EmergencyContactInformationSection(
                isFirstContact: true,
              ),
            ),
            isMobile ? SizedBox(height: 20.sp) : SizedBox(),

            // 2nd Emergency Contact Section - Only show if data exists
            if (hasSecondContact) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.card
                ),
                child: EmergencyContactInformationSection(
                  isFirstContact: false,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}