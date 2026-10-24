import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/product_details.dart';

class ViewProductDetails extends StatelessWidget {
  final ProductModel? productModel; // Add optional product model parameter

  const ViewProductDetails({
    super.key,
    this.productModel,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(body: Builder(builder: (context) {
      if (isTablet && isLandscape) {
        return ViewProductDetailsScreen(productModel: productModel);
      } else if (isTablet && !isLandscape) {
        return ViewProductDetailsScreen(productModel: productModel);
      } else if (!isTablet && isLandscape) {
        return ViewProductDetailsScreen(productModel: productModel);
      } else {
        return ViewProductDetailsScreen(productModel: productModel);
      }
    }));
  }
}
