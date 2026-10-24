/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: result_table_headers.dart
/// Description: `buildResultTableHeaders()`, the translated column titles of
///              the submissions table and of the CSV export.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
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
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/terms_and_condition.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/time_selector_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';

/// Function Name: [buildResultTableHeaders]
///
/// Purpose: the column titles: the person's details, then one column per
/// answered field (title fields have no column).
///
/// Parameters:
/// - [form]: the form.
///
/// Returns: the translated titles, in table order.
List<String> buildResultTableHeaders(FormEntity form) {
  List<String> headers = [];
  headers.add(S.current.employeeId);
  headers.add(S.current.firstName);
  headers.add(S.current.lastName);
  headers.add(S.current.department);
  headers.add(S.current.jobTitle);

  for (PageEntity page in form.pages) {
    for (var row in page.rows) {
      for (var field in row.fields) {
        if (field.type == FormFieldType.title) continue;
        switch (field.type) {
          case FormFieldType.textField:
            headers.add((field as TextFieldModel).title);
            break;
          case FormFieldType.checkBox:
            headers.add((field as CheckBoxFieldModel).title);
            break;

          case FormFieldType.termsAndCondition:
            headers.add((field as TermsAndConditionsFieldModel).title);
            break;

          case FormFieldType.phone:
            headers.add((field as PhoneFieldModel).title);
            break;
          case FormFieldType.image:
            headers.add((field as ImageFieldModel).title);
            break;
          case FormFieldType.link:
            headers.add((field as LinkFieldModel).title);
            break;
          case FormFieldType.email:
            headers.add((field as EmailFieldModel).title);
            break;
          case FormFieldType.radio:
            headers.add((field as RadioFieldModel).title);
            break;
          case FormFieldType.radioTextField:
            headers.add(S.current.fieldTypeRadioTextField);
            break;
          case FormFieldType.title:
          case FormFieldType.location:
            headers.add(S.current.fieldTypeLocation);
          case FormFieldType.dropDown:
            headers.add((field as DropDownFieldModel).title);
            break;
          case FormFieldType.description:
            headers.add((field as DescriptionFieldModel).title);
            break;
          case FormFieldType.attachment:
            headers.add((field as AttachmentFieldModel).title);
            break;
          case FormFieldType.digitalSignature:
            headers.add((field as AttachmentDigitalSignatureFieldModel).title);
            break;
          case FormFieldType.dateSelector:
            headers.add((field as DateFieldModel).title);
            break;
          case FormFieldType.address:
            headers.add((field as AddressFieldModel).title);
            break;
          case FormFieldType.timeSelector:
            headers.add((field as TimeSelectorFieldModel).title ?? "");
            break;
        }
      }
    }
  }

  return headers;
}
