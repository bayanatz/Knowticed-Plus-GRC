/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: requests_cubit.dart
/// Description: Loads, submits and decides change requests for the settings pages.
/// Author: Amr Mesbah
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N02 / N04. Replaces the Firestore chains and `try`
/// blocks the four pages held, and the `GetxController` + `StateMixin` +
/// `RxStatus` controller beside them.
library;

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/settings_notification_service.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/repository/requests_repository.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/base_repository/requests_base_repository.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';
// ADDED 9/10/2026 — SelfApprovalFailure → RequestsState.userMessage.
import 'package:knowticed_plus/features/settings/se6_requests/domain/rules/self_approval_rule.dart';

part 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  RequestsCubit({RequestsBaseRepository? repository})
      : repository = repository ?? RequestsRepository(),
        super(const RequestsState());

  /// Typed as the domain contract so it can be faked in tests.
  final RequestsBaseRepository repository;
  final LiveRefresh _live = LiveRefresh();
  String? _liveEmployeeId;
  String? _liveRequestId;

  /// Reloads whatever list / detail this cubit last loaded, without a spinner.
  void _watchRequests() {
    _live.watchPaths(<String>[
      '${RequestCollectionPaths.rolesDoc}/'
          '${RequestCollectionPaths.requestsCollection}',
    ], () {
      final String? employeeId = _liveEmployeeId;
      final String? requestId = _liveRequestId;
      if (employeeId != null) loadForEmployee(employeeId, silent: true);
      if (requestId != null) loadRequest(requestId, silent: true);
    });
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  @override
  void emit(RequestsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Drops the one-shot flags after the page has shown them.
  void clearMessages() => emit(state.consumed());

  /// Function Name: [loadForEmployee]
  ///
  /// Purpose: Load one employee's requests into [RequestsState.requests].
  Future<void> loadForEmployee(String employeeId, {bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: RequestsStatus.loading));

    final Either<Failure, List<ChangeRequest>> result =
        await repository.getRequestsForEmployee(employeeId);

    if (silent && result.isLeft()) return;
    emit(
      result.fold(
        (Failure failure) => state.copyWith(
          status: RequestsStatus.failure,
          errorMessage: failure.errMessage,
        ),
        (List<ChangeRequest> requests) =>
            state.copyWith(status: RequestsStatus.success, requests: requests),
      ),
    );
    _liveEmployeeId = employeeId;
    _watchRequests();
  }

  /// Function Name: [loadRequest]
  ///
  /// Purpose: Load one request into [RequestsState.selected].
  Future<void> loadRequest(String requestId, {bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: RequestsStatus.loading));

    final Either<Failure, ChangeRequest?> result = await repository.getRequest(
      requestId,
    );

    if (silent && result.isLeft()) return;
    emit(
      result.fold(
        (Failure failure) => state.copyWith(
          status: RequestsStatus.failure,
          errorMessage: failure.errMessage,
        ),
        (ChangeRequest? request) =>
            state.copyWith(status: RequestsStatus.success, selected: request),
      ),
    );
    _liveRequestId = requestId;
    _watchRequests();
  }

  /// Function Name: [submit]
  ///
  /// Purpose: Raise a new change request.
  ///
  /// Parameters:
  /// - [section]: the settings section the edits came from, e.g.
  ///   `Personal Information`, `Health Insurance` or `Emergency Contact`.
  /// - [changes]: one entry per edited field.
  /// - [isArabic]: language the reviewers' notification is sent in.
  ///
  /// Returns: [Future<bool>] — `true` on success, so the page can drive its own
  ///          dialog flow without inspecting state.
  ///
  /// ADDED 24/8/2026: on success this notifies everyone who may review the
  /// request. `SettingsNotificationService.changeRequestSubmitted` had zero
  /// call sites, so a submitted request sat in the queue with nobody told it
  /// was there.
  Future<bool> submit({
    required String section,
    required String employeeId,
    required String employeeName,
    required String employeeEmail,
    required String requestNote,
    required List<FieldChange> changes,
    bool isArabic = false,
  }) =>
      submitMany(
        parts: <({String section, List<FieldChange> changes})>[
          (section: section, changes: changes),
        ],
        employeeId: employeeId,
        employeeName: employeeName,
        employeeEmail: employeeEmail,
        requestNote: requestNote,
        isArabic: isArabic,
      );

  /// Function Name: [submitMany]
  ///
  /// Purpose: Raise one request per [parts] entry as ONE write
  ///          (CR-KNP-SET-HR-05, 20/10/2026). The Health Insurance page files
  ///          up to two sections from one form; before this it called
  ///          [submit] twice, so a failure on the second left the first
  ///          already in the reviewers' queue with no way to undo it.
  ///
  /// Parts with no changes are dropped; if nothing is left the call fails
  /// like an empty [submit] would.
  Future<bool> submitMany({
    required List<({String section, List<FieldChange> changes})> parts,
    required String employeeId,
    required String employeeName,
    required String employeeEmail,
    required String requestNote,
    bool isArabic = false,
  }) async {
    emit(state.copyWith(status: RequestsStatus.loading));

    final List<ChangeRequest> requests = parts
        .where((({String section, List<FieldChange> changes}) p) =>
            p.changes.isNotEmpty)
        .map((({String section, List<FieldChange> changes}) p) => ChangeRequest(
              section: p.section,
              employeeId: employeeId,
              employeeName: employeeName,
              employeeEmail: employeeEmail,
              requestNote: requestNote,
              changes: p.changes,
            ))
        .toList();

    final Either<Failure, List<String>> result =
        await repository.submitRequests(requests);

    // The new requests' ids, in [requests] order, for the notifications.
    final List<String> ids = result.getOrElse(() => const <String>[]);

    final bool ok = result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            status: RequestsStatus.failure,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(state.copyWith(status: RequestsStatus.success, submitted: true));
        return true;
      },
    );

    if (ok) {
      for (int i = 0; i < requests.length; i++) {
        final ChangeRequest request = requests[i];
        await _notifyReviewers(
          requestId: i < ids.length ? ids[i] : '',
          section: request.section,
          employeeEmail: employeeEmail,
          employeeName: employeeName,
          isArabic: isArabic,
        );
      }
    }

    return ok;
  }

  /// Function Name: [_notifyReviewers]
  ///
  /// Purpose: Tell everyone who may review change requests that one is waiting.
  ///
  /// The audience is resolved inside the notification service — see
  /// `SettingsNotificationService`. A failure here never fails the submission:
  /// the request document is already written, and a missing notification must
  /// not report the submission as broken.
  Future<void> _notifyReviewers({
    required String requestId,
    required String section,
    required String employeeEmail,
    required String employeeName,
    required bool isArabic,
  }) async {
    if (employeeEmail.isEmpty) return;

    try {
      await SettingsNotificationService.changeRequestSubmitted(
        requestId: requestId,
        section: section,
        employeeEmail: employeeEmail,
        employeeName: employeeName,
        isArabic: isArabic,
      );
    } catch (e) {
      // CR-KNP-SET-HR-07 (20/10/2026): never fails the submission, but no
      // longer silent either — logged, and surfaced as a one-shot warning the
      // page shows as a snackbar.
      debugPrint('Change request submitted; reviewer notification failed: $e');
      emit(state.copyWith(warning: _notificationWarning(isArabic)));
    }
  }

  /// The one sentence both notification paths show when the write succeeded
  /// but the notification did not (HR-07).
  static String _notificationWarning(bool isArabic) => isArabic
      ? 'تم الحفظ، لكن تعذّر إرسال الإشعار.'
      : 'Saved, but the notification could not be sent.';

  /// Function Name: [approve]
  ///
  /// Purpose: Apply a request to the employee profile and mark it approved.
  ///
  /// Returns: [Future<bool>] — `false` leaves the request pending.
  /// Parameters:
  /// - [approverEmail] / [isArabic]: passed through to the employee's
  ///   notification. Optional so existing callers keep compiling; without an
  ///   approver email there is no sender, so no notification is sent.
  ///
  /// CHANGED 9/10/2026: [approverEmail] (and [approverEmployeeId]) now also go
  /// to the repository's self-approval check. Without an approver email the
  /// approval is REFUSED (fail closed), not just left un-notified.
  Future<bool> approve({
    required ChangeRequest request,
    required String employeeId,
    String approverEmail = '',
    String approverEmployeeId = '',
    bool isArabic = false,
    String approvalReason = '',
  }) async {
    emit(state.copyWith(status: RequestsStatus.loading));

    final Either<Failure, List<String>> result =
        await repository.approveRequest(
      request: request,
      employeeId: employeeId,
      approverEmail: approverEmail,
      approverEmployeeId: approverEmployeeId,
      reason: approvalReason,
    );

    // CR-KNP-SET-HR-03 (20/10/2026): fields the profile could not store are
    // no longer dropped on the floor — the reviewer is told which ones.
    final List<String> skipped =
        result.fold((_) => const <String>[], (List<String> s) => s);

    final bool ok = await _finishDecision(
      result.map((_) {}),
      request,
      RequestStatus.approved,
      approverEmail: approverEmail,
      isArabic: isArabic,
    );
    if (ok && skipped.isNotEmpty) {
      emit(state.copyWith(
        warning: isArabic
            ? 'تمت الموافقة، لكن تعذّر تطبيق: ${skipped.join('، ')}'
            : 'Approved, but these fields could not be applied: '
                '${skipped.join(', ')}',
      ));
    }
    return ok;
  }

  /// Function Name: [setStatus]
  ///
  /// Purpose: Move a request to [status] — reject or cancel. The employee
  ///          profile is untouched; only [approve] writes it.
  ///
  /// CHANGED 9/10/2026: a reject is checked by the repository's self-approval
  /// rule with [approverEmail] / [approverEmployeeId]; cancel is not.
  Future<bool> setStatus(
    ChangeRequest request,
    RequestStatus status, {
    String approverEmail = '',
    String approverEmployeeId = '',
    bool isArabic = false,
    String rejectionReason = '-',
  }) async {
    emit(state.copyWith(status: RequestsStatus.loading));

    final Either<Failure, void> result = await repository.setRequestStatus(
      requestId: request.id,
      status: status,
      reason: rejectionReason == '-' ? '' : rejectionReason,
      deciderEmail: approverEmail,
      deciderEmployeeId: approverEmployeeId,
    );

    return _finishDecision(
      result,
      request,
      status,
      approverEmail: approverEmail,
      isArabic: isArabic,
      rejectionReason: rejectionReason,
    );
  }

  /// Function Name: [reject]
  ///
  /// Purpose: Mark a request rejected.
  Future<bool> reject(
    ChangeRequest request, {
    String approverEmail = '',
    String approverEmployeeId = '',
    bool isArabic = false,
    String rejectionReason = '-',
  }) =>
      setStatus(
        request,
        RequestStatus.rejected,
        approverEmail: approverEmail,
        approverEmployeeId: approverEmployeeId,
        isArabic: isArabic,
        rejectionReason: rejectionReason,
      );

  Future<bool> _finishDecision(
    Either<Failure, void> result,
    ChangeRequest request,
    RequestStatus status, {
    String approverEmail = '',
    bool isArabic = false,
    String rejectionReason = '-',
  }) async {
    final bool ok = result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            status: RequestsStatus.failure,
            errorMessage: failure.errMessage,
            // 9/10/2026 — a blocked self-approval carries a localized message
            // the screen shows as-is.
            userMessage:
                failure is SelfApprovalFailure ? failure.errMessage : null,
          ),
        );
        return false;
      },
      (_) {
        final ChangeRequest updated = request.copyWith(status: status);
        emit(
          state.copyWith(
            status: RequestsStatus.success,
            selected: updated,
            requests: state.requests
                .map((ChangeRequest r) => r.id == updated.id ? updated : r)
                .toList(),
            decided: true,
          ),
        );
        return true;
      },
    );

    if (ok) {
      await _notifyEmployee(
        request: request,
        status: status,
        approverEmail: approverEmail,
        isArabic: isArabic,
        rejectionReason: rejectionReason,
      );
    }
    return ok;
  }

  /// Function Name: [_notifyEmployee]
  ///
  /// Purpose: Tell the employee their change request was approved or rejected.
  ///
  /// The one choke point every decision passes through, so approve, reject and
  /// the `reject` shorthand all notify without repeating themselves. Cancelling
  /// sends nothing: the employee cancelled it themselves, and the catalog has
  /// no cancelled event.
  ///
  /// A failure here never fails the decision — the status change is already
  /// written, and a missing notification must not report the approval as
  /// broken. `AppNotificationSender` swallows its own errors; the catch is for
  /// anything thrown before it is reached.
  Future<void> _notifyEmployee({
    required ChangeRequest request,
    required RequestStatus status,
    required String approverEmail,
    required bool isArabic,
    required String rejectionReason,
  }) async {
    if (approverEmail.isEmpty || request.employeeEmail.isEmpty) return;

    try {
      if (status == RequestStatus.approved) {
        await SettingsNotificationService.changeRequestApproved(
          requestId: request.id,
          section: request.section,
          employeeEmail: request.employeeEmail,
          approverEmail: approverEmail,
          isArabic: isArabic,
        );
      } else if (status == RequestStatus.rejected) {
        await SettingsNotificationService.changeRequestRejected(
          requestId: request.id,
          section: request.section,
          employeeEmail: request.employeeEmail,
          approverEmail: approverEmail,
          reason: rejectionReason,
          isArabic: isArabic,
        );
      }
    } catch (e) {
      // CR-KNP-SET-HR-07 (20/10/2026): the decision stands, but the failure
      // is logged and shown as a one-shot warning instead of swallowed.
      debugPrint(
          'Request ${request.id} decided; employee notification failed: $e');
      emit(state.copyWith(warning: _notificationWarning(isArabic)));
    }
  }
}
