/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: field_controller_mapper.dart
/// Description: Builds the editor controllers for a form field, row, page and form.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/terms_conditions_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/date_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/description_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/email_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/image_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/link_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/radio_text_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/terms_and_condition.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/time_selector_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/title_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/row_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/row_controller_model.dart';
import 'package:knowticed_plus/core/helper/extensions.dart'
    hide ContextExtension;
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

/// Builds the editor controllers for a whole form.
extension FormEntityControllerMapper on FormEntity {
  /// Method Name: [toControllers]
  ///
  /// Purpose: one page controller per page of the form.
  ///
  /// Returns: the page controllers.
  List<PageControllerModel> toControllers() =>
      pages.map((page) => page.toController()).toList();
}

/// Builds the editor controller for a page.
extension PageEntityControllerMapper on PageEntity {
  /// Method Name: [toController]
  ///
  /// Purpose: builds the page controller (one row controller per row).
  ///
  /// Parameters:
  /// - [isSetData]: true to also copy the saved answers.
  ///
  /// Returns: [PageControllerModel].
  PageControllerModel toController({bool isSetData = false}) {
    return PageControllerModel(
      rows: rows.map((row) => row.toController(isSetData: isSetData)).toList(),
    );
  }
}

/// Builds the editor controller for a row.
extension RowEntityControllerMapper on RowEntity {
  /// Method Name: [toController]
  ///
  /// Purpose: builds the row controller (one field controller per field).
  ///
  /// Parameters:
  /// - [isSetData]: true to also copy the saved answers.
  ///
  /// Returns: [RowControllerModel].
  RowControllerModel toController({bool isSetData = false}) {
    final List<FieldController> controllers = [];
    for (final element in fields) {
      controllers.add(element.toController(isSetData: isSetData)!);
    }
    final RowControllerModel model = RowControllerModel(
      controllers: controllers,
    );
    model.numOfColumn!.text = FormDateTimeHelper.formatInt(controllers.length);
    return model;
  }
}

/// Builds the editor controller for a [FieldModel].
extension FieldModelControllerMapper on FieldModel {
  /// Method Name: [toController]
  ///
  /// Purpose: builds the editor controller for this field.
  ///
  /// Parameters:
  /// - [isSetData]: true to also copy the saved answer.
  ///
  /// Returns: the controller, or null for an unknown field.
  FieldController? toController({bool isSetData = false}) {
    final FieldModel field = this;
    if (field is AddressFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is AttachmentDigitalSignatureFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is AttachmentFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is CheckBoxFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is DateFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is DescriptionFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is DropDownFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is EmailFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is ImageFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is LinkFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is LocationFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is PhoneFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is RadioFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is RadioTextFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is TermsAndConditionsFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is TextFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is TimeSelectorFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    if (field is TitleFieldModel) {
      return field._toController(isSetData: isSetData);
    }
    return null;
  }
}

extension _AddressFieldModelController on AddressFieldModel {
  AddressFieldController _toController({bool isSetData = false}) {
    AddressFieldController controller = AddressFieldController();
    List<FieldText> hintsController = [];
    for (var element in hints) {
      hintsController.add(FieldText(text: element));
    }
    controller.hints = hintsController;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    if (isSetData) controller.answers = answers;
    return controller;
  }
}

extension _AttachmentDigitalSignatureFieldModelController
    on AttachmentDigitalSignatureFieldModel {
  AttachmentDigitalSignatureFieldController _toController({
    bool isSetData = false,
  }) {
    AttachmentDigitalSignatureFieldController controller =
        AttachmentDigitalSignatureFieldController();
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.isRequired = isRequired;
    controller.attachmentEntity = attachmentLink;
    return controller;
  }
}

extension _AttachmentFieldModelController on AttachmentFieldModel {
  AttachmentFieldController _toController({bool isSetData = false}) {
    AttachmentFieldController controller = AttachmentFieldController();
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.isRequired = isRequired;
    if (isSetData) {
      controller.attachmentEntity = attachmentLink;
      /*     if (attachmentLink != null) {
        if (!attachmentLink!.contains('http')) {
          controller.file = File(attachmentLink!);
        }
      }*/
    }
    return controller;
  }
}

extension _CheckBoxFieldModelController on CheckBoxFieldModel {
  CheckBoxFieldController _toController({bool isSetData = false}) {
    CheckBoxFieldController controller = CheckBoxFieldController();
    List<CheckboxOptions> hintsController = [];
    for (var element in options) {
      hintsController.add(
        CheckboxOptions(
          option: FieldText(text: element),
          value: answers?.contains(element) ?? false,
        ),
      );
    }
    controller.options = hintsController;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.arrangement = arrangement;
    controller.maximumSelection!.text = maximumSelection == null
        ? ''
        : FormDateTimeHelper.formatInt(maximumSelection!);
    return controller;
  }
}

extension _DateFieldModelController on DateFieldModel {
  DateFieldController _toController({bool isSetData = false}) {
    DateFieldController controller = DateFieldController();
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.hint!.text = hint;
    controller.isRequired = isRequired;
    if (isSetData) controller.answerDate = answerDate;
    return controller;
  }
}

extension _DescriptionFieldModelController on DescriptionFieldModel {
  DescriptionFieldController _toController({bool isSetData = false}) {
    DescriptionFieldController controller = DescriptionFieldController();
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.hint!.text = hint;
    controller.isRequired = isRequired;
    controller.limitation!.text = limitation;
    controller.answerController!.text = descriptionAnswer ?? "";
    return controller;
  }
}

extension _DropDownFieldModelController on DropDownFieldModel {
  DropDownFieldController _toController({bool isSetData = false}) {
    DropDownFieldController controller = DropDownFieldController();
    List<FieldText> hintsController = [];
    for (var element in hints) {
      hintsController.add(FieldText(text: element));
    }
    if (isSetData) controller.currentValue = currentValue;
    controller.hints = hintsController;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    return controller;
  }
}

extension _EmailFieldModelController on EmailFieldModel {
  EmailFieldController _toController({bool isSetData = false}) {
    EmailFieldController controller = EmailFieldController();

    controller.hint!.text = hint;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    if (isSetData) controller.answer = emailAnswer;

    return controller;
  }
}

extension _ImageFieldModelController on ImageFieldModel {
  ImageFieldController _toController({bool isSetData = false}) {
    ImageFieldController controller = ImageFieldController();
    controller.limitation!.text = limitation;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.insertImagesList(limitation);
    controller.imagesLink = images ?? controller.imagesLink;

    return controller;
  }
}

extension _LinkFieldModelController on LinkFieldModel {
  LinkFieldController _toController({bool isSetData = false}) {
    LinkFieldController controller = LinkFieldController();

    controller.hint!.text = hint;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    if (isSetData) controller.answer = linkAnswer;
    return controller;
  }
}

extension _LocationFieldModelController on LocationFieldModel {
  LocationFieldController _toController({bool isSetData = false}) {
    LocationFieldController controller = LocationFieldController();
    controller.title!.text = title;
    controller.hintLatitude?.text = hintLatitude ?? '';
    controller.hintLongitude?.text = hintLongitude ?? '';
    controller.hintLink?.text = hintLink ?? '';
    controller.isRequired = isRequired;
    controller.locationType = locationType;
    controller.alignment = alignment;
    if (isSetData) {
      controller.answerLatitude = latitudeLocationAnswer;
      controller.answerLongitude = longitudeLocationAnswer;
      controller.answerLink = linkLocationAnswer;
    }
    return controller;
  }
}

extension _PhoneFieldModelController on PhoneFieldModel {
  PhoneFieldController _toController({bool isSetData = false}) {
    PhoneFieldController controller = PhoneFieldController();

    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    if (isSetData) {
      controller.phoneAnswer = phoneAnswer;
      controller.currentCountry = phoneCodeAnswer;
    }
    return controller;
  }
}

extension _RadioFieldModelController on RadioFieldModel {
  RadioFieldController _toController({bool isSetData = false}) {
    RadioFieldController controller = RadioFieldController();
    List<FieldText> hintsController = [];
    for (var element in hints) {
      hintsController.add(FieldText(text: element));
    }
    controller.hints = hintsController;
    controller.arrangement = arrangement;
    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    if (isSetData) controller.selectedRadio = selectedRadio;
    return controller;
  }
}

extension _RadioTextFieldModelController on RadioTextFieldModel {
  RadioTextFieldController _toController({bool isSetData = false}) {
    RadioTextFieldController controller = RadioTextFieldController();

    controller.isRequired = isRequired;
    List<FieldText> hintsController = [];
    for (var element in hints) {
      hintsController.add(FieldText(text: element));
    }
    controller.hints = hintsController;
    if (isSetData) {
      controller.selectedRadio = selectedRadio;
    }
    return controller;
  }
}

extension _TermsAndConditionsFieldModelController
    on TermsAndConditionsFieldModel {
  TermsConditionsFieldController _toController({bool isSetData = false}) {
    TermsConditionsFieldController controller =
        TermsConditionsFieldController();
    controller.title!.text = title;
    controller.termsAr!.text = termsAr;
    controller.termsEn!.text = termsEn;
    controller.alignment = alignment;
    controller.isRequired = true; // Always required
    controller.isAccepted = isAccepted ?? false;
    return controller;
  }
}

extension _TextFieldModelController on TextFieldModel {
  TextFieldController _toController({bool isSetData = false}) {
    TextFieldController controller = TextFieldController();

    controller.isRequired = isRequired;
    controller.title!.text = title;
    controller.alignment = alignment;
    controller.hint!.text = hint;
    if (isSetData) controller.answer = textAnswer;
    return controller;
  }
}

extension _TimeSelectorFieldModelController on TimeSelectorFieldModel {
  TimeSelectorFieldController _toController({bool isSetData = false}) {
    TimeSelectorFieldController controller = TimeSelectorFieldController();

    controller.isRequired = isRequired;
    controller.amOrPM = amOrPm ?? 'AM';
    controller.time = time;
    controller.title!.text = title ?? '';

    return controller;
  }
}

extension _TitleFieldModelController on TitleFieldModel {
  TitleFieldController _toController({bool isSetData = false}) {
    TitleFieldController controller = TitleFieldController();

    controller.title!.text = title;
    controller.isRequired = isRequired;
    controller.alignment = alignment;
    controller.textSize!.text = FormDateTimeHelper.formatInt(textSize.toInt())
        .doubleDigit;
    controller.isUnderLine = isUnderLine;
    controller.isBold = isBold;
    controller.titleColor = titleColor.toColor();
    controller.isItalic = isItalic;

    return controller;
  }
}
