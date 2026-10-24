/// Module: knowledge_hub/kh7_dashboard/presentation/controller
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_states.dart
/// Description: States of the dashboard cubit.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/domain/use_cases/dashboard_statistics.dart';

abstract class DashboardStates {}

class DashboardInitial extends DashboardStates {}

class DashboardLoading extends DashboardStates {}

class DashboardEmpty extends DashboardStates {}

/// Loading failed. The screen shows a translated message; the technical
/// error is only logged (it is never shown to the user).
class DashboardError extends DashboardStates {}

class DashboardLoaded extends DashboardStates {
  DashboardLoaded({
    required this.figures,
    required this.departmentNamesEn,
    required this.departmentNamesAr,
    required this.selectedDepartmentIds,
    this.unreadableRecords = 0,
  });

  /// The figures for the documents in the selected departments (all
  /// departments when none is selected).
  final DashboardFigures figures;

  /// Department id -> name. The widget picks the language.
  final Map<String, String> departmentNamesEn;
  final Map<String, String> departmentNamesAr;

  /// Department filter; empty means every department.
  final List<String> selectedDepartmentIds;

  /// Records left out of the figures because they could not be read
  /// (KH-DASH-09). The screen shows a short notice when above zero.
  final int unreadableRecords;
}
