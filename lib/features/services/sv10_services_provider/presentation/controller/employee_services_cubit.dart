/// Module: services / sv10_services_provider / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: employee_services_cubit.dart
/// Purpose: The provider's request list ("my assigned services"): reads the
///          requests assigned to the provider through the repository, adds
///          the requester's details and the service name, and computes the
///          chip counts, the chip/search filter and the sort (moved here
///          from the page, Provider rule 2).
/// Author: Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 18/10/2026: SVC-PROV-22 — only the provider's requests are read.
///   - 22/10/2026 (Amr Mesbah): no Firestore here (the service name comes
///     from CreateServicesRepository.getParentServiceDetails); counts,
///     filter and sort moved in from the page; field names from
///     ServicesHistoryKeys; Pending and Rejected chips (suggestion 5).
library;

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/controller/employee_services_state.dart';

/// Class Name: [ProviderListKeys]
///
/// Purpose: The chip keys of the provider's list (stable values, never
/// translated text).
abstract final class ProviderListKeys {
  static const String all = 'all';

  /// Statuses the provider's list shows, in chip order (SVC-PROV-14).
  static const List<String> statuses = [
    RequestStatus.done,
    RequestStatus.approved,
    RequestStatus.inProgress,
    RequestStatus.pending,
    RequestStatus.rejected,
    RequestStatus.breachedSla,
    RequestStatus.cancel,
  ];
}

class EmployeeServicesCubit extends Cubit<EmployeeServicesState> {
  final LiveRefresh _live = LiveRefresh();

  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await.
  @override
  void emit(EmployeeServicesState state) {
    if (isClosed) return;
    super.emit(state);
  }

  final MainCoreEmployeeController employeeController;

  /// SVC-PROV-22: requests are read through the repository.
  final CreateServicesRepository repository;

  EmployeeServicesCubit({
    required this.employeeController,
    required this.repository,
  }) : super(const EmployeeServicesLoading());

  List<ServicesHistoryModel> _services = const [];
  String _statusKey = ProviderListKeys.all;
  String _query = '';

  String _first(dynamic value) {
    if (value == null) return '';
    if (value is List) return value.isEmpty ? '' : value[0]?.toString() ?? '';
    return value.toString();
  }

  /// Function Name: [loadAndCacheServices]
  ///
  /// Purpose: Reads the requests assigned to [currentProviderEmail] (the
  /// provider is the LAST entry of the provider history), adds the
  /// requester's names and the service name, then emits the list.
  Future<void> loadAndCacheServices(
    String currentProviderEmail, {
    bool silent = false,
  }) async {
    if (!silent) emit(const EmployeeServicesLoading());

    // Live refresh: watched even while the list is empty so a newly assigned
    // request shows up without a restart.
    _live.watchPaths([
      getBaseUrl(FirestoreCollections.requestServicesRoot),
    ], () => loadAndCacheServices(currentProviderEmail, silent: true));

    final currentEmail = currentProviderEmail.trim().toLowerCase();
    if (currentEmail.isEmpty) {
      _services = const [];
      _emitLoaded();
      return;
    }

    try {
      final docs = await repository.getRequestServiceDocsForProvider(
        currentProviderEmail,
      );
      final assigned = <ServicesHistoryModel>[];
      var skipped = 0;
      for (final doc in docs) {
        try {
          final model = await _readRequest(doc.key, doc.value, currentEmail);
          if (model != null) assigned.add(model);
        } catch (e) {
          // SVC-PROV-11: one bad document must not fail the whole list.
          skipped++;
          svcLog('EmployeeServicesCubit: request ${doc.key} unreadable: $e');
        }
      }
      if (skipped > 0) {
        svcLog('EmployeeServicesCubit: $skipped request(s) could not be read');
      }
      _services = assigned;
      _emitLoaded();
    } catch (e) {
      if (!silent) emit(EmployeeServicesError('Error loading services: $e'));
    }
  }

  /// One request, or null when it is not the provider's current assignment
  /// or has no service name.
  Future<ServicesHistoryModel?> _readRequest(
    String id,
    Map<String, dynamic> data,
    String currentEmail,
  ) async {
    final assignedRaw = data[ServicesHistoryKeys.kAssignedProviderEmail];
    var assignedEmail = '';
    if (assignedRaw is List && assignedRaw.isNotEmpty) {
      assignedEmail = assignedRaw.last?.toString().trim().toLowerCase() ?? '';
    } else if (assignedRaw is String) {
      assignedEmail = assignedRaw.trim().toLowerCase();
    }
    if (assignedEmail.isEmpty || assignedEmail != currentEmail) return null;

    final requesterEmail = _first(data[ServicesHistoryKeys.kEmailRequester]);
    if (requesterEmail.isNotEmpty) {
      final employee = employeeController.getLocaleEmployee(requesterEmail);
      if (employee != null) {
        final nameEn =
            "${employee.firstName ?? ''} ${employee.lastName ?? ''}".trim();
        final nameAr =
            "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}"
                .trim();
        data[ServicesHistoryKeys.kFirstNameRequester] = nameEn.split(' ').first;
        data[ServicesHistoryKeys.kLastNameRequester] =
            nameEn.split(' ').skip(1).join(' ');
        data[ServicesHistoryKeys.kFirstNameRequesterArabic] =
            nameAr.split(' ').first;
        data[ServicesHistoryKeys.kLastNameRequesterArabic] =
            nameAr.split(' ').skip(1).join(' ');
        data[ServicesHistoryKeys.kJobTitleRequester] = employee.title ?? '';
        data[ServicesHistoryKeys.kJobTitleRequesterArabic] =
            employee.titleInArabic ?? '';
        data[ServicesHistoryKeys.kDepartmentRequester] =
            employee.departmentId ?? '';
      }
    }

    bool hasName() =>
        _first(data[ServicesHistoryKeys.kServiceNameEnglish]).isNotEmpty ||
        _first(data[ServicesHistoryKeys.kServiceNameArabic]).isNotEmpty;

    if (!hasName()) {
      final parentServiceId = _first(
        data[ServicesHistoryKeys.kParentServiceId],
      );
      if (parentServiceId.isEmpty || requesterEmail.isEmpty) return null;
      final details = await repository.getParentServiceDetails(parentServiceId);
      String orDash(String v) => v.isEmpty ? '-' : v;
      data[ServicesHistoryKeys.kServiceNameEnglish] = orDash(
        details.nameEnglish,
      );
      data[ServicesHistoryKeys.kServiceNameArabic] = orDash(details.nameArabic);
      data[ServicesHistoryKeys.kServiceDescriptionEnglish] = orDash(
        details.descriptionEnglish,
      );
      data[ServicesHistoryKeys.kServiceDescriptionArabic] = orDash(
        details.descriptionArabic,
      );
      data[ServicesHistoryKeys.kDurationOfServices] = orDash(details.duration);
      data[ServicesHistoryKeys.kSelectedDurationUnit] = orDash(details.unit);
    }
    if (!hasName()) return null;
    return ServicesHistoryModel.fromJson(data, id);
  }

  /// Function Name: [selectStatus]
  ///
  /// Purpose: Shows the requests of one status chip ([ProviderListKeys.all]
  /// for every status).
  void selectStatus(String statusKey) {
    _statusKey = statusKey;
    _emitLoaded();
  }

  /// Function Name: [search]
  ///
  /// Purpose: Filters by service name (English or Arabic).
  void search(String query) {
    _query = query;
    _emitLoaded();
  }

  /// The list's status of a request — the shared rule (SVC-PROV-18/19).
  static String statusOf(ServicesHistoryModel request) =>
      RequestStatus.of(request);

  static int _rank(String status) {
    final index = const [
      RequestStatus.done,
      RequestStatus.approved,
      RequestStatus.inProgress,
      RequestStatus.breachedSla,
      RequestStatus.cancel,
    ].indexOf(status);
    return index < 0 ? 999 : index;
  }

  void _emitLoaded() {
    final counts = <String, int>{
      for (final key in ProviderListKeys.statuses) key: 0,
    };
    for (final s in _services) {
      final status = statusOf(s);
      if (counts.containsKey(status)) counts[status] = counts[status]! + 1;
    }
    // SVC-PROV-14: "All" counts every status the list shows.
    counts[ProviderListKeys.all] = counts.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    final q = _query.trim().toLowerCase();
    final visible = _services.where((service) {
      if (service.currentProviderServices.isEmpty) return false;
      final status = statusOf(service);
      if (!ProviderListKeys.statuses.contains(status)) return false;
      if (_statusKey != ProviderListKeys.all && status != _statusKey) {
        return false;
      }
      return q.isEmpty ||
          service.currentServiceNameEnglish.toLowerCase().contains(q) ||
          service.currentServiceNameArabic.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) {
        final ra = _rank(statusOf(a));
        final rb = _rank(statusOf(b));
        if (ra != rb) return ra.compareTo(rb);
        // SVC-PROV-08: newest first by the date the request was MADE.
        return RequestDates.compareNewestFirst(a, b);
      });

    emit(
      EmployeeServicesLoaded(
        services: _services,
        visible: visible,
        counts: counts,
        statusKey: _statusKey,
        query: _query,
      ),
    );
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
