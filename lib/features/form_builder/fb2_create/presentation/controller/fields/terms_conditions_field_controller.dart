/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: terms_conditions_field_controller.dart
/// Description: `TermsConditionsFieldController` controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/terms_and_condition.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class TermsConditionsFieldController extends FieldController {
  // Text controllers for the title, Arabic terms, and English terms
  FieldText? title, termsAr, termsEn;

  // Represents the alignment of the terms and conditions field
  String? alignment;

  // Terms and conditions is ALWAYS required
  bool isRequired = true;

  bool isAccepted = false;

  /// Constructor that initializes the controller with terms and conditions field type
  TermsConditionsFieldController() : super(FormFieldType.termsAndCondition) {
    init();
  }

  @override
  /// Initializes the terms and conditions field controllers
  init() {
    title = FieldText();
    termsAr = FieldText();
    termsEn = FieldText();
    alignment = AlignmentEnum.center.name;
    isRequired = true; // Always required
    isAccepted = false;
    return super.init();
  }

  @override
  /// Disposes the terms and conditions field controllers
  dispose() {
    title?.dispose();
    termsAr?.dispose();
    termsEn?.dispose();
    return super.dispose();
  }

  @override
  /// Prints the model data of the terms and conditions field
  printModel() {
    return super.printModel();
  }

  @override
  /// Creates a duplicate of the current terms and conditions field controller
  duplicate() {
    var newController = TermsConditionsFieldController();
    newController.title?.text = title?.text ?? '';
    newController.termsAr?.text = termsAr?.text ?? '';
    newController.termsEn?.text = termsEn?.text ?? '';
    newController.alignment = alignment;
    newController.isRequired = true; // Always required
    newController.isAccepted = false;
    return newController;
  }

  @override
  /// Converts the terms and conditions field controller to a model
  TermsAndConditionsFieldModel toModel({bool isSetAnswer = false}) {
    return TermsAndConditionsFieldModel(
      title: title?.text ?? '',
      termsAr: termsAr?.text ?? '',
      termsEn: termsEn?.text ?? '',
      alignment: alignment!,
      isRequired: true, // Always required
      isAccepted: isSetAnswer ? isAccepted : null,
    );
  }

  @override
  bool valid() {
    // Check if required and not accepted
    if (isRequired && !isAccepted) {
      return false;
    }

    // Check if title is empty
    if (title?.text.trim().isEmpty ?? true) {
      return false;
    }

    // Check if Arabic terms is empty
    if (termsAr?.text.trim().isEmpty ?? true) {
      return false;
    }

    // Check if English terms is empty
    if (termsEn?.text.trim().isEmpty ?? true) {
      return false;
    }

    return super.valid();
  }
}
