/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: result_base_repository.dart
/// Description: `ResultBaseRepository`, what the Results page needs from
///              the data layer. Cubits and use cases depend on this
///              interface, injected, never on the implementation.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/form_response.dart';

/// What the Results page needs from the data layer.
abstract class ResultBaseRepository {
  /// Method Name: [getFormResponses]
  ///
  /// Purpose: every response stored for [formId].
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: the responses, or the failure.
  Future<Either<Failure, List<FormResponse>>> getFormResponses(
      {required String formId});

  /// Method Name: [remindUser]
  ///
  /// Purpose: records a reminder for [userId] (24-hour rule enforced).
  ///
  /// Parameters:
  /// - [userId]: the person's email.
  /// - [formId]: the form.
  ///
  /// Returns: [Right] when recorded, [Left] otherwise.
  Future<Either<Failure, void>> remindUser(
      {required String userId, required String formId});

  /// Method Name: [getActiveRecipients]
  ///
  /// Purpose: emails on the form's access list whose status is "active".
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: the emails, or the failure.
  Future<Either<Failure, List<String>>> getActiveRecipients(String formId);
}
