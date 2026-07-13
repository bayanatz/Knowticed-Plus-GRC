///********************* FILE INFO ***********************///
/// Purpose: This file contains the HealthInsuranceFields in health insurance settings page.
/// Author: Mohamed Elrashidy
/// Refactored at: 12/11/2023
/// Updated: Added 2nd Emergency Contact section

import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import '../../../../employee/data/models/emplyees_model/new_employee_model.dart';
import '../../../../employee/presentation/controller/main_core_employee_controller.dart';

import '../../controller/settings_controller.dart';
import 'emergency_contact_information_section.dart';
import 'health_insurance_section.dart';

class HealthInsuranceFields extends StatefulWidget {
  HealthInsuranceFields({super.key});

  @override
  State<HealthInsuranceFields> createState() => _HealthInsuranceFieldsState();
}

class _HealthInsuranceFieldsState extends State<HealthInsuranceFields> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    var isMobile = context.isPhone;
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