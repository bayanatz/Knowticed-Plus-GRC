// Moved out of core/helper/messaging (removed). The date_time_helper import
// was dropped: nothing here used it, and that file is itself broken (it
// imports messaging/data/models/chat_enums.dart, which does not exist).

// Date: 4/8/2024
// By: Youssef Ashraf, Nada Mohammed
// Last update: 8/8/2024
// Objectives: This file is responsible for providing extensions to several classes in the project.

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/custom/46_custom_image_picker.dart';
import 'package:grc_module/generated/l10n.dart';

import '../../extension/context_extensions.dart';
import './date_time_helper.dart';

/// Screen-info helpers that are *not* already provided by
/// [core/extension/context_extensions.dart].
///
/// `isTablett` and `isArabic` used to be declared here too, with implementations
/// identical to the ones in context_extensions.dart. Two extensions declaring
/// the same member on BuildContext makes every call ambiguous in any library
/// that imports both, so the duplicates were removed and context_extensions.dart
/// is now the single source for them.
extension ContextExtension on BuildContext {
  // ScreenInfo
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  bool get isTabletRange500To600 =>
      MediaQuery.of(this).size.width >= 500 &&
      MediaQuery.of(this).size.width <= 600;
  bool get isTabletVer =>
      MediaQuery.of(this).size.width >= 600 &&
      MediaQuery.of(this).size.width < 800;

  // NOTE: this reads `>= 600`, i.e. it is true on *wide* screens — the opposite
  // of context_extensions.dart's `isPhone` (`shortestSide < 600`). Left as-is so
  // its three call sites keep their current behaviour; see the migration notes.
  bool get isPhone => MediaQuery.of(this).size.width >= 600;
}

extension AudioWavesSample on PlayerController {
  int getNumOfSamples(audioWavesSpacing) {
    print('audioWavesSpacing: $audioWavesSpacing');
    // 328 is the width of the audio waves container in tablet, 146 is the width of the audio waves container in mobile
    return Get.context!.isTablett
        ? (328.w ~/ audioWavesSpacing)
        : (146.w ~/ audioWavesSpacing);
  }
}

/// Extension to add additional functionalities for string manipulation, specifically for number conversions.
extension NumberToArabic on String {
  /// Converts English digits in the string to equivalent Arabic digits.
  String toArabicNumbers() {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = this;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], arabicDigits[i]);
    }
    return result;
  }

  int toEnglishNumber() {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = this;
    for (int i = 0; i < arabicDigits.length; i++) {
      result = result.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    return result.toInt();
  }

  double toEnglishNumberAsDouble() {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = this;
    for (int i = 0; i < arabicDigits.length; i++) {
      result = result.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    return result.toDouble();
  }

  bool isLink() {
    return this.startsWith('http://') ||
        this.startsWith('https://') ||
        this.startsWith('www.');
  }

  /// Returns the string padded with leading zeros to ensure it has at least two digits.
  String get doubleDigit {
    try {
      return padLeft(2, DateTimeHelper.formatInt(0));
    } catch (e) {
      return this;
    }
  }

  /// Converts the string to an integer, returning 0 if the conversion fails.
  int toInt() => int.tryParse(this) ?? 0;

  /// Converts the string to an integer, returning a default value if the conversion fails or the value is 0.
  int toIntDefualt(int number) =>
      int.tryParse(this) == 0 ? number : int.tryParse(this) ?? number;

  /// Converts the string to a double, returning 0 if the conversion fails.
  double toDouble() => double.tryParse(this) ?? 0;

  /// Converts all digits in the string to '0'.
  String replaceAllDigitsWithZero() {
    const digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    String result = this;
    for (var digit in digits) {
      result = result.replaceAll(digit, DateTimeHelper.formatInt(0));
    }
    return result;
  }

  Color? toColor() {
    try {
      var hexColor = replaceAll("Color(", "").replaceAll(")", "");

      return Color(int.parse(hexColor));
    } catch (e) {
      return Colors.black; // Fallback color
    }
  }

  toImage() {
    if (this != null && isNotEmpty) {
      if (contains('http') || contains('https')) {
        return Image.network(this);
      } else {
        return appImageWidget(this);
      }
    }

    return null;
  }
}

extension IntToOrdinal on int {
  /// Converts integers up to 9 to their ordinal form, otherwise appends "th".
  String toOrdinal() {
    switch (this) {
      case 0:
        return S.current.k1st;
      case 1:
        return S.current.k2nd;
      case 2:
        return S.current.k3rd;

      default:
        return (Get.locale!.languageCode == 'en')
            ? (this + 1).toString() + S.current.th
            : (this + 1).toString().toArabicNumbers() +
                S.current.th; // or '${this + 1}th'.tr if you want to maintain the +1 logic from original
    }
  }

  String formatNumber() {
    String formattedNumber;

    if (this >= 1000000) {
      formattedNumber = '${(this / 1000000).truncate()}M';
    } else if (this >= 1000) {
      formattedNumber = '${(this / 1000).truncate()}K';
    } else {
      formattedNumber = this.toString();
    }

    // التحقق من اللغة الحالية وإرجاع الرقم بالتنسيق المناسب
    if (Get.context!.isArabic) {
      return DateTimeHelper.formatInt(int.parse(
          formattedNumber.replaceAll('K', '000').replaceAll('M', '000000')));
    } else {
      return formattedNumber;
    }
  }
}

/// Extension to provide additional functionality to the bool type.
extension BoolExtension on bool {
  /// Toggles the boolean value and returns the opposite.
  bool toggle() {
    return !this;
  }
}
