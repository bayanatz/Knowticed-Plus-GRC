/// Module: services / sv6_services_requests / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_cubit.dart
/// Purpose: Cubit for the "My requests" page: loads the signed-in user's
///          requests, counts them per status and applies the status,
///          department, search, date and sort filters. It has no
///          BuildContext and no text controller; the page owns those and
///          calls these methods.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/domain/enums/request_sort.dart';
import 'package:knowticed_plus/features/services/domain/enums/service_duration_unit.dart';
import 'package:knowticed_plus/features/services/helpers/services_status_chips.dart';
import 'package:knowticed_plus/features/services/presentation/controller/request_details_lookup.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/my_request_state.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

class MyRequestCubit extends Cubit<MyRequestState> {
  final LiveRefresh _live = LiveRefresh();

  /// All dependencies are injected by the page.
  MyRequestCubit({
    required this.repository,
    required this.departments,
    required this.requesterEmail,
    required this.requester,
  }) : super(const MyRequestInitial());

  final CreateServicesRepository repository;
  final MainCoreDepartmentCubit departments;

  /// E-mail of the signed-in user, whose requests are counted.
  final String requesterEmail;

  /// The signed-in user; their department is shown when a request has none.
  final RequesterInfo requester;

  Map<String, int> _counts = const {};
  int _total = 0;

  // Guards every emit against the cubit being closed mid-await.
  @override
  void emit(MyRequestState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [loadAllData]
  ///
  /// Purpose: Loads the user's requests and their per-status counts, then
  /// shows all of them sorted by request date. Emits [MyRequestError] when
  /// the read fails.
  Future<void> loadAllData({bool silent = false}) async {
    if (!silent) emit(const MyRequestLoading());
    try {
      final services = await repository.getMyRequestServices();
      final forCounts = await repository.getMyRequestServicesByRequester(
        requesterEmail,
      );
      _countStatuses(forCounts);
      final MyRequestLoaded? current = _loaded;
      if (silent && current != null) {
        // Live refresh keeps the user's current search / status / sort.
        _filter(
          services: services,
          status: current.selectedStatus,
          departmentKeys: current.selectedDepartmentKeys,
          sort: current.selectedSort,
          query: current.searchQuery,
        );
      } else {
        _filter(
          services: services,
          status: kServicesAllStatus,
          departmentKeys: const [],
          sort: RequestSort.dateRequested,
          query: '',
        );
      }
      _live.watchPaths([
        getBaseUrl(FirestoreCollections.requestServicesRoot),
        getBaseUrl(FirestoreCollections.createServicesRoot),
      ], () => loadAllData(silent: true));
    } catch (e) {
      if (kDebugMode) svcLog('MyRequestCubit.loadAllData failed: $e');
      if (!silent) emit(const MyRequestError());
    }
  }

  void _countStatuses(List<ServicesHistoryModel> requests) {
    final counts = {for (final status in RequestStatus.all) status: 0};
    for (final request in requests) {
      final status = RequestStatus.of(request);
      counts[status] = (counts[status] ?? 0) + 1;
    }
    _counts = counts;
    _total = requests.length;
  }

  MyRequestLoaded? get _loaded {
    final current = state;
    return current is MyRequestLoaded ? current : null;
  }

  /// Function Name: [search]
  ///
  /// Purpose: Filters by service name or point of contact.
  ///
  /// Parameters:
  /// - [query]: the search text.
  void search(String query) {
    final current = _loaded;
    if (current == null) return;
    _filter(
      services: current.services,
      status: current.selectedStatus,
      departmentKeys: current.selectedDepartmentKeys,
      sort: current.selectedSort,
      query: query,
    );
  }

  /// Function Name: [updateStatus]
  ///
  /// Purpose: Shows only requests with [status] ('all' for every status).
  void updateStatus(String status) {
    final current = _loaded;
    if (current == null) return;
    _filter(
      services: current.services,
      status: status,
      departmentKeys: current.selectedDepartmentKeys,
      sort: current.selectedSort,
      query: current.searchQuery,
    );
  }

  /// Function Name: [updateDepartments]
  ///
  /// Purpose: Shows only requests from the selected departments.
  ///
  /// Parameters:
  /// - [departmentKeys]: department ids; empty for every department.
  void updateDepartments(List<String> departmentKeys) {
    final current = _loaded;
    if (current == null) return;
    _filter(
      services: current.services,
      status: current.selectedStatus,
      departmentKeys: departmentKeys,
      sort: current.selectedSort,
      query: current.searchQuery,
    );
  }

  /// Function Name: [updateSort]
  ///
  /// Purpose: Re-sorts the shown requests.
  void updateSort(RequestSort sort) {
    final current = _loaded;
    if (current == null) return;
    _filter(
      services: current.services,
      status: current.selectedStatus,
      departmentKeys: current.selectedDepartmentKeys,
      sort: sort,
      query: current.searchQuery,
    );
  }

  /// Function Name: [applyMobileFilter]
  ///
  /// Purpose: The phone filter dialog: departments (by name, either
  /// language), statuses (any stored spelling) and a request date.
  ///
  /// Parameters:
  /// - [departmentNames]: selected department names; empty for all.
  /// - [statuses]: selected statuses; empty for all.
  /// - [date]: only requests made that day, or null.
  void applyMobileFilter({
    List<String> departmentNames = const [],
    List<String> statuses = const [],
    DateTime? date,
  }) {
    final current = _loaded;
    if (current == null) return;
    final wantedStatuses = statuses.map(RequestStatus.normalize).toSet();
    final wantedDepartments =
        departmentNames.map((name) => name.trim().toLowerCase()).toSet();

    final items = <MyRequestItem>[];
    for (final service in current.services) {
      final item = _item(service);
      final created = _dateRequested(service);
      final matchesDepartment = wantedDepartments.isEmpty ||
          wantedDepartments.contains(item.departmentEnglish.toLowerCase()) ||
          wantedDepartments.contains(item.departmentArabic.toLowerCase());
      final matchesStatus =
          wantedStatuses.isEmpty || wantedStatuses.contains(item.status);
      final matchesDate = date == null ||
          (created.year == date.year &&
              created.month == date.month &&
              created.day == date.day);
      if (matchesDepartment && matchesStatus && matchesDate) items.add(item);
    }

    emit(
      MyRequestLoaded(
        services: current.services,
        displayedItems: items,
        filteredModel: current.filteredModel,
        selectedStatus: current.selectedStatus,
        selectedDepartmentKeys: current.selectedDepartmentKeys,
        selectedSort: current.selectedSort,
        searchQuery: current.searchQuery,
        statusCounts: _counts,
        totalServices: _total,
      ),
    );
  }

  void _filter({
    required List<ServicesHistoryModel> services,
    required String status,
    required List<String> departmentKeys,
    required RequestSort sort,
    required String query,
  }) {
    final search = query.trim().toLowerCase();
    final filtered = <ServicesHistoryModel>[];

    for (final service in services) {
      final providers = service.currentProviderServices;
      final contact = providers.isEmpty
          ? ''
          : '${providers.first.firstName ?? ''} ${providers.first.lastName ?? ''} '
                  '${providers.first.firstNameInArabic ?? ''} ${providers.first.lastNameInArabic ?? ''}'
              .toLowerCase();
      final names = '${service.currentServiceNameEnglish} '
              '${service.currentServiceNameArabic}'
          .toLowerCase();
      final matchesSearch =
          search.isEmpty || contact.contains(search) || names.contains(search);

      final matchesStatus = status == kServicesAllStatus ||
          RequestStatus.of(service) == RequestStatus.normalize(status);

      final departmentId = service.currentDepartmentRequester.trim();
      final matchesDepartment = departmentKeys.isEmpty ||
          _inDepartments(departmentId, departmentKeys);

      if (matchesSearch && matchesStatus && matchesDepartment) {
        filtered.add(service);
      }
    }

    final sorted = List<ServicesHistoryModel>.from(filtered);
    switch (sort) {
      case RequestSort.dateRequested:
        sorted.sort((a, b) => _dateRequested(b).compareTo(_dateRequested(a)));
        break;
      case RequestSort.duration:
        sorted.sort((a, b) => _durationHours(b).compareTo(_durationHours(a)));
        break;
      case RequestSort.lastUpdate:
        sorted.sort((a, b) => _lastUpdate(b).compareTo(_lastUpdate(a)));
        break;
    }

    emit(
      MyRequestLoaded(
        services: services,
        displayedItems: sorted.map(_item).toList(),
        filteredModel: filtered,
        selectedStatus: status,
        selectedDepartmentKeys: departmentKeys,
        selectedSort: sort,
        searchQuery: query,
        statusCounts: _counts,
        totalServices: _total,
      ),
    );
  }

  /// A request matches when its department (stored as an id or, on older
  /// requests, as a name) is one of the selected department ids.
  bool _inDepartments(String departmentValue, List<String> departmentIds) {
    if (departmentValue.isEmpty) return false;
    for (final id in departmentIds) {
      if (departmentValue == id) return true;
      final english = departments.getEnglishDepartmentNameFromDepartmentId(
        departmentId: id,
      );
      final arabic = departments.getArabicDepartmentNameFromDepartmentId(
        departmentId: id,
      );
      if (english != null &&
          departmentValue.toLowerCase() == english.toLowerCase()) {
        return true;
      }
      if (arabic != null && departmentValue == arabic) return true;
    }
    return false;
  }

  MyRequestItem _item(ServicesHistoryModel service) {
    final departmentId = service.currentDepartmentRequester.trim();
    final english = departmentId.isEmpty
        ? requester.departmentEnglish
        : departments.getEnglishDepartmentNameFromDepartmentId(
              departmentId: departmentId,
            ) ??
            departmentId;
    final arabic = departmentId.isEmpty
        ? requester.departmentArabic
        : departments.getArabicDepartmentNameFromDepartmentId(
              departmentId: departmentId,
            ) ??
            departmentId;
    return MyRequestItem(
      model: service,
      status: RequestStatus.of(service),
      departmentEnglish: english,
      departmentArabic: arabic,
    );
  }

  DateTime _dateRequested(ServicesHistoryModel m) => m.timestamps.isEmpty
      ? DateTime.fromMillisecondsSinceEpoch(0)
      : DateTime.fromMillisecondsSinceEpoch(m.timestamps.first);

  /// Last update is the LAST entry of the timestamps history.
  DateTime _lastUpdate(ServicesHistoryModel m) => m.timestamps.isEmpty
      ? DateTime.fromMillisecondsSinceEpoch(0)
      : DateTime.fromMillisecondsSinceEpoch(m.timestamps.last);

  double _durationHours(ServicesHistoryModel m) {
    final value = double.tryParse(m.currentDurationOfServices) ?? 0;
    final unit = ServiceDurationUnit.parse(m.currentSelectedDurationUnit);
    return unit == null ? value : value * unit.hours;
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
