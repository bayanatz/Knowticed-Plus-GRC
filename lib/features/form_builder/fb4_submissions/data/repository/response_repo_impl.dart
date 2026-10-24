/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: response_repo_impl.dart
/// Description: `ResponseRepoImpl`, the [ResponseRepo] backed by Firestore
///              and Storage. The one place responses are read and written.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/features/form_builder/helpers/fb_failure.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/data/mappers/form_entity_mapper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/data_source/remote_data_source/response_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/models/response_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/models/user_responses_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/data/repository/field_media_uploader.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/base_repository/response_repo.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/form_response.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/user_submissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The [ResponseRepo] backed by Firestore and Storage.
class ResponseRepoImpl implements ResponseRepo {
  /// The Firestore access for responses (injected).
  final ResponseDataSource responseDataSource;

  ResponseRepoImpl({required this.responseDataSource});

  @override
  Future<Either<Failure, void>> sendResponse({
    required List<PageEntity> pages,
    required FormEntity form,
    required String responseId,
  }) async {
    final Either<Failure, void> uploaded = await uploadMedia(
      pages: pages,
      form: form,
      responseId: responseId,
    );
    if (uploaded.isLeft()) return uploaded;

    try {
      final ResponseModel responseModel = ResponseModel(
        reminder: [],
        pages: pages.map((page) => page.toModel()).toList(),
        submittedBy: responseId,
        timestamps: [Timestamp.now()],
      );
      // FB-FILL-02: the response and the user's index are written in one
      // transaction; a failure in either is returned, not ignored.
      await responseDataSource.saveResponseWithIndex(responseModel, form.id);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  /// Method Name: [uploadMedia]
  ///
  /// Purpose: uploads every local file of the answer (images, attachments,
  /// signatures). FB-FILL-01: the first failed upload stops the submission,
  /// so a phone file path is never saved as an answer.
  ///
  /// Parameters:
  /// - [pages]: the answered pages.
  /// - [form]: the form answered.
  /// - [responseId]: the filler's email.
  ///
  /// Returns: [Right] when every file is uploaded, [Left] with "Upload
  /// failed, please try again" otherwise.
  Future<Either<Failure, void>> uploadMedia({
    required List<PageEntity> pages,
    required FormEntity form,
    required String responseId,
  }) async {
    final String mediaPath = getBaseUrl(
      "${FormApiConstants.storageBase}/${form.personEntity.department}/${form.id}/Responses/$responseId/ResponseData",
    );
    final String fileNamePrefix =
        "${form.formHeadModel.title}_${responseId}_${FormDateTimeHelper.getMediaTimestamp(Timestamp.now())}";
    try {
      for (final page in pages) {
        for (final row in page.rows) {
          for (final field in row.fields) {
            await uploadFieldMedia(
              field,
              mediaPath: mediaPath,
              fileNamePrefix: fileNamePrefix,
            );
          }
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(S.current.uploadFailedTryAgain));
    }
  }

  @override
  Future<Either<Failure, List<FormResponse>>> getFormResponses(
    String formId,
  ) async {
    try {
      final List<ResponseModel> models = await responseDataSource
          .getFormResponses(formId);
      return Right(models.map(_toEntity).toList());
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, FormResponse?>> getUserResponse({
    required String formId,
    required String email,
  }) async {
    try {
      final ResponseModel? model = await responseDataSource.getUserResponse(
        formId: formId,
        email: email,
      );
      return Right(model == null ? null : _toEntity(model));
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> addReminder({
    required String formId,
    required String email,
  }) async {
    try {
      final ResponseModel? stored = await responseDataSource.getUserResponse(
        formId: formId,
        email: email,
      );
      // FB-RESULT-05: the 24-hour rule is enforced here against the STORED
      // last reminder, not only on the phone screen.
      final Timestamp? lastReminder =
          (stored == null || stored.reminder.isEmpty)
          ? null
          : stored.reminder.last;
      if (lastReminder != null &&
          DateTime.now().difference(lastReminder.toDate()) <
              const Duration(hours: 24)) {
        return Left(ValidationError(S.current.reminderTooSoon));
      }
      final ResponseModel updated = stored == null
          ? ResponseModel(
              id: email,
              reminder: [Timestamp.now()],
              submittedBy: email,
              pages: null,
              timestamps: [],
            )
          : stored.copyWith(
              id: stored.id ?? email,
              reminder: [...stored.reminder, Timestamp.now()],
            );
      await responseDataSource.setResponse(updated, formId);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, UserSubmissions?>> getUserSubmissions(
    String email,
  ) async {
    try {
      final UserResponsesModel? model = await responseDataSource
          .getUserSubmissions(email);
      if (model == null) return const Right(null);
      return Right(
        UserSubmissions(
          email: model.email,
          formIds: model.formIds,
          submittedAt: model.submissionTimestamp
              .map((t) => t.toDate())
              .toList(),
        ),
      );
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  /// Maps the stored response to the domain entity.
  FormResponse _toEntity(ResponseModel model) {
    return FormResponse(
      submittedBy: model.submittedBy,
      pages: model.pages
          ?.map((page) => PageEntityMapper.fromModel(page))
          .toList(),
      submittedAt: model.timestamps.map((t) => t.toDate()).toList(),
      reminders: model.reminder.map((t) => t.toDate()).toList(),
    );
  }
}
