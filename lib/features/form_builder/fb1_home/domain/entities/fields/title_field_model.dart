/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: title_field_model.dart
/// Description: `TitleFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a title field
class TitleFieldModel extends FieldModel {
  /// Title of the field
  String title;

  @override
  String? get fieldTitle => title;

  /// Text size of the title
  double textSize;

  /// Alignment of the title field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;

  /// Flag to determine if the title is bold
  bool isBold;

  /// Flag to determine if the title is italic
  bool isItalic;

  /// Flag to determine if the title is underlined
  bool isUnderLine;

  /// Color of the title text
  String titleColor;

  /// Constructor for initializing the TitleFieldModel instance
  TitleFieldModel({
    required this.title,
    required this.isRequired,
    required this.alignment,
    required this.textSize,
    required this.isUnderLine,
    required this.isBold,
    required this.titleColor,
    required this.isItalic,
  }) : super(FormFieldType.title);

  /// Method to duplicate the title field model
  /// Returns a new instance of TitleFieldModel with the same properties
  @override
  duplicate() {
    TitleFieldModel newModel = TitleFieldModel(
      title: title,
      isRequired: isRequired,
      alignment: alignment,
      textSize: textSize,
      isUnderLine: isUnderLine,
      isBold: isBold,
      titleColor: titleColor,
      isItalic: isItalic,
    );
    return newModel;
  }
}
