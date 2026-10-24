/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: text_field_model.dart
/// Description: `TextFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a text field
class TextFieldModel extends FieldModel {
  /// Hint text for the text field
  String hint;

  /// Title of the text field
  String title;

  @override
  String? get fieldTitle => title;

  /// Alignment of the text field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  String? textAnswer;

  /// Constructor for initializing the TextFieldModel instance
  TextFieldModel({
    required this.title,
    required this.alignment,
    required this.isRequired,
    required this.hint,
    this.textAnswer,
  }) : super(FormFieldType.textField);

  /// Method to duplicate the text field model
  /// Returns a new instance of TextFieldModel with the same properties
  @override
  duplicate() {
    TextFieldModel newModel = TextFieldModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
    );
    return newModel;
  }
}
