import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/select_employee_with_data.dart';

class SelectEmployeeWithDataToggle extends StatelessWidget {
  final Map<String, dynamic> storageLocationData;

  final List<EmployeeEntityPro> selectedEmployees;

  const SelectEmployeeWithDataToggle(
      {super.key,
      required this.storageLocationData,
      required this.selectedEmployees});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (isTablet && isLandscape) {
            return SelectEmployeeWithData(
              storageLocationData: storageLocationData,
              selectedEmployees: selectedEmployees,
            );
          } else if (isTablet && !isLandscape) {
            return SelectEmployeeWithData(
              storageLocationData: storageLocationData,
              selectedEmployees: selectedEmployees,
            );
          } else if (!isTablet && isLandscape) {
            return SelectEmployeeWithData(
              storageLocationData: storageLocationData,
              selectedEmployees: selectedEmployees,
            );
          } else {
            return SelectEmployeeWithData(
              storageLocationData: storageLocationData,
              selectedEmployees: selectedEmployees,
            );
          }
        },
      ),
    );
  }
}
