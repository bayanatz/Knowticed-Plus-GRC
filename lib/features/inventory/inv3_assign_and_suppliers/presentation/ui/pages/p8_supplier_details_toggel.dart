import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p8_supplier_details.dart';

class SupplierDetails extends StatelessWidget {
  const SupplierDetails({super.key, this.supplierData});
  final Map<String, dynamic>? supplierData;

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return SupplierDetailsScreen(
              supplierData: supplierData,
            );
          } else if (isTablet && !isLandscape) {
            return SupplierDetailsScreen(
              supplierData: supplierData,
            );
          } else if (!isTablet && isLandscape) {
            return SupplierDetailsScreen(
              supplierData: supplierData,
            );
          } else {
            return SupplierDetailsScreen(
              supplierData: supplierData,
            );
          }
        },
      ),
    );
  }
}
