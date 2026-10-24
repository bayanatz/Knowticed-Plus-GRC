import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p14_storage_location_details.dart';

class StorageLocationDetails extends StatelessWidget {
  const StorageLocationDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return StorageLocationDetailsDesktopScreen();
          } else if (isTablet && !isLandscape) {
            return StorageLocationDetailsDesktopScreen();
          } else if (!isTablet && isLandscape) {
            return StorageLocationDetailsDesktopScreen();
          } else {
            return StorageLocationDetailsDesktopScreen();
          }
        },
      ),
    );
  }
}
