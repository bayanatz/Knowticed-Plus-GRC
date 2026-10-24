/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: color_generator.dart
/// Description: `ColorGenerator`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:ui';

import 'package:knowticed_plus/core/theme/app_colors.dart';

/// Chart colours built from the theme.
class ColorGenerator {
  static Color yellowBase = AppColors.primary;
  static Color lightGreyBase = AppColors.grey;
  static Color darkGreyBase = AppColors.secondaryText;

  /// Method Name: [generateColors]
  ///
  /// Purpose: chart colours from the theme: primary, grey and dark grey, then darker shades of them.
  ///
  /// Parameters:
  /// - [count]: how many colours.
  ///
  /// Returns: the colours.
  static List<Color> generateColors(int count) {
    List<Color> colors = [];

    // Add the three main colors first
    colors.add(yellowBase);
    colors.add(lightGreyBase);
    colors.add(darkGreyBase);

    // If we need more colors, generate variations
    if (count > 3) {
      int remainingColors = count - 3;
      double step = 1.0 / (remainingColors ~/ 3 + 1);

      for (int i = 0; i < remainingColors; i++) {
        if (i < remainingColors / 3) {
          // Yellow variations
          double factor = 0.8 - (step * i);
          colors.add(_adjustColor(yellowBase, factor));
        } else if (i < (remainingColors * 2) / 3) {
          // Light grey variations
          double factor = 0.8 - (step * (i - remainingColors ~/ 3));
          colors.add(_adjustColor(lightGreyBase, factor));
        } else {
          // Dark grey variations
          double factor = 0.8 - (step * (i - (remainingColors * 2) ~/ 3));
          colors.add(_adjustColor(darkGreyBase, factor));
        }
      }
    }

    return colors;
  }

  static Color _adjustColor(Color baseColor, double factor) {
    return Color.fromARGB(
      _to8Bit(baseColor.a),
      (_to8Bit(baseColor.r) * factor).round(),
      (_to8Bit(baseColor.g) * factor).round(),
      (_to8Bit(baseColor.b) * factor).round(),
    );
  }

  /// A 0–1 colour channel as the 0–255 value the old `.red`/`.alpha`… gave.
  static int _to8Bit(double channel) => (channel * 255.0).round().clamp(0, 255);
}
