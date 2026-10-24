/// Module: services / sv10_services_provider / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: employee_services_state.dart
/// Purpose: State of the provider's request list: loading, error, or the
///          loaded requests with the chip counts, the chosen chip and the
///          search text (counting and filtering are done by the cubit).
/// Author: Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): counts, filter and sort moved here from the
///     page (Provider rule 2).
library;

import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

abstract class EmployeeServicesState extends Equatable {
  const EmployeeServicesState();

  @override
  List<Object?> get props => [];
}

class EmployeeServicesLoading extends EmployeeServicesState {
  const EmployeeServicesLoading();
}

class EmployeeServicesLoaded extends EmployeeServicesState {
  /// Every request assigned to the provider.
  final List<ServicesHistoryModel> services;

  /// The requests to show (chip + search applied, sorted).
  final List<ServicesHistoryModel> visible;

  /// Requests per status key (see ProviderListKeys), including 'all'.
  final Map<String, int> counts;

  /// The selected status chip.
  final String statusKey;

  /// The search text.
  final String query;

  const EmployeeServicesLoaded({
    required this.services,
    required this.visible,
    required this.counts,
    required this.statusKey,
    required this.query,
  });

  @override
  List<Object?> get props => [services, visible, counts, statusKey, query];
}

class EmployeeServicesError extends EmployeeServicesState {
  /// English detail for logs only — never shown to the user.
  final String message;

  const EmployeeServicesError(this.message);

  @override
  List<Object?> get props => [message];
}
