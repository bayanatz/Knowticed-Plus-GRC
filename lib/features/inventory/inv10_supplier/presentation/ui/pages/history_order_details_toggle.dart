import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/history_order_details.dart';

class HistoryOderDetailsToggle extends StatelessWidget {
  // Accept both single order and list of orders for flexibility
  final ProductModel? orderData;
  final List<ProductModel>? orderDataList;

  const HistoryOderDetailsToggle({
    super.key,
    this.orderData,
    this.orderDataList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          // Determine which data to use
          List<ProductModel> products;

          if (orderDataList != null && orderDataList!.isNotEmpty) {
            // Use the provided list
            products = orderDataList!;
          } else if (orderData != null) {
            // Convert single ProductModel to List<ProductModel>
            products = [orderData!];
          } else {
            // No data provided, show empty list
            products = <ProductModel>[];
          }

          // Debug information
          debugPrint("🔍 HistoryOderDetails Debug:");
          debugPrint("  - Products count: ${products.length}");
          if (products.isNotEmpty) {
            final product = products[0];
            debugPrint("  - First product ID: '${product.productId.value}'");
            debugPrint("  - Order ID: '${product.orderId.value}'");
            debugPrint("  - Supplier ID: '${product.supplierId.value}'");
            debugPrint("  - Supplier Name: '${product.supplierName.value}'");
          }

          // Always use desktop screen regardless of device type for now
          // You can add different layouts later if needed
          return HistoryOrderDetailsDesktopScreen(products: products);
        },
      ),
    );
  }
}
