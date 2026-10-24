/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: date_field_model.dart
/// Description: `DateFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a date field
class DateFieldModel extends FieldModel {
  /// Hint text for the date field
  String hint;

  /// Title of the date field
  String title;

  @override
  String? get fieldTitle => title;

  /// Alignment of the date field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Date of the answer
  DateTime? answerDate;

  /// Constructor for initializing the DateFieldModel instance
  DateFieldModel({
    required this.alignment,
    required this.isRequired,
    required this.title,
    required this.hint,
    this.answerDate,
  }) : super(FormFieldType.dateSelector);

  /// Method to duplicate the date field model
  /// Returns a new instance of DateFieldModel with the same properties
  @override
  duplicate() {
    DateFieldModel newModel = DateFieldModel(
      alignment: alignment,
      isRequired: isRequired,
      title: title,
      hint: hint,
    );
    return newModel;
  }
}
