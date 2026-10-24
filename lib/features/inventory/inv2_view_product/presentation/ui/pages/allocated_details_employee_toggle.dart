import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/allocated_details_employee.dart';

class AllocatedDetailsEmployeeToggle extends StatelessWidget {
  const AllocatedDetailsEmployeeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return AllocatedDetailsEmployee();
          } else if (isTablet && !isLandscape) {
            return AllocatedDetailsEmployee();
          } else if (!isTablet && isLandscape) {
            return AllocatedDetailsEmployee();
          } else {
            return AllocatedDetailsEmployee();
          }
        },
      ),
    );
  }
}
