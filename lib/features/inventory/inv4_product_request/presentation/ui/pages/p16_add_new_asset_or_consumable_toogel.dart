import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p16_add_new_asset_or_consumable.dart';

class AddNewAssetsOrConsumable extends StatelessWidget {
  const AddNewAssetsOrConsumable({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return AddNewAssetsOrConsumableDesktopScreen(
              type: type,
            );
          } else if (isTablet && !isLandscape) {
            return AddNewAssetsOrConsumableDesktopScreen(
              type: type,
            );
          } else if (!isTablet && isLandscape) {
            return AddNewAssetsOrConsumableDesktopScreen(
              type: type,
            );
          } else {
            return AddNewAssetsOrConsumableDesktopScreen(
              type: type,
            );
          }
        },
      ),
    );
  }
}
