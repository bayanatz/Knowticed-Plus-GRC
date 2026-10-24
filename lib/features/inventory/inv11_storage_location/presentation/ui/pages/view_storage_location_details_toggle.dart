import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/view_storage_location_details.dart';

class StorageLocationDetailsToggle extends StatelessWidget {
  final StorageLocation? storageLocation;

  const StorageLocationDetailsToggle({
    super.key,
    this.storageLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return StorageLocationDetails(
              storageLocation: storageLocation,
            );
          } else if (isTablet && !isLandscape) {
            return StorageLocationDetails(
              storageLocation: storageLocation,
            );
          } else if (!isTablet && isLandscape) {
            return StorageLocationDetails(
              storageLocation: storageLocation,
            );
          } else {
            return StorageLocationDetails(
              storageLocation: storageLocation,
            );
          }
        },
      ),
    );
  }
}
