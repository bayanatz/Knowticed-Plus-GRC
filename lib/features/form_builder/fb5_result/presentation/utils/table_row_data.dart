/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: table_row_data.dart
/// Description: Row data shown in the results table.
/// Author: Amr Mesbah
/// Created at: 25/3/2025
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/row_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/user_grid_item.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/attachment_field_model.dart';
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
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/time_selector_field_model.dart';

/// One row of the submissions table / CSV export.
class TableRowData {
  String id;
  String firstName;
  String lastName;
  String department;
  String title;
  List<String> answers;

  TableRowData(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.department,
      required this.title,
      required this.answers});

  /// Method Name: [fromUserGridItem]
  ///
  /// Purpose: one table / CSV row for a submitted person. A one-word name
  /// no longer throws (the last name is then empty).
  ///
  /// Parameters:
  /// - [user]: the person and their answers.
  ///
  /// Returns: the row.
  static TableRowData fromUserGridItem(UserGridItem user) {
    final List<String> nameParts = user.person.name.trim().split(' ');
    return TableRowData(
        id: user.person.id,
        firstName: FormatHelper.capitalize(nameParts.first),
        lastName: FormatHelper.capitalize(
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : ''),
        department: FormatHelper.capitalize(user.person.departmentName),
        title: FormatHelper.capitalize(user.person.title),
        answers: _getAnswersFromPages(user.page ?? const []));
  }

  /// Method Name: [_getAnswersFromPages]
  ///
  /// Purpose: This method is responsible for getting the answers from the services_management_module.
  ///
  /// Arguments: [List<PageEntity>] services_management_module
  ///
  /// Returns: [List<String>] answers
  static List<String> _getAnswersFromPages(List<PageEntity> pages) {
    List<String> answers = [];

    for (PageEntity page in pages) {
      for (RowEntity row in page.rows) {
        for (FieldModel field in row.fields) {
          if (field.type == FormFieldType.title) continue;
          switch (field.type) {
            case FormFieldType.textField:
              answers.add((field as TextFieldModel).textAnswer ?? "");
              break;
            case FormFieldType.checkBox:
              List<String> ans = [];
              for (String option
                  in ((field as CheckBoxFieldModel).answers ?? [])) {
                ans.add(option);
              }

              answers.add(ans.join(', '));

              break;

            case FormFieldType.termsAndCondition:
              bool isAccepted =
                  (field as TermsAndConditionsFieldModel).isAccepted ?? false;

              answers.add(isAccepted.toString());
              break;

            case FormFieldType.phone:
              answers.add((field as PhoneFieldModel).phoneAnswer ?? "");
              break;

            case FormFieldType.image:
              List<String> imagesList = [];
              if ((field as ImageFieldModel).images != null) {
                for (int i = 0; i < (field).images!.length; i++) {
                  if ((field).images![i] != null) {
                    imagesList.add((field).images![i]!);
                  }
                }
              }
              String images = _joinList(imagesList);
              answers.add(images);
            case FormFieldType.email:
              answers.add((field as EmailFieldModel).emailAnswer ?? "");
              break;
            case FormFieldType.location:
              String answer = "";
              if ((field as LocationFieldModel).latitudeLocationAnswer !=
                  null) {
                answer +=
                    "${(field).latitudeLocationAnswer} : ${(field).longitudeLocationAnswer}";
              } else {
                answer += "${(field).linkLocationAnswer}";
              }
              answers.add(answer);
            case FormFieldType.dropDown:
              answers.add((field as DropDownFieldModel).currentValue ?? "");
              break;
            case FormFieldType.radio:
              answers.add((field as RadioFieldModel).selectedRadio ?? "");
              break;
            case FormFieldType.description:
              answers.add(
                  (field as DescriptionFieldModel).descriptionAnswer ?? "");
              break;
            case FormFieldType.attachment:
              answers.add(
                  (field as AttachmentFieldModel).attachmentLink?.path ?? "");
              break;
            case FormFieldType.link:
              answers.add((field as LinkFieldModel).linkAnswer ?? "");
              break;
            case FormFieldType.digitalSignature:
              answers.add((field as AttachmentDigitalSignatureFieldModel)
                      .attachmentLink
                      ?.path ??
                  "");
            case FormFieldType.dateSelector:
              answers.add((field as DateFieldModel).answerDate == null
                  ? ""
                  : DateFormat('dd/MM/yyyy').format((field).answerDate!));
              break;
            case FormFieldType.address:
              answers.add(_joinList((field as AddressFieldModel).answers));
              break;
            case FormFieldType.timeSelector:
              answers.add((field as TimeSelectorFieldModel).time ??
                  "${(field).time != null ? ' : ' : ''}${((field).amOrPm ?? "")}");
            case FormFieldType.title:
              /*answers.add((field as TitleFieldModel).title ?? "");*/
              break;
            case FormFieldType.radioTextField:
              answers.add((field as RadioTextFieldModel).selectedRadio ?? "");

              break;
          }
        }
      }
    }

    return answers;
  }

  static String _joinList(List<String>? strings) {
    return strings?.join(', ') ?? "";
  }

  /// Method Name: [getTableList]
  ///
  /// Purpose: the row's cells in table order.
  ///
  /// Returns: [List<String>] the cells.
  List<String> getTableList() {
    List<String> tableList = [];
    tableList.add(id);
    tableList.add(firstName);
    tableList.add(lastName);
    tableList.add(department);
    tableList.add(title);
    tableList.addAll(answers);
    return tableList;
  }
}
