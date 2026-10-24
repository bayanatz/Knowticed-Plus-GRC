/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: email_field_model.dart
/// Description: `EmailFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for an email field
class EmailFieldModel extends FieldModel {
  /// Hint text for the email field
  String hint;

  /// Title of the email field
  String title;

  @override
  String? get fieldTitle => title;

  /// Alignment of the email field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Email of the answer
  String? emailAnswer;

  /// Constructor for initializing the EmailFieldModel instance
  EmailFieldModel({
    required this.title,
    required this.isRequired,
    required this.alignment,
    required this.hint,
    this.emailAnswer,
  }) : super(FormFieldType.email);

  /// Method to duplicate the email field model
  /// Returns a new instance of EmailFieldModel with the same properties
  @override
  duplicate() {
    EmailFieldModel newModel = EmailFieldModel(
      title: title,
      isRequired: isRequired,
      alignment: alignment,
      hint: hint,
    );
    return newModel;
  }
}
