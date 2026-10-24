/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_helper.dart
/// Description: Helper class for handling attachment-related operations
/// Author: Amr Mesbah
/// Created at: 6/4/2025
library;

import 'dart:io';

import 'package:intl/intl.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/attachment_entity.dart';

String getAttachmentExtension(String attachmentPath) {
  return attachmentPath.split('.').last;
}

String getAttachmentNameWithExtension(String attachmentPath) {
  String name = "";
  if (attachmentPath.contains('/')) {
    name = attachmentPath.split('/').last;
  } else if (attachmentPath.contains('\\')) {
    name = attachmentPath.split('\\').last;
  }
  return name;
}

String getAttachmentName(String attachmentPath) {
  return getAttachmentNameWithExtension(attachmentPath).split('.').first;
}

String createNewAttachmentName(
    {required String attachmentPath, required String fileNamePrefix}) {
  String fileName = getAttachmentName(attachmentPath);
  String extension = getAttachmentExtension(attachmentPath);
  String newName = "${fileNamePrefix}_${fileName}_$extension.$extension";
  return newName;
}

/// Function Name: [attachmentEntityFromFile]
///
/// Purpose: describes a picked file as an [AttachmentEntity] (moved out of
/// the domain entity, which must not use dart:io).
///
/// Parameters:
/// - [file]: the picked file.
///
/// Returns: the attachment (size in KB, date as dd_MMM_yyyy).
AttachmentEntity attachmentEntityFromFile(File file) {
  final String path = file.path;
  return AttachmentEntity(
    path: path,
    name: getAttachmentNameWithExtension(path),
    size: (file.lengthSync() / 1024).round(),
    createdAt: DateFormat('dd_MMM_yyyy').format(DateTime.now()),
  );
}
