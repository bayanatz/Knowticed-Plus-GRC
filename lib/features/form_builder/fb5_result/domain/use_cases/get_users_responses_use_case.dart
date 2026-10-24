/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: get_users_responses_use_case.dart
/// Description: `GetUsersResponsesUseCase`, splits a form's people into
///              pending and submitted. Everything it needs is injected.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/entities/form_response.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/base_repository/result_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/user_grid_item.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/users_responses.dart';

/// Splits a form's people into pending and submitted.
class GetUsersResponsesUseCase {
  /// The Results data (injected).
  final ResultBaseRepository resultRepository;

  /// Looks a person up by email; returns a "Former employee (email)" person
  /// when the email is not in the employee list (FB-RESULT-01). Injected.
  final PersonEntity Function(String email) personOf;

  GetUsersResponsesUseCase({
    required this.resultRepository,
    required this.personOf,
  });

  /// Method Name: [execute]
  ///
  /// Purpose: everyone invited ([userIds]) plus everyone who answered, each
  /// once, split into pending and submitted.
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [userIds]: the active recipients of the form.
  ///
  /// Returns: [UsersResponses], or the failure.
  Future<Either<Failure, UsersResponses>> execute({
    required String formId,
    required List<String> userIds,
  }) async {
    final Either<Failure, List<FormResponse>> result =
        await resultRepository.getFormResponses(formId: formId);
    return result.map((responses) => _split(responses, userIds));
  }

  UsersResponses _split(List<FormResponse> responses, List<String> userIds) {
    final List<String> people = userIds.toSet().toList();
    final Map<String, FormResponse> byEmail = {};
    for (final FormResponse response in responses) {
      byEmail[response.submittedBy] = response;
      if (!people.contains(response.submittedBy)) {
        people.add(response.submittedBy);
      }
    }

    final List<UserGridItem> pending = [];
    final List<UserGridItem> submitted = [];
    for (final String email in people) {
      final FormResponse response = byEmail[email] ??
          FormResponse(
              submittedBy: email,
              pages: const [],
              submittedAt: const [],
              reminders: const []);
      final UserGridItem item = UserGridItem(
        person: personOf(response.submittedBy),
        lastReminderTime: response.lastReminder,
        reminderCounter: response.reminders.length,
        page: response.pages,
        submissionTime: response.firstSubmission,
      );
      (response.isSubmitted ? submitted : pending).add(item);
    }
    return UsersResponses(pending: pending, submitted: submitted);
  }
}
