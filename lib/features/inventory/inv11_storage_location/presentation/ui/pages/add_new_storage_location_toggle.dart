import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/add_new_storage_location.dart';

class AddNewStorageToggle extends StatelessWidget {
  const AddNewStorageToggle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return AddNewStorageLocation(); // Or Tablet Landscape
          } else if (isTablet && !isLandscape) {
            return AddNewStorageLocation();
          } else if (!isTablet && isLandscape) {
            return AddNewStorageLocation();
          } else {
            return AddNewStorageLocation();
          }
        },
      ),
    );
  }
}
