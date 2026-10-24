import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p10_employee_details.dart';

class EmployeeDetails extends StatelessWidget {
  const EmployeeDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return EmployeeDetailsDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return EmployeeDetailsDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return EmployeeDetailsDesktopScreen();
          } else {
            return EmployeeDetailsDesktopScreen();
          }
        },
      ),
    );
  }
}
