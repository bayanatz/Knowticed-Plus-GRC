/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: home_repository.dart
/// Description: `HomeRepository`, the Firestore [HomeBaseRepository].
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Implements HomeBaseRepository with typed results.
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/form_builder/helpers/fb_failure.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/data/data_source/remote_data_source/home_remote_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/data/mappers/form_entity_mapper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/base_repository/home_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/models/response_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/models/user_responses_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/form_response.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/user_submissions.dart';

/// The [HomeBaseRepository] backed by Firestore.
class HomeRepository implements HomeBaseRepository {
  /// The Firestore reads (injected).
  final HomeRemoteDataSource homeRemoteDataSource;

  HomeRepository({required this.homeRemoteDataSource});

  @override
  Future<Either<Failure, UserSubmissions?>> getUserSubmissions(
    String email,
  ) async {
    try {
      final UserResponsesModel? model =
          await homeRemoteDataSource.getUserResponses(email);
      if (model == null) return const Right(null);
      return Right(
        UserSubmissions(
          email: model.email,
          formIds: model.formIds,
          submittedAt:
              model.submissionTimestamp.map((t) => t.toDate()).toList(),
        ),
      );
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, FormResponse?>> getFormResponse({
    required String formId,
    required String email,
  }) async {
    try {
      final ResponseModel? model = await homeRemoteDataSource.getFormResponse(
        formId: formId,
        email: email,
      );
      if (model == null) return const Right(null);
      return Right(
        FormResponse(
          submittedBy: model.submittedBy,
          pages: model.pages
              ?.map((page) => PageEntityMapper.fromModel(page))
              .toList(),
          submittedAt: model.timestamps.map((t) => t.toDate()).toList(),
          reminders: model.reminder.map((t) => t.toDate()).toList(),
        ),
      );
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, int>> getFormNumberOfUsage(String formId) async {
    try {
      return Right(await homeRemoteDataSource.getFormNumberOfUsage(formId));
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }
}
