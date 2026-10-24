/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_digital_signature_field_model.dart
/// Description: `AttachmentDigitalSignatureFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/attachment_entity.dart';

class AttachmentDigitalSignatureFieldModel extends FieldModel {
  /// Title of the attachment digital signature field
  String title;

  @override
  String? get fieldTitle => title;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Alignment of the email field
  String alignment;

  AttachmentEntity? attachmentLink;

  /// Constructor for initializing the AttachmentDigitalSignatureFieldModel instance
  AttachmentDigitalSignatureFieldModel(
      {required this.title,
      required this.alignment,
      required this.isRequired,
      this.attachmentLink})
      : super(FormFieldType.digitalSignature);

  /// Method to duplicate the attachment digital signature field model
  /// Returns a new instance of AttachmentDigitalSignatureFieldModel with the same properties
  @override
  duplicate() {
    AttachmentDigitalSignatureFieldModel newModel =
        AttachmentDigitalSignatureFieldModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
    );
    return newModel;
  }
}
