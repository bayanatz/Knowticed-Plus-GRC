/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: terms_and_condition.dart
/// Description: `TermsAndConditionsFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

class TermsAndConditionsFieldModel extends FieldModel {
  /// Title of the terms and conditions field
  String title;

  @override
  String? get fieldTitle => title;

  /// Alignment of the terms and conditions field
  String alignment;

  /// Arabic terms and conditions text
  String termsAr;

  /// English terms and conditions text
  String termsEn;

  /// Flag to determine if the field is required (always true for T&C)
  bool isRequired;

  /// Checkbox acceptance status (for submitted forms)
  bool? isAccepted;

  /// Constructor for initializing the TermsAndConditionsFieldModel instance
  TermsAndConditionsFieldModel({
    required this.title,
    required this.termsAr,
    required this.termsEn,
    required this.alignment,
    this.isRequired = true, // Always required
    this.isAccepted,
  }) : super(FormFieldType.termsAndCondition);

  /// Method to duplicate the terms and conditions field model
  /// Returns a new instance of TermsAndConditionsFieldModel with the same properties
  @override
  duplicate() {
    TermsAndConditionsFieldModel newModel = TermsAndConditionsFieldModel(
      title: title,
      termsAr: termsAr,
      termsEn: termsEn,
      alignment: alignment,
      isRequired: true, // Always required
      isAccepted: null, // Reset acceptance in duplicate
    );
    return newModel;
  }
}
