import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';

class ViewSupplierDetails extends StatelessWidget {
  final SupplierModel? supplierModel; // Add this line

  const ViewSupplierDetails({super.key, this.supplierModel});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return ViewSupplierDetails(
              supplierModel: supplierModel,
            ); // Or Tablet Landscape
          } else if (isTablet && !isLandscape) {
            return ViewSupplierDetails(
              supplierModel: supplierModel,
            ); // Or Tablet Landscape
          } else if (!isTablet && isLandscape) {
            return ViewSupplierDetails(
              supplierModel: supplierModel,
            ); // Or Tablet Landscape
          } else {
            return ViewSupplierDetails(
              supplierModel: supplierModel,
            ); // Or Tablet Landscape
          }
        },
      ),
    );
  }
}
