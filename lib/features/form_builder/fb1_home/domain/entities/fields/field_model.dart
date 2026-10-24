/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: field_model.dart
/// Description: `FieldModel`, the base of every form field. Plain data only: the Firestore mapping lives in data/mappers/field_model_mapper.dart, the editor controllers in presentation/controller/fields/field_controller_mapper.dart and the Storage uploads in the response repository.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Base class of every form field.
class FieldModel {
  /// Type of the field
  FormFieldType type;

  /// Constructor for initializing the FieldModel instance
  FieldModel(this.type);

  /// The field's title, or null for a field type that has none.
  String? get fieldTitle => null;

  /// Method Name: [duplicate]
  ///
  /// Purpose: copies the field definition (without the answer).
  ///
  /// Returns: a new instance, or null for the base class.
  FieldModel? duplicate() {
    return null;
  }
}
