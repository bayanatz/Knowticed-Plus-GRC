import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv5_employee/presentation/ui/pages/p23_employee_name_details.dart';

class EmployeeNameDetails extends StatelessWidget {
  const EmployeeNameDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return EmployeeNameDetailsDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return EmployeeNameDetailsDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return EmployeeNameDetailsDesktopScreen();
          } else {
            return EmployeeNameDetailsDesktopScreen();
          }
        },
      ),
    );
  }
}
