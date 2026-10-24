import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/order_info.dart';

class AddingProductAssets extends StatelessWidget {
  const AddingProductAssets({
    super.key,
    this.orderData,
    this.isConsumable = false,
    required this.isMultiProduct,
    required this.currentProductIndex,
    required this.productModels,
  });

  final Map<String, dynamic>? orderData;
  final bool isConsumable;

  final bool isMultiProduct;
  final int currentProductIndex;
  final List<ProductModel> productModels;

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return AddingProductAssetsDesktopScreen(
              orderData: orderData!,
              isConsumable: isConsumable,
              isMultiProduct: isMultiProduct,
              currentProductIndex: currentProductIndex,
              productModels: productModels,
            );
          } else if (isTablet && !isLandscape) {
            return AddingProductAssetsDesktopScreen(
              orderData: orderData!,
              isConsumable: isConsumable,
              isMultiProduct: isMultiProduct,
              currentProductIndex: currentProductIndex,
              productModels: productModels,
            );
          } else if (!isTablet && isLandscape) {
            return AddingProductAssetsDesktopScreen(
              orderData: orderData!,
              isConsumable: isConsumable,
              isMultiProduct: isMultiProduct,
              currentProductIndex: currentProductIndex,
              productModels: productModels,
            );
          } else {
            return AddingProductAssetsDesktopScreen(
              orderData: orderData!,
              isConsumable: isConsumable,
              isMultiProduct: isMultiProduct,
              currentProductIndex: currentProductIndex,
              productModels: productModels,
            );
          }
        },
      ),
    );
  }
}
