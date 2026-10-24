/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: send_response_use_case.dart
/// Description: `SendResponseUseCase`, saves a filled-out form and tells
///              the form owner. Everything it needs is injected: the
///              response store, the notifier and the responder's email.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_notifier.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/domain/base_repository/response_repo.dart';

/// Saves a filled-out form and notifies its owner.
class SendResponseUseCase {
  /// The response store (injected).
  final ResponseRepo responseRepo;

  /// Sends the owner's notification (injected).
  final FormBuilderNotifier notifier;

  SendResponseUseCase({required this.responseRepo, required this.notifier});

  /// Method Name: [execute]
  ///
  /// Purpose: saves the answers of [model] as [responderEmail]'s response,
  /// then sends "New Form Submission Received" (or "Response Resubmitted")
  /// to the owner. FB-RESULT-09: with no owner email the notification is
  /// skipped instead of crashing after the answer was saved.
  ///
  /// Parameters:
  /// - [model]: the form with the answered pages.
  /// - [isEdit]: true when an existing answer is re-sent.
  /// - [responderEmail]: the signed-in person's email (passed in, not looked
  ///   up here).
  ///
  /// Returns: [Right] when saved, [Left] with the failure otherwise.
  Future<Either<Failure, void>> execute({
    required FormEntity model,
    required bool isEdit,
    required String responderEmail,
  }) async {
    final Either<Failure, void> response = await responseRepo.sendResponse(
      pages: model.pages,
      form: model,
      responseId: responderEmail,
    );
    if (response.isLeft()) return response;

    // `requestedBy` is the form's `Created_By_Email`.
    final String? owner = model.requestedBy;
    if (owner != null && owner.isNotEmpty) {
      notifier.notifyResponse(
        formId: model.id,
        ownerEmail: owner,
        formNameEn: model.formHeadModel.title,
        formNameAr: model.formHeadModel.arTitle,
        isResubmission: isEdit,
      );
    }
    return response;
  }
}
