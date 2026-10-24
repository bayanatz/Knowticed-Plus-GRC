/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: health_insurance_fields.dart
/// Purpose: Stacks the insurance and emergency-contact cards.
/// Author: Amr Mesbah
/// Created at: 12/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N16: the employee history is resolved once here and passed
///          down, instead of each contact section locating three controllers.
library;

///********************* FILE INFO ***********************///
/// Purpose: This file contains the HealthInsuranceFields in health insurance settings page.
/// Author: Amr Mesbah
/// Refactored at: 12/11/2023
/// Updated: Added 2nd Emergency Contact section

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/features/settings/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/settings/se5_emergency_contact/presentation/ui/widgets/sections/emergency_contact_information_section.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/ui/widgets/sections/health_insurance_section.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthInsuranceFields extends StatefulWidget {
  const HealthInsuranceFields({super.key});

  @override
  State<HealthInsuranceFields> createState() => _HealthInsuranceFieldsState();
}

class _HealthInsuranceFieldsState extends State<HealthInsuranceFields> {
  @override
  Widget build(BuildContext context) {
    !kpIsPhoneLayout(context);
    var isMobile = ContextExtension(context).isPhone;
    Theme.of(context).brightness == Brightness.light;

    // Resolved once here and passed down, rather than each contact section
    // locating three controllers of its own (CR-SKEL-SE4-N16, CR-SKEL-SE5-N14).
    // The `employee!` force-unwrap is gone with it.
    final MainCoreEmployeeController employeeController =
        Get.find<MainCoreEmployeeController>();
    final String currentUserEmail =
        Get.find<EmployeeController>().employee?.email.lastOrNull ?? '';

    final NewEmployeeModelHistory? currentEmployeeHistory =
        employeeController.allNewEmployees?.firstWhereOrNull((emp) =>
            emp.email.isNotEmpty && emp.email.last == currentUserEmail);

    bool hasSecondContact = false;
    if (currentEmployeeHistory != null) {
      hasSecondContact = currentEmployeeHistory.secondContactFirstName
              .any((name) => name.isNotEmpty) ||
          currentEmployeeHistory.secondContactEmail
              .any((email) => email.isNotEmpty) ||
          currentEmployeeHistory.secondContactPhone
              .any((phone) => phone.isNotEmpty);
    }

    // Was GetBuilder with `init: SettingsController()`, which constructed a
    // SECOND controller instead of observing the registered one — so this
    // subtree never saw updates from the real instance.
    return BlocBuilder<SettingsController, SettingsState>(
      bloc: Get.find<SettingsController>(),
      builder: (BuildContext context, SettingsState state) {
        final Widget groups = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Insurance Section
            Container(
              decoration: isMobile
                  ? null
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.card),
              child: isMobile
                  ? HealthInsuranceSection()
                  : Padding(
                      padding: EdgeInsets.only(
                          top: 16.sp, right: 16.sp, left: 16.sp),
                      child: HealthInsuranceSection(),
                    ),
            ),

            // D-223 (21/10/2026): one box, the groups' own insets are the gaps.
            const SizedBox(height: 0),

            // 1st Emergency Contact Section
            Container(
              decoration: isMobile
                  ? null
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.card),
              child: EmergencyContactInformationSection(
                employeeHistory: currentEmployeeHistory,
                isFirstContact: true,
              ),
            ),
            const SizedBox(height: 0),

            // 2nd Emergency Contact Section - Only show if data exists
            if (hasSecondContact) ...[
              Container(
                decoration: isMobile
                    ? null
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.card),
                child: EmergencyContactInformationSection(
                  employeeHistory: currentEmployeeHistory,
                  isFirstContact: false,
                ),
              ),
            ],
          ],
        );
        if (!isMobile) return groups;
        // D-223 (21/10/2026): ONE box with the titled groups inside.
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.card,
          ),
          child: groups,
        );
      },
    );
  }
}
