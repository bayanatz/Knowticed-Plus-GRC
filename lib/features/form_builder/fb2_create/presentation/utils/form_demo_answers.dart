/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_demo_answers.dart
/// Description: `FormDemoAnswers` — puts a sample answer into every field of a
///          form being filled out (the "Fill demo data" button on the fill-out
///          / submission screen), so Submit can be tested in one tap.
/// Author: Amr Mesbah
/// Created at: 13/10/2026
///
/// Image, attachment and signature fields are skipped: they need a real file
/// picked from the device.
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/terms_conditions_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/core/helper/extensions.dart';

class FormDemoAnswers {
  FormDemoAnswers._();

  static const List<String> _addressValues = [
    'Egypt',
    'Cairo',
    'Nasr City',
    '11765',
    '25',
    'Building 4, Apt 12',
  ];

  /// Fills every answerable field in [pages]. Returns how many were filled.
  static int fill(List<PageControllerModel> pages) {
    int filled = 0;
    for (final page in pages) {
      for (final row in page.rows) {
        for (final field in row.controllers) {
          if (_fillOne(field)) filled++;
        }
      }
    }
    return filled;
  }

  static String? _firstOption(Iterable<String> options) {
    for (final o in options) {
      if (o.trim().isNotEmpty) return o;
    }
    return null;
  }

  static bool _fillOne(Object field) {
    if (field is TextFieldController) {
      field.answer = 'Demo User';
    } else if (field is EmailFieldController) {
      field.answer = 'demo.user@company.com';
    } else if (field is PhoneFieldController) {
      field.currentCountry ??= 'EG';
      field.phoneAnswer = '1012345678';
    } else if (field is LinkFieldController) {
      field.answer = 'https://www.example.com';
    } else if (field is DateFieldController) {
      field.answerDate = DateTime.now();
    } else if (field is TimeSelectorFieldController) {
      field.time = '09:30';
      field.amOrPM = 'AM';
    } else if (field is DescriptionFieldController) {
      const text = 'This is a demo answer used to test filling out the form.';
      final int max = field.limitation?.text.toEnglishNumber() ?? 0;
      field.answerController?.text =
          (max > 0 && text.length > max) ? text.substring(0, max) : text;
    } else if (field is DropDownFieldController) {
      field.currentValue = _firstOption(field.hints.map((h) => h.text));
    } else if (field is RadioFieldController) {
      field.selectedRadio = _firstOption(field.hints.map((h) => h.text));
    } else if (field is RadioTextFieldController) {
      field.selectedRadio = _firstOption(field.hints.map((h) => h.text));
    } else if (field is CheckBoxFieldController) {
      final int maxSel = field.maximumSelection?.text.trim().isNotEmpty == true
          ? field.maximumSelection!.text.toEnglishNumber()
          : 2;
      int ticked = 0;
      for (final o in field.options) {
        o.value = ticked < (maxSel <= 0 ? 1 : maxSel) && ticked < 2;
        if (o.value) ticked++;
      }
    } else if (field is AddressFieldController) {
      final int n = field.hints?.length ?? 0;
      field.answers = List<String>.generate(
          n, (i) => i < _addressValues.length ? _addressValues[i] : 'Demo');
    } else if (field is LocationFieldController) {
      field.answerLatitude = '30.0444';
      field.answerLongitude = '31.2357';
      field.answerLink = 'https://maps.google.com/?q=30.0444,31.2357';
    } else if (field is TermsConditionsFieldController) {
      field.isAccepted = true;
    } else {
      return false; // title / image / attachment / signature
    }
    return true;
  }
}
