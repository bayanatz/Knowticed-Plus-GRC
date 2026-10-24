import 'package:flutter/material.dart';
// Only if using context extensions
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page.dart';

class InventoryManagement extends StatelessWidget {
  final String? initialFilter; // Made optional with nullable type

  const InventoryManagement(
      {super.key, this.initialFilter}); // Removed required keyword

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return InventoryManagementDesktopScreen(
              initialSelectedLabel: initialFilter, // Pass the optional filter
            );
          } else if (isTablet && !isLandscape) {
            return InventoryManagementDesktopScreen(
              initialSelectedLabel: initialFilter, // Pass the optional filter
            );
          } else if (!isTablet && isLandscape) {
            return InventoryManagementDesktopScreen(
              initialSelectedLabel: initialFilter, // Pass the optional filter
            );
          } else {
            return InventoryManagementDesktopScreen(
              initialSelectedLabel: initialFilter, // Pass the optional filter
            );
          }
        },
      ),
    );
  }
}
