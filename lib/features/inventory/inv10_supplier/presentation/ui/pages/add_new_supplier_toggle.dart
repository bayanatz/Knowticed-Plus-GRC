import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier.dart';

class AddNewSupplierToggle extends StatelessWidget {
  const AddNewSupplierToggle({
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
            return AddNewSupplier(); // Or Tablet Landscape
          } else if (isTablet && !isLandscape) {
            return AddNewSupplier();
          } else if (!isTablet && isLandscape) {
            return AddNewSupplier();
          } else {
            return AddNewSupplier();
          }
        },
      ),
    );
  }
}
