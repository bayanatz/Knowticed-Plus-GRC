import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p13_select_assigning_product.dart';

class SelectAssignProduct extends StatelessWidget {
  const SelectAssignProduct({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return SelectAssignProductDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return SelectAssignProductDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return SelectAssignProductDesktopScreen();
          } else {
            return SelectAssignProductDesktopScreen();
          }
        },
      ),
    );
  }
}
