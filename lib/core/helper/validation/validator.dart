/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: validator.dart
/// Description: Declares `Validator`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

/// **************************** FILE INFO **************************** ///
/// Description: Single app-wide Validator.
/// Merged from:
///   - features/roles/r4_active_directory/core/helpers/validator.dart (CSV/employee
///     import validators — the superset, null-safe, long guidance messages)
///   - core/helper/main_helper/validator.dart (legacy validators used by the
///     sign-in / settings screens)
///   - features/form_builder_module/helper/form_builder/validation_helper.dart (the former
///     ValidationHelper — form-builder field validators; see the section at the
///     bottom of this class)
/// Where the two versions of a method differed, the active_directory behaviour
/// is kept under the original name and the legacy behaviour is preserved under
/// an explicit alias, so no call site changed behaviour. See [emailLocalized].
import 'package:country_phone_validator/country_phone_validator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/core/helper/extensions.dart';
import 'package:grc_module/generated/l10n.dart';

part 'validator/validator_statics.dart';
part 'validator/validator_statics2.dart';

class Validator {
  Validator();

  /// Returns "<label> required" when [value] is null or empty, else null.
  ///
  /// Ported from the messaging module's former ValidationHelper.isEmpty so
  /// generic "this field is required" checks have one home alongside the
  /// field-specific validators below.
  static String? isEmpty(String? value, String label) {
    if (value == null || value.isEmpty) {
      return '$label ${S.current.required}';
    }
    return null;
  }

  static String? email(String? value) => _ValidatorStatics.email(value);

  static String? emailTitle(String? value) =>
      _ValidatorStatics.emailTitle(value);

// employee sheet
  static String? name(String? value, String invalid) =>
      _ValidatorStatics2.name(value, invalid);

  static String? firstNameEnglish(String? value) =>
      _ValidatorStatics.firstNameEnglish(value);

  static String? firstNameEnglishTtitle(String? value) =>
      _ValidatorStatics.firstNameEnglishTtitle(value);

  static String? middleNameEnglish(String? value) =>
      _ValidatorStatics.middleNameEnglish(value);

  static String? middleNameEnglishTitle(String? value) =>
      _ValidatorStatics.middleNameEnglishTitle(value);

  static String? lastNameEnglish(String? value) =>
      _ValidatorStatics.lastNameEnglish(value);

  static String? lastNameEnglishTitle(String? value) =>
      _ValidatorStatics.lastNameEnglishTitle(value);

  static String? firstNameArabic(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseEnterTheFirstNameInArabicThisIsARequiredFieldForL;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi;
    } else {
      return null;
    }
  }

  static String? firstNameArabicTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.arabicFirstNameMissing;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.arabicLanguageMandatory;
    } else {
      return null;
    }
  }

  static String? middleNameArabic(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseEnterTheMiddleNameInArabicThisIsARequiredFieldFor;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi;
    } else {
      return null;
    }
  }

  static String? middleNameArabicTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.arabicMiddleNameMissing;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.arabicLanguageMandatory;
    } else {
      return null;
    }
  }

  static String? lastNameArabic(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseEnterTheLastNameInArabicThisIsARequiredFieldForLo;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi;
    } else {
      return null;
    }
  }

  static String? lastNameArabicTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.arabicLastNameMissing;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.arabicLanguageMandatory;
    } else {
      return null;
    }
  }

  static dynamic isEnglish(String? value) {
    final RegExp english = RegExp(r'^[a-zA-Z]+');
    if (value != null && !english.hasMatch(value)) {
      return S.current.pleaseEnterTheTextInEnglishLanguage;
    } else {
      return null;
    }
  }

  static String? isArabic(String? value, String empty, String invalid) {
    if (value == null || value.isEmpty) {
      return empty;
    }
    final RegExp arabic = RegExp(r'^[\u0621-\u064A]+');
    if (!arabic.hasMatch(value)) {
      return invalid;
    } else {
      return null;
    }
  }

  static String? isValidnumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invalid Data Type';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Invalid Data Type';
    }
    return null; // Input is a valid number
  }

  static String? work(String? value, String invalid) {
    String pattern =
        r"^(?:[a-zA-Z\u0600-\u06FF]+(([',.-][a-zA-Z\u0600-\u06FF])?[a-zA-Z\u0600-\u06FF]*)*)|(?:[\p{L}\s'-]+)$";
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value!) || value.length <= 1) {
      return invalid;
    } else {
      return null;
    }
  }

  static String? date(String? value) {
    String pattern = r"(\d{4}-?\d\d-?\d\d)";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.invalidDate;
    } else {
      return null;
    }
  }

  static String? id(String? value, String invalid) {
    if (value == null || value.isEmpty) {
      return invalid;
    }
    String pattern = r'^[a-zA-Z0-9]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value) || value.isEmpty) {
      return invalid;
    } else {
      return null;
    }
  }

  static String? departmentId(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseProvideAValidDepartmentIDThisFieldIsMandatoryForO;
    }
    String pattern = r'^[0-9]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.theDepartmentIDMustBeNumericAndContainNoLetters;
    } else {
      return null;
    }
  }

  static String? departmentIdTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.missingDepartmentID;
    }
    String pattern = r'^[0-9]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.invalidDepartmentIDFormat;
    } else {
      return null;
    }
  }

  static String? location(String? value, String invalid) {
    if (value == null || value.isEmpty) {
      return null;
    }
    String pattern = r'^(?!\s*\d+\s*$)[a-zA-Z0-9\s,]*$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value) || value.isEmpty) {
      return invalid;
    } else {
      return null;
    }
  }

  static String? isNationalIdDateValid(String dateString) =>
      _ValidatorStatics.isNationalIdDateValid(dateString);

  static String? isNationalIdDateValidTitle(String dateString) =>
      _ValidatorStatics.isNationalIdDateValidTitle(dateString);

  static String? isPassportDateValid(String dateString) =>
      _ValidatorStatics.isPassportDateValid(dateString);

  static String? isPassportDateValidTitle(String dateString) =>
      _ValidatorStatics.isPassportDateValidTitle(dateString);

  static String? isDateValid(String dateString) =>
      _ValidatorStatics.isDateValid(dateString);

  static String? isDateValidTitle(String dateString) =>
      _ValidatorStatics.isDateValidTitle(dateString);

  static String? extension(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseEnterTheOfficeExtensionNumber;
    }
    String pattern = r'^\d+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return S.current.onlyDigitsArePermittedInTheExtensionField;
    } else {
      return null;
    }
  }

  static String? extensionTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.extensionRequired;
    }
    String pattern = r'^\d+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return S.current.onlyDigitsArePermittedInTheExtensionField;
    } else {
      return null;
    }
  }

  static String? countryCodeValidate(String? value) {
    bool isValid = CountryUtils.getCountryByDialCode('+$value') != null;
    if (isValid) {
      return null;
    } else {
      return 'Invalid Country Code';
    }
  }

  /// Function Name: [formatPhoneNumber]
  ///
  /// Purpose: Validate a `dialCode-number` phone string.
  ///
  /// Re-enabled 11/8/2026: this method began with an unconditional
  /// `return null;`, making every statement below it unreachable — phone
  /// validation was silently disabled everywhere this validator is used.
  ///
  /// Returns: [String?] an error message, or `null` when the number is valid.
  static String? formatPhoneNumber(String? phoneNumber) =>
      _ValidatorStatics.formatPhoneNumber(phoneNumber);

  /// Function Name: [formatPhoneNumberTitle]
  ///
  /// Purpose: Same validation as [formatPhoneNumber] with title-specific
  ///          messages. Also had an unconditional `return null;` first line.
  ///
  /// Returns: [String?] an error message, or `null` when the number is valid.
  static String? formatPhoneNumberTitle(String? phoneNumber) =>
      _ValidatorStatics.formatPhoneNumberTitle(phoneNumber);

  static String? countryName(String? value) {
    String pattern = r'^[a-zA-Z\s]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Name'
          : "اسم غير صالح";
    } else {
      return null;
    }
  }

  static String? validateTaxNumber(String? value) {
    String pattern = r'^\d{9,14}$'; // Allowing numbers from 9 to 14 digits
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(value!)) {
      return 'Invalid Tax Number';
    } else {
      return null;
    }
  }

  static String? zip(String? value) {
    String pattern = r'^\d{4,14}$'; // Allowing numbers from 9 to 14 digits
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(value!)) {
      return 'Invalid Zip Code';
    } else {
      return null;
    }
  }

  static String? http(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else {
      if (!Uri.parse(value).isAbsolute) {
        return 'Invalid URL';
      }
      return null;
    }
  }

  ///validator link
  static String? isCorrectWebsiteLink(String websiteName, String link) =>
      _ValidatorStatics.isCorrectWebsiteLink(websiteName, link);

  static bool isValidLink(String link) {
    bool isLink = true;
    final urlRegex = RegExp(
        r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');
    isLink = urlRegex.hasMatch(link);
    return isLink;
  }

  static String? zipCode(String? value) {
    String pattern = r"^\d{5}$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.invalidPostalCode;
    } else {
      return null;
    }
  }

  static String? text(String? value, String invalid) {
    if (value == null || value.isEmpty) {
      return invalid;
    }
    return null;
  }

  static String? insurancePolicyNumber(String? value, String invalidMessage) {
    String pattern = r"^[a-zA-Z0-9]+$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!) || value.length <= 1) {
      return invalidMessage;
    } else {
      return null;
    }
  }

  static String? gpa(String? value) => _ValidatorStatics.gpa(value);

  static String? nationalId(String? value) =>
      _ValidatorStatics.nationalId(value);

  static String? nationalIdTitle(String? value) =>
      _ValidatorStatics.nationalIdTitle(value);

  static String? passportNumber(String? value) {
    String pattern = r'^[a-zA-Z0-9]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return "Only letters and numbers are allowed. Please remove any other symbols.";
    } else if (value.length < 8 || value.length > 11) {
      return "The passport number must consist of 9 alphanumeric characters.";
    } else {
      return null;
    }
  }

  static String? passportNumberTitle(String? value) {
    String pattern = r'^[a-zA-Z0-9]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.unsupportedCharactersInPassportNumber;
    } else if (value.length < 9 || value.length > 9) {
      return S.current.invalidPassportNumber;
    }
    return null;
  }

  static String? gender(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    String pattern = r'^(male|female|other)$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value)) {
      return S.current.genderFieldMustBeEitherMaleFemaleOrOther;
    } else {
      return null;
    }
  }

  static String? genderTitle(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    String pattern = r'^(male|female|other)$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value)) {
      return S.current.invalidGender;
    }
    return null;
  }

  static String? postalCode(String? value) =>
      _ValidatorStatics2.postalCode(value);

  static String? postalCodeTitle(String? value) =>
      _ValidatorStatics2.postalCodeTitle(value);

  static String? maritalStatus(String? value) {
    String pattern = r'^(single|married|divorced|widowed)$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Marital Status'
          : "حالة زواج غير صالحة";
    } else {
      return null;
    }
  }

  static String? relationship(String? value) {
    String pattern =
        r'^(brother|sister|father|mother|son|daughter|uncle|aunt|cousin|nephew|niece|grandfather|grandmother|grandson|granddaughter)$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Relationship Name'
          : "اسم العلاقة غير صالح";
    } else {
      return null;
    }
  }

  static String? validateSalary(String? value) {
    String pattern = r'^[0-9]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Salary'
          : "الراتب غير صالح";
    } else {
      return null;
    }
  }

  static String? validateCurrencyCode(String? value) {
    String pattern = r'^[A-Z]{3}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Currency Code'
          : "رمز العملة غير صالح";
    } else {
      return null;
    }
  }

  static String? validateWorkDays(String? value) {
    String pattern =
        r'^(saturday|sunday|monday|tuesday|wednesday|thursday|friday|SAT|SUN|MON|TUE|WED|THU|FRI)(,\s*(saturday|sunday|monday|tuesday|wednesday|thursday|friday|SAT|SUN|MON|TUE|WED|THU|FRI))*$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Workdays'
          : "أيام العمل غير صالحة";
    } else {
      return null;
    }
  }

  static String? validateTime(String? value) {
    String pattern = r'^(1[012]|[1-9]):[0-5][0-9]\s(AM|PM)$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Time'
          : "وقت غير صالح";
    } else {
      return null;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Merged in from the legacy core/helper/main_helper/validator.dart
  // ───────────────────────────────────────────────────────────────────────────

  /// Phone validator from the legacy validator (kept for the settings screens).
  static String? number(String? value) => _ValidatorStatics.number(value);

  /// Email validator preserving the LEGACY message (`S.current.invalidEmail`),
  /// used by the sign-in screens. Same regex as [email]; only the returned
  /// message differs. [email] keeps the longer CSV-import guidance text.
  /// A null/empty guard was added — the legacy version threw on null.
  static String? emailLocalized(String? value) =>
      _ValidatorStatics.emailLocalized(value);

  // ───────────────────────────────────────────────────────────────────────────
  // Merged in from the former features/form_builder_module/helper/form_builder/validation_helper.dart
  // (class ValidationHelper). Bodies are unchanged so call sites keep their
  // exact messages. `isEnglish` / `isArabic` were NOT carried over — this class
  // already had equivalents and the ValidationHelper versions had no callers.
  // ───────────────────────────────────────────────────────────────────────────

  /// Email check returning [S.current.pleaseEnterTheValidEmail]. Kept distinct
  /// from [email] / [emailLocalized], which return different messages.
  static String? isEmailValid(String email) =>
      _ValidatorStatics.isEmailValid(email);

  /// Required-field check that builds its own "<label> required" message.
  /// Differs from [text], which takes the whole message from the caller.
  static dynamic isEmptyy(String? value, String label, {bool? isArabic}) =>
      _ValidatorStatics2.isEmptyy(value, label, isArabic: isArabic);

  static String? isNumber(String value) {
    // Remove any whitespace
    final trimmedValue = value.trim();

    // Check if string contains only numbers using RegExp
    final numberRegExp = RegExp(r'^[0-9٠-٩]+$');
    if (!numberRegExp.hasMatch(trimmedValue)) {
      return 'Please enter numbers only';
    }

    return null; // Return null if validation passes
  }

  static String? isNumberWithNegative(String value) =>
      _ValidatorStatics2.isNumberWithNegative(value);

  static bool isBetween(double value, double min, double max) {
    return value >= min && value <= max;
  }

  /// Function to check if latitude is valid
  static String? isValidLatitude(double latitude) {
    if (!isBetween(latitude, -90.0, 90.0)) {
      return S.current.latitudeInvalid;
    }

    return null;
  }

  /// Function to check if longitude is valid
  static String? isValidLongitude(double longitude) {
    if (!isBetween(longitude, -180.0, 180.0)) {
      return S.current.longitudeInvalid;
    }

    return null;
  }

  static String? isGoogleMapsLink(String url) {
    final googleMapsPattern = RegExp(
      r'^(https?:\/\/)?(www\.)?(google\.)?(com|[a-z]{2})(\/maps)?\/([a-zA-Z0-9@:%._\+~#=]{1,256})$',
      caseSensitive: false,
    );
    if (!googleMapsPattern.hasMatch(url)) {
      return S.current.linkInvalid;
    }
    return null;
  }

  /// Link check returning [S.current.pleaseEnterAValidLink]. Distinct from
  /// [isValidLink] (returns a bool) and [http] (returns 'Invalid URL').
  static String? isLink(String value) => _ValidatorStatics2.isLink(value);

  static String? isMoreThanZero(String value) =>
      _ValidatorStatics2.isMoreThanZero(value);

  static String? isNotDuplicateOption(List<String> options, String option) {
    // Check if the option already exists in the list
    if (options.where((element) => element == option).length > 1) {
      return S.current.youCannotAddAnOptionThatAlreadyExists;
    }
    return null; // No duplicate found
  }

  static bool isPasswordValid(String password) {
    return RegExp(
            r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$")
        .hasMatch(password);
  }

  static bool isPhoneNumberValid(String phoneNumber) {
    return RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(phoneNumber);
  }

  static bool isAgeAboveSixteen(String dobString) =>
      _ValidatorStatics2.isAgeAboveSixteen(dobString);

  static bool hasLowerCase(String password) {
    return RegExp(r'^(?=.*[a-z])').hasMatch(password);
  }

  static bool hasUpperCase(String password) {
    return RegExp(r'^(?=.*[A-Z])').hasMatch(password);
  }

  static bool hasNumber(String password) {
    return RegExp(r'^(?=.*?[0-9])').hasMatch(password);
  }

  static bool hasSpecialCharacter(String password) {
    return RegExp(r'^(?=.*?[#?!@$%^&*-])').hasMatch(password);
  }

  static bool hasMinLength(String password) {
    return RegExp(r'^(?=.{8,})').hasMatch(password);
  }
}
