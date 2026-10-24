import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/edit_storage_location_details.dart';

class EditStorageLocationDetailsToggle extends StatelessWidget {
  final StorageLocation? storageLocation;
  final Map<String, String> storageLocationData;
  final List<EmployeeEntityPro> selectedEmployees;

  const EditStorageLocationDetailsToggle({
    super.key,
    this.storageLocation,
    this.storageLocationData = const {},
    this.selectedEmployees = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return EditStorageLocationDetails(
              storageLocation: storageLocation,
            );
          } else if (isTablet && !isLandscape) {
            return EditStorageLocationDetails(
              storageLocation: storageLocation,
            );
          } else if (!isTablet && isLandscape) {
            return EditStorageLocationDetails(
              storageLocation: storageLocation,
            );
          } else {
            return EditStorageLocationDetails(
              storageLocation: storageLocation,
            );
          }
        },
      ),
    );
  }
}
