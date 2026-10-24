/// Module: core/helper
///
///*************************** FILE INFO ****************************///
/// File Name: validator_statics.dart
/// Description: `_ValidatorStatics` — split out of `validator.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../validator.dart';

// Split from validator.dart to keep every file under 700 lines.

abstract final class _ValidatorStatics {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseEnterAValidEmailAddressForCommunication;
    }

    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return S.current.theEmailMustFollowTheFormatUserDomainCom;
    } else {
      return null;
    }
  }

  static String? emailTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.emailRequired2;
    }

    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return S.current.invalidEmailFormat;
    } else {
      return null;
    }
  }

  static String? firstNameEnglish(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.kindlyEnterTheEmployeeSFirstNameThisFieldIsMandatoryFor;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl;
    } else if (value.length <= 1) {
      return S.current.invalidFirstName;
    } else {
      return null;
    }
  }

  static String? firstNameEnglishTtitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.firstNameMissing;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.englishLanguageMandatory;
    } else if (value.length <= 1) {
      return S.current.invalidFirstName;
    } else {
      return null;
    }
  }

  static String? middleNameEnglish(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.kindlyEnterTheEmployeeSMiddleNameThisFieldIsMandatoryFo;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl;
    } else if (value.length <= 1) {
      return S.current.invalidMiddleName;
    } else {
      return null;
    }
  }

  static String? middleNameEnglishTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.middleNameMissing;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.englishLanguageMandatory;
    } else if (value.length <= 1) {
      return S.current.invalidMiddleName;
    } else {
      return null;
    }
  }

  static String? lastNameEnglish(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.kindlyEnterTheEmployeeSLastNameThisFieldIsMandatoryForI;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl;
    } else if (value.length <= 1) {
      return S.current.invalidLastName;
    } else {
      return null;
    }
  }

  static String? lastNameEnglishTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.lastNameMissing;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.englishLanguageMandatory;
    } else if (value.length <= 1) {
      return S.current.invalidFirstName;
    } else {
      return null;
    }
  }

  static String? isNationalIdDateValid(String dateString) {
    String invalidFormatMessage =
        S.current.pleaseEnterAValidDateInDDMMYYYYFormat;

    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return invalidFormatMessage; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return invalidFormatMessage;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return invalidFormatMessage;
        } else {
          if (day > 28) return invalidFormatMessage;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return invalidFormatMessage;
      }

      // check if date is expired
      DateTime idDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (idDate.isBefore(now)) {
        return S
            .current.pleaseSelectADateLaterThanTodayForTheNationalIDExpirati;
      }
      return null;
    } catch (e) {
      return invalidFormatMessage;
    }
  }

  static String? isNationalIdDateValidTitle(String dateString) {
    String invalidFormatMessage = S.current.invalidExpiryDate;

    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return invalidFormatMessage; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return invalidFormatMessage;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return invalidFormatMessage;
        } else {
          if (day > 28) return invalidFormatMessage;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return invalidFormatMessage;
      }

      // check if date is expired
      DateTime idDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (idDate.isBefore(now)) return S.current.expiryDateMustBeInTheFuture;
      return null;
    } catch (e) {
      return invalidFormatMessage;
    }
  }

  static String? isPassportDateValid(String dateString) {
    String invalidFormatMessage =
        S.current.pleaseEnterAValidDateInDDMMYYYYFormat;

    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return invalidFormatMessage; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return invalidFormatMessage;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return invalidFormatMessage;
        } else {
          if (day > 28) return invalidFormatMessage;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return invalidFormatMessage;
      }

      // check if date is expired
      DateTime idDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (idDate.isBefore(now)) {
        return S
            .current.pleaseSelectADateLaterThanTodayForTheNationalIDExpirati;
      }
      return null;
    } catch (e) {
      return invalidFormatMessage;
    }
  }

  static String? isPassportDateValidTitle(String dateString) {
    String invalidFormatMessage = S.current.invalidExpiryDate;

    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return invalidFormatMessage; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return invalidFormatMessage;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return invalidFormatMessage;
        } else {
          if (day > 28) return invalidFormatMessage;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return invalidFormatMessage;
      }

      // check if date is expired
      DateTime idDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (idDate.isBefore(now)) return S.current.expiryDateMustBeInTheFuture;
      return null;
    } catch (e) {
      return invalidFormatMessage;
    }
  }

  static String? isDateValid(String dateString) {
    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return S.current
            .pleaseEnterAValidDateInDDMMYYYYFormat; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return S.current.pleaseEnterAValidDateInDDMMYYYYFormat;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return S.current.pleaseEnterAValidDateInDDMMYYYYFormat;
        } else {
          if (day > 28) return S.current.pleaseEnterAValidDateInDDMMYYYYFormat;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return S.current.pleaseEnterAValidDateInDDMMYYYYFormat;
      }

      // check if date is in the future
      DateTime inputDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (inputDate.isAfter(now)) {
        return S.current.pleaseEnterAValidDateOfBirthFutureDatesAreNotAllowed;
      }

      return null;
    } catch (e) {
      return S.current.pleaseEnterAValidDateInDDMMYYYYFormat;
    }
  }

  static String? isDateValidTitle(String dateString) {
    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return S.current.invalidBirthDate; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return S.current.invalidBirthDate;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return S.current.invalidBirthDate;
        } else {
          if (day > 28) return S.current.invalidBirthDate;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return S.current.invalidBirthDate;
      }

      // check if date is in the future
      DateTime inputDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (inputDate.isAfter(now)) {
        return S.current.invalidBirthDate;
      }

      return null;
    } catch (e) {
      return S.current.invalidBirthDate;
    }
  }

  static String? formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null) {
      return S.current.pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe;
    }
    if (phoneNumber.split('-').length < 2) {
      //means 1 field is missing
      return S.current.pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe;
    }
    String dialCode = phoneNumber.split('-')[0];
    phoneNumber = phoneNumber.split('-')[1].trim();
    phoneNumber = phoneNumber.replaceAll(' ', '');
    bool isValid = CountryUtils.validatePhoneNumber(phoneNumber, '+$dialCode');

    if (isValid) {
      return null;
    } else {
      return S.current.thePhoneNumberMustBeBetween8And15Digit;
    }
  }

  static String? formatPhoneNumberTitle(String? phoneNumber) {
    if (phoneNumber == null) {
      return S.current.phoneRequired;
    }
    if (phoneNumber.split('-').length < 2) {
      //means 1 field is missing
      return S.current.pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe;
    }
    String dialCode = phoneNumber.split('-')[0];
    phoneNumber = phoneNumber.split('-')[1].trim();
    phoneNumber = phoneNumber.replaceAll(' ', '');
    bool isValid = CountryUtils.validatePhoneNumber(phoneNumber, '+$dialCode');

    if (isValid) {
      return null;
    } else {
      return S.current.invalidPhoneFormat;
    }
  }

  static String? isCorrectWebsiteLink(String websiteName, String link) {
    if (link == "") {
      return null;
    }
    bool isLink = Validator.isValidLink(link.trim());
    if (!isLink) {
      return "Invalid URL";
    }
    //String modelLink="https://www.$websiteName.com";
    bool correctWebsiteLink = link.contains(websiteName);
    String returnedMessage = "This link is not ${websiteName.capitalize} link";
    if (!correctWebsiteLink) {
      return returnedMessage;
    }

    return null;
  }

  static String? gpa(String? value) {
    if (value == null || value.isEmpty) {
      return Get.locale.toString().contains('en')
          ? 'GPA Cannot Be Empty'
          : "لا يمكن أن يكون المعدل التراكمي فارغًا";
    }

    double gpaValue;
    try {
      gpaValue = double.parse(value);
    } catch (e) {
      return Get.locale.toString().contains('en')
          ? 'Invalid GPA Format'
          : "تنسيق المعدل التراكمي غير صالح";
    }

    if (gpaValue < 0.0 || gpaValue > 4.0) {
      return Get.locale.toString().contains('en')
          ? 'GPA Must Be Between 0.0 and 4.0'
          : "يجب أن يتراوح المعدل التراكمي بين 0.0 و4.0";
    }

    return null;
  }

  static String? nationalId(String? value) {
    // check if value is null or empty
    if (value == null || value.isEmpty) {
      return null;
    }
    // check if national Id contains only digits
    String pattern = r'^\d+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return S.current.onlyDigitsAreAllowedPleaseRemoveAnyLettersOrSymbols;
    }
    // check if national Id is 14 digits
    if (value.length < 9 || value.length > 14) {
      return S.current.nationalIDMustBeExactly14DigitsLong;
    }
    return null;
  }

  static String? nationalIdTitle(String? value) {
    // check if value is null or empty
    if (value == null || value.isEmpty) {
      return null;
    }
    // check if national Id contains only digits
    String pattern = r'^\d+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return S.current.nonNumericCharactersInNationalID;
    }
    // check if national Id is 14 digits
    if (value.length != 14) {
      return S.current.invalidNationalID;
    }
    return null;
  }

  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.invalidPhoneNumber;
    }
    String pattern0 = r'^\D?(\d{3})\D?\D?(\d{5})\D?(\d{4})$';
    String pattern1 = r'^\D?(\d{3})\D?\D?(\d{5})\D?(\d{3})$';
    RegExp regex0 = RegExp(pattern0);
    RegExp regex1 = RegExp(pattern1);
    if (!regex0.hasMatch(value) && !regex1.hasMatch(value)) {
      return S.current.invalidPhoneNumber;
    } else {
      return null;
    }
  }

  static String? emailLocalized(String? value) {
    if (value == null || value.isEmpty) {
      return Get.locale.toString().contains("en")
          ? S.current.invalidEmail
          : 'حساب غير صحيح';
    }
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return Get.locale.toString().contains("en")
          ? S.current.invalidEmail
          : 'حساب غير صحيح';
    } else {
      return null;
    }
  }

  static String? isEmailValid(String email) {
    var exp = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(email);
    if (!exp) {
      return S.current.pleaseEnterTheValidEmail;
    }
    return null;
  }
}
