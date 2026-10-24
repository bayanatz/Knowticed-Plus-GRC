/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: link_field_model.dart
/// Description: `LinkFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a link field
class LinkFieldModel extends FieldModel {
  /// Hint text for the link field
  String hint;

  /// Title of the link field
  String title;

  @override
  String? get fieldTitle => title;

  /// Alignment of the link field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Link of the answer
  String? linkAnswer;

  /// Constructor for initializing the LinkFieldModel instance
  LinkFieldModel({
    required this.title,
    required this.isRequired,
    required this.hint,
    required this.alignment,
    this.linkAnswer,
  }) : super(FormFieldType.link);

  /// Method to duplicate the link field model
  /// Returns a new instance of LinkFieldModel with the same properties
  @override
  duplicate() {
    LinkFieldModel newModel = LinkFieldModel(
      title: title,
      isRequired: isRequired,
      hint: hint,
      alignment: alignment,
    );
    return newModel;
  }
}
