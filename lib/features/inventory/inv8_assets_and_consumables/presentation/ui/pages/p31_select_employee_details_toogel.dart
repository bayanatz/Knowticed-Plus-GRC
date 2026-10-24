import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv8_assets_and_consumables/presentation/ui/pages/p31_select_employee_details.dart';

class SelectEmployeeDetailsSection extends StatelessWidget {
  const SelectEmployeeDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return SelectEmployeeDetailsDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return SelectEmployeeDetailsDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return SelectEmployeeDetailsDesktopScreen();
          } else {
            return SelectEmployeeDetailsDesktopScreen();
          }
        },
      ),
    );
  }
}
