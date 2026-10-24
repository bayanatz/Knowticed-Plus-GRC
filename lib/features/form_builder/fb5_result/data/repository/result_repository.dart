/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: result_repository.dart
/// Description: `ResultRepository`, the [ResultBaseRepository] for the
///              Results page. Its data source and the response store are
///              injected.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/form_builder/helpers/fb_failure.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/base_repository/response_repo.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/form_response.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/data/data_source/remote_data_source/result_remote_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/base_repository/result_base_repository.dart';

/// The Results data: responses from the response store, the access list
/// from the form's privacy record.
class ResultRepository implements ResultBaseRepository {
  /// The one response store (injected).
  final ResponseRepo responseRepo;

  /// Reads the access record (injected).
  final ResultRemoteDataSource remoteDataSource;

  ResultRepository({
    required this.responseRepo,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<FormResponse>>> getFormResponses(
          {required String formId}) =>
      responseRepo.getFormResponses(formId);

  @override
  Future<Either<Failure, void>> remindUser(
          {required String userId, required String formId}) =>
      responseRepo.addReminder(formId: formId, email: userId);

  @override
  Future<Either<Failure, List<String>>> getActiveRecipients(
      String formId) async {
    try {
      final FormPrivacyModel? privacy =
          await remoteDataSource.getFormPrivacy(formId);
      final List<String> emails = privacy?.usersModel?.emails ?? const [];
      final List<String> statuses = privacy?.usersModel?.status ?? const [];
      final List<String> active = [];
      for (int i = 0; i < emails.length; i++) {
        // Guard against a status list shorter than the email list (old data).
        if (i < statuses.length && statuses[i] == 'active') {
          active.add(emails[i]);
        }
      }
      return Right(active);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }
}
