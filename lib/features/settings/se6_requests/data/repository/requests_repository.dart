/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: requests_repository.dart
/// Purpose: Implements [RequestsBaseRepository] over the remote data source.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N01 / N02. This is the legal home for the 17 `try`
/// blocks that were spread across the four pages.
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/data_source/remote_data_source/requests_remote_data_source.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/base_repository/requests_base_repository.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';
// ADDED 9/10/2026 — self-approval block.
import 'package:knowticed_plus/features/settings/se6_requests/domain/rules/self_approval_rule.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestsRepository implements RequestsBaseRepository {
  RequestsRepository({RequestsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? RequestsRemoteDataSource();

  final RequestsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ChangeRequest>>> getRequestsForEmployee(
      String employeeId) async {
    if (employeeId.isEmpty) {
      return Left<Failure, List<ChangeRequest>>(
        FeatureFailure('No employee id available to load requests for.'),
      );
    }

    try {
      return Right<Failure, List<ChangeRequest>>(
        await _remoteDataSource.readForEmployee(employeeId),
      );
    } catch (e) {
      return Left<Failure, List<ChangeRequest>>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChangeRequest?>> getRequest(String requestId) async {
    if (requestId.isEmpty) {
      return Left<Failure, ChangeRequest?>(
        FeatureFailure('No request id was supplied.'),
      );
    }

    try {
      return Right<Failure, ChangeRequest?>(
          await _remoteDataSource.read(requestId));
    } catch (e) {
      return Left<Failure, ChangeRequest?>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markReminderSent(String requestId) async {
    try {
      await _remoteDataSource.markReminderSent(requestId);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitRequest(ChangeRequest request) =>
      submitRequests(<ChangeRequest>[request]);

  @override
  Future<Either<Failure, List<String>>> submitRequests(
      List<ChangeRequest> requests) async {
    if (requests.isEmpty) {
      return Left<Failure, List<String>>(
        FeatureFailure('There are no changes to submit.'),
      );
    }
    for (final ChangeRequest request in requests) {
      if (request.employeeId.isEmpty) {
        return Left<Failure, List<String>>(
          FeatureFailure('Employee ID is not available.'),
        );
      }
      if (request.changes.isEmpty) {
        return Left<Failure, List<String>>(
          FeatureFailure('There are no changes to submit.'),
        );
      }
    }

    try {
      // Confirm the employee exists before logging a request against it — the
      // same guard the submit page performed, kept here so both the personal
      // and health-insurance submit paths share it. One request set is always
      // one employee's, so one check covers all of them.
      if (!await _remoteDataSource.employeeExists(requests.first.employeeId)) {
        return Left<Failure, List<String>>(
          FeatureFailure('Employee document not found.'),
        );
      }

      // One batch for all of them (CR-KNP-SET-HR-05).
      return Right<Failure, List<String>>(
          await _remoteDataSource.createAll(requests));
    } catch (e) {
      return Left<Failure, List<String>>(FirebaseFailure(e.toString()));
    }
  }

  /// Function Name: [_guardDecision]
  ///
  /// Purpose: The self-approval check, run against the STORED request
  ///          (ADDED 9/10/2026, owner decision).
  ///
  /// The screens already hide Approve / Reject on an own request; this is the
  /// second check, so a stale screen, a role switch mid-session or a future
  /// caller cannot get round it. The request is re-read rather than trusted
  /// from the caller, and anything that cannot be verified is refused.
  ///
  /// Returns: `null` when the decision may go ahead, otherwise the
  ///          localized [SelfApprovalFailure] to return. Never throws.
  Future<Failure?> _guardDecision({
    required String requestId,
    required String deciderEmail,
    required String deciderEmployeeId,
  }) async {
    try {
      final ChangeRequest? stored = await _remoteDataSource.read(requestId);

      final SelfApprovalVerdict verdict = stored == null
          ? SelfApprovalVerdict.unverifiable
          : SelfApprovalRule.check(
              requesterEmail: stored.employeeEmail,
              requesterId: stored.employeeId,
              deciderEmail: deciderEmail,
              deciderId: deciderEmployeeId,
            );

      if (verdict.isAllowed) return null;
      return _selfApprovalFailure(verdict);
    } catch (e) {
      // Could not read the request — fail closed.
      return _selfApprovalFailure(SelfApprovalVerdict.unverifiable);
    }
  }

  /// The user-facing EN/AR failure for a blocked decision.
  static SelfApprovalFailure _selfApprovalFailure(SelfApprovalVerdict verdict) {
    String message;
    try {
      message = verdict == SelfApprovalVerdict.ownRequest
          ? S.current.selfApprovalBlocked
          : S.current.requestDecisionUnverifiable;
    } catch (_) {
      // S not loaded (should not happen in the app) — still refuse.
      message = verdict == SelfApprovalVerdict.ownRequest
          ? 'You cannot approve or reject your own request.'
          : 'This decision could not be verified, so nothing was saved.';
    }
    return SelfApprovalFailure(message, verdict: verdict);
  }

  @override
  Future<Either<Failure, List<String>>> approveRequest({
    required ChangeRequest request,
    required String employeeId,
    required String approverEmail,
    String approverEmployeeId = '',
    String reason = '',
  }) async {
    if (employeeId.isEmpty) {
      return Left<Failure, List<String>>(
          FeatureFailure('Employee ID not found.'));
    }
    if (request.id.isEmpty) {
      return Left<Failure, List<String>>(
          FeatureFailure('No request id was supplied.'));
    }

    // ADDED 9/10/2026 — never the requester; checked before ANY write.
    final Failure? blocked = await _guardDecision(
      requestId: request.id,
      deciderEmail: approverEmail,
      deciderEmployeeId: approverEmployeeId,
    );
    if (blocked != null) return Left<Failure, List<String>>(blocked);

    try {
      // CHANGED 20/10/2026 (CR-KNP-SET-HR-03): was two writes — profile, then
      // status — so a crash in between left a changed profile on a request
      // that was still pending, and two reviewers could both apply it. One
      // transaction now: the request must still be pending, the profile and
      // the status are written together, and a batch where NO field could be
      // applied writes nothing (the 13/8/2026 rule, kept).
      final List<String> skipped = await _remoteDataSource.approveAtomically(
        requestId: request.id,
        employeeId: employeeId,
        changes: request.changes,
        reason: reason,
      );
      return Right<Failure, List<String>>(skipped);
    } on StateError catch (e) {
      return Left<Failure, List<String>>(FeatureFailure(e.message));
    } catch (e) {
      return Left<Failure, List<String>>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setRequestStatus({
    required String requestId,
    required RequestStatus status,
    String reason = '',
    String deciderEmail = '',
    String deciderEmployeeId = '',
  }) async {
    if (requestId.isEmpty) {
      return Left<Failure, void>(FeatureFailure('No request id was supplied.'));
    }

    // ADDED 9/10/2026 — a reject (or approve) is a reviewer's decision and
    // goes through the same self-approval check; cancel does not.
    if (SelfApprovalRule.isDecision(status)) {
      final Failure? blocked = await _guardDecision(
        requestId: requestId,
        deciderEmail: deciderEmail,
        deciderEmployeeId: deciderEmployeeId,
      );
      if (blocked != null) return Left<Failure, void>(blocked);
    }

    try {
      await _remoteDataSource.updateStatus(requestId, status, reason: reason);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }
}
