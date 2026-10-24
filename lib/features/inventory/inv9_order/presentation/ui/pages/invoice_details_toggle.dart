import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv9_order/presentation/ui/pages/invoice_details.dart';

class InvoiceDetailsToggle extends StatelessWidget {
  final List<ProductModel> products;

  const InvoiceDetailsToggle({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return InvoiceDetailsScreen(products: products);
        },
      ),
    );
  }
}
