/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: home_base_repository.dart
/// Description: `HomeBaseRepository`, the reads the Form Builder home screen
///              needs (the user's submissions, one response, usage count).
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/form_response.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/user_submissions.dart';

/// The reads the Form Builder home screen needs. Cubits depend on this
/// class, not on the Firestore implementation.
abstract class HomeBaseRepository {
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

  /// Method Name: [getFormResponse]
  ///
  /// Purpose: one person's answer to a form.
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [email]: the person who answered.
  ///
  /// Returns: the response, null when there is none, or the failure.
  Future<Either<Failure, FormResponse?>> getFormResponse({
    required String formId,
    required String email,
  });

  /// Method Name: [getFormNumberOfUsage]
  ///
  /// Purpose: how many people have submitted a form.
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: the count, or the failure when it cannot be read (never 0 on
  /// an error, so a used form is never treated as unused).
  Future<Either<Failure, int>> getFormNumberOfUsage(String formId);
}
