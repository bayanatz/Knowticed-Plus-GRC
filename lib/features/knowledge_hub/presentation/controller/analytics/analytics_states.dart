/// Module: knowledge_hub/presentation/controller/analytics
///
///*************************** FILE INFO ****************************///
/// File Name: analytics_states.dart
/// Description: `AnalyticsStates` state, `AnalyticsInitial` state, `FetchingAnalyticsLoadingState` state and 9 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: analytics_states.dart
/// Purpose: Contains all states for Analytics
/// Author: Youssef Khaled
/// Created At: 20/10/2025

abstract class AnalyticsStates {}

class AnalyticsInitial extends AnalyticsStates {}

class FetchingAnalyticsLoadingState extends AnalyticsStates {}

class FetchingAnalyticsSuccessState extends AnalyticsStates {
  final Map<String, int> departmentCounts;
  final Map<String, int> monthlyDownloads;
  final Map<String, int> monthlyViews;
  final int totalDownloads;
  final int totalViews;

  FetchingAnalyticsSuccessState({
    required this.departmentCounts,
    required this.monthlyDownloads,
    required this.monthlyViews,
    required this.totalDownloads,
    required this.totalViews,
  });
}

class FetchingAnalyticsEmptyState extends AnalyticsStates {}

/// Delete Knowledge Loading State
class DeleteKnowledgeLoading extends AnalyticsStates {}

/// Delete Knowledge Success State
class DeleteKnowledgeSuccess extends AnalyticsStates {}

/// Delete Knowledge Failure State
class DeleteKnowledgeFailure extends AnalyticsStates {
  final String error;

  DeleteKnowledgeFailure({required this.error});
}

class FetchingAnalyticsErrorState extends AnalyticsStates {
  final String error;
  FetchingAnalyticsErrorState(this.error);
}

class EmployeesLoading extends AnalyticsStates {}

class EmployeesLoadedSuccess extends AnalyticsStates {
  final List<EmployeeData> employees;
  EmployeesLoadedSuccess(this.employees);
}

class EmployeesLoadingFailure extends AnalyticsStates {
  final String error;
  EmployeesLoadingFailure(this.error);
}
