/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_repo.dart
/// Description: Interface for form repository. Works with domain entities
///              only; the Firestore models stay in the data layer.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 23/10/2026 - Domain entities instead of FormModel /
///                       FormPrivacyModel (Home rule 1).
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/form_access_grant.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/form_access_record.dart';

/// Reads and writes forms and their access lists.
abstract class FormRepo {
  /// Method Name: [createForm]
  ///
  /// Purpose: saves a new form (uploads its cover and watermark first).
  ///
  /// Parameters:
  /// - [form]: the form.
  ///
  /// Returns: [Right] when saved, otherwise [Left] with the [Failure].
  Future<Either<Failure, void>> createForm(FormEntity form);

  /// Method Name: [updateForm]
  ///
  /// Purpose: saves an edited form under its id, keeping its history.
  ///
  /// Parameters:
  /// - [form]: the edited form.
  ///
  /// Returns: [Right] when saved, otherwise [Left] with the [Failure].
  Future<Either<Failure, void>> updateForm(FormEntity form);

  /// Method Name: [deleteForm]
  ///
  /// Purpose: moves a form to Deleted.
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: [Right] when deleted, otherwise [Left] with the [Failure].
  Future<Either<Failure, void>> deleteForm(String formId);

  /// Method Name: [restoreForm]
  ///
  /// Purpose: restores a deleted form to the status it had before.
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: [Right] with the restored status, otherwise [Left].
  Future<Either<Failure, FormStatus>> restoreForm(String formId);

  /// Method Name: [saveFormAccess]
  ///
  /// Purpose: saves the access list of a form, then logs the change and
  /// notifies the recipients.
  ///
  /// Parameters:
  /// - [formId]: the form.
  /// - [grant]: the recipients, period and edit permission.
  /// - [formNameEn]: the English form name (for the notification).
  /// - [formNameAr]: the Arabic form name (for the notification).
  ///
  /// Returns: [Right] when saved, otherwise [Left] with the [Failure].
  Future<Either<Failure, void>> saveFormAccess({
    required String formId,
    required FormAccessGrant grant,
    required String formNameEn,
    String? formNameAr,
  });

  /// Method Name: [uploadFile]
  ///
  /// Purpose: uploads a file to the cloud storage.
  ///
  /// Parameters:
  /// - [filePath]: the local file.
  /// - [storagePath]: the path in the cloud storage.
  ///
  /// Returns: [Right] with the download URL, otherwise [Left].
  Future<Either<Failure, String>> uploadFile(
    String filePath,
    String storagePath,
  );

  /// Method Name: [getCreatedForms]
  ///
  /// Purpose: the forms the user created (every status), each with its
  /// access list. A form whose access list cannot be read is skipped
  /// (FB-HOME-04), so it is never edited with an empty list.
  ///
  /// Parameters:
  /// - [email]: the creator's email.
  ///
  /// Returns: [Right] with the forms, otherwise [Left].
  Future<Either<Failure, List<FormEntity>>> getCreatedForms(String email);

  /// Method Name: [getMyAccessRecords]
  ///
  /// Purpose: the user's own row of every access list that names them.
  ///
  /// Parameters:
  /// - [email]: the user's email.
  ///
  /// Returns: [Right] with the rows, otherwise [Left].
  Future<Either<Failure, List<FormAccessRecord>>> getMyAccessRecords(
    String email,
  );

  /// Method Name: [getSharedForm]
  ///
  /// Purpose: one form shared with the user, with its access list.
  ///
  /// Parameters:
  /// - [record]: the user's row of the form's access list.
  /// - [isHasAccess]: whether the access period is open now.
  ///
  /// Returns: [Right] with the form (null when it does not exist), otherwise
  /// [Left].
  Future<Either<Failure, FormEntity?>> getSharedForm(
    FormAccessRecord record, {
    required bool isHasAccess,
  });
}
