/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: phone_field_model.dart
/// Description: `PhoneFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a phone field
class PhoneFieldModel extends FieldModel {
  /// Title of the phone field
  String title;

  @override
  String? get fieldTitle => title;

  /// Alignment of the phone field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Phone of the answer
  String? phoneAnswer;

  /// Phone code of the answer
  String? phoneCodeAnswer;

  /// Constructor for initializing the PhoneFieldModel instance
  PhoneFieldModel({
    required this.isRequired,
    required this.alignment,
    required this.title,
    this.phoneAnswer,
    this.phoneCodeAnswer,
  }) : super(FormFieldType.phone);

  /// Method to duplicate the phone field model
  /// Returns a new instance of PhoneFieldModel with the same properties
  @override
  duplicate() {
    PhoneFieldModel newModel = PhoneFieldModel(
      isRequired: isRequired,
      alignment: alignment.isEmpty
          ? alignment
          : '${alignment[0].toUpperCase()}${alignment.substring(1).toLowerCase()}',
      title: title,
    );
    return newModel;
  }
}
