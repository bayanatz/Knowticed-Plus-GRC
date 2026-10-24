import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv7_dashboard/presentation/ui/pages/p7_dashboard.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return DashboardDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return DashboardDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return DashboardDesktopScreen();
          } else {
            return DashboardDesktopScreen();
          }
        },
      ),
    );
  }
}
