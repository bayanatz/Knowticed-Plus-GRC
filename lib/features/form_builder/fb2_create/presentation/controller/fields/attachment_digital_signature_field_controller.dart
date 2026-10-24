/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_digital_signature_field_controller.dart
/// Description: `AttachmentDigitalSignatureFieldController` controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;



import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/attachment_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class AttachmentDigitalSignatureFieldController extends FieldController {
  // Text controller for the title of the digital signature field.
  FieldText? title;

  String? alignment;
  // Indicates whether this digital signature field is required or not.
  bool? isRequired;
  AttachmentEntity? attachmentEntity;

  /// Constructor that initializes the controller with digital signature field type.
  AttachmentDigitalSignatureFieldController()
    : super(FormFieldType.digitalSignature) {
    init();
  }

  @override
  /// Initializes the digital signature field controllers.
  init() {
    title = FieldText();
    isRequired = false;
    alignment = AlignmentEnum.center.name;
    return super.init();
  }

  @override
  /// Disposes the digital signature field controllers.
  dispose() {
    title?.dispose();
    return super.dispose();
  }

  @override
  /// Prints the model data of the digital signature field.
  printModel() {
    return super.printModel();
  }

  @override
  /// Creates a duplicate of the current digital signature field controller.
  duplicate() {
    var newController = AttachmentDigitalSignatureFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the alignment
    newController.alignment = alignment;
    return newController;
  }

  @override
  /// Converts the digital signature field controller to a model.
  AttachmentDigitalSignatureFieldModel toModel({bool isSetAnswer = false}) {
    return AttachmentDigitalSignatureFieldModel(
      isRequired: isRequired!,
      alignment: alignment!,
      title: title?.text ?? '',
      attachmentLink: attachmentEntity,
    );
  }

  @override
  bool valid() {
    if (isRequired! && attachmentEntity == null) {
      return false;
    }
    return super.valid();
  }
}
