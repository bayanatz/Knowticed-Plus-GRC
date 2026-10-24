import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv5_employee/presentation/ui/pages/p22_employee_name.dart';

class EmployeeName extends StatelessWidget {
  const EmployeeName({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return EmployeeNameDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return EmployeeNameDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return EmployeeNameDesktopScreen();
          } else {
            return EmployeeNameDesktopScreen();
          }
        },
      ),
    );
  }
}
