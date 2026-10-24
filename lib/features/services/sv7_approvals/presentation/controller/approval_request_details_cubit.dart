/// Module: services / sv7_approvals / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request_details_cubit.dart
/// Purpose: Cubit for the approval details page: loads the request's saved
///          comments and status, the requester and the parent service, and
///          approves / rejects through the injected ApprovalDecisionService
///          (the same flow as the approvals list).
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/services/data/models/request_comment_fields.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/approval_decision_service.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/domain/entities/approval_decision.dart';
import 'package:knowticed_plus/features/services/presentation/controller/request_details_lookup.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/controller/approval_request_details_state.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

class ApprovalRequestDetailsCubit extends Cubit<ApprovalRequestDetailsState> {
  final LiveRefresh _live = LiveRefresh();

  // Guards every emit against the cubit being closed mid-await.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository repository;
  final ServicesHistoryModel approvalModel;
  final RequestDetailsLookup lookup;
  final ApprovalDecisionService decisions;

  /// All dependencies are injected by the page.
  ApprovalRequestDetailsCubit({
    required this.repository,
    required this.approvalModel,
    required this.lookup,
    required this.decisions,
  }) : super(const ApprovalRequestDetailsLoading());

  ApprovalRequestDetailsData get _current => state.data;

  /// Function Name: [initialize]
  ///
  /// Purpose: Loads the comments, cancel reason and status, then the
  /// requester and the parent service's details.
  Future<void> initialize({bool silent = false}) async {
    if (silent && isClosed) return;
    if (!silent) emit(const ApprovalRequestDetailsLoading());

    final docId = approvalModel.currentId;

    String rejectComment = '';
    String approveComment = '';
    String? cancelReason;
    String? currentState;

    if (docId.isNotEmpty) {
      Map<String, dynamic>? docData;
      try {
        docData = await repository.getRequestServiceDocById(docId);
      } catch (e) {
        if (kDebugMode) svcLog('Reading the request failed: $e');
      }

      if (docData != null) {
        final rejectRaw = docData['rejectComment'];
        if (rejectRaw != null && rejectRaw.toString().isNotEmpty) {
          rejectComment = rejectRaw.toString();
        }

        final approveRaw = docData['approveComment'];
        if (approveRaw != null && approveRaw.toString().isNotEmpty) {
          approveComment = approveRaw.toString();
        }

        cancelReason = RequestCommentFields.cancelReasonOf(docData);

        // SVC-REQ-10: the CURRENT status is the LAST history entry (the
        // first one is the status the request was created with).
        final stateValue = docData['state'];
        if (stateValue is List && stateValue.isNotEmpty) {
          currentState = stateValue.last?.toString().toLowerCase();
        } else if (stateValue is String) {
          currentState = stateValue.toLowerCase();
        } else {
          currentState = stateValue?.toString().toLowerCase();
        }
      }
    }

    emit(
      ApprovalRequestDetailsLoaded(
        _current.copyWith(
          rejectCommentText: rejectComment,
          approveCommentText: approveComment,
          cancelReason: cancelReason,
          currentState: currentState,
        ),
      ),
    );

    await loadRequesterInfo();
    await loadServiceDataFromCreateServices();
    // Live refresh: the status and comments follow other approvers' decisions.
    _live.watchPaths([
      getBaseUrl(FirestoreCollections.requestServicesRoot),
    ], () => initialize(silent: true));
  }

  /// Function Name: [loadRequesterInfo]
  ///
  /// Purpose: The requester's names, job title and department (both
  /// languages) from the request's saved fields.
  Future<void> loadRequesterInfo() async {
    final docId = approvalModel.currentId;
    if (docId.isEmpty) return;

    Map<String, dynamic>? data;
    try {
      data = await repository.getRequestServiceDocById(docId);
    } catch (e) {
      if (kDebugMode) svcLog('Reading the requester failed: $e');
    }
    if (data == null) return;

    String extractString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List && value.isNotEmpty) {
        return value[0]?.toString() ?? '';
      }
      return value.toString();
    }

    emit(
      ApprovalRequestDetailsLoaded(
        _current.copyWith(
          requesterFirstNameEn: extractString(data['firstNameRequester']),
          requesterLastNameEn: extractString(data['lastNameRequester']),
          requesterJobTitleEn: extractString(data['jobTitleRequester']),
          requesterDepartment: extractString(data['departmentRequester']),
          requesterFirstNameAr: extractString(data['firstNameRequesterArabic']),
          requesterLastNameAr: extractString(data['lastNameRequesterArabic']),
          requesterJobTitleAr: extractString(data['jobTitleRequesterArabic']),
        ),
      ),
    );
  }

  /// Function Name: [loadServiceDataFromCreateServices]
  ///
  /// Purpose: The parent service's current name, description and duration.
  Future<void> loadServiceDataFromCreateServices() async {
    final parentServiceId = approvalModel.currentParentServiceId.isNotEmpty
        ? approvalModel.currentParentServiceId
        : approvalModel.currentId;
    try {
      final details = await lookup.load(
        parentServiceId: parentServiceId,
        requesterEmail: approvalModel.currentEmailRequester,
      );
      final service = details.service;
      emit(
        ApprovalRequestDetailsLoaded(
          _current.copyWith(
            serviceNameEnglish: service.nameEnglish,
            serviceNameArabic: service.nameArabic,
            serviceDescriptionEnglish: service.descriptionEnglish,
            serviceDescriptionArabic: service.descriptionArabic,
            serviceDuration: service.duration,
            serviceDurationUnit: service.unit,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) svcLog('Reading the parent service failed: $e');
    }
  }

  /// Function Name: [refreshModelFromFirestore]
  ///
  /// Purpose: Re-reads the request, e.g. after a provider was assigned.
  ///
  /// Returns: the fresh request, or null when it cannot be read.
  Future<ServicesHistoryModel?> refreshModelFromFirestore() async {
    final docId = approvalModel.currentId;
    if (docId.isEmpty) return null;
    try {
      final data = await repository.getRequestServiceDocById(docId);
      if (data == null) return null;
      return ServicesHistoryModel.fromJson(data, docId);
    } catch (e) {
      if (kDebugMode) svcLog('Re-reading the request failed: $e');
      return null;
    }
  }

  ApprovalRefusal? _lastRefusal;
  bool _lastNotificationFailed = false;

  /// Why the last approve/reject was refused (not pending / not your turn).
  ApprovalRefusal? get lastRefusal => _lastRefusal;

  /// Whether the last decision was saved but a notification failed.
  bool get lastNotificationFailed => _lastNotificationFailed;

  String get _requesterDisplayName {
    final first = approvalModel.currentFirstNameRequester;
    final last = approvalModel.currentLastNameRequester;
    final name = '$first $last'.trim();
    return name.isEmpty ? approvalModel.currentEmailRequester : name;
  }

  String get _requesterDisplayNameArabic =>
      '${approvalModel.currentFirstNameRequesterArabic} '
              '${approvalModel.currentLastNameRequesterArabic}'
          .trim();

  /// Function Name: [approve]
  ///
  /// Purpose: Approves the request on behalf of [approverEmail].
  ///
  /// Returns: whether the decision was saved.
  Future<bool> approve({
    required String approverEmail,
    required String comment,
    required String displayServiceName,
    String displayServiceNameArabic = '',
  }) =>
      _decide(
        approve: true,
        approverEmail: approverEmail,
        comment: comment,
        displayServiceName: displayServiceName,
        displayServiceNameArabic: displayServiceNameArabic,
      );

  /// Function Name: [reject]
  ///
  /// Purpose: Rejects the request on behalf of [approverEmail].
  ///
  /// Returns: whether the decision was saved.
  Future<bool> reject({
    required String approverEmail,
    required String comment,
    required String displayServiceName,
    String displayServiceNameArabic = '',
  }) =>
      _decide(
        approve: false,
        approverEmail: approverEmail,
        comment: comment,
        displayServiceName: displayServiceName,
        displayServiceNameArabic: displayServiceNameArabic,
      );

  Future<bool> _decide({
    required bool approve,
    required String approverEmail,
    required String comment,
    required String displayServiceName,
    required String displayServiceNameArabic,
  }) async {
    final before = _current;
    emit(ApprovalRequestDetailsSubmitting(before));

    final docId = approvalModel.currentId;
    if (docId.isEmpty) {
      emit(ApprovalRequestDetailsLoaded(before));
      return false;
    }

    final outcome = await decisions.decide(
      docId: docId,
      approverEmail: approverEmail,
      approve: approve,
      comment: comment,
      requesterEmail: approvalModel.currentEmailRequester,
      names: ApprovalNames(
        serviceEnglish: displayServiceName,
        serviceArabic: displayServiceNameArabic,
        requesterEnglish: _requesterDisplayName,
        requesterArabic: _requesterDisplayNameArabic,
      ),
    );
    _lastRefusal = outcome.refusal;
    _lastNotificationFailed = outcome.notificationFailed;
    final ok = outcome.saved;

    if (!ok) {
      emit(ApprovalRequestDetailsLoaded(before));
      return false;
    }

    // Re-read the state that was actually saved.
    final fresh = await refreshModelFromFirestore();
    emit(
      ApprovalRequestDetailsLoaded(
        before.copyWith(
          currentState: fresh?.currentState ?? before.currentState,
          approveCommentText: approve ? comment : null,
          rejectCommentText: approve ? null : comment,
        ),
      ),
    );
    return true;
  }

  /// Function Name: [fetchRequestedServiceId]
  ///
  /// Purpose: The `id` of the request's RequestedServices entry named
  /// [serviceName].
  ///
  /// Returns: the id, or '' when there is none.
  Future<String> fetchRequestedServiceId(String? serviceName) async {
    final docId = approvalModel.currentId;
    if (docId.isEmpty) return '';

    final entries = await repository.getRequestedServices(docId: docId);
    for (final entry in entries) {
      if (entry.serviceName == serviceName) {
        return entry.id ?? '';
      }
    }
    return '';
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
