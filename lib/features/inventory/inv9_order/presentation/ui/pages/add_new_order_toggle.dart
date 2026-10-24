import 'package:flutter/material.dart';
// Only if using context extensions
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv9_order/presentation/ui/pages/add_new_order_first.dart';

class AddNewOrderFirstToggle extends StatelessWidget {
  const AddNewOrderFirstToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return AddNewOrderPageFirst(); // Or Tablet Landscape
          } else if (isTablet && !isLandscape) {
            return AddNewOrderPageFirst();
          } else if (!isTablet && isLandscape) {
            return AddNewOrderPageFirst();
          } else {
            return AddNewOrderPageFirst();
          }
        },
      ),
    );
  }
}
