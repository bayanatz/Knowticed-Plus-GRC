/// Module: services / sv6_services_requests / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_services_state.dart
/// Purpose: States of the "Service requests" page.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

import 'package:knowticed_plus/features/services/sv6_services_requests/data/department_count_model.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/data/service_filter_model.dart';

abstract class RequestServicesState {}

class RequestServicesInitial extends RequestServicesState {}

class RequestServicesLoading extends RequestServicesState {}

class RequestServicesLoaded extends RequestServicesState {
  final List<ServicesHistoryModel> filteredServices;
  final DepartmentCountModel departmentCounts;
  final ServiceFilterModel filterModel;

  RequestServicesLoaded({
    required this.filteredServices,
    required this.departmentCounts,
    required this.filterModel,
  });
}

/// Loading failed; the page shows the translated load error.
class RequestServicesError extends RequestServicesState {}
