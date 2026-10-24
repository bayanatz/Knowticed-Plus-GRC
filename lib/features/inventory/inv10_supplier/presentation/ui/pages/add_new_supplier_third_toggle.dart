import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier_third.dart';

class AddNewSupplierThirdToggle extends StatelessWidget {
  const AddNewSupplierThirdToggle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return AddNewSupplierThird(); // Or Tablet Landscape
          } else if (isTablet && !isLandscape) {
            return AddNewSupplierThird();
          } else if (!isTablet && isLandscape) {
            return AddNewSupplierThird();
          } else {
            return AddNewSupplierThird();
          }
        },
      ),
    );
  }
}
