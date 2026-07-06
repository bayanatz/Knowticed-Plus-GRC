/// Module: Core · Helper · Main Helper · Date Helper
/// Description: Shared date formatting helper extracted out of settings
///              widgets so the try/catch around date parsing no longer
///              lives in UI code (§11.2).
/// Author: Knowticed Team
/// Date: 01/07/2026
/// Dependencies: intl
/// Revision History:
///   - 01/07/2026: Extracted from PersonalData widget (formatDate).
library;

import 'package:intl/intl.dart';

import 'package:demo_app/core/helper/main_helper/locale_helper.dart';

///*************************** FILE INFO ****************************///
/// File Name: date_helper.dart
/// Purpose: Parse a date string in one of several accepted formats and
///          render it as yyyy/MM/dd, optionally in Arabic numerals.

/// Converts English digits (0-9) to Arabic-Indic digits (٠-٩).
String convertNumberToArabic(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  String output = input;
  for (int i = 0; i < english.length; i++) {
    output = output.replaceAll(english[i], arabic[i]);
  }
  return output;
}

/// Formats [dateString] (accepts `-`, `/` separated, or `dd MMM yyyy`
/// formats) as `yyyy/MM/dd`, converting digits to Arabic numerals when the
/// resolved locale for [context] is Arabic. Returns '' for null/empty input
/// and falls back to the original string (locale-converted) if parsing
/// fails.
String formatDateForLocale(String? dateString, {required bool isArabic}) {
  if (dateString == null || dateString.isEmpty) return '';

  try {
    DateTime date;

    if (dateString.contains('-')) {
      date = DateTime.parse(dateString);
    } else if (dateString.contains('/')) {
      // Already in slash format, just convert numbers if needed.
      return isArabic ? convertNumberToArabic(dateString) : dateString;
    } else {
      date = DateFormat('dd MMM yyyy').parse(dateString);
    }

    String formattedDate = DateFormat('yyyy/MM/dd').format(date);
    if (isArabic) {
      formattedDate = convertNumberToArabic(formattedDate);
    }
    return formattedDate;
  } catch (e) {
    return isArabic ? convertNumberToArabic(dateString) : dateString;
  }
}
