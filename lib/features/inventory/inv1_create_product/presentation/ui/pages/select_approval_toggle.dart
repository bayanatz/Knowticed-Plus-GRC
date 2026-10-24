import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';

class UploadProductDetailsAssets extends StatelessWidget {
  final ProductModel productModel;
  final List<ProductModel> productModels;
  final int currentProductIndex;
  final bool isMultiProduct;
  final Map<String, dynamic> orderData; // ✅ Add this
  final bool isConsumable; // ✅ ADD THIS
  final bool isEditMode; // Add this parameter

  const UploadProductDetailsAssets({
    super.key,
    required this.productModel,
    required this.productModels,
    required this.currentProductIndex,
    required this.isMultiProduct,
    required this.orderData, // ✅ Add this
    required this.isConsumable,
    required this.isEditMode, // ✅ ADD THIS
  });
  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return RequireApprovalProductDetailsAssetsDesktopScreen(
              isConsumable: isConsumable, // ✅ ADD THIS
              isEditMode: isEditMode,

              productModel: productModel,
              productModels: productModels,
              currentProductIndex: currentProductIndex,
              isMultiProduct: isMultiProduct,
              orderData: orderData, // ✅ Add this
            );
          } else if (isTablet && !isLandscape) {
            return RequireApprovalProductDetailsAssetsDesktopScreen(
              isConsumable: isConsumable, // ✅ ADD THIS

              productModel: productModel,
              productModels: productModels,
              currentProductIndex: currentProductIndex,
              isMultiProduct: isMultiProduct,
              orderData: orderData, // ✅ Add this
              isEditMode: isEditMode,
            );
          } else if (!isTablet && isLandscape) {
            return RequireApprovalProductDetailsAssetsDesktopScreen(
              isConsumable: isConsumable, // ✅ ADD THIS

              productModel: productModel,
              productModels: productModels,
              currentProductIndex: currentProductIndex,
              isMultiProduct: isMultiProduct,
              orderData: orderData,
              isEditMode: isEditMode,
            );
          } else {
            return RequireApprovalProductDetailsAssetsDesktopScreen(
              isConsumable: isConsumable, // ✅ ADD THIS
              isEditMode: isEditMode,

              productModel: productModel,
              productModels: productModels,
              currentProductIndex: currentProductIndex,
              isMultiProduct: isMultiProduct,
              orderData: orderData, // ✅ Add this
            );
          }
        },
      ),
    );
  }
}
