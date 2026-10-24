/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: phone_field_controller.dart
/// Description: `PhoneFieldController` controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;


import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class PhoneFieldController extends FieldController {
  // Text controller for the title of the phone field.
  FieldText? title;
  // Represents the alignment of the phone field.
  String? alignment, currentCountry;
  // Indicates whether this phone field is required or not.
  bool? isRequired;

  String? phoneAnswer;

  /// Constructor that initializes the controller with phone field type.
  PhoneFieldController() : super(FormFieldType.phone) {
    init();
  }

  @override
  /// Initializes the phone field controllers.
  init() {
    title = FieldText();
    isRequired = false;
    alignment = AlignmentEnum.center.name;
    return super.init();
  }

  @override
  /// Disposes the phone field controllers.
  dispose() {
    title!.dispose();
    return super.dispose();
  }

  @override
  /// Prints the model data of the phone field.
  printModel() {
    return super.printModel();
  }

  @override
  /// Creates a duplicate of the current phone field controller.
  duplicate() {
    var newController = PhoneFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the alignment
    newController.alignment = alignment;
    return newController;
  }

  @override
  /// Converts the phone field controller to a model.
  PhoneFieldModel toModel({bool isSetAnswer = false}) {
    return PhoneFieldModel(
      title: title!.text,
      isRequired: isRequired!,
      alignment: alignment!,
      phoneAnswer: isSetAnswer ? phoneAnswer : null,
      // Bug report p.39 ("where is the country code"): the country is only
      // set when the user CHANGES the picker, so a submission left on the
      // default (+20) saved `null` and the results showed "null". The picker
      // falls back to Egypt (CountryParseHelper), so the answer does too.
      phoneCodeAnswer: isSetAnswer
          ? ((currentCountry == null || currentCountry!.trim().isEmpty)
                ? 'EG'
                : currentCountry)
          : null,
    );
  }
}
