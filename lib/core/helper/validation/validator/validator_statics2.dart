/// Module: core/helper
///
///*************************** FILE INFO ****************************///
/// File Name: validator_statics2.dart
/// Description: `_ValidatorStatics2` — split out of `validator.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../validator.dart';

// Split from validator.dart to keep every file under 700 lines.

abstract final class _ValidatorStatics2 {
  static String? name(String? value, String invalid) {
    if (value == null || value.isEmpty) {
      return invalid;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z0-9-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value) || value.length <= 1) {
      return invalid;
    } else {
      return null;
    }
  }

  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    String pattern = r'^\d{5}(?:[-\s]?\d{4})?$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return S.current.pleaseProvideAValidPostalCodeItMustMatchTheCityAndProvi;
    } else {
      return null;
    }
  }

  static String? postalCodeTitle(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    String pattern = r'^\d{5}(?:[-\s]?\d{4})?$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return S.current.invalidPostalCode;
    } else {
      return null;
    }
  }

  static dynamic isEmptyy(String? value, String label, {bool? isArabic}) {
    if (value == null || value.trim().isEmpty) {
      return isArabic == null
          ? '$label ${'Required'}'
          : isArabic
              ? "$label ${'مطلوب'}"
              : "$label ${'required'}";
    } else {
      return null;
    }
  }

  static String? isNumberWithNegative(String value) {
    // Remove any whitespace
    final trimmedValue = value.trim();

    // Check if string contains only numbers or a negative sign followed by
    // numbers using RegExp
    final numberRegExp = RegExp(r'^-?[0-9]+$');
    if (!numberRegExp.hasMatch(trimmedValue)) {
      return 'Please enter numbers only';
    }

    return null; // Return null if validation passes
  }

  static String? isLink(String value) {
    final linkPattern = RegExp(
      r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9@:%._\+~#=-]+\.)+[a-z]{2,6}(\/[a-zA-Z0-9@:%._\+~#?&//=~-]*)?$',
      caseSensitive: false,
    );

    if (!linkPattern.hasMatch(value)) {
      return S.current.pleaseEnterAValidLink;
    }

    return null;
  }

  static String? isMoreThanZero(String value) {
    String? error = Validator.isNumber(value);
    if (error != null) {
      return error;
    }
    final trimmedValue = value.trim();
    final convertedValue = trimmedValue.toEnglishNumber();

    if (convertedValue <= 0) {
      return S.current.pleaseEnterNumbersOnlyMoreThen0;
    }

    return null; // Return null if validation passes
  }

  static bool isAgeAboveSixteen(String dobString) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final DateTime dob = dateFormat.parse(dobString);

    final DateTime now = DateTime.now();
    int age = now.year - dob.year;

    // check if the birthday has passed this year
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age >= 16;
  }
}
