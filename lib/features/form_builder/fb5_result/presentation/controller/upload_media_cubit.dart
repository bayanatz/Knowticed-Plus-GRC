/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: upload_media_cubit.dart
/// Description: `UploadMediaCubit`, the Uploaded Documents page: pick
///              people and file types, then download their files. The
///              downloader is injected; the page owns the search controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/image_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/row_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/user_grid_item.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/upload_media_state.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/result_constants.dart';

import 'package:knowticed_plus/features/form_builder/fb5_result/data/utils/media_handler.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The Uploaded Documents page.
class UploadMediaCubit extends Cubit<UploadMediaState> {
  /// Downloads one file to where the user can open it (injected).
  final MediaHandler mediaHandler;

  UploadMediaCubit({required this.mediaHandler}) : super(UploadMediaInitial());

  /// Method Name: [initialize]
  ///
  /// Purpose: opens the page for [form] with its submitted people (passed
  /// in by the page; this cubit no longer reads ResultCubit).
  ///
  /// Parameters:
  /// - [form]: the form.
  /// - [submittedUsers]: the people who answered.
  void initialize({
    required FormEntity form,
    required List<UserGridItem> submittedUsers,
  }) {
    if (isClosed) return;
    final List<UserGridItem> userGridItems =
        _createUserGridItems(submittedUsers);
    emit(UploadMediaLoaded(
      formEntity: form,
      userGridItems: userGridItems,
      filteredUserGridItems: userGridItems,
      mediaType: const [],
      employeeType: ResultConstants.employeesAll,
      isHasMedia: _checkIfHasMedia(form),
    ));
  }

  List<UserGridItem> _createUserGridItems(List<UserGridItem> submissions) {
    List<UserGridItem> userGridItems = [];
    for (UserGridItem submission in submissions) {
      userGridItems.add(UserGridItem(
        person: submission.person.copy(),
        reminderCounter: submission.reminderCounter,
        page: submission.page,
        lastReminderTime: submission.lastReminderTime,
        submissionTime: submission.submissionTime,
      ));
    }
    return userGridItems;
  }

  /// Method Name: [applyFilter]
  ///
  /// Purpose: filters the people by department and search text.
  ///
  /// Parameters:
  /// - [query]: the search text; null keeps the current one.
  void applyFilter([String? query]) {
    if (state is! UploadMediaLoaded) return;
    final currentState =
        (state as UploadMediaLoaded).copyWith(searchQuery: query);

    List<UserGridItem> filteredUserGridItems = [];
    for (UserGridItem item in currentState.userGridItems) {
      // FB-RESULT-04: filtered by department ID; null means all departments.
      if (currentState.departmentType == null ||
          item.person.department == currentState.departmentType) {
        final searchText = currentState.searchQuery.toLowerCase();
        if (item.person.arabicName.contains(searchText) ||
            item.person.englishName.toLowerCase().contains(searchText) ||
            item.person.titleArabic.toLowerCase().contains(searchText) ||
            item.person.titleEnglish.toLowerCase().contains(searchText)) {
          filteredUserGridItems.add(item);
        }
      }
    }

    emit(currentState.copyWith(filteredUserGridItems: filteredUserGridItems));
  }

  /// Method Name: [togglePersonSelection]
  ///
  /// Purpose: selects or unselects one person.
  ///
  /// Parameters:
  /// - [userGridItem]: the person.
  void togglePersonSelection(UserGridItem userGridItem) {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    userGridItem.person.isSelected = !userGridItem.person.isSelected;
    emit(currentState.copyWith(revision: currentState.revision + 1));
  }

  /// Method Name: [updateSelectedEmployeeType]
  ///
  /// Purpose: "All" selects everyone, "Custom" clears the selection.
  ///
  /// Parameters:
  /// - [value]: one of [ResultConstants.employeeFilter].
  void updateSelectedEmployeeType(String? value) {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    final userGridItems = List<UserGridItem>.from(currentState.userGridItems);
    for (int i = 0; i < userGridItems.length; i++) {
      userGridItems[i].person.isSelected =
          value == ResultConstants.employeesAll;
    }

    emit(currentState.copyWith(
      employeeType: value ?? ResultConstants.employeesAll,
      userGridItems: userGridItems,
      revision: currentState.revision + 1,
    ));
  }

  /// Method Name: [updateDepartmentType]
  ///
  /// Purpose: filters by department (FB-RESULT-04: by id).
  ///
  /// Parameters:
  /// - [value]: a department id, or [ResultConstants.allDepartments].
  void updateDepartmentType(String? value) {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    // [value] is a department ID, or [ResultConstants.allDepartments].
    final bool all = value == null || value == ResultConstants.allDepartments;
    emit(all
        ? currentState.copyWith(clearDepartmentType: true)
        : currentState.copyWith(departmentType: value));
    applyFilter();
  }

  /// Method Name: [selectMediaType]
  ///
  /// Purpose: adds or removes a file type to download.
  ///
  /// Parameters:
  /// - [value]: one of [ResultConstants.mediaTypeFilter].
  void selectMediaType(String value) {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    final mediaType = List<String>.from(currentState.mediaType);
    if (mediaType.contains(value)) {
      mediaType.remove(value);
    } else {
      mediaType.add(value);
    }

    emit(currentState.copyWith(mediaType: mediaType));
  }

  /// Downloads the chosen media of the selected people.
  ///
  /// FB-RESULT-03: returns null when it worked, or a translated message
  /// when nothing was chosen or a download failed, so the page can show a
  /// loading indicator, then a success or failure message (it used to show
  /// nothing, and a failure was not caught).
  Future<String?> downloadMedia() async {
    if (state is! UploadMediaLoaded) return S.current.noFilesToDownload;
    final currentState = state as UploadMediaLoaded;

    final List<UserGridItem> selected = currentState.filteredUserGridItems
        .where((item) => item.person.isSelected)
        .toList();
    if (selected.isEmpty || currentState.mediaType.isEmpty) {
      return S.current.noFilesToDownload;
    }
    try {
      for (final UserGridItem userGridItem in selected) {
        await downloadUserMedia(userGridItem);
      }
      return null;
    } catch (e) {
      return S.current.downloadFailed;
    }
  }

  /// Method Name: [downloadUserMedia]
  ///
  /// Purpose: downloads the chosen file types of one person.
  ///
  /// Parameters:
  /// - [userGridItem]: the person.
  ///
  /// Returns: [Future]; throws when a download fails.
  Future<void> downloadUserMedia(UserGridItem userGridItem) async {
    if (state is! UploadMediaLoaded) return;
    for (PageEntity page in userGridItem.page!) {
      for (RowEntity rowEntity in page.rows) {
        for (FieldModel fieldModel in rowEntity.fields) {
          await handleImageDownload(fieldModel, userGridItem);
          await handleAttachmentDownload(fieldModel, userGridItem);
          await handleSignatureDownload(fieldModel, userGridItem);
        }
      }
    }
  }

  /// Method Name: [handleImageDownload]
  ///
  /// Purpose: downloads the images of an Image answer (when images are chosen).
  ///
  /// Parameters:
  /// - [fieldModel]: the answered field.
  /// - [userGridItem]: the person.
  Future<void> handleImageDownload(
    FieldModel fieldModel,
    UserGridItem userGridItem,
  ) async {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    if (!(currentState.mediaType
        .contains(ResultConstants.mediaTypeFilter[0]))) {
      return;
    }

    if (fieldModel.type == FormFieldType.image) {
      if ((fieldModel as ImageFieldModel).images != null) {
        for (int i = 0; i < fieldModel.images!.length; i++) {
          String mediaPath = fieldModel.images![i] ?? '';
          if (mediaPath.isEmpty) continue;
          String mediaName =
              getMediaName(mediaPath, fieldModel.title, userGridItem.person.id);
          await mediaHandler.downloadFile(mediaPath, mediaName);
        }
      }
    }
  }

  /// Method Name: [handleAttachmentDownload]
  ///
  /// Purpose: downloads the file of an Attachment answer (when attachments are chosen).
  ///
  /// Parameters:
  /// - [fieldModel]: the answered field.
  /// - [userGridItem]: the person.
  Future<void> handleAttachmentDownload(
    FieldModel fieldModel,
    UserGridItem userGridItem,
  ) async {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    if (!(currentState.mediaType
        .contains(ResultConstants.mediaTypeFilter[1]))) {
      return;
    }

    if (fieldModel.type == FormFieldType.attachment) {
      if ((fieldModel as AttachmentFieldModel).attachmentLink != null) {
        String originalMediaName = fieldModel.attachmentLink!.name;
        String mediaPath = fieldModel.attachmentLink!.path;
        String mediaName = getMediaName(
            originalMediaName, fieldModel.title, userGridItem.person.id);
        await mediaHandler.downloadFile(mediaPath, mediaName);
      }
    }
  }

  /// Method Name: [handleSignatureDownload]
  ///
  /// Purpose: downloads the signature of a Signature answer (when signatures are chosen).
  ///
  /// Parameters:
  /// - [fieldModel]: the answered field.
  /// - [userGridItem]: the person.
  Future<void> handleSignatureDownload(
    FieldModel fieldModel,
    UserGridItem userGridItem,
  ) async {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    if (!(currentState.mediaType
        .contains(ResultConstants.mediaTypeFilter[2]))) {
      return;
    }

    if (fieldModel.type == FormFieldType.digitalSignature) {
      if ((fieldModel as AttachmentDigitalSignatureFieldModel).attachmentLink !=
          null) {
        String mediaPath = fieldModel.attachmentLink!.path;
        String mediaName =
            getMediaName(mediaPath, fieldModel.title, userGridItem.person.id);
        await mediaHandler.downloadFile(mediaPath, mediaName);
      }
    }
  }

  /// Method Name: [getMediaName]
  ///
  /// Purpose: the saved file name: form title, field title, person and original name.
  ///
  /// Parameters:
  /// - [mediaPath]: the stored path or URL.
  /// - [fieldTitle]: the question.
  /// - [userId]: the person's email.
  ///
  /// Returns: the file name.
  String getMediaName(String mediaPath, String fieldTitle, String userId) {
    if (state is! UploadMediaLoaded) return '';
    final currentState = state as UploadMediaLoaded;

    String mediaName = mediaPath.split('/').last;
    String name = currentState.formEntity!.formHeadModel.title;
    name += '_$fieldTitle';
    name += '_$userId';
    name += '_$mediaName';
    return name;
  }

  bool _checkIfHasMedia(FormEntity formEntity) {
    for (var page in formEntity.pages) {
      for (var row in page.rows) {
        for (var field in row.fields) {
          if (field is ImageFieldModel ||
              field is AttachmentFieldModel ||
              field is AttachmentDigitalSignatureFieldModel) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Method Name: [hasSignature]
  ///
  /// Returns: true when the form has a Signature question.
  bool hasSignature() {
    if (state is! UploadMediaLoaded) return false;
    final currentState = state as UploadMediaLoaded;

    for (var page in currentState.formEntity!.pages) {
      for (var row in page.rows) {
        for (var field in row.fields) {
          if (field is AttachmentDigitalSignatureFieldModel) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Method Name: [hasAttachment]
  ///
  /// Returns: true when the form has an Attachment question.
  bool hasAttachment() {
    if (state is! UploadMediaLoaded) return false;
    final currentState = state as UploadMediaLoaded;

    for (var page in currentState.formEntity!.pages) {
      for (var row in page.rows) {
        for (var field in row.fields) {
          if (field is AttachmentFieldModel) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Method Name: [hasImage]
  ///
  /// Returns: true when the form has an Image question.
  bool hasImage() {
    if (state is! UploadMediaLoaded) return false;
    final currentState = state as UploadMediaLoaded;

    for (var page in currentState.formEntity!.pages) {
      for (var row in page.rows) {
        for (var field in row.fields) {
          if (field is ImageFieldModel) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
