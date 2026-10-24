/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: helper_format.dart
/// Description: `InputFormattersHelper`, `abbreviation` constant, `FormatHelper`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/services.dart';

class InputFormattersHelper {
  /// Allows only English characters, numbers, spaces, and common punctuation
  static TextInputFormatter englishOnly() {
    return FilteringTextInputFormatter.allow(
      RegExp(r'''[a-zA-Z0-9\s.,!?;:\-_()'"]'''),
    );
  }

  /// Allows only Arabic characters, numbers, spaces, and common Arabic punctuation
  static TextInputFormatter arabicOnly() {
    return FilteringTextInputFormatter.allow(
      RegExp(r'''[\u0600-\u06FF0-9\s.,،؛؟!:\-_()'"]'''),
    );
  }
}

List<String> abbreviation = [
  "it",
  "hr",
  'utils ux',
  'log',
  'qa',
  'pr',
  'dev',
  'ceo',
  "grc",
  "mena",
  "ksa",
  "uae",
  "coo",
  "cfo",
  "cdo",
  "cso",
  "cbo",
  "cmo",
  "cto",
  "cno",
  "cco",
  "chro",
  "cxo"
];

abstract class FormatHelper {
  static String capitalize(String input) {
    input.toLowerCase();
    input = applyAbbreviation(input);

    if (input.isEmpty) {
      return "";
    }

    List<String> words = input.split(" ");
    words = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      } else {
        return "";
      }
    }).toList();
    return words.join(" ");
  }

  static String applyAbbreviation(String input) {
    for (String abbreviation in abbreviation) {
      RegExp regex = RegExp(r'\b' + abbreviation + r'\b', caseSensitive: false);
      if (regex.hasMatch(input)) {
        input = input.replaceAllMapped(
            regex, (match) => abbreviation.toUpperCase());
      }
    }
    return input;
  }
}
