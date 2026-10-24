/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: card_preview_field_builder.dart
/// Description: `buildPreviewFieldWidget()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/terms_conditions_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/terms_controller.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/address_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/attachment_digital_signature_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/attachment_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/check_box_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/date_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/description_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/drop_down_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/email_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/image_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/link_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/location_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/phone_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/radio_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/radio_text_field_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/text_field_result_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/time_selector_preview_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/type_result_widgets/title_result_widget.dart';

/// Builds individual field preview widget based on type.
Widget buildPreviewFieldWidget(
  FormFieldType type,
  int index,
  int rowIndex,
  int pageIndex,
  FieldController fieldController,
  bool isExpand,
) {
  final widgetMap = {
    FormFieldType.dropDown: () => DropDownResultWidget(
          isReadOnly: true,
          isExpand: isExpand,
          fieldController: fieldController as DropDownFieldController,
        ),
    FormFieldType.image: () => ImagePreviewWidget(
          isReadOnly: true,
          fieldController: fieldController as ImageFieldController,
        ),
    FormFieldType.textField: () => TextFieldResultWidget(
          isReadOnly: true,
          isExpand: isExpand,
          fieldController: fieldController as TextFieldController,
        ),
    FormFieldType.email: () => EmailResultWidget(
          isReadOnly: true,
          isExpand: isExpand,
          fieldController: fieldController as EmailFieldController,
        ),
    FormFieldType.phone: () => PhoneResultWidget(
          isReadOnly: true,
          isExpand: isExpand,
          fieldController: fieldController as PhoneFieldController,
        ),
    FormFieldType.location: () => LocationResultWidget(
          isReadOnly: true,
          fieldController: fieldController as LocationFieldController,
        ),
    FormFieldType.radio: () => RadioResultWidget(
          isReadOnly: true,
          fieldController: fieldController as RadioFieldController,
        ),
    FormFieldType.termsAndCondition: () => TermsAndConditionsPreviewWidget(
          isReadOnly: true,
          fieldController: fieldController as TermsConditionsFieldController,
        ),
    FormFieldType.checkBox: () => CheckBoxResultWidget(
          isReadOnly: true,
          fieldController: fieldController as CheckBoxFieldController,
        ),
    FormFieldType.description: () => DescriptionResultWidget(
          isReadOnly: true,
          isExpand: isExpand,
          fieldController: fieldController as DescriptionFieldController,
        ),
    FormFieldType.attachment: () => AttachmentPreviewWidget(
          isReadOnly: true,
          fieldController: fieldController as AttachmentFieldController,
        ),
    FormFieldType.link: () => LinkResultWidget(
          isReadOnly: true,
          isExpand: isExpand,
          fieldController: fieldController as LinkFieldController,
        ),
    FormFieldType.digitalSignature: () =>
        AttachmentDigitalSignatureResultWidget(
          isReadOnly: true,
          fieldController:
              fieldController as AttachmentDigitalSignatureFieldController,
        ),
    FormFieldType.dateSelector: () => DatePreviewWidget(
          isReadOnly: true,
          fieldController: fieldController as DateFieldController,
          isExpand: isExpand,
        ),
    FormFieldType.address: () => AddressPreviewWidget(
          isReadOnly: true,
          fieldController: fieldController as AddressFieldController,
        ),
    FormFieldType.timeSelector: () => TimeSelectorPreviewWidget(
          isReadOnly: true,
          fieldController: fieldController as TimeSelectorFieldController,
        ),
    FormFieldType.title: () => TitleResultWidget(
          fieldController: fieldController as TitleFieldController,
        ),
    FormFieldType.radioTextField: () => RadioTextFieldResultWidget(
          isReadOnly: true,
          fieldController: fieldController as RadioTextFieldController,
        ),
  };
  return widgetMap[type]!();
}
