/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: radio_text_field_model.dart
/// Description: `RadioTextFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a radio text field
class RadioTextFieldModel extends FieldModel {
  /// List of hint texts for the radio options
  List<String> hints = [];

  /// Flag to determine if the field is required
  bool isRequired;
  String? selectedRadio;

  /// Constructor for initializing the RadioTextFieldModel instance
  RadioTextFieldModel({
    required this.isRequired,
    required this.hints,
    this.selectedRadio,
  }) : super(FormFieldType.radioTextField);

  /// Method to duplicate the radio text field model
  /// Returns a new instance of RadioTextFieldModel with the same properties
  @override
  duplicate() {
    RadioTextFieldModel newModel = RadioTextFieldModel(
      isRequired: isRequired,
      selectedRadio: selectedRadio,
      hints: List<String>.from(hints),
    );
    return newModel;
  }
}
