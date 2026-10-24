/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: title_field_controller.dart
/// Description: `TitleFieldController` controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/title_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';

import 'package:knowticed_plus/core/helper/extensions.dart'
    hide ContextExtension;
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class TitleFieldController extends FieldController {
  // Text controllers for the title and text size of the title field.
  FieldText? title, textSize;
  // Represents the alignment of the title field.
  String? alignment;
  // Indicates whether this title field is required or not.
  bool? isRequired;
  // Indicates whether the title text is bold.
  bool? isBold;
  // Indicates whether the title text is italic.
  bool? isItalic;
  // Indicates whether the title text is underlined.
  bool? isUnderLine;
  // Represents the color of the title text.
  Color? titleColor;

  /// Constructor that initializes the controller with title field type.
  TitleFieldController() : super(FormFieldType.title) {
    init();
  }

  @override
  /// Initializes the title field controllers.
  init() {
    title = FieldText();
    alignment = AlignmentEnum.center.name;
    textSize = FieldText(
      text: NumberToArabic(FormDateTimeHelper.formatInt(8)).doubleDigit,
    );
    isRequired = false;
    isBold = false;
    isItalic = false;
    isUnderLine = false;
    // Theme colour (Home rule 3), not a raw Colors value.
    titleColor = AppColors.black;
    return super.init();
  }

  @override
  /// Disposes the title field controllers.
  dispose() {
    title!.dispose();
    textSize!.dispose();
    return super.dispose();
  }

  @override
  /// Prints the model data of the title field.
  printModel() {
    return super.printModel();
  }

  @override
  /// Creates a duplicate of the current title field controller.
  duplicate() {
    var newController = TitleFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the text size
    newController.textSize?.text = textSize?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the isBold flag
    newController.isBold = isBold;
    // Duplicate the isItalic flag
    newController.isItalic = isItalic;
    // Duplicate the isUnderLine flag
    newController.isUnderLine = isUnderLine;
    // Duplicate the title color
    newController.titleColor = titleColor;
    // Duplicate the alignment
    newController.alignment = alignment;
    return newController;
  }

  @override
  /// Converts the title field controller to a model.
  TitleFieldModel toModel({bool isSetAnswer = false}) {
    return TitleFieldModel(
      title: title!.text,
      alignment: alignment!,
      isRequired: isRequired!,
      isBold: isBold!,
      isItalic: isItalic!,
      isUnderLine: isUnderLine!,
      textSize: textSize!.text.toEnglishNumberAsDouble(),
      // Stored as "Color(0xAARRGGBB)" explicitly — Color.toString() is no
      // longer hex on Flutter 3.27+ (form bug report #16).
      titleColor:
          'Color(0x${titleColor!.toARGB32().toRadixString(16).padLeft(8, '0')})',
    );
  }
}
