/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: address_field_model.dart
/// Description: `AddressFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

class AddressFieldModel extends FieldModel {
  /// Title of the address field
  String title;

  @override
  String? get fieldTitle => title;

  /// List of hint texts for the address field
  List<String> hints;

  /// Flag to determine if the field is required
  bool isRequired;

  /// List of answers for the address field
  List<String>? answers;

  /// Constructor for initializing the AddressFieldModel instance
  AddressFieldModel(
      {required this.hints,
      required this.title,
      required this.isRequired,
      this.answers})
      : super(FormFieldType.address);

  /// Method to duplicate the address field model
  /// Returns a new instance of AddressFieldModel with the same properties
  @override
  duplicate() {
    AddressFieldModel newModel =
        AddressFieldModel(hints: hints, title: title, isRequired: isRequired);
    return newModel;
  }
}
