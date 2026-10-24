/// Module: services / sv6_services_requests / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_state.dart
/// Purpose: States of the "My requests" page: the requests, the filters in
///          use, the per-status counts and the items currently shown.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/domain/enums/request_sort.dart';

/// One request card on the page.
class MyRequestItem extends Equatable {
  const MyRequestItem({
    required this.model,
    required this.status,
    required this.departmentEnglish,
    required this.departmentArabic,
  });

  final ServicesHistoryModel model;

  /// Canonical status (RequestStatus).
  final String status;
  final String departmentEnglish;
  final String departmentArabic;

  @override
  List<Object?> get props => [
        model,
        status,
        departmentEnglish,
        departmentArabic,
      ];
}

abstract class MyRequestState extends Equatable {
  const MyRequestState();

  @override
  List<Object?> get props => [];
}

class MyRequestInitial extends MyRequestState {
  const MyRequestInitial();
}

class MyRequestLoading extends MyRequestState {
  const MyRequestLoading();
}

class MyRequestLoaded extends MyRequestState {
  final List<ServicesHistoryModel> services;
  final List<MyRequestItem> displayedItems;
  final List<ServicesHistoryModel> filteredModel;

  /// 'all' or a canonical status.
  final String selectedStatus;
  final List<String> selectedDepartmentKeys;
  final RequestSort selectedSort;
  final String searchQuery;

  /// Number of requests per canonical status.
  final Map<String, int> statusCounts;
  final int totalServices;

  const MyRequestLoaded({
    required this.services,
    required this.displayedItems,
    required this.filteredModel,
    required this.selectedStatus,
    this.selectedDepartmentKeys = const [],
    this.selectedSort = RequestSort.dateRequested,
    this.searchQuery = '',
    this.statusCounts = const {},
    this.totalServices = 0,
  });

  @override
  List<Object?> get props => [
        services,
        displayedItems,
        filteredModel,
        selectedStatus,
        selectedDepartmentKeys,
        selectedSort,
        searchQuery,
        statusCounts,
        totalServices,
      ];
}

/// Loading failed; the page shows the translated load error.
class MyRequestError extends MyRequestState {
  const MyRequestError();
}
