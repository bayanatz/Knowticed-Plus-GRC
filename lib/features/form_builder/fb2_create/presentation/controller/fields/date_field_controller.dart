/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: date_field_controller.dart
/// Description: `DateFieldController` controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;


import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/date_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class DateFieldController extends FieldController {
  // Text controllers for the hint and title of the date selector field.
  FieldText? hint, title;
  // Represents the alignment of the date selector field.
  String? alignment;
  // Indicates whether this date selector field is required or not.
  bool? isRequired;

  DateTime? answerDate;

  /// Constructor that initializes the controller with date selector field type.
  DateFieldController() : super(FormFieldType.dateSelector) {
    init();
  }

  @override
  /// Initializes the date selector field controllers.
  init() {
    hint = FieldText();
    title = FieldText();
    alignment = AlignmentEnum.center.name;
    isRequired = false;
    return super.init();
  }

  @override
  /// Disposes the date selector field controllers.
  dispose() {
    hint!.dispose();
    title!.dispose();
    return super.dispose();
  }

  @override
  /// Prints the model data of the date selector field.
  printModel() {
    return super.printModel();
  }

  @override
  /// Creates a duplicate of the current date selector field controller.
  duplicate() {
    var newController = DateFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the hint
    newController.hint?.text = hint?.text ?? '';
    // Duplicate the alignment
    newController.alignment = alignment;
    return newController;
  }

  @override
  /// Converts the date selector field controller to a model.
  DateFieldModel toModel({bool isSetAnswer = false}) {
    return DateFieldModel(
      alignment: alignment!,
      isRequired: isRequired!,
      title: title?.text ?? '',
      hint: hint?.text ?? '',
      answerDate: isSetAnswer ? answerDate : null,
    );
  }
}
