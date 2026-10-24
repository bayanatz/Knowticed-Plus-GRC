/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: description_field_model.dart
/// Description: `DescriptionFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a description field
class DescriptionFieldModel extends FieldModel {
  /// Hint text for the description field
  String hint;

  /// Title of the description field
  String title;

  @override
  String? get fieldTitle => title;

  /// Limitation or maximum length of the description
  String limitation;

  /// Alignment of the description field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  String? descriptionAnswer;

  /// Constructor for initializing the DescriptionFieldModel instance
  DescriptionFieldModel({
    required this.hint,
    required this.title,
    required this.isRequired,
    required this.alignment,
    required this.limitation,
    this.descriptionAnswer,
  }) : super(FormFieldType.description);

  /// Method to duplicate the description field model
  /// Returns a new instance of DescriptionFieldModel with the same properties
  @override
  duplicate() {
    DescriptionFieldModel newModel = DescriptionFieldModel(
      hint: hint,
      title: title,
      isRequired: isRequired,
      alignment: alignment,
      limitation: limitation,
    );
    return newModel;
  }
}
