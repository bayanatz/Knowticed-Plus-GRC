import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/edit_supplier_details.dart';

class EditSupplierDetailsToggle extends StatelessWidget {
  const EditSupplierDetailsToggle({super.key, this.supplierData});
  final Map<String, dynamic>? supplierData;

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return EditSupplierDetailsScreen(
              supplierData: supplierData,
            );
          } else if (isTablet && !isLandscape) {
            return EditSupplierDetailsScreen(
              supplierData: supplierData,
            );
          } else if (!isTablet && isLandscape) {
            return EditSupplierDetailsScreen(
              supplierData: supplierData,
            );
          } else {
            return EditSupplierDetailsScreen(
              supplierData: supplierData,
            );
          }
        },
      ),
    );
  }
}
