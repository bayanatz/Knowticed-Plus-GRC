// add_new_order_second_toggle.dart
import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv9_order/presentation/ui/pages/add_new_order_second.dart';

class AddNewOrderSecondToggle extends StatelessWidget {
  final List<ProductModel>? products;
  final Map<String, dynamic>? orderData;
  final String? draftId; // ADD THIS
  final bool isDraftEdit; // ADD THIS

  const AddNewOrderSecondToggle({
    super.key,
    this.products,
    this.orderData,
    this.draftId, // ADD THIS
    this.isDraftEdit = false, // ADD THIS
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return AddNewOrderPageSecond(
            products: products,
            orderData: orderData,
            draftId: draftId, // ADD THIS
            isDraftEdit: isDraftEdit, // ADD THIS
          );
        },
      ),
    );
  }
}
