/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: arabic_number_format.dart
/// Purpose: Declares `ArabicNumberFormatter`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/services.dart';

class ArabicNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // CHANGED 17/10/2026 (D-145): numbers are always Western digits, so an
    // Arabic-Indic digit typed on an Arabic keyboard is turned Western.
    final newText = newValue.text.replaceAllMapped(
      RegExp('[\u0660-\u0669]'),
      (Match match) => '${match.group(0)!.codeUnitAt(0) - 0x0660}',
    );
    return newValue.copyWith(text: newText);
  }
}

/// Digit helpers. Since D-145 (17/10/2026) numbers are always Western digits.
/// Moved here from core/extension/context_extensions.dart so all Arabic-number
/// conversion lives in one place.
extension ArabicDigits on String {
  // CHANGED 17/10/2026 (D-145): Western digits always — the name stays for
  // its callers; any Arabic-Indic digit is turned Western.
  String toArabicNumbers() => replaceAllMapped(
        RegExp('[\u0660-\u0669]'),
        (Match match) => '${match.group(0)!.codeUnitAt(0) - 0x0660}',
      );
}
