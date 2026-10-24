/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: location_field_controller.dart
/// Description: `LocationFieldController` controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/location_drop_down.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class LocationFieldController extends FieldController {
  /// Controllers for hint text in latitude, longitude, and link fields
  FieldText? hintLatitude, hintLongitude, hintLink;

  /// Type of location (e.g., latitude and longitude)
  String? locationType;

  FieldText? title;

  /// Alignment of the location field
  String? alignment;

  /// Flag to determine if the field is required
  bool? isRequired;

  String? answerLatitude, answerLongitude, answerLink;

  /// Constructor initializing the FieldController with location type
  LocationFieldController() : super(FormFieldType.location) {
    init();
  }

  /// Initializes the hint text controllers and other properties
  @override
  init() {
    hintLatitude = FieldText(text: S.current.latitude);
    hintLongitude = FieldText(text: S.current.longitude);
    hintLink = FieldText(text: S.current.fieldTypeLink);
    title = FieldText();

    locationType = LocationDropDown.latitudeAndLongitude.name;
    alignment = AlignmentEnum.center.name;
    isRequired = false;
    return super.init();
  }

  /// Disposes the hint text controllers
  @override
  dispose() {
    hintLatitude!.dispose();
    hintLongitude!.dispose();
    hintLink!.dispose();
    title!.dispose();
    return super.dispose();
  }

  /// Prints the details of the location field model
  @override
  printModel() {
    return super.printModel();
  }

  /// Duplicates the current controller instance
  @override
  duplicate() {
    var newController = LocationFieldController();
    newController.title?.text = title?.text ?? '';
    newController.isRequired = isRequired;
    newController.hintLatitude?.text = hintLatitude?.text ?? '';
    newController.hintLongitude?.text = hintLongitude?.text ?? '';
    newController.hintLink?.text = hintLink?.text ?? '';
    newController.locationType = locationType;
    newController.alignment = alignment;
    return newController;
  }

  @override
  /// Converts the location field controller to a model
  LocationFieldModel toModel({bool isSetAnswer = false}) {
    return LocationFieldModel(
      title: title!.text,
      hintLatitude: hintLatitude?.text ?? '',
      hintLongitude: hintLongitude?.text ?? '',
      hintLink: hintLink?.text ?? '',
      locationType: locationType!,
      alignment: alignment!,
      isRequired: isRequired!,
      latitudeLocationAnswer: isSetAnswer ? answerLatitude : null,
      longitudeLocationAnswer: isSetAnswer ? answerLongitude : null,
      linkLocationAnswer: isSetAnswer ? answerLink : null,
    );
  }
}
