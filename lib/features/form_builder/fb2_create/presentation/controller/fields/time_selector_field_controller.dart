/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: time_selector_field_controller.dart
/// Description: `TimeSelectorFieldController` controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/time_selector_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class TimeSelectorFieldController extends FieldController {
  // Text controllers for the hint and title of the time selector field.
  FieldText? title;
  // Indicates whether this time selector field is required or not.
  bool? isRequired;
  String? time, amOrPM;

  /// Constructor that initializes the controller with time selector field type.
  TimeSelectorFieldController() : super(FormFieldType.timeSelector) {
    init();
  }

  @override
  /// Initializes the time selector field controllers.
  init() {
    title = FieldText();
    isRequired = false;
    return super.init();
  }

  @override
  /// Disposes the time selector field controllers.
  dispose() {
    title!.dispose();
    return super.dispose();
  }

  @override
  /// Prints the model data of the time selector field.
  printModel() {
    return super.printModel();
  }

  @override
  /// Creates a duplicate of the current time selector field controller.
  duplicate() {
    var newController = TimeSelectorFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    newController.amOrPM = amOrPM;
    newController.time = time;

    return newController;
  }

  @override
  /// Returns the model data of the time selector field.
  TimeSelectorFieldModel toModel({bool isSetAnswer = false}) {
    return TimeSelectorFieldModel(
      title: title?.text,
      time: isSetAnswer ? time : null,
      amOrPm: isSetAnswer ? amOrPM : null,
      isRequired: isRequired,
    );
  }
}
