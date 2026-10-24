/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: field_model_mapper.dart
/// Description: Maps every form field to and from the Firestore `ColumnModel`.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/column_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/attachment_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/location_drop_down.dart';
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
import 'package:knowticed_plus/core/helper/extensions.dart';

/// Maps a [FieldModel] to and from the `ColumnModel` saved in Firestore.
extension FieldModelColumnMapper on FieldModel {
  /// Method Name: [toModel]
  ///
  /// Purpose: builds the Firestore column for this field.
  ///
  /// Returns: [ColumnModel]. Throws [UnsupportedError] for an unknown field.
  ColumnModel toModel() {
    final FieldModel field = this;
    if (field is AddressFieldModel) return field._toColumn();
    if (field is AttachmentDigitalSignatureFieldModel) return field._toColumn();
    if (field is AttachmentFieldModel) return field._toColumn();
    if (field is CheckBoxFieldModel) return field._toColumn();
    if (field is DateFieldModel) return field._toColumn();
    if (field is DescriptionFieldModel) return field._toColumn();
    if (field is DropDownFieldModel) return field._toColumn();
    if (field is EmailFieldModel) return field._toColumn();
    if (field is ImageFieldModel) return field._toColumn();
    if (field is LinkFieldModel) return field._toColumn();
    if (field is LocationFieldModel) return field._toColumn();
    if (field is PhoneFieldModel) return field._toColumn();
    if (field is RadioFieldModel) return field._toColumn();
    if (field is RadioTextFieldModel) return field._toColumn();
    if (field is TermsAndConditionsFieldModel) return field._toColumn();
    if (field is TextFieldModel) return field._toColumn();
    if (field is TimeSelectorFieldModel) return field._toColumn();
    if (field is TitleFieldModel) return field._toColumn();
    throw UnsupportedError('Unknown field type: ${field.type}');
  }

  /// Method Name: [fromModel]
  ///
  /// Purpose: builds the field saved in [model].
  ///
  /// Parameters:
  /// - [model]: the Firestore column.
  ///
  /// Returns: the field, or null for an unknown field type.
  static FieldModel? fromModel(ColumnModel model) {
    FormFieldType type = FormFieldType.values.firstWhere((element) {
      return (element.name.toLowerCase() == model.fieldType);
    });
    switch (type) {
      case FormFieldType.image:
        return _imageFieldModelFromColumn(model);
      case FormFieldType.textField:
        return _textFieldModelFromColumn(model);
      case FormFieldType.email:
        return _emailFieldModelFromColumn(model);
      case FormFieldType.phone:
        return _phoneFieldModelFromColumn(model);
      case FormFieldType.location:
        return _locationFieldModelFromColumn(model);
      case FormFieldType.dropDown:
        return _dropDownFieldModelFromColumn(model);
      case FormFieldType.radio:
        return _radioFieldModelFromColumn(model);
      case FormFieldType.checkBox:
        return _checkBoxFieldModelFromColumn(model);

      case FormFieldType.termsAndCondition:
        return _termsAndConditionsFieldModelFromColumn(model);

      case FormFieldType.description:
        return _descriptionFieldModelFromColumn(model);
      case FormFieldType.attachment:
        return _attachmentFieldModelFromColumn(model);
      case FormFieldType.link:
        return _linkFieldModelFromColumn(model);
      case FormFieldType.digitalSignature:
        return _attachmentDigitalSignatureFieldModelFromColumn(model);
      case FormFieldType.dateSelector:
        return _dateFieldModelFromColumn(model);
      case FormFieldType.address:
        return _addressFieldModelFromColumn(model);
      case FormFieldType.timeSelector:
        return _timeSelectorFieldModelFromColumn(model);
      case FormFieldType.title:
        return _titleFieldModelFromColumn(model);
      case FormFieldType.radioTextField:
        return _radioTextFieldModelFromColumn(model);
    }
  }
}

/// `capitalize` without GetX: first letter upper case, the rest lower case.
extension _FieldCapitalize on String {
  String? get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}

extension _AddressFieldModelColumn on AddressFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: null,
      isRequired: isRequired,
      hint: hints.map((e) => e).join(', '),
      fieldType: FormFieldType.address.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: answers?.map((e) => e).join(', '),
    );
  }
}

FieldModel _addressFieldModelFromColumn(ColumnModel model) {
  return AddressFieldModel(
    isRequired: model.isRequired!,
    title: model.title!,
    hints: model.hint!.split(', '),
    answers: model.response?.split(', '),
  );
}

extension _AttachmentDigitalSignatureFieldModelColumn
    on AttachmentDigitalSignatureFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.digitalSignature.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: attachmentLink?.encodedAttachmentData,
    );
  }
}

FieldModel _attachmentDigitalSignatureFieldModelFromColumn(ColumnModel model) {
  return AttachmentDigitalSignatureFieldModel(
    title: model.title!,
    alignment: model.alignment!.capitalize!,
    isRequired: model.isRequired!,
    attachmentLink: model.response == null
        ? null
        : AttachmentEntity.fromDecodedData(model.response!),
  );
}

extension _AttachmentFieldModelColumn on AttachmentFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.attachment.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: attachmentLink?.encodedAttachmentData,
    );
  }
}

FieldModel _attachmentFieldModelFromColumn(ColumnModel model) {
  return AttachmentFieldModel(
    title: model.title!,
    alignment: model.alignment!.capitalize!,
    isRequired: model.isRequired!,
    attachmentLink: model.response == null
        ? null
        : AttachmentEntity.fromDecodedData(model.response!),
  );
}

extension _CheckBoxFieldModelColumn on CheckBoxFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.checkBox.name.toLowerCase(),
      arrangement: arrangement,
      options: options,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: maximumSelection?.toString(),
      response: answers?.map((e) => e).join(', '),
    );
  }
}

FieldModel _checkBoxFieldModelFromColumn(ColumnModel model) {
  return CheckBoxFieldModel(
    title: model.title!,
    isRequired: model.isRequired!,
    options: model.options!.map((e) => e!).toList(),
    maximumSelection:
        model.maxSelection != null ? int.parse(model.maxSelection!) : null,
    alignment: model.alignment!,
    arrangement: model.arrangement!,
    answers: model.response?.split(', '),
  );
}

extension _DateFieldModelColumn on DateFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
      fieldType: FormFieldType.dateSelector.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: answerDate?.toString(),
    );
  }
}

FieldModel _dateFieldModelFromColumn(ColumnModel model) {
  return DateFieldModel(
    alignment: model.alignment!.capitalize!,
    isRequired: model.isRequired!,
    title: model.title!,
    hint: model.hint!,
    answerDate: model.response != null ? DateTime.parse(model.response!) : null,
  );
}

extension _DescriptionFieldModelColumn on DescriptionFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
      fieldType: FormFieldType.description.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: int.parse(limitation),
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: descriptionAnswer,
    );
  }
}

FieldModel _descriptionFieldModelFromColumn(ColumnModel model) {
  return DescriptionFieldModel(
    title: model.title!,
    alignment: model.alignment!.capitalize!,
    isRequired: model.isRequired!,
    hint: model.hint!,
    limitation: model.limitation.toString(),
    descriptionAnswer: model.response,
  );
}

extension _DropDownFieldModelColumn on DropDownFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hints.map((e) => e).join(', '),
      fieldType: FormFieldType.dropDown.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: currentValue,
    );
  }
}

FieldModel _dropDownFieldModelFromColumn(ColumnModel model) {
  return DropDownFieldModel(
    alignment: model.alignment!.capitalize!,
    isRequired: model.isRequired!,
    title: model.title!,
    hints: model.hint!.split(', '),
    currentValue: model.response,
  );
}

extension _EmailFieldModelColumn on EmailFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
      fieldType: FormFieldType.email.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: emailAnswer,
    );
  }
}

FieldModel _emailFieldModelFromColumn(ColumnModel model) {
  return EmailFieldModel(
    isRequired: model.isRequired!,
    title: model.title!,
    alignment: model.alignment!.capitalize!,
    hint: model.hint!,
    emailAnswer: model.response,
  );
}

extension _ImageFieldModelColumn on ImageFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: null,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.image.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: int.parse(limitation),
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: images?.map((e) => e).join(', '),
    );
  }
}

FieldModel _imageFieldModelFromColumn(ColumnModel model) {
  return ImageFieldModel(
    isRequired: model.isRequired!,
    title: model.title!,
    limitation: model.limitation.toString(),
    images: model.response != null
        ? model.response!.split(', ').map((e) => e).toList()
        : [],
  );
}

extension _LinkFieldModelColumn on LinkFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
      fieldType: FormFieldType.link.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: linkAnswer,
    );
  }
}

FieldModel _linkFieldModelFromColumn(ColumnModel model) {
  return LinkFieldModel(
    title: model.title!,
    isRequired: model.isRequired!,
    hint: model.hint!,
    alignment: model.alignment!.capitalize!,
    linkAnswer: model.response,
  );
}

extension _LocationFieldModelColumn on LocationFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: locationType == LocationDropDown.link.name
          ? hintLink
          : '$hintLatitude, $hintLongitude',
      fieldType: FormFieldType.location.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: locationType,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: locationType == LocationDropDown.link.name
          ? linkLocationAnswer
          : '$latitudeLocationAnswer, $longitudeLocationAnswer',
    );
  }
}

FieldModel _locationFieldModelFromColumn(ColumnModel model) {
  return LocationFieldModel(
    title: model.title ?? '',
    isRequired: model.isRequired!,
    alignment: model.alignment!.capitalize!,
    hintLink: model.hint ?? '',
    locationType: model.locationType!,
    hintLongitude: model.locationType == LocationDropDown.link.name
        ? null
        : model.hint?.split(',')[0],
    hintLatitude: model.locationType == LocationDropDown.link.name
        ? null
        : model.hint?.split(',')[1],
  );
}

extension _PhoneFieldModelColumn on PhoneFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.phone.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: (phoneCodeAnswer == null && phoneAnswer == null)
          ? null
          : ' $phoneCodeAnswer, $phoneAnswer',
    );
  }
}

FieldModel _phoneFieldModelFromColumn(ColumnModel model) {
  return PhoneFieldModel(
    isRequired: model.isRequired!,
    title: model.title!,
    alignment: model.alignment!,
    phoneAnswer: model.response?.split(', ')[1],
    phoneCodeAnswer: model.response?.split(', ')[0],
  );
}

extension _RadioFieldModelColumn on RadioFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hints.map((e) => e).join(', '),
      fieldType: FormFieldType.radio.name.toLowerCase(),
      arrangement: arrangement,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: selectedRadio,
    );
  }
}

FieldModel _radioFieldModelFromColumn(ColumnModel model) {
  return RadioFieldModel(
    title: model.title!,
    alignment: model.alignment!.capitalize!,
    isRequired: model.isRequired!,
    hints: model.hint!.split(', '),
    arrangement: model.arrangement!.capitalize!,
    selectedRadio: model.response,
  );
}

extension _RadioTextFieldModelColumn on RadioTextFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: null,
      alignment: null,
      isRequired: isRequired,
      hint: hints.map((e) => e).join(', '),
      fieldType: FormFieldType.radioTextField.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: selectedRadio,
    );
  }
}

FieldModel _radioTextFieldModelFromColumn(ColumnModel model) {
  return RadioTextFieldModel(
    isRequired: model.isRequired ?? false,
    hints: model.hint?.split(', ') ?? [],
    selectedRadio: model.response,
  );
}

extension _TermsAndConditionsFieldModelColumn on TermsAndConditionsFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: true, // Always required
      hint: termsAr, // Store Arabic terms in hint field
      fieldType: FormFieldType.termsAndCondition.name.toLowerCase(),
      arrangement: termsEn, // Store English terms in arrangement field
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: isAccepted?.toString(),
    );
  }
}

FieldModel _termsAndConditionsFieldModelFromColumn(ColumnModel model) {
  return TermsAndConditionsFieldModel(
    title: model.title!,
    termsAr: model.hint ?? '', // Read Arabic terms from hint field
    termsEn:
        model.arrangement ?? '', // Read English terms from arrangement field
    alignment: model.alignment!,
    isRequired: true, // Always required
    isAccepted: model.response != null ? model.response == 'true' : null,
  );
}

extension _TextFieldModelColumn on TextFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: hint,
      fieldType: FormFieldType.textField.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: textAnswer,
    );
  }
}

FieldModel _textFieldModelFromColumn(ColumnModel model) {
  return TextFieldModel(
    isRequired: model.isRequired!,
    title: model.title!,
    alignment: model.alignment!.capitalize!,
    hint: model.hint!,
    textAnswer: model.response,
  );
}

extension _TimeSelectorFieldModelColumn on TimeSelectorFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: null,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.timeSelector.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: time == null ? null : '$time, $amOrPm',
    );
  }
}

FieldModel _timeSelectorFieldModelFromColumn(ColumnModel model) {
  return TimeSelectorFieldModel(
    title: model.title,
    isRequired: model.isRequired,
    time: model.response?.split(',').first,
    amOrPm: model.response?.split(',').last,
  );
}

extension _TitleFieldModelColumn on TitleFieldModel {
  ColumnModel _toColumn() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.title.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: textSize.toString(),
      isBold: isBold,
      isItalic: isItalic,
      isUnderLine: isUnderLine,
      color: titleColor,
      maxSelection: null,
      response: null,
    );
  }
}

FieldModel _titleFieldModelFromColumn(ColumnModel model) {
  return TitleFieldModel(
    title: model.title!,
    isRequired: model.isRequired!,
    alignment: model.alignment!.capitalize!,
    textSize: model.textSize!.toDouble(),
    isUnderLine: model.isUnderLine!,
    isBold: model.isBold!,
    titleColor: model.color!,
    isItalic: model.isItalic!,
  );
}
