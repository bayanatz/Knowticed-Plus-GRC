/// Module: form_builder_module/f5_submissions
///
///*************************** FILE INFO ****************************///
/// File Name: field_media_uploader.dart
/// Description: Uploads the photos, files and signatures of an answer to Storage.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/features/form_builder/helpers/attachment_helper.dart';
import 'package:knowticed_plus/core/app_services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/image_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';

/// Function Name: [uploadFieldMedia]
///
/// Purpose: uploads the local files of one answered field (images,
/// attachments, signatures) and replaces each local path with its download
/// URL. FB-HOME-21 / FB-FILL-01: errors are NOT caught here; the response
/// repository turns them into a failure and does not save the answer.
///
/// Parameters:
/// - [field]: the answered field.
/// - [mediaPath]: the Storage folder of this response.
/// - [fileNamePrefix]: prefix for the uploaded file names.
///
/// Returns: [Future] that completes when every file is uploaded.
Future<void> uploadFieldMedia(
  FieldModel field, {
  required String mediaPath,
  required String fileNamePrefix,
}) async {
  if (field is AttachmentDigitalSignatureFieldModel) {
    return field._uploadMedia(
        mediaPath: mediaPath, fileNamePrefix: fileNamePrefix);
  }
  if (field is AttachmentFieldModel) {
    return field._uploadMedia(
        mediaPath: mediaPath, fileNamePrefix: fileNamePrefix);
  }
  if (field is ImageFieldModel) {
    return field._uploadMedia(
        mediaPath: mediaPath, fileNamePrefix: fileNamePrefix);
  }
}

extension _AttachmentDigitalSignatureFieldModelUpload
    on AttachmentDigitalSignatureFieldModel {
  Future<void> _uploadMedia(
      {required String mediaPath, required String fileNamePrefix}) async {
    if (attachmentLink != null && !attachmentLink!.path.contains('http')) {
      attachmentLink!.path =
          await FirebaseRepository.uploadFileWithoutHandlingError(
              collectionName: mediaPath,
              documentName: createNewAttachmentName(
                  attachmentPath: attachmentLink!.path,
                  fileNamePrefix: fileNamePrefix),
              filePath: attachmentLink!.path);
    }

    return;
  }
}

extension _AttachmentFieldModelUpload on AttachmentFieldModel {
  Future<void> _uploadMedia(
      {required String mediaPath, required String fileNamePrefix}) async {
    // FB-HOME-21: an upload error is no longer swallowed here. It reaches
    // ResponseRepoImpl.uploadMedia, which returns a failure and does not
    // save the answer with the filler's local file path.
    if (attachmentLink != null && !attachmentLink!.path.contains('http')) {
      attachmentLink!.path =
          await FirebaseRepository.uploadFileWithoutHandlingError(
              collectionName: mediaPath,
              documentName: createNewAttachmentName(
                  attachmentPath: attachmentLink!.path,
                  fileNamePrefix: fileNamePrefix),
              filePath: attachmentLink!.path);
    }
    return;
  }
}

extension _ImageFieldModelUpload on ImageFieldModel {
  Future<void> _uploadMedia(
      {required String mediaPath, required String fileNamePrefix}) async {
    if (images != null) {
      for (int i = 0; i < images!.length; i++) {
        if (images![i] != null &&
            images![i] != 'null' &&
            !images![i]!.contains('http')) {
          images![i] = await FirebaseRepository.uploadFileWithoutHandlingError(
              collectionName: mediaPath,
              documentName: createNewAttachmentName(
                  attachmentPath: images![i]!, fileNamePrefix: fileNamePrefix),
              filePath: images![i]!);
        }
      }
    }
    return;
  }
}
