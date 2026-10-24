/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: field_type.dart
/// Description: `FormFieldType` enum, `kFieldTypeIconSize` constant, extension methods of `FormFieldType`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum FormFieldType {
  image,
  textField,
  email,
  phone,
  location,
  dropDown,
  radio,
  checkBox,
  description,
  attachment,
  link,
  digitalSignature,
  dateSelector,
  address,
  timeSelector,
  title,
  radioTextField,
  termsAndCondition,
}

/// Extension to provide additional functionalities to the FieldType enum.
extension FieldTypeExtension on FormFieldType {
  /// The STABLE, language-independent identifier for the field type.
  ///
  /// This used to double as the on-screen label, which is why
  /// Field types showed English while the rest of the app was in Arabic. It is
  /// Still English on purpose: it is what gets written to Firestore, what
  /// [fromName] parses back, and what `DropdownMenuItem.value` carries, so
  /// Translating it would silently orphan every form already saved. Anything
  /// The user READS must use [label] instead.
  String get name {
    switch (this) {
      case FormFieldType.image:
        return 'Image';
      case FormFieldType.textField:
        return 'Text Field';
      case FormFieldType.email:
        return 'Email';
      case FormFieldType.phone:
        return 'Phone';
      case FormFieldType.location:
        return 'Location';
      case FormFieldType.dropDown:
        return 'Drop Down';
      case FormFieldType.radio:
        return 'Radio';
      case FormFieldType.checkBox:
        return 'Check Box';

      case FormFieldType.termsAndCondition:
        return 'Terms And Condition';

      case FormFieldType.description:
        return 'Description';
      case FormFieldType.attachment:
        return 'Attachment';
      case FormFieldType.link:
        return 'Link';
      case FormFieldType.digitalSignature:
        return 'Attached Digital Signature';
      case FormFieldType.dateSelector:
        return 'Date Selector';
      case FormFieldType.address:
        return 'Address';
      case FormFieldType.timeSelector:
        return 'Time Selector';
      case FormFieldType.title:
        return 'Title';
      case FormFieldType.radioTextField:
        return 'Radio - Text Field';
    }
  }

  /// The translated label for the field type — use this everywhere a human
  /// Reads it. Backed by `intl_en.arb` / `intl_ar.arb`, so it follows the
  /// Active locale instead of being frozen to English like [name].
  String get label {
    final s = S.current;
    switch (this) {
      case FormFieldType.image:
        return s.fieldTypeImage;
      case FormFieldType.textField:
        return s.fieldTypeTextField;
      case FormFieldType.email:
        return s.fieldTypeEmail;
      case FormFieldType.phone:
        return s.fieldTypePhone;
      case FormFieldType.location:
        return s.fieldTypeLocation;
      case FormFieldType.dropDown:
        return s.fieldTypeDropDown;
      case FormFieldType.radio:
        return s.fieldTypeRadio;
      case FormFieldType.checkBox:
        return s.fieldTypeCheckBox;
      case FormFieldType.termsAndCondition:
        return s.fieldTypeTermsAndCondition;
      case FormFieldType.description:
        return s.fieldTypeDescription;
      case FormFieldType.attachment:
        return s.fieldTypeAttachment;
      case FormFieldType.link:
        return s.fieldTypeLink;
      case FormFieldType.digitalSignature:
        return s.fieldTypeDigitalSignature;
      case FormFieldType.dateSelector:
        return s.fieldTypeDateSelector;
      case FormFieldType.address:
        return s.fieldTypeAddress;
      case FormFieldType.timeSelector:
        return s.fieldTypeTimeSelector;
      case FormFieldType.title:
        return s.fieldTypeTitle;
      case FormFieldType.radioTextField:
        return s.fieldTypeRadioTextField;
    }
  }

  /// Returns the icon asset path associated with the enum item.
  String get icon {
    switch (this) {
      case FormFieldType.image:
        return AppAssets.imageIcon;
      case FormFieldType.textField:
        return AppAssets.text;
      case FormFieldType.email:
        return AppAssets.emailIcon;
      case FormFieldType.phone:
        return AppAssets.phoneIcon;
      case FormFieldType.location:
        return AppAssets.locationIcon;
      case FormFieldType.dropDown:
        return AppAssets.dropDownIcon;
      case FormFieldType.radio:
        return AppAssets.radioIcon;
      case FormFieldType.checkBox:
        return AppAssets.checkBoxIcon;
      case FormFieldType.termsAndCondition:
        return AppAssets.checkBoxIcon;
      case FormFieldType.description:
        return AppAssets.descriptionIcon;
      case FormFieldType.attachment:
        return AppAssets.attachmentIcon;
      case FormFieldType.link:
        return AppAssets.linkIcon;
      case FormFieldType.digitalSignature:
        return AppAssets.attachedDigitalSignatureIcon;
      case FormFieldType.dateSelector:
        return AppAssets.calendar;
      case FormFieldType.address:
        return AppAssets.addressIcon;
      case FormFieldType.timeSelector:
        return AppAssets.timeSelectorIcon;
      case FormFieldType.title:
        return AppAssets.text;
      case FormFieldType.radioTextField:
        return AppAssets.radioIcon;
    }
  }

  /// Returns an enum item based on its name.
  static FormFieldType? fromName(String name) {
    return FormFieldType.values.firstWhere(
      (element) => element.name == name,
      orElse: () => FormFieldType.textField,
    );
  }
}
