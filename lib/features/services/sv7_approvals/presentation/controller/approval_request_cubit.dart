/// Module: services / sv7_approvals / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request_cubit.dart
/// Purpose: Cubit of the approvals list: the chip counts (its state), the
///          status / department / search filter and the sort (Requests R1:
///          moved here from the page), and the approve / reject buttons.
///          The decision and its notifications are done by the injected
///          ApprovalDecisionService, the same flow the approval details page
///          uses.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/approval_decision_service.dart';
import 'package:knowticed_plus/features/services/domain/entities/approval_decision.dart';
import 'package:knowticed_plus/features/services/domain/entities/parent_service_details.dart';
import 'package:knowticed_plus/features/services/presentation/controller/request_details_lookup.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/controller/approval_request_state.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/domain/enums/request_sort.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/controller/approval_list_rules.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

class ApprovalRequestCubit extends Cubit<ApprovalRequestState> {
  /// [decisions] and [lookup] are created once at the module root.
  ApprovalRequestCubit({required this.decisions, required this.lookup})
      : super(const ApprovalRequestCounts());

  final ApprovalDecisionService decisions;
  final RequestDetailsLookup lookup;

  final Map<String, Future<ParentServiceDetails>> _serviceDetails = {};

  /// Function Name: [serviceDetails]
  ///
  /// Purpose: The current details of the service behind a request, read
  /// once per service and shared by every card of that service.
  ///
  /// Parameters:
  /// - [parentServiceId]: the CreateServices id.
  ///
  /// Returns: the details, or [ParentServiceDetails.empty] when they cannot
  /// be read.
  Future<ParentServiceDetails> serviceDetails(String parentServiceId) {
    return _serviceDetails.putIfAbsent(parentServiceId, () async {
      try {
        return await lookup.repository.getParentServiceDetails(parentServiceId);
      } catch (e) {
        if (kDebugMode) svcLog('Reading the parent service failed: $e');
        _serviceDetails.remove(parentServiceId);
        return ParentServiceDetails.empty;
      }
    });
  }

  /// Function Name: [requester]
  ///
  /// Purpose: The requester's names, job title and department.
  RequesterInfo requester(String email) => lookup.requesterInfo(email);

  /// True when the last approve/reject was saved but at least one
  /// notification could not be sent.
  bool lastNotificationFailed = false;

  /// Why the last approve/reject was refused, if it was.
  ApprovalRefusal? lastRefusal;

  // Guards every emit against the cubit being closed mid-await.
  @override
  void emit(ApprovalRequestState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [recount]
  ///
  /// Purpose: Recomputes the chip counts of [approverEmail] from
  /// [approvals] and emits them.
  void recount(List<ServicesHistoryModel> approvals, String approverEmail) {
    emit(ApprovalListRules.countFor(approvals, approverEmail));
  }

  /// Function Name: [visibleApprovals]
  ///
  /// Purpose: The requests to show: filtered by status chip, departments
  /// (by id) and search text, then sorted by [sort].
  List<ServicesHistoryModel> visibleApprovals({
    required List<ServicesHistoryModel> approvals,
    required String approverEmail,
    required String statusKey,
    required Set<String> departmentIds,
    required String query,
    required RequestSort sort,
  }) {
    final filtered = ApprovalListRules.filter(
      approvals: approvals,
      email: approverEmail,
      statusKey: statusKey,
      departmentIds: departmentIds,
      query: query,
      departmentOf: (email) => lookup.findEmployee(email)?.departmentId,
    );
    return ApprovalListRules.sort(filtered, sort);
  }

  /// Function Name: [approve]
  ///
  /// Purpose: Approves [firestoreDocId] for [approverEmail] and notifies the
  /// requester, the next approver and, on the final approval, the provider.
  ///
  /// Returns: false when nothing was saved (see [lastRefusal]).
  Future<bool> approve({
    required String firestoreDocId,
    required String approverEmail,
    required String comment,
    required String displayServiceName,
    required String displayRequesterName,
    required String? requesterEmail,
    String displayServiceNameArabic = '',
    String displayRequesterNameArabic = '',
  }) {
    return _decide(
      approve: true,
      firestoreDocId: firestoreDocId,
      approverEmail: approverEmail,
      comment: comment,
      names: ApprovalNames(
        serviceEnglish: displayServiceName,
        serviceArabic: displayServiceNameArabic,
        requesterEnglish: displayRequesterName,
        requesterArabic: displayRequesterNameArabic,
      ),
      requesterEmail: requesterEmail,
    );
  }

  /// Function Name: [reject]
  ///
  /// Purpose: Rejects [firestoreDocId] for [approverEmail] and notifies the
  /// requester and the provider.
  ///
  /// Returns: false when nothing was saved (see [lastRefusal]).
  Future<bool> reject({
    required String firestoreDocId,
    required String approverEmail,
    required String comment,
    required String displayServiceName,
    required String displayRequesterName,
    required String? requesterEmail,
    String displayServiceNameArabic = '',
    String displayRequesterNameArabic = '',
  }) {
    return _decide(
      approve: false,
      firestoreDocId: firestoreDocId,
      approverEmail: approverEmail,
      comment: comment,
      names: ApprovalNames(
        serviceEnglish: displayServiceName,
        serviceArabic: displayServiceNameArabic,
        requesterEnglish: displayRequesterName,
        requesterArabic: displayRequesterNameArabic,
      ),
      requesterEmail: requesterEmail,
    );
  }

  Future<bool> _decide({
    required bool approve,
    required String firestoreDocId,
    required String approverEmail,
    required String comment,
    required ApprovalNames names,
    required String? requesterEmail,
  }) async {
    final outcome = await decisions.decide(
      docId: firestoreDocId,
      approverEmail: approverEmail,
      approve: approve,
      comment: comment,
      names: names,
      requesterEmail: requesterEmail,
    );
    lastRefusal = outcome.refusal;
    lastNotificationFailed = outcome.notificationFailed;
    return outcome.saved;
  }
}
