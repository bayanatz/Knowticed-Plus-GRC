import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p11_employee_product_details.dart';

class EmployeeProductDetails extends StatelessWidget {
  const EmployeeProductDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return EmployeeProductDetailsDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return EmployeeProductDetailsDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return EmployeeProductDetailsDesktopScreen();
          } else {
            return EmployeeProductDetailsDesktopScreen();
          }
        },
      ),
    );
  }
}
