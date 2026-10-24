/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: share_base_repository.dart
/// Description: `ShareBaseRepository`, the contract for sharing a form.
///              Presentation depends on it, not on the Firestore
///              implementation.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Typed return types; method docs.
/// Updated: 23/10/2026 - Domain types only, no FormPrivacyModel
///                       (Share rule 3).
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';

/// The contract for sharing a form.
abstract class ShareBaseRepository {
  /// Method Name: [getSharedEmails]
  ///
  /// Purpose: the emails on the access list of a form.
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: the emails (empty when the form has no access list), or the
  /// failure when the list cannot be read.
  Future<Either<Failure, List<String>>> getSharedEmails(String formId);

  /// Method Name: [grantAccess]
  ///
  /// Purpose: gives [persons] access. Reads the current access list itself
  /// (in a transaction), so it does not take the screen's copy
  /// (FB-SHARE-06).
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [persons]: the people.
  /// - [timeBegin]: start of the access.
  /// - [timeEnd]: end of the access (must be after [timeBegin]).
  /// - [isEditPermission]: whether they may edit their answer.
  ///
  /// Returns: the emails on the saved access list, or a translated failure.
  Future<Either<Failure, List<String>>> grantAccess({
    required String formId,
    required List<PersonEntity> persons,
    required DateTime timeBegin,
    required DateTime timeEnd,
    required bool isEditPermission,
  });
}
