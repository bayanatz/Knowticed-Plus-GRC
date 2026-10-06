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

import 'package:dartz/dartz.dart';

import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/settings/se6_requests/data/data_source/remote_data_source/requests_remote_data_source.dart';
import 'package:grc_module/features/settings/se6_requests/domain/base_repository/requests_base_repository.dart';
import 'package:grc_module/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:grc_module/features/settings/se6_requests/domain/enums/request_status.dart';

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
  Future<Either<Failure, void>> submitRequest(ChangeRequest request) async {
    if (request.employeeId.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure('Employee ID is not available.'),
      );
    }
    if (request.changes.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure('There are no changes to submit.'),
      );
    }

    try {
      // Confirm the employee exists before logging a request against it — the
      // same guard the submit page performed, kept here so both the personal
      // and health-insurance submit paths share it.
      if (!await _remoteDataSource.employeeExists(request.employeeId)) {
        return Left<Failure, void>(
          FeatureFailure('Employee document not found.'),
        );
      }

      await _remoteDataSource.create(request);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveRequest({
    required ChangeRequest request,
    required String employeeId,
    String reason = '',
  }) async {
    if (employeeId.isEmpty) {
      return Left<Failure, void>(FeatureFailure('Employee ID not found.'));
    }
    if (request.id.isEmpty) {
      return Left<Failure, void>(FeatureFailure('No request id was supplied.'));
    }

    try {
      // Profile first, status second. If the profile write throws, the request
      // keeps its pending status and stays actionable — the previous ordering
      // in details_request.dart was the same, and it is the ordering that
      // matters: a request must never read as approved with nothing written.
      final List<String> skipped =
          await _remoteDataSource.applyChangesToEmployee(
        employeeId: employeeId,
        changes: request.changes,
      );

      // ADDED 13/8/2026: the data source now skips a field the employee model
      // cannot store instead of throwing and losing the rest of the batch. If
      // it could not store *any* of them the approval wrote nothing, so it must
      // not be recorded as approved — that is the state that produced "the info
      // doesn't change after approval" with no error anywhere.
      if (skipped.length == request.changes.length &&
          request.changes.isNotEmpty) {
        return Left<Failure, void>(FeatureFailure(
          'None of the requested fields could be applied: ${skipped.join(', ')}',
        ));
      }

      await _remoteDataSource.updateStatus(request.id, RequestStatus.approved,
          reason: reason);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setRequestStatus({
    required String requestId,
    required RequestStatus status,
    String reason = '',
  }) async {
    if (requestId.isEmpty) {
      return Left<Failure, void>(FeatureFailure('No request id was supplied.'));
    }

    try {
      await _remoteDataSource.updateStatus(requestId, status, reason: reason);
      return const Right<Failure, void>(null);
    } catch (e) {
      return Left<Failure, void>(FirebaseFailure(e.toString()));
    }
  }
}
