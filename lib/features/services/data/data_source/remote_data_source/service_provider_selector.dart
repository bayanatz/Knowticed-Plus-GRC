/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: service_provider_selector.dart
/// Purpose: Pure provider-selection logic extracted from ServicesManagerCubit
///          (workload balancing / round-robin candidate picking).
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/dashboard_metrics.dart';
import 'package:knowticed_plus/features/services/domain/enums/service_duration_unit.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// Encapsulates the algorithm that chooses which provider a new request is
/// assigned to, based on historical workload. Holds no UI/cubit state.
class ServiceProviderSelector {
  ServiceProviderSelector({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> selectProviderForNewRequest({
    required List<ServiceEmployeeModel> providers,
    String? parentServiceId,
  }) async {
    if (providers.isEmpty) return null;
    if (providers.length == 1) {
      return convertEmployeeToMap(providers.first);
    }

    try {
      if (parentServiceId != null && parentServiceId.isNotEmpty) {
        // ✅ Query the RequestServices collection directly.
        // ⚠️ Must use the Firestore key, not the Dart property name.
        // 'parentServiceId' matched nothing, so history was always empty and
        // every provider tied at 0 workload → the same person won every time.
        final historicalDocs = await _firestore
            .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
            .where(
              ServicesHistoryKeys.kParentServiceId,
              arrayContains: parentServiceId,
            )
            .get();

        final candidates = providers
            .map(
              (e) => {
                'email': e.email ?? '',
                'firstName': e.firstName ?? '',
                'lastName': e.lastName ?? '',
                'firstNameInArabic': e.firstNameInArabic ?? '',
                'lastNameInArabic': e.lastNameInArabic ?? '',
              },
            )
            .where((m) => (m['email'] ?? '').toString().isNotEmpty)
            .toList();

        return selectProviderByTotalWorkload(
          candidates: candidates,
          allHistoricalDocs: historicalDocs.docs,
        );
      }
    } catch (e, s) {
      // Silently swallowing this is what hid the field-name bug for so long.
      svcLog(
        '❌ selectProviderForNewRequest failed, '
        'falling back to providers.first: $e',
      );
      svcLog('stack', stackTrace: s);
    }

    return convertEmployeeToMap(providers.first);
  }

  Map<String, dynamic> convertEmployeeToMap(ServiceEmployeeModel employee) {
    return {
      'id': employee.id ?? '',
      'email': employee.email ?? '',
      'firstName': employee.firstName ?? '',
      'lastName': employee.lastName ?? '',
      'firstNameInArabic': employee.firstNameInArabic ?? '',
      'lastNameInArabic': employee.lastNameInArabic ?? '',
      'middleName': employee.middleName ?? '',
      'middleNameInArabic': employee.middleNameInArabic ?? '',
      'departmentId': employee.departmentId ?? '',
      'title': employee.title ?? '',
      'titleInArabic': employee.titleInArabic ?? '',
      'role': employee.role ?? '',
      'gender': employee.gender ?? '',
      'workLocation': employee.workLocation ?? '',
      'status': employee.status ?? 'active',
    };
  }

  /// The provider to show / assign for a service, by the module's ONE
  /// picking rule ([selectProviderForNewRequest]: lowest total workload).
  Future<Map<String, dynamic>?> computeProvider({
    required List<ServiceEmployeeModel> providerServices,
    String? parentServiceId,
  }) {
    return selectProviderForNewRequest(
      providers: providerServices,
      parentServiceId: parentServiceId,
    );
  }

  Map<String, dynamic>? selectProviderByTotalWorkload({
    required List<Map<String, dynamic>> candidates,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>>
        allHistoricalDocs,
  }) {
    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.first;

    final Map<String, double> totalWorkload = {};
    final Map<String, int> totalAssignments = {};

    for (final candidate in candidates) {
      final email = (candidate['email'] ?? '').toString().toLowerCase();
      totalWorkload[email] = 0.0;
      totalAssignments[email] = 0;
    }

    for (final doc in allHistoricalDocs) {
      final data = doc.data();

      // ⚠️ Firestore keys, not Dart property names. Reading
      // 'assignedProviderEmail' / 'provider' always missed, so every
      // provider's workload stayed at 0.
      final assignedEmail = _lastString(
        data[ServicesHistoryKeys.kAssignedProviderEmail],
      ).toLowerCase();

      if (assignedEmail.isNotEmpty &&
          totalWorkload.containsKey(assignedEmail)) {
        final minutes = calculateWorkloadMinutes(data);
        totalWorkload[assignedEmail] =
            (totalWorkload[assignedEmail] ?? 0) + minutes;
        totalAssignments[assignedEmail] =
            (totalAssignments[assignedEmail] ?? 0) + 1;
      }
    }

    final sortedCandidates = List<Map<String, dynamic>>.from(candidates);
    sortedCandidates.sort((a, b) {
      final emailA = (a['email'] ?? '').toString().toLowerCase();
      final emailB = (b['email'] ?? '').toString().toLowerCase();

      final workloadA = totalWorkload[emailA] ?? 0.0;
      final workloadB = totalWorkload[emailB] ?? 0.0;

      if (workloadA != workloadB) {
        return workloadA.compareTo(workloadB);
      }

      final assignmentsA = totalAssignments[emailA] ?? 0;
      final assignmentsB = totalAssignments[emailB] ?? 0;
      if (assignmentsA != assignmentsB) {
        return assignmentsA.compareTo(assignmentsB);
      }

      return emailA.compareTo(emailB);
    });

    // ⚠️ Without this, providers tied on workload AND assignment count always
    // resolve alphabetically — so the alphabetically-first provider took every
    // request. Break genuine ties at random, like pickProviderFromRecentDocs.
    final best = sortedCandidates.first;
    final bestEmail = (best['email'] ?? '').toString().toLowerCase();
    final bestWorkload = totalWorkload[bestEmail] ?? 0.0;
    final bestAssignments = totalAssignments[bestEmail] ?? 0;

    final tied = sortedCandidates.where((c) {
      final e = (c['email'] ?? '').toString().toLowerCase();
      return (totalWorkload[e] ?? 0.0) == bestWorkload &&
          (totalAssignments[e] ?? 0) == bestAssignments;
    }).toList();

    if (tied.length <= 1) return best;

    tied.shuffle(Random());
    return tied.first;
  }

  /// Reads the newest entry of a Firestore field that may be stored either as
  /// a history list (this module's convention) or as a bare scalar.
  static String _lastString(dynamic raw) {
    if (raw == null) return '';
    if (raw is List) return raw.isEmpty ? '' : raw.last.toString().trim();
    return raw.toString().trim();
  }

  double calculateWorkloadMinutes(Map<String, dynamic> data) {
    // ⚠️ Firestore keys ('Duration_Of_Services' / 'Selected_Duration_Unit'),
    // not the camelCase Dart property names.
    final value = double.tryParse(
          _lastString(data[ServicesHistoryKeys.kDurationOfServices]),
        ) ??
        0.0;

    var unit = _lastString(data[ServicesHistoryKeys.kSelectedDurationUnit]);
    if (unit.isEmpty) unit = ServiceDurationUnit.minute.key;

    // One unit parser for the module (English or Arabic units).
    return DashboardMetrics.toHours(value, unit) * 60;
  }
}
