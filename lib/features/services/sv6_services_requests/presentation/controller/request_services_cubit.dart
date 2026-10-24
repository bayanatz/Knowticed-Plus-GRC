/// Module: services / sv6_services_requests / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_services_cubit.dart
/// Purpose: Cubit for the "Service requests" page: keeps the active services
///          the signed-in user may request, counts them per owning
///          department and applies the search and department filters.
///          Departments are compared by id, never by (translated) name. It
///          has no BuildContext; the page passes the services in.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/service_department_access.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/data/department_count_model.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/data/service_filter_model.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/request_services_state.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

class RequestServicesCubit extends Cubit<RequestServicesState> {
  /// All dependencies are injected by the page.
  RequestServicesCubit({
    required this.departmentCubit,
    required this.repository,
    required this.currentUser,
    required this.findEmployee,
  }) : super(RequestServicesInitial()) {
    _filterModel = _filterModel.copyWith(
      userEmail: currentUser?.email ?? '',
      userDepartment: currentUser?.departmentId ?? '',
    );
  }

  /// Key of the "All departments" filter.
  static const String allDepartments = 'All';

  final MainCoreDepartmentCubit departmentCubit;
  final CreateServicesRepository repository;

  /// The signed-in employee, or null before sign-in data is ready.
  final EmployeeEntityPro? currentUser;

  /// Finds an employee in the directory by e-mail, or null.
  final EmployeeEntityPro? Function(String email) findEmployee;

  List<ServicesHistoryModel> _allServices = [];
  List<ServicesHistoryModel> _filteredServices = [];
  ServiceFilterModel _filterModel = ServiceFilterModel.initial();
  DepartmentCountModel _departmentCounts = DepartmentCountModel.empty();
  final Map<String, Map<String, dynamic>?> _providerCache = {};
  Timer? _searchDebounce;

  List<ServicesHistoryModel> get filteredServices => _filteredServices;
  ServiceFilterModel get filterModel => _filterModel;

  /// Number of services per owning-department id.
  DepartmentCountModel get departmentCounts => _departmentCounts;
  Map<String, Map<String, dynamic>?> get providerCache => _providerCache;

  // Guards every emit against the cubit being closed mid-await.
  @override
  void emit(RequestServicesState state) {
    if (isClosed) return;
    super.emit(state);
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  /// Function Name: [startLoading]
  ///
  /// Purpose: Shows the loading state until [loadServices] is called.
  void startLoading() => emit(RequestServicesLoading());

  /// Function Name: [loadServices]
  ///
  /// Purpose: Replaces the services and re-applies the filters.
  ///
  /// Parameters:
  /// - [services]: every request-able service, as loaded by the page.
  void loadServices(List<ServicesHistoryModel> services) {
    _allServices = services;
    applyFilters();
  }

  /// Function Name: [showLoadError]
  ///
  /// Purpose: Shows the load error (the page shows the translated text).
  void showLoadError() => emit(RequestServicesError());

  /// Function Name: [applyFilters]
  ///
  /// Purpose: Applies the search and department filters and recounts the
  /// departments.
  void applyFilters() {
    final query = _filterModel.searchQuery.toLowerCase().trim();
    final selected = _filterModel.selectedDepartment;

    final visible = _allServices.where(_isRequestable).toList();
    _filteredServices = visible.where((service) {
      final names = '${service.currentServiceNameEnglish} '
              '${service.currentServiceNameArabic}'
          .toLowerCase();
      if (query.isNotEmpty && !names.contains(query)) return false;
      if (selected == allDepartments) return true;
      return _departmentIdOf(service) == selected;
    }).toList();

    _recountDepartments(visible);

    emit(
      RequestServicesLoaded(
        filteredServices: _filteredServices,
        departmentCounts: _departmentCounts,
        filterModel: _filterModel,
      ),
    );
  }

  /// Active, published services the user is allowed to see.
  bool _isRequestable(ServicesHistoryModel service) {
    if (service.currentStatus.toLowerCase() != 'active') return false;
    if (service.currentState.toLowerCase() == 'draft') return false;
    return _canUserSeeService(service);
  }

  /// The owning department of a service: the department of the employee
  /// who created it.
  String? _departmentIdOf(ServicesHistoryModel service) {
    final email = service.currentEmailRequester;
    if (email.isEmpty) return null;
    final id = findEmployee(email)?.departmentId;
    return (id == null || id.isEmpty) ? null : id;
  }

  void _recountDepartments(List<ServicesHistoryModel> services) {
    final counts = <String, int>{};
    var total = 0;
    for (final service in services) {
      final id = _departmentIdOf(service);
      if (id == null) continue;
      counts[id] = (counts[id] ?? 0) + 1;
      total++;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _departmentCounts = DepartmentCountModel(
      total: total,
      departmentCounts: Map.fromEntries(sorted),
    );
  }

  /// A service limited to some departments is visible only to those
  /// departments (compared by id).
  bool _canUserSeeService(ServicesHistoryModel service) {
    if (service.currentLimitAvailability != true) return true;
    return ServiceDepartmentAccess.isAllowed(
      allowedDepartments: service.currentSelectDepartment,
      userDepartmentId: currentUser?.departmentId,
      nameToId: (name) => departmentCubit.getDepartmentIdFromDepartmentName(
        departmentName: name,
      ),
    );
  }

  /// Function Name: [searchServices]
  ///
  /// Purpose: Filters by service name, 300 ms after the last key press.
  ///
  /// Parameters:
  /// - [query]: the search text.
  void searchServices(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (isClosed) return;
      _filterModel = _filterModel.copyWith(searchQuery: query);
      applyFilters();
    });
  }

  /// Function Name: [changeDepartmentFilter]
  ///
  /// Purpose: Shows only services of one owning department.
  ///
  /// Parameters:
  /// - [departmentId]: the department id, or [allDepartments].
  void changeDepartmentFilter(String departmentId) {
    _filterModel = _filterModel.copyWith(selectedDepartment: departmentId);
    applyFilters();
  }

  /// Function Name: [getCachedServiceProvider]
  ///
  /// Purpose: The provider a new request for [serviceId] would get, read
  /// once per service through the repository.
  ///
  /// Parameters:
  /// - [serviceId]: the service id.
  ///
  /// Returns: the provider fields, or null.
  Future<Map<String, dynamic>?> getCachedServiceProvider(
    String serviceId,
  ) async {
    if (_providerCache.containsKey(serviceId)) return _providerCache[serviceId];
    try {
      final provider = await repository.selectServiceProvider(serviceId);
      _providerCache[serviceId] = provider;
      return provider;
    } catch (e) {
      if (kDebugMode) svcLog('Provider lookup failed: $e');
      return null;
    }
  }
}
