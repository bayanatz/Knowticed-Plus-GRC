/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: orientation.dart
/// Description: `OrientationEnum` enum, extension methods of `OrientationEnum`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';

enum OrientationEnum { landscape, portrait }

/// Extension to provide additional functionalities to the OrientationEnum enum.
extension OrientationExtension on OrientationEnum {
  /// STABLE identifier — persisted on the form. NOT translated; see [label].
  String get name {
    switch (this) {
      case OrientationEnum.landscape:
        return 'Landscape';
      case OrientationEnum.portrait:
        return 'Portrait';
    }
  }

  /// Translated label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case OrientationEnum.landscape:
        return s.orientationLandscape;
      case OrientationEnum.portrait:
        return s.orientationPortrait;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in OrientationEnum.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }
}
