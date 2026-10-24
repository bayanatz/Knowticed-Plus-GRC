import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/upload_order.dart';

class ProductDetailsAssets extends StatelessWidget {
  final List<ProductModel> productModels;
  final int currentProductIndex;
  final bool isMultiProduct;
  final bool isConsumable; // ✅ ADD THIS
  final Map<String, dynamic> orderData;
  final bool isEditMode; // Add this parameter

  const ProductDetailsAssets({
    super.key,
    required this.productModels,
    required this.currentProductIndex,
    required this.isMultiProduct,
    required this.isConsumable, // ✅ ADD THIS
    required this.orderData,
    required this.isEditMode,
  });
  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          final productModel = productModels.last; // ✅ get last filled

          if (isTablet && isLandscape) {
            return ProductDetailsAssetsDesktopScreen(
              productModel: productModel, // ✅ required
              isConsumable: isConsumable, // ✅ ADD THIS
              isEditMode: isEditMode,
              orderData: orderData, // ✅ Pass it here

              productModels: productModels,
              currentProductIndex: currentProductIndex,
              isMultiProduct: isMultiProduct,
            );
          } else if (isTablet && !isLandscape) {
            return ProductDetailsAssetsDesktopScreen(
              productModel: productModel, // ✅ required
              orderData: orderData, // ✅ Pass it here
              isConsumable: isConsumable, // ✅ ADD THIS
              isEditMode: isEditMode,

              productModels: productModels,
              currentProductIndex: currentProductIndex,
              isMultiProduct: isMultiProduct,
            );
          } else if (!isTablet && isLandscape) {
            return ProductDetailsAssetsDesktopScreen(
              productModel: productModel, // ✅ required
              orderData: orderData, // ✅ Pass it here
              isConsumable: isConsumable, // ✅ ADD THIS
              isEditMode: isEditMode,

              productModels: productModels,
              currentProductIndex: currentProductIndex,
              isMultiProduct: isMultiProduct,
            );
          } else {
            return ProductDetailsAssetsDesktopScreen(
              productModel: productModel, // ✅ required
              orderData: orderData, // ✅ Pass it here
              isConsumable: isConsumable, // ✅ ADD THIS
              isEditMode: isEditMode,

              productModels: productModels,
              currentProductIndex: currentProductIndex,
              isMultiProduct: isMultiProduct,
            );
          }
        },
      ),
    );
  }
}
