/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: alignment.dart
/// Description: `AlignmentEnum` enum, extension methods of `AlignmentEnum`, extension methods of `String`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';

enum AlignmentEnum { left, right, center, expand }

/// Extension to provide additional functionalities to the AlignmentEnum enum.
extension AlignmentEnumExtension on AlignmentEnum {
  /// STABLE identifier — persisted on the field and parsed back by
  /// [AlignmentFromStringExtension.alignment]. NOT translated; see [label].
  String get name {
    switch (this) {
      case AlignmentEnum.left:
        return 'Left';
      case AlignmentEnum.right:
        return 'Right';
      case AlignmentEnum.center:
        return 'Center';
      case AlignmentEnum.expand:
        return 'Expand';
    }
  }

  /// Translated label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case AlignmentEnum.left:
        return s.alignmentLeft;
      case AlignmentEnum.right:
        return s.alignmentRight;
      case AlignmentEnum.center:
        return s.alignmentCenter;
      case AlignmentEnum.expand:
        return s.alignmentExpand;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in AlignmentEnum.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }
}
