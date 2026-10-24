import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv8_assets_and_consumables/presentation/ui/pages/p32_select_services_history.dart';

class SelectServicesHistorySection extends StatelessWidget {
  const SelectServicesHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return SelectServicesHistoryDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return SelectServicesHistoryDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return SelectServicesHistoryDesktopScreen();
          } else {
            return SelectServicesHistoryDesktopScreen();
          }
        },
      ),
    );
  }
}
