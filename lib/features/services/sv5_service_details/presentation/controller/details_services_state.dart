/// Module: services / sv5_service_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: details_services_state.dart
/// Purpose: Details services state — declares DetailsServicesState,
///          DetailsServicesInitial, DetailsServicesLoading,
///          DetailsServicesLoaded.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';

import 'package:knowticed_plus/features/services/sv5_service_details/data/models/service_stats_model.dart';

abstract class DetailsServicesState {}

class DetailsServicesInitial extends DetailsServicesState {}

class DetailsServicesLoading extends DetailsServicesState {}

class DetailsServicesLoaded extends DetailsServicesState {
  final List<Map<String, dynamic>> filteredItems;
  final List<Map<String, dynamic>> displayedItems;
  final List<ServiceEmployeeModel> allEmployees;
  final ServiceStatsModel stats;

  DetailsServicesLoaded({
    required this.filteredItems,
    required this.displayedItems,
    required this.allEmployees,
    required this.stats,
  });
}

class DetailsServicesError extends DetailsServicesState {
  final String message;

  DetailsServicesError(this.message);
}

class DetailsServicesFilterApplied extends DetailsServicesState {
  final List<Map<String, dynamic>> displayedItems;

  DetailsServicesFilterApplied(this.displayedItems);
}

class DetailsServicesSearchApplied extends DetailsServicesState {}

class DetailsServicesTabChanged extends DetailsServicesState {
  final bool isEmployeesTab;

  DetailsServicesTabChanged(this.isEmployeesTab);
}
