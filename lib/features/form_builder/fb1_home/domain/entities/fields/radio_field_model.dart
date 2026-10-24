/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: radio_field_model.dart
/// Description: `RadioFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a radio field
class RadioFieldModel extends FieldModel {
  /// Title of the radio field
  String title;

  @override
  String? get fieldTitle => title;

  /// Alignment of the radio field
  String alignment;

  /// Arrangement of the radio options (e.g., vertical, horizontal)
  String arrangement;

  /// Currently selected radio option
  String? selectedRadio;

  /// Flag to determine if the field is required
  bool isRequired;

  /// List of hint texts for the radio options
  List<String> hints = [];

  /// Constructor for initializing the RadioFieldModel instance
  RadioFieldModel({
    required this.title,
    required this.alignment,
    required this.isRequired,
    required this.hints,
    required this.arrangement,
    this.selectedRadio,
  }) : super(FormFieldType.radio);

  /// Method to duplicate the radio field model
  /// Returns a new instance of RadioFieldModel with the same properties
  @override
  duplicate() {
    RadioFieldModel newModel = RadioFieldModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hints: List<String>.from(hints),
      arrangement: arrangement,
      selectedRadio: selectedRadio,
    );
    return newModel;
  }
}
