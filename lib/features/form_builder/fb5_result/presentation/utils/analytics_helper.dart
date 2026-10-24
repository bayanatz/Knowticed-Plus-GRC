/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: analytics_helper.dart
/// Description: `AnalyticsHelper`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:country_picker/country_picker.dart';

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/date_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/email_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/link_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/time_selector_field_model.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/description_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/phone_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/text_field_model.dart';
import 'package:knowticed_plus/features/form_builder/helpers/country_parse_helper.dart';

/// Which analytics each field type has, and its answers as text.
abstract class AnalyticsHelper {
  /// Safely resolves a country from a phone dial code, returning `null`
  /// instead of throwing when the code can't be parsed. Keeps try/catch out
  /// of UI widgets (§11.2) — parsing safety lives in this util (§11.1).
  static Country? safeParsePhoneCode(String dialCode) {
    // The stored value is the picker's
    // ISO country code ("EG") — and older rows carry a leading space or the
    // literal "null" — so it is cleaned, tried as an ISO code first, then as
    // a dial code ("20" / "+20").
    final String code = dialCode.trim().replaceAll('+', '');
    if (code.isEmpty || code.toLowerCase() == 'null') return null;
    try {
      return CountryParser.parseCountryCode(code);
    } catch (_) {}
    try {
      return CountryParser.parsePhoneCode(code);
    } catch (_) {
      return null;
    }
  }

  /// "+20" for a stored phone country value, or "" when there is none.
  /// The results used to print the raw
  /// stored value, which read "null" for every default-country answer.
  ///
  /// Large-screen bug report p.8 ("where is the country code"): answers
  /// saved before the default-country fix stored `null` for a number left on
  /// the picker's default country. That default is Egypt
  /// ([CountryParseHelper]), so those answers now show "+20" too.
  static String phoneCodeLabel(String storedCode) {
    final Country? country = phoneCountry(storedCode);
    return country == null ? '' : '+${country.phoneCode}';
  }

  /// The country of a stored phone answer, falling back to the phone
  /// picker's default country when nothing (or "null") was stored.
  static Country? phoneCountry(String storedCode) =>
      safeParsePhoneCode(storedCode) ??
      CountryParseHelper.parseCountrySafely(null);

  /// Method Name: [getFieldAnswer]
  ///
  /// Purpose: an answer as the text the analytics count and show.
  ///
  /// Parameters:
  /// - [model]: the answered field.
  ///
  /// Returns: the answer text ('' when unanswered).
  static dynamic getFieldAnswer(FieldModel model) {
    switch (model.type) {
      case FormFieldType.dropDown:
        {
          return (model as DropDownFieldModel).currentValue ?? "";
        }
      case FormFieldType.radio:
        {
          return (model as RadioFieldModel).selectedRadio ?? "";
        }
      case FormFieldType.description:
        {
          return (model as DescriptionFieldModel).descriptionAnswer ?? "";
        }
      case FormFieldType.textField:
        {
          return (model as TextFieldModel).textAnswer ?? "";
        }
      case FormFieldType.email:
        {
          return (model as EmailFieldModel).emailAnswer ?? "";
        }
      case FormFieldType.dateSelector:
        {
          return (model as DateFieldModel).answerDate == null
              ? ""
              // The app's current locale (set by the l10n loader).
              : DateFormat("dd/MM/yyyy").format((model).answerDate!);
        }
      case FormFieldType.link:
        {
          return (model as LinkFieldModel).linkAnswer ?? "";
        }
      case FormFieldType.location:
        {
          String ans = "";
          if ((model as LocationFieldModel).locationType.toLowerCase() ==
              "link") {
            ans = (model).linkLocationAnswer ?? "";
          } else {
            ans = (model).latitudeLocationAnswer ?? "";
            ans += ",";
            ans += (model).longitudeLocationAnswer ?? "";
          }
          return ans;
        }
      case FormFieldType.phone:
        {
          String ans = "";
          ans += (model as PhoneFieldModel).phoneCodeAnswer ?? "";
          ans += "-";
          ans += (model).phoneAnswer ?? "";
          return ans;
        }
      case FormFieldType.address:
        {
          List<String> answers = (model as AddressFieldModel).answers ?? [];
          String ans = "";

          if (answers.isEmpty || answers.first.isEmpty) {
            answers = List.filled(model.hints.length, " ");
          }
          ans = answers.join(',   ');

          return ans;
        }
      case FormFieldType.timeSelector:
        {
          String ans = "";
          ans += (model as TimeSelectorFieldModel).time ?? "";
          ans += " ";
          ans += (model).amOrPm ?? "";

          return ans;
        }
      case FormFieldType.checkBox:
        {
          List<String> ans = [];
          ans = (model as CheckBoxFieldModel).answers ?? [];
          return ans.join(', ');
        }

      default:
        return "";
    }
  }

  /// Method Name: [doughnutChartAnalytics]
  ///
  /// Returns: true for the field types shown as a doughnut chart.
  static bool doughnutChartAnalytics(FormFieldType type) {
    switch (type) {
      case FormFieldType.dropDown:
        return true;
      case FormFieldType.radio:
        return true;
      default:
        return false;
    }
  }

  /// Method Name: [isChartWithFixedOptions]
  ///
  /// Returns: true for the field types whose chart lists every option, even unpicked ones.
  static bool isChartWithFixedOptions(FormFieldType type) {
    switch (type) {
      case FormFieldType.dropDown:
        return true;
      case FormFieldType.radio:
        return true;
      case FormFieldType.checkBox:
        return true;
      default:
        return false;
    }
  }

  /// Method Name: [barChartAnalytics]
  ///
  /// Returns: true for the field types shown as a bar chart.
  static bool barChartAnalytics(FormFieldType type) {
    switch (type) {
      case FormFieldType.checkBox:
        return true;
      case FormFieldType.timeSelector:
        return true;
      case FormFieldType.dateSelector:
        return true;
      case FormFieldType.address:
        return true;
      default:
        return false;
    }
  }

  /// Method Name: [answerAnalytics]
  ///
  /// Returns: true for the field types that list each person's answer.
  static bool answerAnalytics(FormFieldType type) {
    switch (type) {
      case FormFieldType.textField:
        return true;
      case FormFieldType.email:
        return true;
      case FormFieldType.phone:
        return true;
      case FormFieldType.location:
        return true;
      case FormFieldType.description:
        return true;
      case FormFieldType.link:
        return true;
      case FormFieldType.timeSelector:
        return true;
      case FormFieldType.dateSelector:
        return true;
      case FormFieldType.address:
        return true;
      default:
        return false;
    }
  }

  /// Method Name: [isHasAnalytics]
  ///
  /// Returns: false for the field types with no analytics (title, image, attachment, signature, radio-text).
  static bool isHasAnalytics(FormFieldType type) {
    switch (type) {
      case FormFieldType.title:
        return false;
      case FormFieldType.image:
        return false;
      case FormFieldType.attachment:
        return false;
      case FormFieldType.digitalSignature:
        return false;
      case FormFieldType.radioTextField:
        return false;
      default:
        return true;
    }
  }

  /// Method Name: [hasTextFieldAndAggregated]
  ///
  /// Returns: true for the field types shown both as a chart and as a list of answers.
  static bool hasTextFieldAndAggregated(FormFieldType type) {
    switch (type) {
      case FormFieldType.timeSelector:
        return true;
      case FormFieldType.dateSelector:
        return true;
      case FormFieldType.address:
        return true;
      default:
        return false;
    }
  }
}
