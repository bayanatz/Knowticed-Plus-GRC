/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: check_box_field_model.dart
/// Description: `CheckBoxFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

class CheckBoxFieldModel extends FieldModel {
  /// Title of the checkbox field
  String title;

  @override
  String? get fieldTitle => title;

  /// Alignment of the checkbox field
  String alignment;

  /// Arrangement of the checkbox options (e.g., vertical, horizontal)
  String arrangement;

  /// Maximum number of selections allowed
  int? maximumSelection;

  /// Flag to determine if the field is required
  bool isRequired;

  /// List of options for the checkbox field
  List<String> options = [];

  List<String>? answers;

  /// Constructor for initializing the CheckBoxFieldModel instance
  CheckBoxFieldModel({
    required this.title,
    required this.isRequired,
    required this.options,
    this.maximumSelection,
    required this.arrangement,
    required this.alignment,
    this.answers,
  }) : super(FormFieldType.checkBox);

  /// Method to duplicate the checkbox field model
  /// Returns a new instance of CheckBoxFieldModel with the same properties
  @override
  duplicate() {
    CheckBoxFieldModel newModel = CheckBoxFieldModel(
      title: title,
      isRequired: isRequired,
      options: List<String>.from(options),
      maximumSelection: maximumSelection,
      arrangement: arrangement,
      alignment: alignment,
    );
    return newModel;
  }
}
