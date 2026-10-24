/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_answer_format.dart
/// Description: `FormAnswerFormat` — the format rules for answers typed into
///          Email, Link and Phone fields while filling out a form. Returns a
///          message that tells the user WHAT to type (with an example), or
///          null when the value is fine. Used live under each field and by
///          the Submit lock, so the two always agree.
/// Author: Amr Mesbah
/// Created at: 13/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/helpers/country_parse_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/phone_field_controller.dart';

class FormAnswerFormat {
  FormAnswerFormat._();

  static final RegExp _email =
      RegExp(r'^[\w.+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$');

  /// http(s):// optional; needs a domain with a dot (example.com).
  static final RegExp _link = RegExp(
      r'^(https?:\/\/)?(www\.)?[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}(:\d+)?(\/\S*)?$');

  static final RegExp _digits = RegExp(r'^[0-9٠-٩]+$');

  static String? emailError(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty || _email.hasMatch(v)) return null;
    return S.current.fbInvalidEmailExample;
  }

  static String? linkError(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty || _link.hasMatch(v)) return null;
    return S.current.fbInvalidLinkExample;
  }

  /// Digits only, and exactly as many digits as the chosen country uses.
  static String? phoneError(String? value, String? countryCode) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final int expected = CountryParseHelper.parseCountrySafely(countryCode)
        .example
        .replaceAll(RegExp(r'\D'), '')
        .length;
    if (!_digits.hasMatch(v)) {
      return S.current.fbPhoneDigitsOnly(expected);
    }
    if (expected > 0 && v.length != expected) {
      return S.current.fbPhoneDigitsCount(expected);
    }
    return null;
  }

  /// The format problem with this field's current answer, or null.
  static String? errorFor(FieldController field) {
    if (field is EmailFieldController) return emailError(field.answer);
    if (field is LinkFieldController) return linkError(field.answer);
    if (field is PhoneFieldController) {
      return phoneError(field.phoneAnswer, field.currentCountry);
    }
    return null;
  }
}
