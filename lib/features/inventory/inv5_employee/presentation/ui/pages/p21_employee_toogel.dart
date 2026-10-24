import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv5_employee/presentation/ui/pages/p21_employee.dart';

class EmployeeSection extends StatelessWidget {
  const EmployeeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return EmployeeDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return EmployeeDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return EmployeeDesktopScreen();
          } else {
            return EmployeeDesktopScreen();
          }
        },
      ),
    );
  }
}
