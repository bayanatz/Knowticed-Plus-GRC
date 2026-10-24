/// Module: services / sv6_services_requests / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_details_cubit.dart
/// Purpose: Cubit for the "My request" details page: loads the request's
///          saved status and comments, the parent service's details and the
///          provider, and cancels the request (telling the provider through
///          the services notification template). All reads and writes go
///          through the injected repository and notification service.
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
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/data/utils/history_append.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/my_request_details_state.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

class MyRequestDetailsCubit extends Cubit<MyRequestDetailsState> {
  final LiveRefresh _live = LiveRefresh();

  /// All dependencies are injected by the page.
  MyRequestDetailsCubit({
    required this.repository,
    required this.notifications,
    required this.model,
    required this.requesterEmail,
  }) : super(const MyRequestDetailsLoading());

  final CreateServicesRepository repository;
  final ServicesNotificationService notifications;
  final ServicesHistoryModel model;

  /// E-mail of the signed-in requester.
  final String requesterEmail;

  /// True when the cancellation was saved but the provider could not be
  /// notified.
  bool lastNotificationFailed = false;

  // Guards every emit against the cubit being closed mid-await.
  @override
  void emit(MyRequestDetailsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  void _log(String action, Object error) {
    if (kDebugMode) svcLog('MyRequestDetailsCubit $action failed: $error');
  }

  /// Function Name: [initialize]
  ///
  /// Purpose: Loads the saved status and comments, then the parent service's
  /// details and the provider. A failed read keeps the request's own values.
  Future<void> initialize({bool silent = false}) async {
    if (silent && (isClosed || state is MyRequestDetailsCancelling)) return;
    if (!silent) emit(const MyRequestDetailsLoading());

    var data = const MyRequestDetailsData();
    try {
      final doc = await repository.getRequestServiceDocById(model.currentId);
      if (doc != null) {
        final rawState = doc['state'];
        final current = rawState is List
            ? (rawState.isEmpty ? null : rawState.last?.toString())
            : rawState?.toString();
        data = data.copyWith(
          currentState:
              current == null ? null : RequestStatus.normalize(current),
          cancelReason: RequestCommentFields.cancelReasonOf(doc),
          rejectCommentText: RequestCommentFields.textOf(
            doc,
            RequestCommentFields.rejectComment,
          ),
          approveCommentText: RequestCommentFields.textOf(
            doc,
            RequestCommentFields.approveComment,
          ),
        );
      }
    } catch (e) {
      _log('reading the request', e);
    }
    emit(MyRequestDetailsLoaded(data));

    await _loadServiceDetails();
    await _loadProvider();
    // Live refresh: the status and comments follow the approver's decision.
    _live.watchPaths([
      getBaseUrl(FirestoreCollections.requestServicesRoot),
    ], () => initialize(silent: true));
  }

  Future<void> _loadServiceDetails() async {
    var details = state.data.copyWith(
      serviceNameEnglish: model.currentServiceNameEnglish,
      serviceNameArabic: model.currentServiceNameArabic,
      descriptionEnglish: model.currentServiceDescriptionEnglish,
      descriptionArabic: model.currentServiceDescriptionArabic,
      duration: model.currentDurationOfServices,
      durationUnit: model.currentSelectedDurationUnit,
      isLoadingServiceDetails: false,
    );
    try {
      final parent = await repository.getParentServiceDetails(
        model.currentParentServiceId,
      );
      if (parent.exists) {
        details = details.copyWith(
          serviceNameEnglish: parent.nameEnglish,
          serviceNameArabic: parent.nameArabic,
          descriptionEnglish: parent.descriptionEnglish,
          descriptionArabic: parent.descriptionArabic,
          duration: parent.duration.isEmpty ? null : parent.duration,
          durationUnit: parent.unit.isEmpty ? null : parent.unit,
        );
      }
    } catch (e) {
      _log('reading the parent service', e);
    }
    emit(MyRequestDetailsLoaded(details));
  }

  Future<void> _loadProvider() async {
    try {
      final provider = await repository.resolveRequestProvider(model);
      emit(
        MyRequestDetailsLoaded(
          state.data.copyWith(provider: provider, isLoadingProvider: false),
        ),
      );
    } catch (e) {
      _log('resolving the provider', e);
      emit(
        MyRequestDetailsLoaded(state.data.copyWith(isLoadingProvider: false)),
      );
    }
  }

  /// Function Name: [cancelRequest]
  ///
  /// Purpose: Cancels the request in one write (appends 'cancel' to the
  /// status history with its time and saves the reason), then tells the
  /// provider.
  ///
  /// Parameters:
  /// - [cancellationReason]: the reason the requester typed.
  /// - [serviceName]: the service name for the notification.
  ///
  /// Returns: whether the cancellation was saved.
  Future<bool> cancelRequest({
    required String cancellationReason,
    required String serviceName,
  }) async {
    final before = state.data;
    emit(MyRequestDetailsCancelling(before));
    lastNotificationFailed = false;

    try {
      await repository.updateRequestServiceDoc(model.currentId, {
        'state': HistoryAppend(RequestStatus.cancel),
        'timestamps': HistoryAppend(DateTime.now().millisecondsSinceEpoch),
        RequestCommentFields.cancelComment: cancellationReason,
      });
    } catch (e) {
      _log('cancelling', e);
      emit(MyRequestDetailsCancelError(before));
      return false;
    }

    final providerEmail = before.provider?.email ?? '';
    if (providerEmail.isNotEmpty) {
      lastNotificationFailed =
          !await notifications.notifyProviderOfCancellation(
        requestId: model.currentId,
        senderEmail: requesterEmail,
        providerEmail: providerEmail,
        serviceName: serviceName,
        isArabic: false,
      );
    }

    emit(
      MyRequestDetailsLoaded(
        before.copyWith(
          currentState: RequestStatus.cancel,
          cancelReason: cancellationReason,
        ),
      ),
    );
    return true;
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
