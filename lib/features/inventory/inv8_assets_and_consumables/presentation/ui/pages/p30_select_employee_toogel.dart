import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv8_assets_and_consumables/presentation/ui/pages/p30_select_employee.dart';

class SelectDetailsSection extends StatelessWidget {
  const SelectDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return SelectEmployeeDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return SelectEmployeeDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return SelectEmployeeDesktopScreen();
          } else {
            return SelectEmployeeDesktopScreen();
          }
        },
      ),
    );
  }
}
