/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_repo_impl.dart
/// Description: Implementation of form repository. Maps the domain
///              entities to and from the Firestore models.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 23/10/2026 - Works with domain entities (Home rules 1 and 9):
///                       the access document is built here, not in HomeCubit.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_access_row.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder/data/models/users_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/data/mappers/form_entity_mapper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/data_source/remote_data_source/form_data_source.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/form_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/base_repository/form_repo.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/form_access_grant.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/form_access_record.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/features/form_builder/helpers/fb_failure.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_log_service.dart';
import 'package:knowticed_plus/features/notification/data/repository/form_builder_notification_service.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class FormRepoImpl extends FormRepo {
  final FormDataSource formDataSource;

  FormRepoImpl({required this.formDataSource});

  /// The access documents read by [getMyAccessRecords], by form id, so
  /// [getSharedForm] does not read each one a second time.
  final Map<String, FormPrivacyModel> _accessCache = {};

  @override

  /// Creates a NEW form in the data source
  ///
  /// [form] The form to be created
  ///
  /// Returns a [Right] with null if the creation is successful, a [Left] with a [Failure]
  /// if the creation fails
  Future<Either<Failure, void>> createForm(FormEntity form) async {
    try {
      final FormModel formModel = form.toModel();
      await uploadImagesIfExist(formModel);
      await formDataSource.createForm(formModel);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override

  /// Updates an EXISTING form in the data source
  ///
  /// [form] The form to be updated
  ///
  /// Returns a [Right] with null if the update is successful, a [Left] with a [Failure]
  /// if the update fails
  Future<Either<Failure, void>> updateForm(FormEntity form) async {
    try {
      final FormModel formModel = form.toModel();

      // Get existing form data
      final Map<String, dynamic>? existingData = await formDataSource.getForm(
        formModel.id,
      );
      if (existingData == null) {
        return Left(FirebaseFailure(S.current.fbFormNotFound));
      }
      final FormModel existingForm = FormModel.fromMap(existingData);

      // Upload new images if they exist
      await uploadImagesIfExist(formModel);

      // Merge with existing data, then save
      final FormModel mergedForm = _mergeFormData(formModel, existingForm);
      await formDataSource.updateForm(mergedForm);

      return const Right(null);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  /// Merges new form data with existing form data
  /// This is a PRIVATE helper method (note the underscore prefix)
  FormModel _mergeFormData(FormModel newForm, FormModel oldForm) {
    oldForm.timestamps.add(newForm.timestamps.last);

    // Only add if values changed
    if (oldForm.image!.lastOrNull != newForm.image!.lastOrNull) {
      oldForm.image!.add(newForm.image!.last);
    }
    if (oldForm.title.last != newForm.title.last) {
      oldForm.title.add(newForm.title.last);
    }
    if (oldForm.description.last != newForm.description.last) {
      oldForm.description.add(newForm.description.last);
    }
    if (oldForm.arabicTitle.last != newForm.arabicTitle.last) {
      oldForm.arabicTitle.add(newForm.arabicTitle.last);
    }
    if (oldForm.arabicDescription.last != newForm.arabicDescription.last) {
      oldForm.arabicDescription.add(newForm.arabicDescription.last);
    }
    if (oldForm.accessMangement.last != newForm.accessMangement.last) {
      oldForm.accessMangement.add(newForm.accessMangement.last);
    }
    if (oldForm.orientation.last != newForm.orientation.last) {
      oldForm.orientation.add(newForm.orientation.last);
    }
    if (oldForm.horizontalPadding.last != newForm.horizontalPadding.last) {
      oldForm.horizontalPadding.add(newForm.horizontalPadding.last);
    }
    if (oldForm.verticalPadding.last != newForm.verticalPadding.last) {
      oldForm.verticalPadding.add(newForm.verticalPadding.last);
    }
    if (oldForm.formStatus.last != newForm.formStatus.last) {
      oldForm.formStatus.add(newForm.formStatus.last);
    }
    if (oldForm.watermark.imageName!.lastOrNull !=
        newForm.watermark.imageName!.lastOrNull) {
      oldForm.watermark.imageName!.add(newForm.watermark.imageName!.last);
    }
    if (oldForm.watermark.imageUrl!.lastOrNull !=
        newForm.watermark.imageUrl!.lastOrNull) {
      oldForm.watermark.imageUrl!.add(newForm.watermark.imageUrl!.last);
    }
    if (oldForm.watermark.opacity!.last != newForm.watermark.opacity!.last) {
      oldForm.watermark.opacity!.add(newForm.watermark!.opacity.last);
    }
    if (oldForm.watermark.size!.last != newForm.watermark.size!.last) {
      oldForm.watermark.size!.add(newForm.watermark!.size.last);
    }

    // Replace services_management_module entirely
    oldForm.pages.clear();
    oldForm.pages.addAll(newForm.pages);

    return oldForm;
  }

  /// Uploads the cover and watermark when they are still local files.
  ///
  /// FB-HOME-05: this is now the ONLY upload path for form images. If an
  /// upload fails it throws, so createForm / updateForm return a failure and
  /// the form is NOT saved with the phone's file path.
  /// FB-HOME-20: files are stored under the form ID with a unique name
  /// (they were stored under the form title, so renaming a form split its
  /// files and two forms could overwrite each other's image).
  Future<void> uploadImagesIfExist(FormModel formModel) async {
    if (formModel.image!.isNotEmpty &&
        !formModel.image!.last.contains("http")) {
      final String url = await formDataSource.uploadFile(
        formModel.image!.last,
        _assetPath(formModel, 'cover', formModel.image!.last),
      );
      formModel.image!.removeLast();
      formModel.image!.add(url);
    }
    // do the same for watermark image
    if (formModel.watermark.imageUrl.isNotEmpty &&
        !formModel.watermark.imageUrl.last.contains("http")) {
      final String url = await formDataSource.uploadFile(
        formModel.watermark.imageUrl.last,
        _assetPath(formModel, 'watermark', formModel.watermark.imageUrl.last),
      );
      formModel.watermark.imageUrl.removeLast();
      formModel.watermark.imageUrl.add(url);
    }
  }

  /// Storage path for a form asset: `<base>/<formId>/FormAssets/<kind>_<ms>.<ext>`.
  String _assetPath(FormModel formModel, String kind, String localPath) {
    final String ext =
        localPath.contains('.') ? localPath.split('.').last : 'jpg';
    return "${getBaseUrl(FormApiConstants.storageBase)}/${formModel.id}/FormAssets/"
        "${kind}_${DateTime.now().millisecondsSinceEpoch}.$ext";
  }

  @override

  /// Uploads a file to the data source
  ///
  /// [filePath] The path to the file to be uploaded
  /// [storagePath] The path in the storage to upload the file to
  ///
  /// Returns a [Right] with the download URL of the file if the upload is successful,
  /// a [Left] with a [Failure] if the upload fails
  Future<Either<Failure, String>> uploadFile(
    String filePath,
    String storagePath,
  ) async {
    try {
      final String url = await formDataSource.uploadFile(filePath, storagePath);
      return Right(url);
    } catch (e) {
      return Left(fbFailure(e));
    }
  }

  /// Method Name: [getFormPrivacy]
  ///
  /// Purpose: the access document of a form (used by the Home summary card).
  ///
  /// Parameters:
  /// - [formId]: the form.
  ///
  /// Returns: [Right] with the [FormPrivacyModel], otherwise [Left].
  Future<Either<Failure, FormPrivacyModel>> getFormPrivacy(
    String formId,
  ) async {
    try {
      return Right(await formDataSource.getFormPrivacy(formId));
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  /// Method Name: [getMyCreatedForms]
  ///
  /// Purpose: the form documents the user created (used by the Home summary
  /// card).
  ///
  /// Parameters:
  /// - [currentUserId]: the creator's email.
  ///
  /// Returns: [Right] with the [FormModel]s, otherwise [Left].
  Future<Either<Failure, List<FormModel>>> getMyCreatedForms(
    String currentUserId,
  ) async {
    try {
      return Right(await formDataSource.getUserCreatedForms(currentUserId));
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> deleteForm(String formId) async {
    try {
      final FormModel? formModel = await _readForm(formId);
      if (formModel == null) {
        return Left(FirebaseFailure(S.current.fbFormNotFound));
      }
      await formDataSource.deletedForm(formModel);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, FormStatus>> restoreForm(String formId) async {
    try {
      final FormModel? formModel = await _readForm(formId);
      if (formModel == null) {
        return Left(FirebaseFailure(S.current.fbFormNotFound));
      }
      // `restoreForm` appends the status the form had before the delete.
      await formDataSource.restoreForm(formModel);
      final String restored = formModel.formStatus.last.toLowerCase();
      return Right(
        FormStatus.values.firstWhere(
          (FormStatus status) => status.name.toLowerCase() == restored,
          orElse: () => FormStatus.publish,
        ),
      );
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> saveFormAccess({
    required String formId,
    required FormAccessGrant grant,
    required String formNameEn,
    String? formNameAr,
  }) async {
    try {
      final UsersModel? before =
          await FormBuilderNotificationService.readAccessList(formId);
      final FormPrivacyModel privacy = _privacyFrom(grant);
      await formDataSource.addFormPrivacy(privacy, formId);
      _logAccessChange(before, privacy.usersModel);
      FormBuilderNotificationService.notifyAccessListChanged(
        formId: formId,
        before: before,
        after: privacy.usersModel,
        formNameEn: formNameEn,
        formNameAr: formNameAr,
      );
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<FormEntity>>> getCreatedForms(
    String email,
  ) async {
    try {
      final List<FormModel> models = await formDataSource.getUserCreatedForms(
        email,
      );
      // 24/10/2026: one read per form, all at once (they were one after the
      // other, which made the Home lists take over a minute to appear).
      final List<FormEntity?> entities = await Future.wait(
        models.map(_createdFormEntity),
      );
      return Right(<FormEntity>[
        for (final FormEntity? entity in entities)
          if (entity != null) entity,
      ]);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<FormAccessRecord>>> getMyAccessRecords(
    String email,
  ) async {
    try {
      final List<FormPrivacyModel> models =
          await formDataSource.getAllMyAccessData(email);
      _accessCache.clear();
      final List<FormAccessRecord> records = [];
      for (final FormPrivacyModel model in models) {
        final FormAccessRecord? record = _recordFor(model, email);
        if (record == null) continue;
        _accessCache[record.formId] = model;
        records.add(record);
      }
      return Right(records);
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, FormEntity?>> getSharedForm(
    FormAccessRecord record, {
    required bool isHasAccess,
  }) async {
    try {
      final FormModel? formModel = await _readForm(record.formId);
      if (formModel == null) return const Right(null);
      final FormPrivacyModel privacy = _accessCache[record.formId] ??
          await formDataSource.getFormPrivacy(record.formId);
      return Right(
        FormEntityMapper.fromModel(
          formModel,
          privacy,
          usedBy: 0,
          isEdit: record.canEdit,
          isHasAccess: isHasAccess,
        ),
      );
    } catch (e, stackTrace) {
      return Left(fbFailure(e, stackTrace));
    }
  }

  /// The form document [formId], or null when it does not exist.
  Future<FormModel?> _readForm(String formId) async {
    final Map<String, dynamic>? form = await formDataSource.getForm(formId);
    return form == null ? null : FormModel.fromMap(form);
  }

  /// One created form with its access list, or null when it cannot be
  /// mapped (FB-HOME-08) or its access list cannot be read (FB-HOME-04).
  Future<FormEntity?> _createdFormEntity(FormModel form) async {
    try {
      final AccessManagement? access = AccessManagementExtension.fromStored(
        form.accessMangement.last,
      );
      FormPrivacyModel privacy = FormPrivacyModel();
      if (access == AccessManagement.openAccess ||
          access == AccessManagement.restrictedAccess) {
        privacy = await formDataSource.getFormPrivacy(form.id);
      }
      return FormEntityMapper.fromModel(
        form,
        privacy,
        isHasAccess: access == AccessManagement.personalAccess,
      );
    } catch (e, stackTrace) {
      fbFailure(e, stackTrace);
      return null;
    }
  }

  /// The row of [email] in [model], or null when it is not listed or the
  /// row cannot be read.
  FormAccessRecord? _recordFor(FormPrivacyModel model, String email) {
    try {
      final UsersModel? users = model.usersModel;
      final int index = users?.emails?.indexOf(email) ?? -1;
      if (index == -1 || model.id == null) return null;
      return FormAccessRecord(
        formId: model.id!,
        accessBegin: users?.accessBegin?[index]?.toDate(),
        accessEnd: users?.accessEnd?[index]?.toDate(),
        isActive: users?.status?[index] == 'active',
        canEdit: users?.editPermission?[index] ?? false,
      );
    } catch (e, stackTrace) {
      fbFailure(e, stackTrace);
      return null;
    }
  }

  /// The Firestore access document for [grant].
  FormPrivacyModel _privacyFrom(FormAccessGrant grant) {
    final int n = grant.emails.length;
    final Timestamp? begin = grant.accessBegin != null
        ? Timestamp.fromDate(grant.accessBegin!)
        : null;
    final Timestamp? end =
        grant.accessEnd != null ? Timestamp.fromDate(grant.accessEnd!) : null;
    return FormPrivacyModel(
      timestamps: [Timestamp.now()],
      usersModel: UsersModel(
        accessBegin: List.generate(n, (_) => begin),
        accessEnd: List.generate(n, (_) => end),
        editPermission: List.generate(n, (_) => grant.editPermission),
        emails: List<String>.of(grant.emails),
        status: List.generate(n, (_) => 'active'),
      ),
    );
  }

  /// System Logs for an access-list save. A first publish (no list before)
  /// is logged as Create / Publish Form by its caller, so only a change to
  /// an EXISTING list is "Update Form Access"; a recipient whose Edit
  /// Permission went from off to on is also "Enable Response Editing".
  void _logAccessChange(UsersModel? before, UsersModel? after) {
    if (before == null) return;
    FormBuilderLogService.log(FormBuilderLogService.actionUpdateFormAccess);
    final Map<String, FormAccessRow> old = FormAccessRow.mapFrom(before);
    final bool editingEnabled =
        FormAccessRow.activeFrom(after).any((FormAccessRow row) {
      final FormAccessRow? previous = old[row.email.toLowerCase()];
      return row.editPermission &&
          (previous == null || !previous.editPermission);
    });
    if (editingEnabled) {
      FormBuilderLogService.log(
        FormBuilderLogService.actionEnableResponseEditing,
      );
    }
  }
}
