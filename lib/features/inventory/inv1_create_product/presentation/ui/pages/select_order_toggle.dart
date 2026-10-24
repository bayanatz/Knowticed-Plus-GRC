import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_order.dart';

class SelectOrder extends StatelessWidget {
  const SelectOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return SelectOrderDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return SelectOrderDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return SelectOrderDesktopScreen();
          } else {
            return SelectOrderDesktopScreen();
          }
        },
      ),
    );
  }
}
