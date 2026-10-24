/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: response_repo.dart
/// Description: `ResponseRepo`, the one store of form responses. Fill-out,
///              Home and Results all read and write responses through it.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/form_response.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/user_submissions.dart';

/// The one store of form responses.
abstract class ResponseRepo {
  /// Method Name: [sendResponse]
  ///
  /// Purpose: uploads the answer's files and saves the response with the
  /// filler's index in one transaction.
  ///
  /// Parameters:
  /// - [pages]: the answered pages.
  /// - [form]: the form answered.
  /// - [responseId]: the filler's email.
  ///
  /// Returns: [Right] when saved, [Left] with the failure otherwise.
  Future<Either<Failure, void>> sendResponse({
    required List<PageEntity> pages,
    required FormEntity form,
    required String responseId,
  });

  /// Method Name: [getFormResponses]
  ///
  /// Purpose: every response stored for a form (including reminder-only
  /// records of people who have not answered).
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: the responses, or the failure.
  Future<Either<Failure, List<FormResponse>>> getFormResponses(String formId);

  /// Method Name: [getUserResponse]
  ///
  /// Purpose: one person's response to a form.
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [email]: the person.
  ///
  /// Returns: the response, null when there is none, or the failure.
  Future<Either<Failure, FormResponse?>> getUserResponse({
    required String formId,
    required String email,
  });

  /// Method Name: [addReminder]
  ///
  /// Purpose: records a reminder for one person. FB-RESULT-05: refused when
  /// the stored last reminder is less than 24 hours old.
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [email]: the person reminded.
  ///
  /// Returns: [Right] when recorded, [Left] (e.g. too soon) otherwise.
  Future<Either<Failure, void>> addReminder({
    required String formId,
    required String email,
  });

  /// Method Name: [getUserSubmissions]
  ///
  /// Purpose: the forms one person has submitted (their index).
  ///
  /// Parameters:
  /// - [email]: the person.
  ///
  /// Returns: the index, null when the person has submitted nothing, or the
  /// failure.
  Future<Either<Failure, UserSubmissions?>> getUserSubmissions(String email);
}
