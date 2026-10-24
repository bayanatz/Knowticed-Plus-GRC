import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv9_order/presentation/ui/pages/order_details.dart';

class OrderDetailsToggle extends StatelessWidget {
  final List<ProductModel> products;
  final Map<String, dynamic>? orderData;

  const OrderDetailsToggle({
    super.key,
    required this.products,
    this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          // All screen sizes use the same component, just pass the products list
          return OrderDetails(products: products);
        },
      ),
    );
  }
}
