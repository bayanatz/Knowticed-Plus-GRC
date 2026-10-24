/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: arrangement.dart
/// Description: `Arrangement` enum, extension methods of `Arrangement`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';

enum Arrangement { vertical, horizontal }

/// Extension to provide additional functionalities to the Arrangement enum.
extension ArrangementExtension on Arrangement {
  /// STABLE identifier — persisted on the field. NOT translated; see [label].
  String get name {
    switch (this) {
      case Arrangement.vertical:
        return 'Vertical';
      case Arrangement.horizontal:
        return 'Horizontal';
    }
  }

  /// Translated label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case Arrangement.vertical:
        return s.arrangementVertical;
      case Arrangement.horizontal:
        return s.arrangementHorizontal;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in Arrangement.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }
}
