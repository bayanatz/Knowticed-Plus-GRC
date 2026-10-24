/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: address_field_controller.dart
/// Description: `AddressFieldController` controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;


import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class AddressFieldController extends FieldController {
  // Text controller for the title of the address field.
  FieldText? title;
  // List of text controllers for the address field hints.
  List<FieldText>? hints;
  List<String>? answers = [];
  // Indicates whether this address field is required or not.
  bool? isRequired;

  /// Constructor that initializes the controller with address field type.
  AddressFieldController() : super(FormFieldType.address) {
    init();
  }

  @override
  /// Initializes the address field controllers.
  @override
  init() {
    title = FieldText(text: S.current.address);
    hints = [];
    hints!.addAll([
      FieldText(text: S.current.country),
      FieldText(text: S.current.stateOrProvince),
      FieldText(text: S.current.city),
      FieldText(text: S.current.postalCode),
      FieldText(text: S.current.fbStreetNumber),
      FieldText(
        text: S.current.buildingApartment, // 6th field with unique name
      ),
    ]);
    isRequired = false;
    return super.init();
  }

  @override
  /// Disposes the address field controllers.
  dispose() {
    title?.dispose();
    for (var hint in hints!) {
      hint.dispose();
    }
    return super.dispose();
  }

  @override
  /// Prints the model data of the address field.
  printModel() {
    return super.printModel();
  }

  @override
  /// Creates a duplicate of the current address field controller.
  duplicate() {
    var newController = AddressFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the list of hints
    newController.hints = [];
    newController.hints!.addAll(hints!.map((e) => FieldText(text: e.text)));
    return newController;
  }

  @override
  /// Converts the address field controller to a model.
  AddressFieldModel toModel({bool isSetAnswer = false}) {
    return AddressFieldModel(
      title: title?.text ?? '',
      hints: hints!.map((e) => e.text).toList(),
      isRequired: isRequired ?? false,
      answers: isSetAnswer ? answers : null,
    );
  }
}
