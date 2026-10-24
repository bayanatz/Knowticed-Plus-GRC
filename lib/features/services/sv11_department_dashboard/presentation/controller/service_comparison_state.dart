/// Module: services / sv11_department_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: service_comparison_state.dart
/// Purpose: State of ServiceComparisonCubit — the monthly cancelled vs
///          rejected counts and the service names for the filter.
/// Author: Knowticed Team
/// Created At: 02/07/2026
library;

import 'package:equatable/equatable.dart';

class ServiceComparisonData extends Equatable {
  /// Keys of one month's counts in [monthlyData].
  static const String canceledKey = 'canceled';
  static const String rejectedKey = 'rejected';

  /// month (1-12) -> {'canceled': count, 'rejected': count}
  final Map<int, Map<String, int>> monthlyData;
  final List<String> allServicesEnglish;
  final List<String> allServicesArabic;

  const ServiceComparisonData({
    this.monthlyData = const {},
    this.allServicesEnglish = const [],
    this.allServicesArabic = const [],
  });

  @override
  List<Object?> get props => [
        monthlyData,
        allServicesEnglish,
        allServicesArabic,
      ];
}

abstract class ServiceComparisonState extends Equatable {
  const ServiceComparisonState();

  @override
  List<Object?> get props => [];
}

class ServiceComparisonLoading extends ServiceComparisonState {
  const ServiceComparisonLoading();
}

/// SVC-DASH-01: loading failed; the chart shows an error with Retry.
class ServiceComparisonError extends ServiceComparisonState {
  final String message;

  const ServiceComparisonError(this.message);

  @override
  List<Object?> get props => [message];
}

class ServiceComparisonLoaded extends ServiceComparisonState {
  final ServiceComparisonData data;

  const ServiceComparisonLoaded(this.data);

  @override
  List<Object?> get props => [data];
}
