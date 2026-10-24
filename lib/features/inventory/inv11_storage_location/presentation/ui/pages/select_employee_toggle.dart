import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/select_employee.dart';

class SelectEmployeeToggle extends StatelessWidget {
  final Map<String, dynamic> storageLocationData; // Add this parameter

  const SelectEmployeeToggle({
    super.key,
    this.storageLocationData = const {},
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return SelectEmployee(
              storageLocationData: storageLocationData,
            );
          } else if (isTablet && !isLandscape) {
            return SelectEmployee(
              storageLocationData: storageLocationData,
            );
          } else if (!isTablet && isLandscape) {
            return SelectEmployee(
              storageLocationData: storageLocationData,
            );
          } else {
            return SelectEmployee(
              storageLocationData: storageLocationData,
            );
          }
        },
      ),
    );
  }
}
