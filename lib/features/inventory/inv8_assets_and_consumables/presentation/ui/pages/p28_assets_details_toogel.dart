import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv8_assets_and_consumables/presentation/ui/pages/p28_assets_details.dart';

class AssetsDetailsSection extends StatelessWidget {
  final ProductModel? productModel;

  const AssetsDetailsSection({
    super.key,
    this.productModel,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return AssetsDetailsDesktopScreen(
              productModel: productModel,
            );
          } else if (isTablet && !isLandscape) {
            return AssetsDetailsDesktopScreen(
              productModel: productModel,
            );
          } else if (!isTablet && isLandscape) {
            return AssetsDetailsDesktopScreen(
              productModel: productModel,
            );
          } else {
            return AssetsDetailsDesktopScreen(
              productModel: productModel,
            );
          }
        },
      ),
    );
  }
}
