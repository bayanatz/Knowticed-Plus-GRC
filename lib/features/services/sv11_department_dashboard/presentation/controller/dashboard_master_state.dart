/// Module: services / sv11_department_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_master_state.dart
/// Purpose: State model for DashBoard Master Mobile Cubit
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';

class DashboardMasterState {
  // ── Bootstrap ──────────────────────────────────────────────────────────────
  final bool bootstrapping;
  final bool bootstrapped;

  /// SVC-DASH-01: the last load failed — show an error with Retry.
  final bool loadError;

  /// SVC-DASH-07: the viewer has no department, so the department dashboard
  /// is empty (it used to fall back to the whole company).
  final bool noDepartment;

  // ── Loading flags ──────────────────────────────────────────────────────────
  final bool isLoading;
  final bool isLoadingFirst;
  final bool isLoadingDepartments;
  final bool isLoadingServicesName;
  final bool isLoadingRejectedCanceled;

  // ── Tab toggle ─────────────────────────────────────────────────────────────
  final bool showRequestedServices;

  // ── Chart toggle (No. of Services vs Total Hours) ──────────────────────────
  final bool isHoursMode; // ✅ NEW: false = service counts, true = total hours

  // ── Chart data ─────────────────────────────────────────────────────────────
  final Map<String, int> statusCounts;
  final Map<String, int> departmentCounts;
  final Map<int, double> monthCounts;
  final Map<int, double> monthHours;
  final Map<int, double> serviceUsageCounts;
  final Map<int, double> monthRejected;
  final Map<int, double> monthCanceled;

  // ── Service names ──────────────────────────────────────────────────────────
  final List<String> serviceNames;
  final List<String> serviceNamesArabic;

  // ── Chart orientations ─────────────────────────────────────────────────────

  // ── Table data ─────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> filteredItems;
  final List<Map<String, dynamic>> displayedItems;

  // ── Filters ────────────────────────────────────────────────────────────────
  final String? activeDepartment;
  final String? activeStatus;
  final DateTime? activeDate;
  final String searchQuery;

  // ── Dynamic department maps ────────────────────────────────────────────────
  final Map<String, String> enToArDepartments;
  final Map<String, Color> departmentColors;
  final List<String> knownDepartments;
  final List<String> knownDepartmentsArabic;

  const DashboardMasterState({
    required this.bootstrapping,
    required this.bootstrapped,
    this.loadError = false,
    this.noDepartment = false,
    required this.isLoading,
    required this.isLoadingFirst,
    required this.isLoadingDepartments,
    required this.isLoadingServicesName,
    required this.isLoadingRejectedCanceled,
    required this.showRequestedServices,
    required this.isHoursMode, // ✅ NEW
    required this.statusCounts,
    required this.departmentCounts,
    required this.monthCounts,
    required this.monthHours,
    required this.serviceUsageCounts,
    required this.monthRejected,
    required this.monthCanceled,
    required this.serviceNames,
    required this.serviceNamesArabic,
    required this.filteredItems,
    required this.displayedItems,
    required this.activeDepartment,
    required this.activeStatus,
    required this.activeDate,
    required this.searchQuery,
    required this.enToArDepartments,
    required this.departmentColors,
    required this.knownDepartments,
    required this.knownDepartmentsArabic,
  });

  factory DashboardMasterState.initial() => const DashboardMasterState(
        bootstrapping: false,
        bootstrapped: false,
        isLoading: true,
        isLoadingFirst: true,
        isLoadingDepartments: true,
        isLoadingServicesName: true,
        isLoadingRejectedCanceled: true,
        showRequestedServices: true,
        isHoursMode: false, // ✅ NEW: default to service counts
        statusCounts: {},
        departmentCounts: {},
        monthCounts: {},
        monthHours: {},
        serviceUsageCounts: {},
        monthRejected: {},
        monthCanceled: {},
        serviceNames: [],
        serviceNamesArabic: [],
        filteredItems: [],
        displayedItems: [],
        activeDepartment: null,
        activeStatus: null,
        activeDate: null,
        searchQuery: '',
        enToArDepartments: {},
        departmentColors: {},
        knownDepartments: [],
        knownDepartmentsArabic: [],
      );

  DashboardMasterState copyWith({
    bool? bootstrapping,
    bool? bootstrapped,
    bool? loadError,
    bool? noDepartment,
    bool? isLoading,
    bool? isLoadingFirst,
    bool? isLoadingDepartments,
    bool? isLoadingServicesName,
    bool? isLoadingRejectedCanceled,
    bool? showRequestedServices,
    bool? isHoursMode, // ✅ NEW
    Map<String, int>? statusCounts,
    Map<String, int>? departmentCounts,
    Map<int, double>? monthCounts,
    Map<int, double>? monthHours,
    Map<int, double>? serviceUsageCounts,
    Map<int, double>? monthRejected,
    Map<int, double>? monthCanceled,
    List<String>? serviceNames,
    List<String>? serviceNamesArabic,
    List<Map<String, dynamic>>? filteredItems,
    List<Map<String, dynamic>>? displayedItems,
    String? activeDepartment,
    String? activeStatus,
    DateTime? activeDate,
    bool clearActiveDate = false,
    bool clearActiveDepartment = false,
    bool clearActiveStatus = false,
    String? searchQuery,
    Map<String, String>? enToArDepartments,
    Map<String, Color>? departmentColors,
    List<String>? knownDepartments,
    List<String>? knownDepartmentsArabic,
  }) {
    return DashboardMasterState(
      bootstrapping: bootstrapping ?? this.bootstrapping,
      bootstrapped: bootstrapped ?? this.bootstrapped,
      loadError: loadError ?? this.loadError,
      noDepartment: noDepartment ?? this.noDepartment,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFirst: isLoadingFirst ?? this.isLoadingFirst,
      isLoadingDepartments: isLoadingDepartments ?? this.isLoadingDepartments,
      isLoadingServicesName:
          isLoadingServicesName ?? this.isLoadingServicesName,
      isLoadingRejectedCanceled:
          isLoadingRejectedCanceled ?? this.isLoadingRejectedCanceled,
      showRequestedServices:
          showRequestedServices ?? this.showRequestedServices,
      isHoursMode: isHoursMode ?? this.isHoursMode, // ✅ NEW
      statusCounts: statusCounts ?? this.statusCounts,
      departmentCounts: departmentCounts ?? this.departmentCounts,
      monthCounts: monthCounts ?? this.monthCounts,
      monthHours: monthHours ?? this.monthHours,
      serviceUsageCounts: serviceUsageCounts ?? this.serviceUsageCounts,
      monthRejected: monthRejected ?? this.monthRejected,
      monthCanceled: monthCanceled ?? this.monthCanceled,
      serviceNames: serviceNames ?? this.serviceNames,
      serviceNamesArabic: serviceNamesArabic ?? this.serviceNamesArabic,
      filteredItems: filteredItems ?? this.filteredItems,
      displayedItems: displayedItems ?? this.displayedItems,
      activeDepartment: clearActiveDepartment
          ? null
          : (activeDepartment ?? this.activeDepartment),
      activeStatus:
          clearActiveStatus ? null : (activeStatus ?? this.activeStatus),
      activeDate: clearActiveDate ? null : (activeDate ?? this.activeDate),
      searchQuery: searchQuery ?? this.searchQuery,
      enToArDepartments: enToArDepartments ?? this.enToArDepartments,
      departmentColors: departmentColors ?? this.departmentColors,
      knownDepartments: knownDepartments ?? this.knownDepartments,
      knownDepartmentsArabic:
          knownDepartmentsArabic ?? this.knownDepartmentsArabic,
    );
  }
}
