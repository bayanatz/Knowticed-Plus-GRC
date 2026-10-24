/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_field_controller.dart
/// Description: `AttachmentFieldController` controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;



import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/attachment_entity.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class AttachmentFieldController extends FieldController {
  // Text controller for the title of the attachment field.
  FieldText? title;
  // Indicates whether this attachment field is required or not.
  String? alignment;
  bool? isRequired;

  AttachmentEntity? attachmentEntity;

  /// Constructor that initializes the controller with attachment field type.
  AttachmentFieldController() : super(FormFieldType.attachment) {
    init();
  }

  @override
  /// Initializes the attachment field controllers.
  init() {
    title = FieldText();
    isRequired = false;
    alignment = AlignmentEnum.center.name;
    return super.init();
  }

  @override
  /// Disposes the attachment field controllers.
  dispose() {
    title!.dispose();
    return super.dispose();
  }

  @override
  /// Prints the model data of the attachment field.
  printModel() {
    return super.printModel();
  }

  @override
  /// Creates a duplicate of the current attachment field controller.
  duplicate() {
    var newController = AttachmentFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the alignment
    newController.alignment = alignment;
    return newController;
  }

  @override
  /// Converts the attachment field controller to a model.
  AttachmentFieldModel toModel({bool isSetAnswer = false}) {
    return AttachmentFieldModel(
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
