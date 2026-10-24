/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: drop_down_field_model.dart
/// Description: `DropDownFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a dropdown field
class DropDownFieldModel extends FieldModel {
  /// Title of the dropdown field
  String title;

  @override
  String? get fieldTitle => title;

  /// Alignment of the dropdown field
  String alignment;

  /// Currently selected value in the dropdown
  String? currentValue;

  /// Flag to determine if the field is required
  bool isRequired;

  /// List of hint texts for the dropdown options
  List<String> hints = [];

  /// Constructor for initializing the DropDownFieldModel instance
  DropDownFieldModel({
    required this.alignment,
    required this.isRequired,
    required this.title,
    required this.hints,
    this.currentValue,
  }) : super(FormFieldType.dropDown);

  /// Method to duplicate the dropdown field model
  /// Returns a new instance of DropDownFieldModel with the same properties
  @override
  duplicate() {
    DropDownFieldModel newModel = DropDownFieldModel(
      alignment: alignment,
      isRequired: isRequired,
      title: title,
      hints: List<String>.from(hints),
      currentValue: currentValue,
    );
    return newModel;
  }
}
