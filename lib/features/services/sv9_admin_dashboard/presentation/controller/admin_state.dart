/// Module: services / sv9_admin_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: admin_state.dart
/// Purpose: State of the Admin Dashboard: load flags, the chosen department,
///          the status / department / monthly numbers, the table rows, the
///          service cards and the monthly cancelled / rejected series.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): the eleven fixed department counters were
///     never read and are gone; monthCountss → serviceUsageCounts
///     (Dashboards rule 21); cancelledByMonth / rejectedByMonth feed the
///     comparison chart, which no longer downloads requests itself (rule 2).
library;

class DashboardAdminState {
  // Bootstrap
  final bool bootstrapping;
  final bool bootstrapped;

  /// SVC-DASH-01: the last load failed — show an error with Retry, not 0s.
  final bool loadError;

  // Filter
  final String selectStatus;
  final bool showRequests;
  final bool showAll;

  // Loading flags
  final bool isLoading;
  final bool isLoadingFirst;
  final bool isLoadingRequests;
  final bool isLoadingServicesName;
  final bool isLoadingDepartments;
  final bool isServiceListLoading;

  /// Requests per status.
  final Map<String, int> statusCounts;

  // Monthly data (0-based month → value)
  final Map<int, double> monthCounts;
  final Map<int, num> monthHours;

  /// Requests per service, in the order of [serviceNames].
  final Map<int, double> serviceUsageCounts;

  /// Cancelled requests per month (12 values), by department English name;
  /// '' is every department.
  final Map<String, List<int>> cancelledByMonth;

  /// Rejected requests per month (12 values), by department English name;
  /// '' is every department.
  final Map<String, List<int>> rejectedByMonth;

  // Service display toggle
  final bool showServiceCount;

  // Service names
  final List<String> serviceNames;
  final List<String> serviceNamesArabic;

  /// Requests per department, and their total.
  final int totalServices;
  final Map<String, int> departmentCounts;

  // Table data
  final List<Map<String, dynamic>> displayedItems;

  // Service list (grid cards)
  final List<Map<String, dynamic>> allServices;

  const DashboardAdminState({
    required this.bootstrapping,
    required this.bootstrapped,
    this.loadError = false,
    required this.selectStatus,
    required this.showRequests,
    required this.showAll,
    required this.isLoading,
    required this.isLoadingFirst,
    required this.isLoadingRequests,
    required this.isLoadingServicesName,
    required this.isLoadingDepartments,
    required this.isServiceListLoading,
    required this.statusCounts,
    required this.monthCounts,
    required this.monthHours,
    required this.serviceUsageCounts,
    required this.cancelledByMonth,
    required this.rejectedByMonth,
    required this.showServiceCount,
    required this.serviceNames,
    required this.serviceNamesArabic,
    required this.totalServices,
    required this.departmentCounts,
    required this.displayedItems,
    required this.allServices,
  });

  factory DashboardAdminState.initial() => const DashboardAdminState(
        bootstrapping: false,
        bootstrapped: false,
        selectStatus: 'All',
        showRequests: true,
        showAll: false,
        isLoading: true,
        isLoadingFirst: true,
        isLoadingRequests: true,
        isLoadingServicesName: true,
        isLoadingDepartments: true,
        isServiceListLoading: true,
        statusCounts: {},
        monthCounts: {},
        monthHours: {},
        serviceUsageCounts: {},
        cancelledByMonth: {},
        rejectedByMonth: {},
        showServiceCount: true,
        serviceNames: [],
        serviceNamesArabic: [],
        totalServices: 0,
        departmentCounts: {},
        displayedItems: [],
        allServices: [],
      );

  DashboardAdminState copyWith({
    bool? bootstrapping,
    bool? bootstrapped,
    bool? loadError,
    String? selectStatus,
    bool? showRequests,
    bool? showAll,
    bool? isLoading,
    bool? isLoadingFirst,
    bool? isLoadingRequests,
    bool? isLoadingServicesName,
    bool? isLoadingDepartments,
    bool? isServiceListLoading,
    Map<String, int>? statusCounts,
    Map<int, double>? monthCounts,
    Map<int, num>? monthHours,
    Map<int, double>? serviceUsageCounts,
    Map<String, List<int>>? cancelledByMonth,
    Map<String, List<int>>? rejectedByMonth,
    bool? showServiceCount,
    List<String>? serviceNames,
    List<String>? serviceNamesArabic,
    int? totalServices,
    Map<String, int>? departmentCounts,
    List<Map<String, dynamic>>? displayedItems,
    List<Map<String, dynamic>>? allServices,
  }) {
    return DashboardAdminState(
      bootstrapping: bootstrapping ?? this.bootstrapping,
      bootstrapped: bootstrapped ?? this.bootstrapped,
      loadError: loadError ?? this.loadError,
      selectStatus: selectStatus ?? this.selectStatus,
      showRequests: showRequests ?? this.showRequests,
      showAll: showAll ?? this.showAll,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFirst: isLoadingFirst ?? this.isLoadingFirst,
      isLoadingRequests: isLoadingRequests ?? this.isLoadingRequests,
      isLoadingServicesName:
          isLoadingServicesName ?? this.isLoadingServicesName,
      isLoadingDepartments: isLoadingDepartments ?? this.isLoadingDepartments,
      isServiceListLoading: isServiceListLoading ?? this.isServiceListLoading,
      statusCounts: statusCounts ?? this.statusCounts,
      monthCounts: monthCounts ?? this.monthCounts,
      monthHours: monthHours ?? this.monthHours,
      serviceUsageCounts: serviceUsageCounts ?? this.serviceUsageCounts,
      cancelledByMonth: cancelledByMonth ?? this.cancelledByMonth,
      rejectedByMonth: rejectedByMonth ?? this.rejectedByMonth,
      showServiceCount: showServiceCount ?? this.showServiceCount,
      serviceNames: serviceNames ?? this.serviceNames,
      serviceNamesArabic: serviceNamesArabic ?? this.serviceNamesArabic,
      totalServices: totalServices ?? this.totalServices,
      departmentCounts: departmentCounts ?? this.departmentCounts,
      displayedItems: displayedItems ?? this.displayedItems,
      allServices: allServices ?? this.allServices,
    );
  }
}
