/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_field_model.dart
/// Description: `AttachmentFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/attachment_entity.dart';

class AttachmentFieldModel extends FieldModel {
  /// Title of the attachment field
  String title;

  @override
  String? get fieldTitle => title;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Alignment of the email field
  String alignment;

  /// Link of the attachment
  AttachmentEntity? attachmentLink;

  /// Constructor for initializing the AttachmentFieldModel instance
  AttachmentFieldModel(
      {required this.title,
      required this.alignment,
      required this.isRequired,
      this.attachmentLink})
      : super(FormFieldType.attachment);

  /// Method to duplicate the attachment field model
  /// Returns a new instance of AttachmentFieldModel with the same properties
  @override
  duplicate() {
    AttachmentFieldModel newModel = AttachmentFieldModel(
      title: title,
      isRequired: isRequired,
      alignment: alignment,
    );
    return newModel;
  }
}
