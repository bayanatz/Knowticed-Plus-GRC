/// Module: services / sv6_services_requests / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: new_request_cubit.dart
/// Purpose: Creates a request for a service: builds the request and its
///          record under the service, saves both in one batch (through
///          ServicesManagerCubit.submitNewRequest, which also picks the
///          provider), refreshes the request lists and notifies the
///          requester and the first approver. Used by the service details
///          page and the request button on each service card, which used to
///          each keep their own copy of this logic inside a button callback.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// Where the request creation is.
enum NewRequestStatus { idle, submitting, success, notSignedIn, failure }

class NewRequestCubit extends Cubit<NewRequestStatus> {
  /// All dependencies are injected by the page.
  NewRequestCubit({
    required this.manager,
    required this.notifications,
    required this.requester,
  }) : super(NewRequestStatus.idle);

  /// Saves the request and keeps the module's request lists.
  final ServicesManagerCubit manager;
  final ServicesNotificationService notifications;

  /// The signed-in employee, or null when nobody is signed in.
  final EmployeeEntityPro? requester;

  // Guards every emit against the cubit being closed mid-await.
  @override
  void emit(NewRequestStatus state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [submit]
  ///
  /// Purpose: Creates a request for [service]. A service without approvers
  /// starts approved, otherwise pending. Notifications are sent after the
  /// save and never decide the result.
  ///
  /// Parameters:
  /// - [service]: the service being requested.
  ///
  /// Returns: [NewRequestStatus.success], [NewRequestStatus.notSignedIn] or
  /// [NewRequestStatus.failure] (also emitted).
  Future<NewRequestStatus> submit(ServicesHistoryModel service) async {
    final employee = requester;
    final email = employee?.email ?? '';
    if (employee == null || email.isEmpty) {
      emit(NewRequestStatus.notSignedIn);
      return NewRequestStatus.notSignedIn;
    }
    emit(NewRequestStatus.submitting);

    final approvers = service.currentApprovalCycle;
    final initialState =
        approvers.isEmpty ? RequestStatus.approved : RequestStatus.pending;
    final request = ServicesHistoryFactory.createMinimalRequest(
      parentServiceId: service.currentId,
      id: service.currentId,
      providerServices: service.currentProviderServices,
      emailRequester: email,
      approvalCycle: approvers,
      state: initialState,
      status: 'active',
    );
    final nameEnglish =
        '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim();
    final nameArabic =
        '${employee.firstNameInArabic ?? employee.firstName ?? ''} '
                '${employee.lastNameInArabic ?? employee.lastName ?? ''}'
            .trim();
    final record = RequestedServices(
      id: request.currentId,
      requestDate: DateFormat('MMMdd_yyyy').format(DateTime.now()),
      serviceProvider: request.currentProviderServices,
      serviceRequester: nameEnglish,
      status: 'Active',
      state: initialState,
    );

    final saved = await manager.submitNewRequest(
      requestDocId: manager.newRequestId(),
      request: request,
      record: record,
    );
    if (!saved) {
      emit(NewRequestStatus.failure);
      return NewRequestStatus.failure;
    }

    try {
      await manager.getMyRequestServices();
      await manager.getMyApprovalServices(email);
    } catch (e) {
      if (kDebugMode) svcLog('Refreshing the request lists failed: $e');
    }

    await _notify(
      requestId: request.currentId,
      service: service,
      requesterEmail: email,
      requesterNameEnglish: nameEnglish,
      requesterNameArabic: nameArabic,
    );

    emit(NewRequestStatus.success);
    return NewRequestStatus.success;
  }

  /// SVC-REQ-08: true when the last submitted request was saved but the
  /// confirmation or the first approver's notification could not be sent.
  bool lastNotificationFailed = false;

  Future<void> _notify({
    required String requestId,
    required ServicesHistoryModel service,
    required String requesterEmail,
    required String requesterNameEnglish,
    required String requesterNameArabic,
  }) async {
    final serviceEnglish = service.currentServiceNameEnglish;
    final serviceArabic = service.currentServiceNameArabic;
    lastNotificationFailed = false;

    final sent = await notifications.notifyRequesterOfSubmission(
      requestId: requestId,
      senderEmail: requesterEmail,
      requesterEmail: requesterEmail,
      serviceName: serviceEnglish,
      serviceNameArabic: serviceArabic,
      isArabic: false,
    );
    if (!sent) {
      lastNotificationFailed = true;
      svcLog('The request confirmation was not sent');
    }

    final approvers = service.currentApprovalCycle;
    final firstApprover =
        approvers.isEmpty ? '' : (approvers.first.email ?? '');
    if (firstApprover.isEmpty) return;
    final notified = await notifications.notifyApproverOfNewRequest(
      requestId: requestId,
      senderEmail: requesterEmail,
      approverEmail: firstApprover,
      serviceName: serviceEnglish,
      serviceNameArabic: serviceArabic,
      requesterName: requesterNameEnglish,
      requesterNameArabic: requesterNameArabic,
      isArabic: false,
    );
    if (!notified) {
      lastNotificationFailed = true;
      svcLog('The approval request was not sent');
    }
  }
}
