import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p15_product_request.dart';

class ProductRequest extends StatelessWidget {
  const ProductRequest({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return ProductRequestDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return ProductRequestDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return ProductRequestDesktopScreen();
          } else {
            return ProductRequestDesktopScreen();
          }
        },
      ),
    );
  }
}
