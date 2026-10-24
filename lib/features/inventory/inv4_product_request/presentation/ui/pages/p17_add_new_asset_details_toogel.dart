import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p17_add_new_asset_details.dart';

class AddNewAssetsDetails extends StatelessWidget {
  const AddNewAssetsDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return AddNewAssetsDetailsDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return AddNewAssetsDetailsDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return AddNewAssetsDetailsDesktopScreen();
          } else {
            return AddNewAssetsDetailsDesktopScreen();
          }
        },
      ),
    );
  }
}
