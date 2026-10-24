import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier_second.dart';

class AddNewSupplierSecondToggle extends StatelessWidget {
  const AddNewSupplierSecondToggle({
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
            return AddNewSupplierSecond(); // Or Tablet Landscape
          } else if (isTablet && !isLandscape) {
            return AddNewSupplierSecond();
          } else if (!isTablet && isLandscape) {
            return AddNewSupplierSecond();
          } else {
            return AddNewSupplierSecond();
          }
        },
      ),
    );
  }
}
